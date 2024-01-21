# Initialise ssh-agent
#
# https://web.archive.org/web/20210506080335/https://mah.everybody.org/docs/ssh
# https://stackoverflow.com/questions/18880024/start-ssh-agent-on-login
#
() {
    local ssh_env="$HOME/.ssh/environment"

    start_ssh_agent() {
        ssh-agent | sed 's/^echo/#echo/' > "${ssh_env}" || {
            echo "Failed to start SSH Agent!"
            return
        }
        chmod --changes 600 "${ssh_env}"
        source "${ssh_env}" > /dev/null
    }

    if [ -f "${ssh_env}" ]; then
        source "${ssh_env}" > /dev/null
        ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
            start_ssh_agent;
        }
    else
        start_ssh_agent;
    fi
}

unfunction start_ssh_agent
