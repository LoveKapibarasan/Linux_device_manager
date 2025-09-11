venvup() {
  if [ ! -d "venv" ] && [ -f "requirements.txt" ]; then
    python -m venv venv
    source venv/bin/activate
    pip install --upgrade pip
    pip install -r requirements.txt
  else
    source venv/bin/activate
  fi
}