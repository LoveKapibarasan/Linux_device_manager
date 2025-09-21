SSH_ENV="$HOME/.ssh/agent_env"

function start_agent {
    eval "$(ssh-agent -s)" > "$SSH_ENV"
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

ssh-add -q ~/.ssh/id_rsa < /dev/null


