#!/usr/bin/env zsh

# Impure
#
# with ideas stolen/borrowed from:
#    https://github.com/Phantas0s/purification
#    https://github.com/therealklanni/purity
#    https://github.com/vincentbernat/zshrc
#    https://ruderich.org/simon/config/zshrc
#    https://vincent.bernat.ch/en/blog/2019-zsh-async-vcs-info
#

_impure_preexec() {
    typeset -g _impure_cmd_start=$EPOCHSECONDS
}

_impure_precmd() {
    # clear terminal emulator title, let tmux handle setting it
    print -Pn "\e]2\a"

    # execution time
    typeset -g _impure_exec_time=""
    if [[ -n $_impure_cmd_start ]]; then
        local exec_time=$((EPOCHSECONDS - _impure_cmd_start))
        if ((exec_time > 3)); then
            local d=$((exec_time / 86400))
            local h=$((exec_time / 3600 % 24))
            local m=$((exec_time / 60 % 60))
            local s=$((exec_time % 60))
            ((d > 0)) && _impure_exec_time+=" ${d}d"
            ((h > 0)) && _impure_exec_time+=" ${h}h"
            ((m > 0)) && _impure_exec_time+=" ${m}m"
            _impure_exec_time+=" ${s}s"
        fi
        unset _impure_cmd_start
    fi
}

_impure_generate_prompt() {
    # Must be first lest it be overwritten
    local exit_code=$?

    # user and host name
    # [ -n ${SSH_CONNECTION} ] && local ps1='%F{246}%n%F{grey}@%F{green}%m'
    local ps1='%F{246}%n%F{grey}@%F{green}%m'

    # current working directory
    ps1+='%F{white}:%F{blue}%(4c:…/:)%3~'

    # git info
    if ! $_IMPURE_GIT_INFO_RPROMPT; then
        ps1+="$_impure_git_prompt"
    fi

    # background jobs
    ps1+='%(1j. %F{cyan}✦%j.)'

    # command execution time
    ps1+='%F{yellow}'$_impure_exec_time

    # dynamic multiline prompt
    # regex to remove elements that take no space (i.e. strip formatting)
    local zero_len='%([BSUbfksu]|([FB]|){*})'
    local ps1_len=${#${(S%)ps1//$~zero_len/}}
    local exit_code_space=" "
    if ((ps1_len > COLUMNS / 2)); then
        ps1+="%F{default} "$'\u21B5\n'
        exit_code_space=""
    fi

    # exit status content and colour. Prompt character changes colour on error
    if ((exit_code)); then
        ps1+=$exit_code_space'%F{red}✗'$exit_code
    else
        ps1+='%F{grey}'
    fi

    # prompt character
    ps1+='⟫%f '

    print $ps1
}

_impure_generate_rprompt() {
    print $_impure_git_rprompt
}

# setup
_impure_setup() {
    # Expand parameters, commands, and arithmetic in PROMPT
    setopt prompt_subst

    # expose $EPOCHDATETIME
    zmodload zsh/datetime

    # hooks
    autoload -Uz add-zsh-hook
    add-zsh-hook precmd _impure_precmd
    add-zsh-hook preexec _impure_preexec

    PROMPT='$(_impure_generate_prompt)'
    if $_IMPURE_GIT_INFO_RPROMPT; then
        RPROMPT='$(_impure_generate_rprompt)'
    fi
}

source $ZDOTDIR/prompt/impure_git.zsh
_impure_setup
