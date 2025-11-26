HISTFILE=~/.histfile 
HISTSIZE=1000
SAVEHIST=1000
autoload -Uz compinit
compinit

export TERMINAL=alacritty
export BROWSER=qutebrowser
export EDITOR=nvim
export VISUAL=nvim
export PATH="$(ls -d /usr/local/texlive/*/bin/x86_64-linux | tail -1):$PATH"

if [ -f ~/.shellrc ]; then
  source ~/.shellrc
else
  echo "~/.shellrc not found"
fi

alias hsc1='hyprctl keyword monitor DP-1,preferred,auto,1.0'
alias hsc2='hyprctl keyword monitor DP-1,preferred,auto,2.0'
alias avante='nvim -c "lua vim.defer_fn(function()require(\"avante.api\").zen_mode()end, 100)"'