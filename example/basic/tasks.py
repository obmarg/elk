from flask import Flask
import logging

app = Flask(__name__)

@app.route('/', methods=['POST'])
def root():
    logging.info("Root task run")
    return ''
