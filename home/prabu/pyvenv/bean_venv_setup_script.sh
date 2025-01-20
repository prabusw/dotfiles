#!/bin/sh

# Set up the Python virtual environment
python3 -m venv /data/docs/prabu/bean_venv/

# Activate the virtual environment
. /data/docs/prabu/bean_venv/bin/activate

# Install the required packages
pip install -r bean_venv_requirements.txt
