defmodule Elk.Supervisor do
  use Supervisor.Behaviour

  def start_link do
    :supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      func_supervisor(:delete_sup, &Elk.GoogleAPI.delete_task/1),
      func_supervisor(:release_sup, &Elk.GoogleAPI.release_lease/1),

      worker(Elk.TokenHandler, []),
      worker(Elk.Leaser, []),

      supervisor(Elk.WorkerSupervisor, [], id: 'worker-sup1')
    ]
    supervise(children, strategy: :one_for_one)
  end

  defp func_supervisor(id, function) do
    supervisor(Elk.FunctionSupervisor, [id, function, [{:restart, :transient}]], id: id)
  end
end


defmodule Elk.WorkerSupervisor do
  @moduledoc """
  A supervisor that monitors a worker pair.

  A worker pair is made up of a python process & it's corresponding Worker.
  When either of the processes fail, the other will also be restarted.
  """

  use Supervisor.Behaviour

  def start_link do
    result = {:ok, sup} = :supervisor.start_link(__MODULE__, [])
    start_workers(sup)
    result
  end

  def init(_) do
    supervise([], strategy: :one_for_all)
  end

  defp start_workers(sup) do
    {:ok, python} = :supervisor.start_child(sup, worker(:python, []))
    :supervisor.start_child(sup, worker(Elk.Worker, [python]))
  end
end
