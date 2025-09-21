# ssh-agent 起動と鍵登録
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
    eval "$(ssh-agent -s)" > /dev/null
fi

ssh-add -q ~/.ssh/id_rsa < /dev/null

