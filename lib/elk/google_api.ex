defmodule Elk.GoogleAPI do
  @moduledoc """
  This module provides a wrapper around the google APIs using
  HTTPotion.  It will request tokens from the TokenHandler.
  """

  use HTTPotion.Base
  require Lager

  @base_url "https://www.googleapis.com/taskqueue/v1beta2/projects"

  @doc "Gets a list of tasks from Google"
  def list_tasks() do
    get('')
    |> process_response
  end

  @doc "Leases n tasks from google"
  def lease_tasks(n_tasks) when n_tasks >= 1 do
    Lager.info "Requesting #{n_tasks} leases"
    query_string = URI.encode_query [{:leaseSecs, 500}, {:numTasks, n_tasks}]

    post("/lease?#{query_string}", "")
    |> process_response
    |> Dict.get("items", [])
    |> Enum.map(&GoogleAPIReader.parse_task/1)
  end

  def lease_tasks(_) do
    []
  end

  @doc "Releases a lease, ready for a retry"
  def release_lease(task_info) do
    Lager.info "Releasing lease for #{inspect task_info}"

    json_data = task_info
    |> GoogleAPIWriter.to_hashdict
    |> JSON.encode!

    query_string = URI.encode_query [{:newLeaseSeconds, 0}]

    "/#{task_info.id}?#{query_string}"
    |> post(json_data, [{"Content-Type", "application/json"}]) 
    |> process_response
  end

  @doc "Deletes a task.  For use when done, or out of retries"
  def delete_task(task_info) do
    Lager.info "Deleting task #{inspect task_info}"

    delete("/#{task_info.id}")
    |> process_response
  end

  ##
  # HTTPotion.Base implementation
  ##
  def process_url(url) do
    project = Elk.Config.get_str(:project)
    task_queue = Elk.Config.get_str(:task_queue)
    "#{@base_url}/#{project}/taskqueues/#{task_queue}/tasks#{url}"
  end

  def process_request_headers(headers) do
    access_token = Elk.TokenHandler.get_token()
    headers 
    |> Dict.put("User-Agent", "Elk")
    |> Dict.put("Authorization", "Bearer #{access_token}")
  end

  def process_response_body(body) do
    Lager.debug "Response from Google:"
    Lager.debug body
    case JSON.decode(body) do
      {:ok, data} -> data
      {:unexpected_end_of_buffer, _} ->
        Lager.debug "Response is not JSON."
        body
      {error, _} ->
        Lager.warning "Could not process JSON response: #{error}"
        Lager.warning "Body: #{body}"
        body
    end
  end

  ##
  # Utility functions
  ## 
  def process_response(response) do
    alias HTTPotion.Response

    case response do
      Response[body: body, status_code: status, headers: _headers ]
      when status in 200..299 ->
        body
      Response[body: body, status_code: status, headers: _headers ] ->
        throw "Remote error #{status} - #{inspect body}"
    end
  end
end

##
# Task Conversion Protocol
##
defprotocol GoogleAPIReader do
  @doc "Converts a google API task (as a HashSet) to an Elk.Task"
  def parse_task(task)
end

defprotocol GoogleAPIWriter do
  @doc "Converts an internal Record to a HashSet, ready for JSON serialization"
  def to_hashdict(data)
end

defimpl GoogleAPIReader, for: HashDict do
  require Elk.Task

  def parse_task(task) do
    payload = Dict.get(task, "payloadBase64")
              |> :base64.decode
              |> JSON.decode!

    # Re-JSONify the actual task payload so the WSGI layer can just pass it in.
    task_payload = JSON.encode!(Dict.get(payload, "payload"))

    Elk.Task[id: Dict.get(task, "id"),
             url: Dict.get(payload, "url"),
             payload: task_payload,
             orig: task,
             retries: Dict.get(task, "retry_count")]
  end
end

defimpl GoogleAPIWriter, for: Elk.Task do

  def to_hashdict(task) do
    task_queue = Elk.Config.get_str(:task_queue)
    # This is stupid, but apparently the google API doesn't like it's own
    # data, so we have to replace queueName with the short queue name (as
    # opposed to the full path the lease API sends us).  This might not be
    # universal, but it certainly is for the release_lease endpoint we use.
    Dict.put(task.orig, "queueName", task_queue)
  end
end
