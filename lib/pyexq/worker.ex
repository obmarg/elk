defmodule Pyexq.Worker do
  @moduledoc """
  State machine for workers.
  """
  use GenFSM.Behaviour


  ##
  # External API
  ##
  def next_task(worker_pid) do
    :gen_fsm.send_event(worker_pid, :coin)
  end


  ##
  # GenFSM Functions
  ##
  def start_link() do
    :gen_fsm.start_link(__MODULE__, [], [])
  end

  def init(_) do
    {:ok, :idle, {}, 200}
  end

  def idle(:timeout, _) do
    fetch_lease()
  end

  def working(:next_task, _) do
    fetch_lease()
  end

  ##
  # Private Functions
  ##
  defp fetch_lease() do
    task_id = Pyexq.Leaser.get_lease()
    case task_id do
      nil -> {:next_state, :idle, {}, 10000}
      task_id ->
        start_task(task_id)
        {:next_state, :working, {}}
    end
  end

  def start_task(task) do
    {:ok, pid} = spawn fn ->
      IO.puts inspect Pyexq.WSGI.call_app('testapp', 'app', '')
    end
    Pyexq.LeaseHolderSupervisor.start_child({pid, &(finish_task(task, self, &1))})
  end

  @doc """
  This function is passed as a callback into the FunctionSupervisor.
  It handles clean up & kicks off the next task.
  """
  defp finish_task(task_id, worker_pid, status) do
    cleanup_sup = case status do
      :done -> :delete_sup
      :error -> :release_sup
    end
    Pyexq.FunctionSupervisor.start_child(cleanup_sup, [[task_id]])
    #next_task(worker_pid)
  end

end
