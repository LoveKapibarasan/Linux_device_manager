#!/bin/bash


extensions=(
  "vscodevim.vim"
  "tomoki1207.pdf"
  "shd101wyy.markdown-preview-enhanced"
  "james-yu.latex-workshop"
  "github.copilot"
  "github.copilot-chat"
)

for ext in "${extensions[@]}"; do
  echo "Installing $ext ..."
  code --install-extension "$ext"
done

# VSCode
jq --arg path "$HOME/.vimrc" \
   '.vim.vimrc.path = $path
    | .vim.vimrc.enable = true
    | .files.autoSave = "afterDelay"' \
   ~/.config/Code/User/settings.json > /tmp/settings.json && \
mv /tmp/settings.json ~/.config/Code/User/settings.json
