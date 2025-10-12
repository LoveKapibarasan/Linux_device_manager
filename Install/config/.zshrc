HISTFILE=~/.histfile 
HISTSIZE=10
SAVEHIST=10
autoload -Uz compinit
compinit

export EDITOR=nvim
export VISUAL=nvim
export PATH="/usr/local/texlive/*/bin/x86_64-linux:$PATH"
