#!/bin/bash


extensions=(
  "vscodevim.vim"
  "tomoki1207.pdf"
  "shd101wyy.markdown-preview-enhanced"
  "james-yu.latex-workshop"
  "github.copilot"
  "github.copilot-chat"
  "ms-python.python"
  "ms-python.vscode-pylance"
  "ms-python.debugpy"
  "ms-python.vscode-python-envs"
)

for ext in "${extensions[@]}"; do
  echo "Installing $ext ..."
  code --install-extension "$ext"
done

