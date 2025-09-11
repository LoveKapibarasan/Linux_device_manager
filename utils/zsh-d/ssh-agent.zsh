# ssh-agent 起動と鍵登録
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    eval "$(ssh-agent -s)"
else
    export SSH_AUTH_SOCK=$(find /tmp/ -type s -name 'agent.*' -user $USER 2>/dev/null | head -n 1)
fi

ssh-add -l > /dev/null 2>&1
if [ $? -ne 0 ]; then
    ssh-add ~/.ssh/id_ed25519
fi
