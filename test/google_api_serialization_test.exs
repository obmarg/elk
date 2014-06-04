defmodule GoogleAPIReaderTest do
  use ExUnit.Case

  def make_task_data(payload) do
    json_data = HashDict.new(url: "/",
                             payload: payload)
                |> JSON.encode!

    HashDict.new([{"id", 123},
                  {"retry_count", 1},
                  {"payloadBase64", :base64.encode(json_data)}])
  end

  test "reads normal data" do
    data = make_task_data([1, 2, 3])
    result = GoogleAPIReader.parse_task(data) 
    
    assert result == Elk.Task[id: 123,
                              url: "/",
                              payload: "[1,2,3]",
                              orig: data,
                              retries: 1]
  end

end
