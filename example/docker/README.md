Elk Docker Example
---

This folder contains an example task runner for use with Elk.

It contains a single "task" that simply prints out a message to it's logs, and
exits.  This task is on the root URL.

It also contains a Dockerfile that can be used to build docker images for
deployment.

Configuring Service Accounts
---

It should be possible to use the `ENV` and `ADD` Dockerfile commands to include
the `ELK_CLIENT_ID` and private key of your service account in a docker image.

However, keeping the private key for the service account in a shared repository
or docker image is not a great idea.  Ideally we would configure each worker
with a different service account, and not store those credentials anywhere
else.  Then we can just revoke & create new service accounts as needed.

With this in mind, it may be a better idea to leave the private key and service
account configuraiton out of your Dockerfile, and just build a generic image.

These variables can then be configured on each host individually, using command
line arguments to `docker run`.

The `-v=[]` option described in [Mount a Host Directory as a Container Volume](http://docs.docker.io/use/working_with_volumes/)
could be used to supply the private key file.  The `-e`
[option described here](http://docs.docker.io/reference/run/#env-environment-variables)
could be used to configure any remaining environment variables.

Alternatively, these variables could be configured by shelling in to the image
and saving the results.

Building
---

The example Dockerfile should be edited with the appropriate variables for your
environment.  You should also be sure to add a private key file.  Then the
docker image can be built:

    docker build .

See the docker documentation for more details.

WARNING: Be careful not to share the private key publiclly, or publish your
docker build anywhere - this would also share your private key, which you don't
want to do.

Running
---

Assuming the dockerfile has been built as `example`, the container can be run using

    $ docker run example

Or if you wish to configure the security details on run:

    $ docker run -e "ELK_CLIENT_ID=1234@developers.google.com" -e "ELK_KEYFILE=/mnt/shared/private.p12" -v=/home/ubuntu/key:/mnt/shared/:ro example

Where the key file is stored in `/home/ubuntu/key/private.p12` on the host, and
in `1234@developers.google.com` is the email address of the service account.
