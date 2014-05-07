Elk Example
---

This folder contains an example task runner for use with Elk.

It contains a single "task" that simply prints out a message to it's logs, and
exits.  This task is on the root URL.

Running
---

This example allows you to run Elk manually.  It contains `env.sh` - a bash
script that can be used to configure Elk.  Assuming these files are configured
and copied to the root of the elk repository, Elk can be run with the following commands:

    $ . ./env.sh
    $ iex -S mix
