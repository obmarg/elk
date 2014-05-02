defmodule Elk do
  use Application.Behaviour
  require Lager

  defrecord Task, id: nil, url: nil, payload: nil, orig: nil, retries: 0

  @required_config [
    "ELK_TASK_QUEUE", "ELK_PROJECT", "ELK_CLIENT_ID",
    "ELK_APP_PACKAGE", "ELK_APP_NAME"
  ]

  # See http://elixir-lang.org/docs/stable/Application.Behaviour.html
  # for more information on OTP Applications
  def start(_type, _args) do

    # Check for required config:
    Enum.map @required_config, fn (var_name) ->
      unless Elk.Config.get_str(var_name, nil) do
        IO.puts "#{var_name} not defined"
        exit(:config_error) 
      end
    end

    task_queue = Elk.Config.get_str("ELK_TASK_QUEUE")
    project = Elk.Config.get_str("ELK_PROJECT")
    Lager.notice "Elk starting for #{task_queue} on #{project}"

    Elk.Supervisor.start_link
  end

end

defimpl Inspect, for: Elk.Task do
  def inspect(task, opts) do
    "#Elk.Task<id: #{inspect task.id}, url: #{inspect task.url}>"
  end
end

