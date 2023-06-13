# Use the official Python base image
FROM python:3.9-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements file and install dependencies
COPY requirements.txt .
RUN pip install -r requirements.txt

# Copy the Flask app code into the container
COPY app.py .

# Copy the HTML templates and static files
COPY templates templates
COPY static static

# Install Gunicorn
RUN pip install gunicorn

# Expose the port that the web server will listen on
EXPOSE 8000

# Start the web server with Gunicorn
CMD ["gunicorn", "-b", "0.0.0.0:8000", "app:app"]
