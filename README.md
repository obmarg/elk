# Elk

An elixir application for running google app engine pull queues.

The actual tasks are implemented by python workers on a WSGI interface.  This
allows the workers to be implemented in a similar fashion to GAE push queues.

## Configuration

Elk is currently configured through environment variables:

Required Variables:

* ELK_PROJECT - The app engine project to read queues from.
* ELK_TASK_QUEUE - The name of the pull queue to read from.
* ELK_CLIENT_ID - The client ID to read from the pull queue with.
* ELK_KEYFILE - Path to our clients private key file.
* ELK_APP_PACKAGE - The name of the python package to load the WSGI app from.
* ELK_APP_NAME - The name of the WSGI app variable in ELK_APP_PACKAGE.
* ELK_VIRTUAL_ENV - The path to the root of the virtualenv to use.

Optional Variables:

* ELK_MAX_RETRIES - The maximum number of retries for each task.

## Instructions

Elk uses WSGI to run python tasks.  This means that we can expose tasks as
"routes" in a web application, similar to how appengine push queue tasks are
defined.

There is an example application in the `example` folder that contains a python
file and a shell script for setting up environment variables.  This would be a
good place to start for developing a python task application.

#### Running Elk

TODO.

#### Sending Tasks To Elk

The following code should add a task to a "pulltest" queue on app engine.  If
used with the example application this would run it's root task, which simply
prints to the logs.

```python
# The url is required to allow Elk to route to the correct task.
# In this case we're just sending to the root URL.
payload = {'url': '/'}

# We should also send in a payload - this is the data that will actually be
# sent in to the task routes themselves.
payload['payload'] = {}

q = taskqueue.Queue("pulltest")
q.add([taskqueue.Task(payload=json.dumps(payload), method='PULL')])
```
