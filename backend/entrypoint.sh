#!/bin/bash

# This script is used to set up the environment for the backend service.
python manage.py migrate

# Collect static files
python manage.py collectstatic --noinput

exec "$@"