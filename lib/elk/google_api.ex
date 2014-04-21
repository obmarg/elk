defmodule Elk.GoogleAPI do
  @moduledoc """
  This module provides a wrapper around the google APIs using
  HTTPotion.  It will request tokens from the TokenHandler.
  """

  use HTTPotion.Base
  require Lager

  @base_url "https://www.googleapis.com/taskqueue/v1beta2/projects"
  @project "s~rolepoint-integration"
  @task_queue "pulltest"

  def list_tasks() do
    get('')
    |> process_response
  end

  def lease_tasks(n_tasks) do
    Lager.info "Requesting #{n_tasks} leases"
    query_string = URI.encode_query [{:leaseSecs, 60}, {:numTasks, n_tasks}]

    post("/lease?#{query_string}", "")
    |> process_response
    |> Dict.get("items")
  end

  def release_lease(task_id) do
    # TODO: Assuming this doesn't work...
    Lager.info "Releasing lease for #{task_id}"
    put("/#{task_id}", [{:newLeaseSeconds, 0}]) |> process_response
  end

  def delete_task(task_id) do
    Lager.info "Deleting task #{task_id}"

    delete("/#{task_id}")
    |> process_response
  end

  ##
  # HTTPotion.Base implementation
  ##
  def process_url(url) do
    "#{@base_url}/#{@project}/taskqueues/#{@task_queue}/tasks#{url}"
  end

  def process_request_headers(headers) do
    access_token = Elk.TokenHandler.get_token()
    headers 
    |> Dict.put("User-Agent", "Elk")
    |> Dict.put("Authorization", "Bearer #{access_token}")
  end

  def process_response_body(body) do
    case JSON.decode(body) do
      {:ok, data} -> data
      {:unexpected_end_of_buffer, _} -> body
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
