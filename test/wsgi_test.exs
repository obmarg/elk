defmodule WsgiTest do
  use ExUnit.Case

  test "call_app handles simple 200" do
    Pyexq.WSGI.call_app("wsgi_wrapper.test", "return200")
  end
end
