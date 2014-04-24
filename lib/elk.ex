defmodule Elk do
  use Application.Behaviour
  require Lager

  defrecord Task, id: nil, url: nil, payload: nil, orig: nil, retries: 0

  # See http://elixir-lang.org/docs/stable/Application.Behaviour.html
  # for more information on OTP Applications
  def start(_type, _args) do
    # Check for required config:
    unless task_queue = Elk.Config.get_str("ELK_TASK_QUEUE", nil) do
      IO.puts "ELK_TASK_QUEUE not defined"
      exit(:config_error)
    end

    unless project = Elk.Config.get_str("ELK_PROJECT", nil) do
      IO.puts "ELK_PROJECT not defined"
      exit(:config_error)
    end

    unless Elk.Config.get_str("ELK_CLIENT_ID", nil) do
      IO.puts "ELK_CLIENT_ID not defined"
      exit(:config_error)
    end

    Lager.notice "Elk starting for #{task_queue} on #{project}"

    Elk.Supervisor.start_link
  end

end

defimpl Inspect, for: Elk.Task do
  def inspect(task, opts) do
    "#Elk.Task<id: #{inspect task.id}, url: #{inspect task.url}>"
  end
end

