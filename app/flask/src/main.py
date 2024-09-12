from flask import Flask
from os import getenv

app = Flask(__name__)

VERSION = "0.0.2"

ENV = getenv("ENV")

@app.route("/")
def hello_world():
    return {"message": f"Hello World from Flask! This is version {VERSION} in environment {ENV}"}

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080)