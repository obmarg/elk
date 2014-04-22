defmodule Elk.WSGI do
  @moduledoc '''
  API around python processes
  '''
  require Lager

  def call_task(py_worker, module_name, app_name, task) do
    call_app(py_worker, module_name, app_name, task.url, task.payload)
  end

  def call_app(py_worker, module_name, app_name, url, input) do
    params = [ module_name, app_name, url, "POST", input ]
    {status, headers, body} = :python.call(
      py_worker, :wsgi_wrapper, :call_application, params
    )
    # TODO: Need to check for non-200 returns in here...
    Lager.info "Worker Finished: #{status}"
    Lager.info "Body: #{body}"
    nil

    # TODO: Need some timeout stuff & tests.
  end

end
