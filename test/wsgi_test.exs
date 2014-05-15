defmodule WsgiTest do
  use ExUnit.Case

  setup do
    {:ok, worker} = :python.start(Elk.Python.python_config)
    {:ok, worker: worker}
  end

  teardown context do
    :python.stop(context[:worker])
    :ok
  end

  test "call_app on on 200", context do
    assert call_app(context, "return200") == :ok
  end

  test "call_app errors on 500", context do
    assert call_app(context, "return500") == :task_failed
  end

  test "call_task ok on 200", context do
    assert call_task(context, "return200") == :ok
  end

  test "call_task errors on 500", context do
    assert call_app(context, "return500") == :task_failed
  end

  defp call_app(context, app, input \\ "") do
    Elk.WSGI.call_app(context[:worker], "wsgi_wrapper.test", app, "", input)
  end

  defp call_task(context, app, input \\ "") do
    task = Elk.Task[url: "", payload: ""]
    Elk.WSGI.call_task(context[:worker], "wsgi_wrapper.test", app, task)
  end
end
