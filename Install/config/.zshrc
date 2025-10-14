HISTFILE=~/.histfile 
HISTSIZE=10
SAVEHIST=10
autoload -Uz compinit
compinit

export EDITOR=nvim
export VISUAL=nvim
export PATH="$(ls -d /usr/local/texlive/*/bin/x86_64-linux | tail -1):$PATH"
export PATH="/usr/local/texlive/*/bin/x86_64-linux:$PATH"
