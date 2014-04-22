import importlib
from cStringIO import StringIO
from webob import Request

def get_application(module_name, app_name):
    '''
    Gets a WSGI application object.

    :param module_name:     The module to import
    :param app_name:        The name of the application within the module.
    '''
    module = importlib.import_module(module_name)
    return getattr(module, app_name)


def call_application(module_name, app_name, url, method, input_str):
    '''
    Wrapper around calling a WSGI application

    :param module_name: The module to import
    :param app_name:    The name of the application within the module.
    :param url:         The url to send things to
    :param method:      The HTTP method
    :param input_str:   The string to use for an input stream.

    :returns:           A tuple of (status, headers, body, error_stream)
    '''
    req = Request.blank(url)
    req.method = method
    req.body = input_str
    req.content_type = 'application/json'

    app = get_application(module_name, app_name)
    response = req.get_response(app)

    # TODO: Need a way to get err_stream from this.
    return (response.status_code, response.headerlist, response.body)


def _test_app(environ, start_response):
    start_response(200, {'Content-Type': 'application/json'})
    yield "Hello WSGI!"
    yield "%r" % environ
