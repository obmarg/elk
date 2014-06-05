# Elk

Elk allows google app engine applications to easily run background tasks on
external servers.  It is written in [Elixir](http://elixir-lang.org/), and uses
[google app engine pull queues](https://developers.google.com/appengine/docs/python/taskqueue/overview-pull#Python_Pull_queue_overview).

The tasks themselves can be implemented in python.  Elk communicates to them
using WSGI, so they can be written as normal routes in a web application using
one of the many python web-frameworks.  Just like normal app engine tasks.

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

However, using app engine pull queues can save some of that work. It can also
ease some of the security pains, as you don't have to expose any ports on your
external services.  App Engine just needs to feed tasks into the pull queue,
and the external service just needs to process them from the pull queue.

App Engine provides a REST API for pull queues with OAuth authentication over
HTTPS, which saves you implementing something similar yourself.

You may still need to implement some authentication when sending results back
into app engine, but this should be easier than setting it up at both ends.

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
* Decouples workers from task queue, they can be debugged as a web-app
  normally.
* Encodes payload data to avoid app engine REST API bugs.

## Configuration

Elk is currently configured through environment variables:

Required Variables:

* `ELK_PROJECT` - The app engine project to read queues from.
* `ELK_TASK_QUEUE` - The name of the pull queue to read from.
* `ELK_CLIENT_ID` - The client ID to read from the pull queue with.
* `ELK_KEYFILE` - Path to our clients private key file.
* `ELK_APP_PACKAGE` - The name of the python package to load the WSGI app from.
* `ELK_APP_NAME` - The name of the WSGI app variable in ELK_APP_PACKAGE.

Optional Variables:

* `ELK_VIRTUAL_ENV` - The path to the root of the virtualenv to use.
* `ELK_MAX_RETRIES` - The maximum number of retries for each task.
* `ELK_LOG_LEVEL` - The level of logs to display in the console.  Defaults to
  info.  See [ExLager](https://github.com/khia/exlager) for more details on the
  options.
* `ELK_NUM_WORKERS` - The number of python workers to spawn.  This defaults to
  4.

## Using Elk

Elk uses WSGI to run python tasks.  This means that we can expose tasks as
"routes" in a web application, similar to how appengine push queue tasks are
defined.

There are 2 example applications in the `example` folder:

* The `docker` example contains a python application and a Dockerfile for
  building a docker image for the application.  This is the recommended method
  for deploying Elk at the moment, as it avoids the need for compiling Elk.
* The `basic` example contains a python application and a shell script for
  setting up environment variables.  This would be a good place to start for
  developing python task application.

#### App Engine Setup

You will need to setup a pull queue on google app engine, using the queue.yaml
file.  [Instructions on configuring a queue are here](https://developers.google.com/appengine/docs/python/config/queue#Python_Defining_pull_queues).

You will also need to setup a google service account for Elk to use to read the
task queue REST API.  This can be done under "APIs and Auth" - "Credentials" in [the google cloud console](https://console.developers.google.com/project).  You will need the email address of the user, and the users secret key to configure elk.

Be sure to list this service account under the `user_email` section for your
queue in your queue.yaml file.

#### Configuring Elk

Elk is configured through environment variables.  Using the recommended docker
deployment, these can be configured in the Dockerfile using the `ENV` command.
An example of such a Dockerfile can be found in `example/docker/Dockerfile`.

Alternatively, an env.sh script can be used. Ideally this script should setup
all the environment variables correctly, then start Elk itself.
`example/basic/env.sh` makes a good starting point for this.

#### Running Elk

##### Using Docker (recommended)

Elk provides a base Dockerfile in `docker/`.  You can create a Dockerfile for
your application using this as a Base.  There is an example of this in the
`examples` folder.  You should just need to set the `CMD` of your docker image
to `elk console` .  This should allow you to run Elk using `docker run
<image-name>`

##### Using an Elk Release (currently not very well supported)

If you are using an Elk release, then you should run `elk console` with the
appropriate environment variables set.  You must ensure that PyOpenSSL is
included in the release, or otherwise accessible to Elk.

##### Running Elk from Repository

Otherwise, running `iex -S mix` from within the Elk repository should do the
trick.  You will have to build Elk before doing this, by following the
instructions below.  More details on running Elk manually can be found under
"Running Elk Manually" below.

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

# It is recommended to zip the payload to avoid app engine problems with
# certain payloads.  To do this:
from zlib import compress
from base64 import b64encode
payload['payload'] = b64encode(compress(json.dumps(payload['payload'])))
payload['zipped'] = True

q = taskqueue.Queue("pulltest")
q.add([taskqueue.Task(payload=json.dumps(payload), method='PULL')])
```

#### Developing Elk Workers

Since Elk interfaces with it's workers using WSGI, they can be developed and
tested as if they were a website - you can make use of the development servers
and interactive debuggers present in most python web-frameworks.

TODO: Add more details

## Building Elk

#### Installing Elk Python Dependencies.

Elk comes with most of it's dependencies.  However, some dependencies need
compiled, and are not suitable for distribution with Elk.  These will need to
be installed manually, using `pip` or another package manager:

* PyOpenSSL (On debian, this will require libffi-dev & python-dev to compile)

It's fine to install this globally, or in the virtualenv Elk will be using.

##### Elixir Setup

Elk is written in Elixir (0.12.5) which will need to be installed.

For Mac OS, this can be done with
    
    homebrew install elixir

Which will install Erlang, and Elixir. Otherwise [Instructions can be found
here](http://elixir-lang.org/getting_started/1.html)

Elixir depends on erlang, which will need to be installed on the systems it is
to run on. [Instructions can be found
here](https://www.erlang-solutions.com/downloads/download-erlang-otp).

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

##### Running Elk Manually

The recommended way to develop applications for Elk is using a virtualenv.
This virtualenv should have all the applications dependencies, and the
application itself installed within.  Applications with setup.py could be
installed by running `setup.py install` or `setup.py develop` within the
virtualenv.  For example:

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

