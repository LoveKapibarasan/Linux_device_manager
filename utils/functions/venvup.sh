venvup() {
  if [ ! -d ".venv" ] && [ -f "requirements.txt" ]; then
    python -m venv .venv
    source .venv/bin/activate
    pip install --upgrade pip
    pip install -r requirements.txt
  elif [ -d ".venv" ];then
    source .venv/bin/activate
  else
    echo "Requirements.txt is missing?"
  fi
}
