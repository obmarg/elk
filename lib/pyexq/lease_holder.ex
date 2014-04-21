defmodule Pyexq.LeaseHolder do
  @moduledoc """
  Defines a process that holds on to a single tasks lease.

  It holds the lease and monitors the worker process.  When the worker process
  stops it takes the appropriate action to release the lease.
  
  This process is not responsible for obtaining the lease or starting the
  worker process.

  This process should be supervised.
  """

  use GenServer.Behaviour

  def start_link(state) do
    :gen_server.start_link(__MODULE__, state, [])
  end

  ##
  # GenServer methods
  ##
  def init(state = {worker_pid, _release_fn}) do
    Process.monitor(worker_pid)
    {:ok, state}
  end

  def handle_info(msg, state = {worker_pid, release_fn}) do
    case msg do
      { :DOWN, _, :process, ^worker_pid, reason } when reason == :normal ->
        release_fn.(:done)
        {:stop, :normal, nil}

      { :DOWN, _, :process, ^worker_pid, reason } ->
        release_fn.(:error)
        {:stop, :normal, nil}

      { :EXIT, ^worker_pid, reason } ->
        release_fn.(:error)
        {:stop, :normal, nil}

      true -> {:noreply, state}
    end
  end

end
