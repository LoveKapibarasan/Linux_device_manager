#!/bin/bash


extensions=(
  "vscodevim.vim"
  "tomoki1207.pdf"
  "shd101wyy.markdown-preview-enhanced"
)

for ext in "${extensions[@]}"; do
  echo "Installing $ext ..."
  code --install-extension "$ext"
done

