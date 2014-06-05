defmodule Elk.Leaser do
  @moduledoc """
  Module responsible for querying for leases and passing them to workers.

  Workers should tell the leaser when they are ready.  The leaser will then
  send them a valid lease when it gets one.

  The Leaser will query for leases instantly when all workers are busy, but
  will batch requests together every 10s otherwise.
  """
  require Lager

  # TODO: Would I be better centralising these in Elk.Config?
  # Default parameter values.
  @max_retries 5
  @poll_time 10 * 1000

  ##
  # Public API
  ## 

  @doc "Tells the Leaser that a worker is ready."
  def worker_ready() do
    :gen_server.call(:leaser, :worker_ready)
  end


  ##
  # GenServer implementation
  ##

  use GenServer.Behaviour

  def start_link() do
    :gen_server.start_link({:local, :leaser}, __MODULE__, [], [])
  end

  def init(_) do
    {:ok, []}
  end

  def handle_call(:worker_ready, {pid, _}, []) do
    Lager.info "Worker #{inspect pid} in queue"
    {:reply, nil, [pid], 0}
  end

  def handle_call(:worker_ready, {pid, _}, waiting) do
    Lager.info "Worker #{inspect pid} in queue."
    {:reply, nil, Enum.uniq([pid | waiting]), @poll_time}
  end

  @doc """
  The timeout handler.  Attempts to lease tasks for any waiting workers.
  """
  def handle_info(:timeout, waiting) do
    tasks = waiting
    |> length
    |> Elk.GoogleAPI.lease_tasks
    |> Enum.map(&process_task/1)
    |> Enum.filter(&(&1))

    Lager.info "#{length(tasks)} tasks leased"

    # If there's no tasks this will stick everything into waiting.
    {workers, waiting} = Enum.split(waiting, length(tasks))
    Enum.zip(workers, tasks) |> Enum.map fn ({worker, task}) ->
      Elk.Worker.send_task(worker, task)
    end

    Enum.map(waiting, &Elk.Worker.ping/1)

    {:noreply, waiting, @poll_time}
  end


  ##
  # Private Functions
  ##
  @doc """
  Preprocesses a leased task before it is sent to a worker.

  Handles deleting tasks that have had too many retries.

  Returns nil for tasks that are deleted, otherwise returns the task.
  """
  defp process_task(task) do
    Lager.info "Processing task"
    max_retries = Elk.Config.get_int(:max_retries, @max_retries)
    if task.retries < max_retries do
      task
    else
      # TODO: Sticking these somewhere other than a log might be nice.
      Lager.info "Task #{inspect task} has been retried too many times."
      Elk.FunctionSupervisor.start_child(:delete_sup, [[task]])
      nil
    end
  end
end
