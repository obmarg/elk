FROM obmarg/elk
MAINTAINER Graeme Coupar "http://github.com/obmarg"

# Create virtual env
RUN pip install virtualenv
RUN virtualenv /venv

# Install our application files to /elk-example
RUN mkdir /elk-example
WORKDIR /elk-example
ADD requirements.txt /elk-example/requirements.txt
ADD tasks.py /elk-example/tasks.py

# Copy tasks.py into the venv, so it's avaliable to Elk
RUN cp /elk-example/tasks.py /venv/lib/python2.7/site-packages

# Install our dependencies to the virtualenv
RUN /venv/bin/pip install -r requirements.txt

CMD /elk/bin/elk foreground

# Uncomment the following if you wish to interact with Elk at the console 
# manually.  This will require docker run to be passed -d -t
#CMD /elk/bin/elk console

###
# CONFIGURATION BEGINS HERE
###

# ELK_TASK_QUEUE defines the name of the GAE queue to pull from.
ENV ELK_TASK_QUEUE pulltest

# ELK_PROJECT defines the name of the GAE app to pull from.  It must include
# the leading s~ used by GAE.
ENV ELK_PROJECT s~elk-example

# ELK_CLIENT_ID is the email address of the google service account to use for
# pulling tasks.  It should have access to the GAE application as a task
# consumer, and should be identified by ELK_KEYFILE
ENV ELK_CLIENT_ID aclientid@developer.gserviceaccount.com

# ELK_KEYFILE should be the path to the .p12 keyfile for the user associated
# with ELK_CLIENT_ID
ENV ELK_KEYFILE private.p12

# ELK_APP_PACKAGE defines the python package that our tasks are run from.
# Since our app lives in tasks.py this is set to tasks.
ENV ELK_APP_PACKAGE tasks

# ELK_APP_NAME defines the name of the application within ELK_APP_PACKAGE - in
# our case this is app
ENV ELK_APP_NAME app

# Optionally, we can define ELK_VIRTUAL_ENV as the path to the virtualenv to
# use for running our application.
ENV ELK_VIRTUAL_ENV /venv
