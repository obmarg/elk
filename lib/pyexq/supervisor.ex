defmodule Pyexq.Supervisor do
  use Supervisor.Behaviour

  def start_link do
    :supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      func_supervisor(:delete_sup, &Pyexq.GoogleAPI.delete_task/1),
      func_supervisor(:release_sup, &Pyexq.GoogleAPI.release_lease/1),

      worker(Pyexq.TokenHandler, []),
      worker(Pyexq.Leaser, []),

      supervisor(Pyexq.WorkerSupervisor, [], id: 'worker-sup1')
    ]
    supervise(children, strategy: :one_for_one)
  end

  defp func_supervisor(id, function) do
    supervisor(Pyexq.FunctionSupervisor, [id, function, [{:restart, :transient}]], id: id)
  end
end


defmodule Pyexq.WorkerSupervisor do
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
    :supervisor.start_child(sup, worker(Pyexq.Worker, [python]))
  end
end
