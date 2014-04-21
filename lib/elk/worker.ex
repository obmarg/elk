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
    task = Elk.Leaser.get_lease()

    case task do
      nil -> 
        Lager.info "No leases avaliable"
        {:noreply, state, 10000}

      task ->
        Lager.info "Got lease.  Starting task"
        pid = start_task(py_pid, task)
        {:noreply, {py_pid, {pid, task}}}
    end
  end

  def handle_info(msg, state = {py_pid, {child_pid, task}}) do
    case msg do
      { :DOWN, _, :process, ^child_pid, reason } ->
        finish_task(reason, task)
        {:noreply, {py_pid, nil}, 200}

      _ -> 
        {:noreply, state}
    end
  end

  def terminate(_reason, {_, {child_pid, task}}) do
    Process.exit(child_pid, :kill)
    Elk.FunctionSupervisor.start_child(:release_sup, [[task]])
  end

  def terminate(_, _) do
  end

  ##
  # Private Functions
  ##
  defp start_task(py_pid, task) do
    # TODO: Need to extract payload from task.
    {pid, _} = Process.spawn_monitor fn ->
      IO.puts inspect Elk.WSGI.call_task(py_pid, "test_app", "app", task)
    end
    pid
  end

  defp finish_task(reason, task) do
    log_down(reason, task)
    cleanup_sup = case reason do
      :normal -> :delete_sup
      _ -> :release_sup
    end
    Elk.FunctionSupervisor.start_child(cleanup_sup, [[task]])
  end

  defp log_down(:normal, task) do
    Lager.info "Child process ended. #{inspect task} done"
  end

  defp log_down(_reason, task) do
    Lager.info "Child process ended. #{inspect task} failed"
  end
end
