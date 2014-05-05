defmodule Mix.Tasks.Deps.Python do
  use Mix.Task

  @shortdoc "Installs elks python dependencies"

  @moduledoc """
  Installs elks python dependenices to the priv/python_deps folder, for
  packaging into a release.
  """
  def run(_) do
    IO.puts :os.cmd 'rm -R priv/python_deps'
    IO.puts :os.cmd 'mkdir priv/python_deps'
    IO.puts :os.cmd 'pip install google-api-python-client==1.2 webob==1.3.1 -t priv/python_deps'
    IO.puts :os.cmd 'pip install google-api-python-client==1.2 webob==1.3.1 -t priv/python_deps'
  end

end
