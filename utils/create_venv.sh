#!/bin/bash

# loop over directories in sudo_python_scripts
for dir in sudo_python_scripts/*/; do
  echo "Setting up venv in $dir"

  # enter the directory
  cd "$dir" || continue

  # create virtual environment if it doesn’t exist
  if [ ! -d ".venv" ]; then
    python -m venv .venv
  fi

  # activate venv and install requirements
  if [ -f "requirements.txt" ]; then
    ./venv/bin/pip install -r requirements.txt
  else
    echo "No requirements.txt found in $dir"
  fi

  # go back to root
  cd - > /dev/null || exit
done
