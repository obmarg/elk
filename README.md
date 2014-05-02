# Elk

An elixir application for running google app engine pull queues.

The actual tasks are implemented by python workers on a WSGI interface.  This
allows the workers to be implemented in a similar fashion to GAE push queues.

## Configuration

Elk is currently configured through environment variables:

Required Variables:

* ELK_PROJECT - The app engine project to read queues from.
* ELK_TASK_QUEUE - The name of the pull queue to read from.
* ELK_CLIENT_ID - The client ID to read from the pull queue with

Currently a private key will be expected in a file called `private.p12`.

Optional Variables:

* ELK_MAX_RETRIES - The maximum number of retries for each task.

## Instructions

*TODO*
