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

  def handle_info(msg, {worker_pid, release_fn}) do
    # TODO: Handle errors
    case msg do
      { :DOWN, _, :process, ^worker_pid, _reason } ->
        release_fn.()
        {:stop, 'child process finished', nil}
    end
  end

end
