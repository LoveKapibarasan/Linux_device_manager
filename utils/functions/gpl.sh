gpl() {
  local msg="$1"
  if [ -z "$msg" ]; then
    echo "Usage: gpl \"commit message\" (default: Auto Commit)"
    msg="Auto Commit"
  fi

  git add .
  git commit -m "$msg"

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
