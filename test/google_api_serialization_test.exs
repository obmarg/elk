defmodule GoogleAPIReaderTest do
  use ExUnit.Case

  test "reads normal data" do
    data = make_task_data([1, 2, 3], false)
    result = GoogleAPIReader.parse_task(data) 
    
    assert result == Elk.Task[id: 123,
                              url: "/",
                              payload: "[1,2,3]",
                              orig: data,
                              retries: 1]
  end

  test "reads gzipped data" do
    data = [1, 2, 3]
           |> compress_data
           |> make_task_data

    result = GoogleAPIReader.parse_task(data)

    assert result == Elk.Task[id: 123,
                              url: "/",
                              payload: "[1,2,3]",
                              orig: data,
                              retries: 1]
  end

  defp make_task_data(payload, gzip // true) do
    json_data = HashDict.new(url: "/",
                             payload: payload,
                             gzip: gzip)
                |> JSON.encode!

    HashDict.new([{"id", 123},
                  {"retry_count", 1},
                  {"payloadBase64", :base64.encode(json_data)}])
  end

  defp compress_data(data) do
    data |> JSON.encode! |> :zlib.compress |> :base64.encode
  end

end
