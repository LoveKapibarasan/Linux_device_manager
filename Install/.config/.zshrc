HISTFILE=~/.histfile 
HISTSIZE=10
SAVEHIST=10
autoload -Uz compinit
compinit

export TERMINAL=alacritty
export BROWSER=qutebrowser
export EDITOR=nvim
export VISUAL=nvim
export PATH="$(ls -d /usr/local/texlive/*/bin/x86_64-linux | tail -1):$PATH"

# Variable expansion, environment variables are valid

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

export PATH="$HOME/Linux_device_manager/utils/scripts:$PATH"

# Alias settings
alias firefox=firefox --kiosk &
alias clip='wl-copy'
alias paste='wl-paste'
alias cp_before='fc -ln -1 | wl-copy'
alias open='xdg-open'

# Load Functions
for file in "$HOME/Linux_device_manager/utils/functions"
do
    if [ -f "$file" ]; then
        source "$file"
    fi
done
