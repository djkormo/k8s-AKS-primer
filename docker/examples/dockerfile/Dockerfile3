FROM python:3.6-slim

ADD app /app

RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r /app/requirements.txt

# Expose the port
EXPOSE 80

# Set the working directory
WORKDIR /app

# Run the flask server for the endpoints
CMD python app.py