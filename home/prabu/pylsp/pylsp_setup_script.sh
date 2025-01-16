#!/bin/sh

# Set up the Python virtual environment
python3 -m venv /data/docs/prabu/pylsp

# Activate the virtual environment
. /data/docs/prabu/pylsp/bin/activate

# Install the required packages
pip install -r pylsp_requirements.txt
