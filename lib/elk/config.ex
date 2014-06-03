defmodule Elk.Config do
  @moduledoc """
  Utility module for configuration values.  All loaded from env vars just now.
  """

  @doc "Checks that a variable has been defined.  Exits if not."
  def check_var(var_name) do
    unless get_env(var_name) do
      IO.puts "#{atom_to_env_var var_name} not defined"
      exit(:config_error) 
    end
  end

  @doc "Gets an integer config variable, or default."
  def get_int(var_name, default) do
    case get_env(var_name) do
      nil -> default
      value -> binary_to_integer(value)
    end
  end

  @doc "Gets a string config variable, or exits."
  def get_str(var_name) when is_atom(var_name) do
    case get_env(var_name) do
      nil -> exit(:undefined_config)
      var -> var
    end
  end

  def get_str(var_names) when is_list(var_names) do
    Enum.map(var_names, &get_str/1)
  end

  @doc "Gets a string config variable, or default."
  def get_str(var_name, default) do
    get_env(var_name) || default
  end

  @doc "Checks verbosity and configures logging appropriately"
  def check_log_level() do
    level = get_str(:log_level, "info")
            |> String.downcase
            |> binary_to_atom
    :lager.set_loglevel :lager_console_backend, level
  end

  defp get_env(var_name) do
    var_name |> atom_to_env_var |> System.get_env
  end

  @doc "Converts an atom to it's corresponding environment variable name"
  def atom_to_env_var(atom) do
    name = atom |> atom_to_binary |> String.upcase

    "ELK_" <> name
  end

end
