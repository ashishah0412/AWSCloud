from flask import Flask

app = Flask(__name__)

@app.route("/service1")
def hello_service1():
    return "Hello from Service 1 (Python Flask)!"

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)


