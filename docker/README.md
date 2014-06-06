This folder contains a Dockerfile for creating the obmarg/elk image.  

This docker contains a built version of [ELk](https://github.com/obmarg/Elk).
It is intended to be used as a Base Dockerfile for applications that want to
use Elk.

Building
--------

To build the docker image from scratch:

    docker build .


Using
-----

The Dockerfile is meant to be used as a Base.  An example Dockerfile that uses
this Dockerfile can be found
[here](https://github.com/obmarg/elk/tree/docker-example/example/docker)
