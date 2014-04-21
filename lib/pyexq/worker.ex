defmodule Pyexq.Worker do
  @moduledoc """
  State machine for workers.
  """
  use GenServer.Behaviour
  require Lager

  ##
  # GenFSM Functions
  ##
  def start_link() do
    :gen_server.start_link(__MODULE__, [], [])
  end

  def init(_) do
    {:ok, nil, 200}
  end

  def handle_info(:timeout, nil) do
    # TODO: Need to change elsewhere to provide task_info
    task_info = Pyexq.Leaser.get_lease()

    case task_info do
      nil -> 
        Lager.info "No leases avaliable"
        {:on, nil, 10000}

      task_info ->
        Lager.info "Got lease.  Starting task"
        pid = start_task(task_info)
        {:noreply, {pid, task_info}}
    end
  end

  def handle_info(msg, state = {child_pid, task_info}) do
    case msg do
      { :DOWN, _, :process, ^child_pid, reason } ->
        finish_task(reason, task_info)
        {:noreply, nil, 200}

      msg -> 
        {:noreply, state}
    end
  end

  def terminate(reason, {child_pid, task_info}) do
    Process.exit(child_pid, :kill)
    Pyexq.FunctionSupervisor.start_child(:release_sup, [[task_info]])
  end

  ##
  # Private Functions
  ##
  def start_task(task_info) do
    {pid, _} = Process.spawn_monitor fn ->
      IO.puts inspect Pyexq.WSGI.call_app("test_app", "app", "")
    end
    pid
  end

  defp finish_task(reason, task_info) do
    log_down(reason, task_info)
    cleanup_sup = case reason do
      :normal -> :delete_sup
      other -> :release_sup
    end
    Pyexq.FunctionSupervisor.start_child(cleanup_sup, [[task_info]])
  end

  defp log_down(:normal, task_info) do
    Lager.info "Child process ended. Task #{inspect task_info} done"
  end

  defp log_down(reason, task_info) do
    Lager.info "Child process ended.  Task #{inspect task_info} failed"
  end
end
