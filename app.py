from flask import Flask, render_template

app = Flask(__name__)

@app.route("/")
def home():
    return render_template('index.html')

@app.route("/bio")
def bio():
    return render_template('bio.html')

@app.route("/contactme")
def contactme():
    return render_template('contactme.html')

if __name__ == '__main__':
    app.run(debug=True, port=8000)