rand() {
  local length="${1:-16}"     # 1st arg: length (default 16)
  local mode="${2:-y}"        # 2nd arg: y=alphanumeric only, n=include symbols (default y)

  if [[ "$mode" == "y" ]]; then
    tr -dc "A-Za-z0-9" < /dev/urandom | head -c "$length"
  else
    tr -dc "A-Za-z0-9!@#$%^&*()_+=-[]{};:,.<>/?" < /dev/urandom | head -c "$length"
  fi
  echo
}