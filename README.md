# Elk

An elixir application for running google app engine pull queues.

The actual tasks are implemented by python workers on a WSGI interface.  This
allows the workers to be implemented in a similar fashion to GAE push queues.

## What problem does it solve?

### The Problem

When building a python application on google app engine, you are somewhat
limited in the libraries and services you can use directly.

It's possible to work around this using HTTPS and the urlfetch service to make
requests to remote machines, but:

* This isn't really suitable for long running requests, due to app engines
  deadlines.
* This brings with it extra security concerns (setting up and managing HTTPS
  and authentication between the various endpoints etc.).
* The urlfetch service is not always reliable.

### A Possible Solution

The first problem could be solved by building a queue external to app engine
that deals with tasks as they come in.

However, we could just use app engine pull queues to save us some of that work.
This also reduces the issue of security, as you don't have to expose any ports
on your external services.  App Engine just needs to feed tasks into the pull
queue, and the external service just needs to process them from the pull queue.

We may still need to deal with authentication when sending results back into
app engine, but this should be easier than setting it up at both ends.

### How does Elk help?

Elk aims to provide a simple server that can be deployed to one or many
machines, and will process tasks on a task queue.

It wouldn't be too hard to write a simple worker in python in a few lines of
code, but Elk aims to cut down on the need for boilerplate;  Allowing
developers to worry about implementing the task itself, not managing the task
queue.

It also tries to cover any edge cases that a naive worker implementation might
miss, and allows tasks to be written in a similar manner to appengine push
queues - as routes in a web application.

#### Features

* Handles OAuth authentication.
* Handles task retries.
* Ensures release/delete of task leases.
* Exposes tasks as routes in webapp.
* Batches requests for leases in quiet periods

## Configuration

Elk is currently configured through environment variables:

Required Variables:

* `ELK_PROJECT` - The app engine project to read queues from.
* `ELK_TASK_QUEUE` - The name of the pull queue to read from.
* `ELK_CLIENT_ID` - The client ID to read from the pull queue with.
* `ELK_KEYFILE` - Path to our clients private key file.
* `ELK_APP_PACKAGE` - The name of the python package to load the WSGI app from.
* `ELK_APP_NAME` - The name of the WSGI app variable in ELK_APP_PACKAGE.
* `ELK_VIRTUAL_ENV` - The path to the root of the virtualenv to use.

Optional Variables:

* `ELK_MAX_RETRIES` - The maximum number of retries for each task.

## Instructions

Elk uses WSGI to run python tasks.  This means that we can expose tasks as
"routes" in a web application, similar to how appengine push queue tasks are
defined.

There is an example application in the `example` folder that contains a python
file and a shell script for setting up environment variables.  This would be a
good place to start for developing a python task application.

#### Configuring Elk

Since elk is configured through environment variables, a configuration shell
script is the recommended way to configure an Elk deployment.  Ideally this
script should setup all the environment variables correctly, then start Elk
itself.  `example/env.sh` makes a good starting point for this.

#### Installing Elk Python Dependencies.

Elk comes with most of it's dependencies.  However, some dependencies need
compiled, and are not suitable for distribution with Elk.  These will need to
be installed manually, using `pip` or another package manager:

* PyOpenSSL (On debian, this will require libffi-dev & python-dev to compile)

#### Running Elk

These are the initial instructions for running elk.  Currently this involves
downloading and building from source. At some point I hope to release packages
but I've not figured out how to do that yet.

##### Erlang Setup

Elk depends on erlang, which will need to be installed on the systems it is
to run on.
[Instructions can be found here](https://www.erlang-solutions.com/downloads/download-erlang-otp).

##### Elixir Setup

Elk is written in Elixir (0.12.5) which will need to be installed.
[Instructions can be found here](http://elixir-lang.org/getting_started/1.html)

##### Other Requirements

Elk requires a recent version of pip to be installed in order to install it's
python dependencies.

##### Building Elk

From within the elk directory:

```shell
$ mix deps.get
$ mix deps.compile
$ mix compile
$ mix deps.python
```

##### Running Elk

The recommended way to run applications in Elk is using a virtualenv.  This
virtualenv should have all the applications dependencies, and the application
itself installed within.  Applications with setup.py could be installed by
running `setup.py install` or `setup.py develop` within the virtualenv.  For
example:

```shell
$ pip install virtualenv
$ virtualenv venv
$ venv/bin/pip install PyOpenSSL
$ venv/bin/python setup.py
```

Once the virtualenv has been setup, elk should be configured using environment
variables.  The recommended way to do this is to take `examples/env.sh`, copy
it to the root of the source tree, and customise it with your settings. Don't
forget to configure `ELK_VIRTUAL_ENV` to the root path of the virtual env you
created.

Elk can then be run in the console like so:

```shell
$ . ~/env.sh
$ iex -S mix
```

This command should be run in the root of the elk source tree.

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
