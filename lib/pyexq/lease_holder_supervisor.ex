defmodule Pyexq.LeaseHolderSupervisor do
  @moduledoc """
  A simple_for_one supervisor for supervising the running of LeaseHolders
  """
  use Supervisor.Behaviour

  def start_child(args) do
    :supervisor.start_child(:leaseholder_sup, args)
  end
 
  def terminate_child(id) do
    :supervisor.terminate_child(:leaseholder_sup, id)
  end

  ## 
  # Supervisor functions
  ##
  def start_link() do
    :supervisor.start_link({:local, :leaseholder_sup}, __MODULE__, [])
  end

  def init(_) do
    children = [
      worker(Pyexq.LeaseHolder, [], restart: :transient)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

end
