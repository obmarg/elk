defmodule Pyexq.Supervisor do
  use Supervisor.Behaviour

  def start_link do
    :supervisor.start_link(__MODULE__, [])
  end


  def init([]) do
    pool_options = [
      name: {:local, :python_pool},
      worker_module: :python,
      size: 3,
      max_overflow: 4
    ]

    children = [
      func_supervisor(:delete_sup, &Pyexq.GoogleAPI.delete_task/1),
      func_supervisor(:release_sup, &Pyexq.GoogleAPI.release_lease/1),

      worker(Pyexq.TokenHandler, []),
      worker(Pyexq.Leaser, []),

      worker(Pyexq.Worker, [], id: 'worker1'),
      worker(Pyexq.Worker, [], id: 'worker2'),
      worker(Pyexq.Worker, [], id: 'worker3'),
      worker(Pyexq.Worker, [], id: 'worker4'),
      :poolboy.child_spec(:python_pool, pool_options, []),
    ]

    # See http://elixir-lang.org/docs/stable/Supervisor.Behaviour.html
    # for other strategies and supported options
    supervise(children, strategy: :one_for_one)
  end

  defp func_supervisor(id, function) do
    supervisor(Pyexq.FunctionSupervisor, [id, function, [{:restart, :transient}]], id: id)
  end
end
