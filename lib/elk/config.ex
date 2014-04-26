defmodule Elk.Config do
  @moduledoc """
  Utility module for configuration values.  All loaded from env vars just now.
  """

  @doc "Gets an integer config variable, or default."
  def get_int(var_name, default) do
    case System.get_env(var_name) do
      nil -> default
      value -> binary_to_integer(value)
    end
  end

  @doc "Gets a string config variable, or exits."
  def get_str(var_name) do
    case System.get_env(var_name) do
      nil -> exit(:undefined_config)
      var -> var
    end
  end

  @doc "Gets a string config variable, or default."
  def get_str(var_name, default) do
    System.get_env(var_name) || default
  end

end
