defmodule Elk.WSGI do
  @moduledoc '''
  API around python processes
  '''

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
                       # These ones will need moved:
                       {"PATH_INFO", "/"}]

  def call_app(py_worker, module_name, app_name, input) do
    params = [ module_name, app_name, @global_wsgi_params, input ]
    :python.call py_worker, :wsgi_wrapper, :call_application, params

    # TODO: Need to do something for wsgi.input & wsgi.errors
    # TODO: also need some timeout stuff & tests.
  end

end