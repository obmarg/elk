import importlib
from cStringIO import StringIO

def get_application(module_name, app_name):
    '''
    Gets a WSGI application object.

    :param module_name:     The module to import
    :param app_name:        The name of the application within the module.
    '''
    module = importlib.import_module(module_name)
    return getattr(module, app_name)


def call_application(module_name, app_name, environ, input_str):
    '''
    Wrapper around calling a WSGI application

    :param module_name: The module to import
    :param app_name:    The name of the application within the module.
    :param environ:     A list of tuples, representing the pairs of the environ
                        dict.
    :param input_str:   The string to use for an input stream.

    :returns:           A tuple of (status, headers, body, error_stream)
    '''
    body = []
    status_headers = [None, None]

    def start_response(status, headers):
        status_headers[:] = [status, headers]

    environ = dict(environ)
    environ['wsgi.input'] = StringIO(input_str)
    environ['wsgi.error'] = err_stream = StringIO()

    app = get_application(module_name, app_name)
    app_iter = app(environ, start_response)

    try:
        for item in app_iter:
            body.append(item)
    finally:
        if hasattr(app_iter, 'close'):
            app_iter.close()

    return (status_headers[0], status_headers[1], ''.join(body),
            err_stream.getvalue())


def _erl_pairs_to_dict(pairs):
    '''
    Converts a list of pairs to a dict
    '''
    return {key.to_string(): value.to_string() for key, value in pairs}


def _test_app(environ, start_response):
    start_response(200, {'Content-Type': 'application/json'})
    yield "Hello WSGI!"
    yield "%r" % environ
