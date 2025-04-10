# Use the official Python image from the Docker Hub
ARG PLATTFORM=linux/amd64
FROM --platform=${PLATTFORM} python:3.13

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set the working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    unixodbc-dev \
    curl \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

COPY --chmod=+x ./install.sh /app/install.sh

RUN bash /app/install.sh

# Install Python dependencies
COPY requirements.txt /app/
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

ENV DJANGO_SETTINGS_MODULE=backend.settings
ENV UWSGI_WSGI_FILE=backend/wsgi.py
ENV UWSGI_STATIC_MAP="/api/static=/app/dist"


# Install uWSGI
RUN pip install uwsgi

# Copy the Django project
COPY . /app/

# Expose the port the app runs on
EXPOSE 8000

ENTRYPOINT ["/app/entrypoint.sh"]
CMD [ "uwsgi", "--http", ":8000", "--wsgi-file", "/app/backend/wsgi.py" ]