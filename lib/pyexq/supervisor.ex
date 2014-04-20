defmodule Pyexq.Supervisor do
  use Supervisor.Behaviour

  def start_link do
    :supervisor.start_link(__MODULE__, [])
  end


  def init([]) do
    HTTPotion.start

    pool_options = [
      name: {:local, :python_pool},
      worker_module: :python,
      size: 3,
      max_overflow: 4
    ]

    children = [
      func_supervisor(:delete_sup, &Pyexq.GoogleAPI.delete_task/1, restart: :transient),
      supervisor(Pyexq.LeaseHolderSupervisor, []),

      :poolboy.child_spec(:python_pool, pool_options, []),

      worker(Pyexq.TokenHandler, []),
    ]

    # See http://elixir-lang.org/docs/stable/Supervisor.Behaviour.html
    # for other strategies and supported options
    supervise(children, strategy: :one_for_one)
  end

  defp func_supervisor(id, function, args) do
    supervisor(Pyexq.FunctionSupervisor, [id, function, args], id: id)
  end
end
