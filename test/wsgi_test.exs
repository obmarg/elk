defmodule WsgiTest do
  use ExUnit.Case

  defp call_app(context, app, input \\ "") do
    Elk.WSGI.call_app(context[:worker], "wsgi_wrapper.test", app, "", input)
  end

  setup do
    {:ok, worker} = :python.start(Elk.Python.python_config)
    {:ok, worker: worker}
  end

  teardown context do
    :python.stop(context[:worker])
    :ok
  end

  test "call_app handles simple 200", context do
    assert call_app(context, "return200") == :ok
  end

  test "call_app errors on 500", context do
    assert call_app(context, "return500") == :task_failed
  end
end
