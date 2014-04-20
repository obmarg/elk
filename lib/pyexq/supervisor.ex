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
      # Define workers and child supervisors to be supervised
      # worker(Pyexq.Worker, [])
      worker(Pyexq.TokenHandler, []),
      :poolboy.child_spec(:python_pool, pool_options, [])
    ]

    # See http://elixir-lang.org/docs/stable/Supervisor.Behaviour.html
    # for other strategies and supported options
    supervise(children, strategy: :one_for_one)
  end
end
