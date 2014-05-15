'''
File containing a tests application for the WSGI module.
'''

def return200(environ, start_response):
    start_response('200 OK', [])
    yield "Hi"

def return500(environ, start_response):
    start_response('500 ERROR', [])
    yield "Oh No!"
