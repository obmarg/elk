defmodule Elk.Python do
  @moduledoc """
  A module for dealing with erlport python that handles Elk specific details.
  """

  @doc """
  Returns a configuration suitable for passing in to :python.start
  """
  def python_config do
    config = [{:python_path, :code.priv_dir('elk')}]
    case python_executable() do
      nil -> config
      exe -> Dict.put(config, :python, exe)
    end
  end

  defp python_executable() do
    case Elk.Config.get_str("ELK_VIRTUAL_ENV", nil) do
      nil -> nil
      virtual_env -> {:python, to_char_list(virtual_env <> "bin/python")}
    end
  end

end
