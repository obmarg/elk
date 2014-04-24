defmodule Elk.Config do
  @moduledoc """
  Utility module for configuration values.  All loaded from env vars just now.
  """

  def get_int(var_name, default) do
    case System.get_env(var_name) do
      nil -> default
      value -> binary_to_integer(value)
    end
  end

  def get_str(var_name) do
    case System.get_env(var_name) do
      nil -> exit(:undefined_config)
      var -> var
    end
  end

  def get_str(var_name, default) do
    System.get_env(var_name) || default
  end

end
