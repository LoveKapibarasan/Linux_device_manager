# NVM 設定
export NVM_DIR="$HOME/.nvm"

if [ -s /usr/share/nvm/init-nvm.sh ]; then
    source /usr/share/nvm/init-nvm.sh
elif [ -s "$NVM_DIR/nvm.sh" ]; then
    source "$NVM_DIR/nvm.sh"
fi
