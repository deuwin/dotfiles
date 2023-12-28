# Initialise ssh-agent
#
# https://web.archive.org/web/20210506080335/https://mah.everybody.org/docs/ssh
# https://stackoverflow.com/questions/18880024/start-ssh-agent-on-login
#
SSH_ENV="$HOME/.ssh/environment"

start_ssh_agent() {
    ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}" || {
        echo "Failed to start SSH Agent!"
        return
    }
    chmod --changes 600 "${SSH_ENV}"
    source "${SSH_ENV}" > /dev/null
}

if [ -f "${SSH_ENV}" ]; then
    source "${SSH_ENV}" > /dev/null
    ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
        start_ssh_agent;
    }
else
    start_ssh_agent;
fi

unfunction start_ssh_agent
unset SSH_ENV
