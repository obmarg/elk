'''
File containing a tests application for the WSGI module.
'''
def return200(environ, start_response):
    start_response('200 OK', {})
    yield "Hi"
