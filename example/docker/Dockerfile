FROM obmarg/elk
MAINTAINER Graeme Coupar "http://github.com/obmarg"

# Create virtual env
RUN pip install virtualenv
RUN virtualenv /venv
RUN /venv/bin/activate

RUN mkdir /elk-example
WORKDIR /elk-example
ADD requirements.txt /elk-example/requirements.txt
ADD tasks.py /elk-example/tasks.py

RUN pip install -r requirements.txt

