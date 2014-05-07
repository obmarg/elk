Elk Docker Example
---

This folder contains an example task runner for use with Elk.

It contains a single "task" that simply prints out a message to it's logs, and
exits.  This task is on the root URL.

It also contains a Dockerfile that can be used to build docker images for
deployment.

Building
---

The example Dockerfile should be edited with the appropriate variables for your
environment.  You should also be sure to add a private key file.  Then the
docker image can be built:

    docker build.

See the docker documentation for more details.

WARNING: Be careful not to share the private key publiclly, or publish your
docker build anywhere - this would also share your private key, which you don't
want to do.

Running
---

Assuming the dockerfile has been built as `example`, the container can be run using

    $ docker run example
