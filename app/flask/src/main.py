from flask import Flask

app = Flask(__name__)

VERSION = "0.0.2"

@app.route("/")
def hello_world():
    return {"message": f"Hello World from Flask! This is version {VERSION}"}

if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080)