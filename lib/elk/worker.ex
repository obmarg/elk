defmodule Elk.Worker do
  @moduledoc """
  State machine for workers.
  """
  use GenServer.Behaviour
  require Lager

  @worker_timeout 1000 * 30

  ##
  # External API
  ##
  def send_task(worker, task) do
    :gen_server.cast(worker, {:task, task})
  end

  def ping(worker) do
    :gen_server.cast(worker, :ping)
  end

  ##
  # GenFSM Functions
  ##
  def start_link(py_pid) do
    :gen_server.start_link(__MODULE__, py_pid, [])
  end

  def init(py_pid) do
    {:ok, {py_pid, nil}, 200}
  end

  def handle_cast({:task, task}, {py_pid, nil}) do
    Lager.info "Worker starting #{inspect task}"
    Lager.info "Payload is #{byte_size task.payload} bytes long"
    pid = start_task(py_pid, task)
    {:noreply, {py_pid, {pid, task}}}
  end

  def handle_cast(:ping, state) do
    # Ping sent by leaser to reset the workers timeout.
    {:noreply, state, @worker_timeout}
  end

  def handle_info(:timeout, state) do
    task = Elk.Leaser.worker_ready()
    {:noreply, state, @worker_timeout}
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
    package = Elk.Config.get_str(:app_package)
    app = Elk.Config.get_str(:app_name)

    {pid, _} = Process.spawn_monitor fn ->
      Elk.WSGI.call_task(py_pid, package, app, task)
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
    Lager.info "Worker finished. #{inspect task} done"
  end

  defp log_down(reason, task) do
    Lager.info "Worker failed (Reason: #{inspect reason}). #{inspect task} failed"
  end
end
