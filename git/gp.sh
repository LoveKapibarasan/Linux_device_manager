#!/bin/bash

# remote = upstream, origin

# Directory to scan (default = home)
COMMIT_MSG="Auto Commit"
BASE_DIR="$HOME"
# 探索と処理
find "$BASE_DIR" -type d -name ".git" | while read gitdir; do
    repo=$(dirname "$gitdir")
    echo "Processing repository: $repo"

    cd "$repo" || continue

    # Gitリポジトリ確認
    if [ -d ".git" ]; then
        git add .

        # コミット（変更があるときだけ）
        if ! git diff --cached --quiet; then
            git commit -m "$COMMIT_MSG"
        else
            echo "→ No staged files found."
        fi

        # 現在のブランチ取得
        current_branch=$(git rev-parse --abbrev-ref HEAD)

        # main に限定
        if [ "$current_branch" = "main" ]; then
            # origin があれば pull & push
            if git remote | grep -q "^origin$"; then
                echo "Updating origin (branch main)..."
                git pull origin main --no-rebase
                git push origin main
            fi

            # upstream があれば pull のみ
            if git remote | grep -q "^upstream$"; then
                echo "Updating upstream (branch main)..."
                git pull upstream main --no-rebase
            fi
        else
            echo "Skipping (branch is $current_branch, not main)"
        fi
    fi
done


