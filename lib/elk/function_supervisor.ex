defmodule Elk.FunctionSupervisor do
  @moduledoc """
  A simple_for_one supervisor for supervising the running of a specific
  function (via Elk.FunctionTask)

  The intention is for other processes to add tasks to this supervisor by
  calling start_child with the appropriate name.
  """
  use Supervisor.Behaviour

  def start_child(simple_sup, args) do
    :supervisor.start_child(simple_sup, args)
  end
 
  def terminate_child(simple_sup, id) do
    :supervisor.terminate_child(simple_sup, id)
  end

  ## 
  # Supervisor functions
  ##
  def start_link(name, worker_fn, opts) do
    :supervisor.start_link({:local, name}, __MODULE__, {worker_fn, opts})
  end

  def init({worker_fn, opts}) do
    children = [
      worker(Elk.FunctionProc, [worker_fn], opts)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

end
