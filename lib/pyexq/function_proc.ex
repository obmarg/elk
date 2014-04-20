defmodule Pyexq.FunctionProc do
  @moduledoc """
  This module implements a process that will run a function then quit.

  It runs the function under a supervisor in transient mode, which allows
  it to benefit from restarts.

  The function should throw an exception on errors.
  """

  use GenServer.Behaviour

  ##
  # GenServer functions
  ##
  def start_link(func, arguments) do
    :gen_server.start_link(__MODULE__, {func, arguments}, [])
  end

  def init({func, arguments}) do
    apply(func, arguments)
    {:stop, :normal}
  end

end
