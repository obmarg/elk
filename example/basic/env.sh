
# ELK_TASK_QUEUE defines the name of the GAE queue to pull from.
export ELK_TASK_QUEUE=pulltest

# ELK_PROJECT defines the name of the GAE app to pull from.  It must include
# the leading s~ used by GAE.
export ELK_PROJECT=s~elk-example

# ELK_CLIENT_ID is the email address of the google service account to use for
# pulling tasks.  It should have access to the GAE application as a task
# consumer, and should be identified by ELK_KEYFILE
export ELK_CLIENT_ID=aclientid@developer.gserviceaccount.com

# ELK_KEYFILE should be the path to the .p12 keyfile for the user associated
# with ELK_CLIENT_ID
export ELK_KEYFILE=private.p12

# ELK_APP_PACKAGE defines the python package that our tasks are run from.
# Since our app lives in tasks.py this is set to tasks.
export ELK_APP_PACKAGE=tasks

# ELK_APP_NAME defines the name of the application within ELK_APP_PACKAGE - in
# our case this is app
export ELK_APP_NAME=app

# Optionally, we can define ELK_VIRTUAL_ENV as the path to the virtualenv to
# use for running our application.
#export ELK_VIRTUAL_ENV=~/.virtualenvs/elk-example/

# ELK_LOG_LEVEL sets the level of logs to display.  By default this is info
# export ELK_LOG_LEVEL='info'

# Optionally, you can override the number of python workers to spawn.
# export ELK_NUM_WORKERS=4
