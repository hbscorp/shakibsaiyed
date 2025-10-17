#!/bin/sh
set -e

. bin/config.env

$CONTAINER_CMD run --rm \
    -v "$(pwd):/app" \
    -w /app \
    "python:3.12-slim" \
    sh -c "pip install --quiet -r resources/requirements.txt && python -m unittest discover -s tests -v"

_exit_code=$?
if [ $_exit_code -eq 0 ]; then
    echo "INFO: All tests passed!"
else
    echo "ERROR: Tests failed with exit code $_exit_code"
    exit 1
fi
