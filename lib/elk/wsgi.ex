defmodule Elk.WSGI do
  @moduledoc '''
  API around python processes
  '''
  require Lager

  # For documentation on WSGI parameters:
  # http://wsgi.readthedocs.org/en/latest/definitions.html
  @global_wsgi_params [{"wsgi.version", {1, 0}},
                       {"wsgi.url_scheme", "http"},
                       {"wsgi.multithread", false},
                       {"wsgi.multiprocess", true},
                       {"wsgi.run_once", false},
                       {"SERVER_SOFTWARE", "Elk"},
                       {"SERVER_NAME", "0.0.0.0"},
                       {"GATEWAY_INTERFACE", "CGI/1.1"},
                       {"SERVER_PROTOCOL", "HTTP/1.1"},
                       {"SERVER_PORT", "80"},
                       {"REQUEST_METHOD", "POST"},
                       {"REMOTE_ADDR", "0.0.0.0"},
                       {"SCRIPT_NAME", ""},
                       {"CONTENT_TYPE", "application/json"}]

  def call_task(py_worker, module_name, app_name, task) do
    call_app(py_worker, module_name, app_name, task.url, task.payload)
  end

  def call_app(py_worker, module_name, app_name, url, input) do
    wsgi_params = Dict.put(@global_wsgi_params, "PATH_INFO", url)
    params = [ module_name, app_name, wsgi_params, input ]
    Lager.info "PLEASE"
    Lager.info input

    {status, headers, body, errors} = :python.call(
      py_worker, :wsgi_wrapper, :call_application, params
    )
    # TODO: Need to check for non-200 returns in here...
    Lager.info "Worker Finished: #{status}"
    Lager.info "Body: #{body}"
    Lager.info errors
    nil

    # TODO: Need to do something for wsgi.input & wsgi.errors
    # TODO: also need some timeout stuff & tests.
  end

end
