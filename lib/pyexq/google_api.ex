defmodule Pyexq.GoogleAPI do
  @moduledoc """
  This module provides a wrapper around the google APIs using
  HTTPotion.  It will request tokens from the TokenHandler.
  """

  use HTTPotion.Base

  @base_url "https://www.googleapis.com/taskqueue/v1beta2/projects"
  @project "rolepoint-integration"
  @task_queue "pulltest"

  def list_tasks() do
    get('') |> process_response
  end

  def lease_task() do
    {:ok, input} = JSON.encode [{:leaseSecs, 60}, {:numTasks, 1}]
    data = post("/lease", input) |> process_response
    # TODO: Check 'kind' is taskqueue#tasks
    #       Extract items as tasks
  end

  def delete_task(id) do
    delete("/delete/#{id}") |> process_response
  end

  ##
  # HTTPotion.Base implementation
  ##
  def process_url(url) do
    "#{@base_url}/#{@project}/taskqueues/#{@task_queue}/tasks#{url}"
  end

  def process_request_headers(headers) do
    access_token = Pyexq.TokenHandler.get_token()
    headers 
    |> Dict.put("User-Agent", "pyexq")
    |> Dict.put("Authorization", "Bearer #{access_token}")
  end

  def process_response_body(body) do
    {:ok, data} = JSON.decode body
    data
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
        throw "Remote error #{status} - #{body}"
    end
  end
end
