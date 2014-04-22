defmodule Elk.Leaser do
  @moduledoc """
  Module responsible for querying for leases. 
  """
  require Lager

  # TODO: Make this configurable
  @max_retries 5

  def get_lease() do
    # TODO: Check syntax of this.
    :gen_server.call(:leaser, :get_lease)
  end

  use GenServer.Behaviour

  def start_link() do
    :gen_server.start_link({:local, :leaser}, __MODULE__, [], [])
  end

  def init(_) do
    {:ok, nil}
  end

  def handle_call(:get_lease, from, state) do
    tasks = Elk.GoogleAPI.lease_tasks(1)
    case tasks do
      [] -> {:reply, nil, state}

      [task] ->
        if task.retries > @max_retries do
          # TODO: Sticking these somewhere other than a log might be nice.
          Lager.info "Task #{inspect task} has been retried too many times."
          Elk.FunctionSupervisor.start_child(:delete_sup, [[task]])
          handle_call(:get_lease, from, state)
        else
          {:reply, task, state}
        end
    end
  end

end
  # TODO: Could refactor to a kinda-state machine:
  # States: - Task Queue Empty (when requests return no results).
  #           - Maintain a list of requesting pids.
  #           - Use this to determine how many leases to ask for.
  #           - timeout every 10s (or something) to check again.
  #         - Working
  #           - Each lease request is made instantly.
