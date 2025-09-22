
SSH_ENV="$HOME/.ssh/agent_env"

function start_agent {
    ssh-agent -s > "$SSH_ENV"
    chmod 600 "$SSH_ENV"
    . "$SSH_ENV" > /dev/null
}

if [ -f "$SSH_ENV" ]; then
    . "$SSH_ENV" > /dev/null
    # エージェントが死んでたら再起動
    if ! kill -0 "$SSH_AGENT_PID" 2>/dev/null; then
        start_agent
    fi
else
    start_agent
fi

# 秘密鍵をまだ追加していない場合だけ追加
for key in ~/.ssh/id_rsa ~/.ssh/id_ed25519; do
    if [ -f "$key" ]; then
        ssh-add -l 2>/dev/null | grep -q "$(ssh-keygen -lf "$key" | awk '{print $2}')" || ssh-add "$key"
    fi
done



