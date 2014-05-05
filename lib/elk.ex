defmodule Elk do
  use Application.Behaviour
  require Lager

  defrecord Task, id: nil, url: nil, payload: nil, orig: nil, retries: 0

  @required_config [
    :task_queue, :project, :client_id, :app_package, :app_name, :keyfile,
  ]

  # See http://elixir-lang.org/docs/stable/Application.Behaviour.html
  # for more information on OTP Applications
  def start(_type, _args) do

    # Check required config:
    Enum.map @required_config, &Elk.Config.check_var/1

    keyfile = Elk.Config.get_str(:keyfile) 
    unless File.exists?(keyfile) do
      IO.puts "#{keyfile} does not exist"
    end

    task_queue = Elk.Config.get_str(:task_queue)
    project = Elk.Config.get_str(:project)
    Lager.notice "Elk starting for #{task_queue} on #{project}"

    Elk.Supervisor.start_link
  end

end

defimpl Inspect, for: Elk.Task do
  def inspect(task, opts) do
    "#Elk.Task<id: #{inspect task.id}, url: #{inspect task.url}>"
  end
end

