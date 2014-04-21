defmodule Elk.Worker do
  @moduledoc """
  State machine for workers.
  """
  use GenServer.Behaviour
  require Lager

  ##
  # GenFSM Functions
  ##
  def start_link(py_pid) do
    :gen_server.start_link(__MODULE__, py_pid, [])
  end

  def init(py_pid) do
    {:ok, {py_pid, nil}, 200}
  end

  def handle_info(:timeout, state = {py_pid, nil}) do
    # TODO: Need to change elsewhere to provide task_info
    task_info = Elk.Leaser.get_lease()

    case task_info do
      nil -> 
        Lager.info "No leases avaliable"
        {:noreply, state, 10000}

      task_info ->
        Lager.info "Got lease.  Starting task"
        pid = start_task(py_pid, task_info)
        {:noreply, {py_pid, {pid, task_info}}}
    end
  end

  def handle_info(msg, state = {py_pid, {child_pid, task_info}}) do
    case msg do
      { :DOWN, _, :process, ^child_pid, reason } ->
        finish_task(reason, task_info)
        {:noreply, {py_pid, nil}, 200}

      _ -> 
        {:noreply, state}
    end
  end

  def terminate(_reason, {_, {child_pid, task_info}}) do
    Process.exit(child_pid, :kill)
    Elk.FunctionSupervisor.start_child(:release_sup, [[task_info]])
  end

  def terminate(_, _) do
  end

  ##
  # Private Functions
  ##
  def start_task(py_pid, _task_info) do
    {pid, _} = Process.spawn_monitor fn ->
      IO.puts inspect Elk.WSGI.call_app(py_pid, "test_app", "app", "")
    end
    pid
  end

  defp finish_task(reason, task_info) do
    log_down(reason, task_info)
    cleanup_sup = case reason do
      :normal -> :delete_sup
      _ -> :release_sup
    end
    Elk.FunctionSupervisor.start_child(cleanup_sup, [[task_info]])
  end

  defp log_down(:normal, task_info) do
    Lager.info "Child process ended. #{inspect task_info} done"
  end

  defp log_down(_reason, task_info) do
    Lager.info "Child process ended. #{inspect task_info} failed"
  end
end
