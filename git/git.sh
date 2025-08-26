#!/bin/bash

# Directory to scan (default = home)
BASE_DIR="$HOME"

# Commit message (default = "auto commit")
COMMIT_MSG="auto commit"

# Find all .git directories and iterate
find "$BASE_DIR" -type d -name ".git" | while read gitdir; do
    repo=$(dirname "$gitdir")
    echo "Processing repository: $repo"

    cd "$repo" || continue

    # Ensure it's a git repo
    if [ -d ".git" ]; then
        git add .

        # Commit only if there are changes
        if ! git diff --cached --quiet; then
            git commit -m "$COMMIT_MSG"
        else
            echo "No changes to commit in $repo"
        fi

        # Pull latest changes (merge strategy, not rebase)
        git pull --no-rebase

        # Push changes
        git push
    fi
done
