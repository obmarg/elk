defmodule Elk do
  use Application.Behaviour

  defrecord Task, id: nil, url: nil, payload: nil, orig: nil, retries: 0

  # See http://elixir-lang.org/docs/stable/Application.Behaviour.html
  # for more information on OTP Applications
  def start(_type, _args) do
    Elk.Supervisor.start_link
  end

end

defimpl Inspect, for: Elk.Task do
  def inspect(task, opts) do
    "#Elk.Task<id: #{inspect task.id}, url: #{inspect task.url}>"
  end
end

