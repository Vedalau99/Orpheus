from flask import Flask

app = Flask(__name__)

@app.route('/')
def hello_orpheus():
    return "🎶 Welcome to Orpheus — DevOps in Harmony!"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
