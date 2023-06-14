from flask import Flask, render_template, request

app = Flask(__name__)

@app.route("/")
def home():
    return render_template('index.html')

@app.route("/bio")
def bio():
    return render_template('bio.html')

@app.route("/contactme", methods=['GET', 'POST'])
def contactme():
    error_message = None  # Set initial value for error_message

    if request.method == 'POST':
        # Process the form data and send email
        name = request.form.get('name')
        email = request.form.get('email')
        message = request.form.get('message')

        if name and email and message:
            # Perform email sending here
            return render_template('thank_you.html', name=name)
        else:
            error_message = "Please fill in all the fields."

    return render_template('contactme.html', error_message=error_message)

if __name__ == '__main__':
    app.run(debug=True, port=8000)
