from flask import Flask, render_template_string

app = Flask(__name__)

VERSION = "1.0.2"
MESSAGE = "Welcome to the main page!"

@app.route('/')
def home():
    html = """
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Main Page for step</title>
        <style>
            body {
                font-family: Arial, sans-serif;
                text-align: center;
                margin-top: 50px;
            }
            .button {
                display: inline-block;
                margin: 10px;
                padding: 10px 20px;
                font-size: 18px;
                color: white;
                background-color: #007BFF;
                text-decoration: none;
                border-radius: 5px;
            }
            .button:hover {
                background-color: #0056b3;
            }
        </style>
    </head>
    <body>
        <h1>Main page!</h1>
        <p>{{ message }}</p>
        <p>Version: {{ version }}</p>
        <a href="/page1" class="button">Go to Page 1</a>
        <a href="/page2" class="button">Go to Page 2</a>
    </body>
    </html>
    """
    return render_template_string(html, message=MESSAGE, version=VERSION)

@app.route('/page1')
def page1():
    return "<h1>Welcome to Page 1!</h1><p><a href='/'>Back to Home</a></p>"

@app.route('/page2')
def page2():
    return "<h1>Welcome to Page 2!</h1><p><a href='/'>Back to Home</a></p>"

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)