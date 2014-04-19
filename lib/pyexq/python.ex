defmodule Pyexq.Python do
  @moduledoc '''
  API around python processes
  '''

  def get_cwd do
    :poolboy.transaction :python_pool, fn (worker) ->
      :python.call worker, :sys, :"version.__str__", []
      :python.call worker, :time, :sleep, [30]
    end
  end
end
