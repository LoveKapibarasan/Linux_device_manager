gpl() {
  if [ -z "$1" ]; then
    echo "Usage: gpl \"commit message\""
    
  fi

  git add .
  git commit -m "$1"

  # Run pull without rebase
  if git pull --no-rebase; then
    # Check if the last commit is a merge commit
    if git log -1 --pretty=%B | grep -q '^Merge'; then
      echo "Merge commit detected. Please check the status."
      git status
    else
      git push
    fi
  else
    echo "git pull failed."
    git status
  fi
}
