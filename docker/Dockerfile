FROM obmarg/docker-elixir
MAINTAINER Graeme Coupar "http://github.com/obmarg"

RUN apt-get -y update --fix-missing

# Install python & pip
RUN apt-get install -y python
RUN apt-get install -y python-setuptools
RUN easy_install pip

# Download Elk
WORKDIR /tmp
RUN git clone https://github.com/obmarg/elk.git
WORKDIR /tmp/elk

# Compile Elk & dependencies.
RUN mix deps.get
RUN mix deps.compile
RUN mix compile
RUN mix deps.python

# Elk requires PyOpenSSL to be installed manually.
# We're inserting PyOpenSSL into the elk release here, to save requiring child
# Dockerfiles from using our venv
RUN apt-get install -y python-dev libffi-dev libssl-dev
RUN pip install -t priv/python_deps/ PyOpenSSL

# Generate Elk release & copy it to /elk
RUN mix release
WORKDIR /
RUN mkdir elk
RUN cp /tmp/elk/rel/elk/elk-0.0.1.tar.gz /elk/elk.tar.gz
WORKDIR /elk
RUN tar -xf elk.tar.gz
RUN rm elk.tar.gz

# Tidy up /tmp
RUN rm -Rf /tmp/*
