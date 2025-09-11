#!/usr/bin/env bash
set -e

# Get the latest stable version (x.y.z) from pyenv install list
latest=$(pyenv install --list | grep -E "^\s*[0-9]+\.[0-9]+\.[0-9]+$" | tail -1 | tr -d ' ')

echo "Latest Python version: $latest"

# Get already installed versions
installed=$(pyenv versions --bare)

# Uninstall all versions except the latest
for v in $installed; do
    if [ "$v" != "$latest" ]; then
        echo "Uninstalling $v ..."
        pyenv uninstall -f "$v"
    fi
done

# Install the latest version if not already installed
if ! pyenv versions --bare | grep -q "^$latest$"; then
    echo "Installing $latest ..."
    pyenv install "$latest"
fi

# Set the latest version as global default
pyenv global "$latest"

echo "Done. Current Python version is:"
python --version
