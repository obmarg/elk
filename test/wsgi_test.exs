defmodule WsgiTest do
  use ExUnit.Case

  defp call_app(fn_name, input // "") do
    Elk.WSGI.call_app("wsgi_wrapper.test", fn_name, input)
  end

  test "call_app handles simple 200" do
    assert call_app("return200") == {"200 OK", [], "Hi", ""}
  end

  test "call_app handles error stream" do
    assert call_app("return500") == {"500 ERROR", [], "Oh No!", "ERROR"}
  end
end
