gpl() {
  local msg="$1"
  if [ -z "$msg" ]; then
    echo "Usage: gpl \"commit message\" (default: Auto Commit)"
    msg="Auto Commit"
  fi

  git add .
  git commit -m "$msg"

if git remote get-url upstream >/dev/null 2>&1; then
    git pull --no-rebase upstream main
fi

# origin が存在しない場合は return
if ! git remote get-url origin >/dev/null 2>&1; then
    return
fi  
# Run pull without rebase
  if git pull --no-rebase; then
    # Check if the last commit is a merge commit
    if git log -1 --pretty=%B | grep -q '^Merge'; then
      echo "Merge commit detected. Please check the status."
      git status
    else
	# Only origin main is allowed    
      git push origin main
    fi
  else
    echo "git pull failed."
    git status
  fi
}
