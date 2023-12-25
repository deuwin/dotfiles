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

    # background jobs
    typeset -g _impure_bg_jobs
    print -Pv _impure_bg_jobs '%(1j. ✦%j.)'
}

_impure_generate_prompt() {
    # Must be first lest it be overwritten
    local exit_code=$?

    # user and host name
    # [ -n ${SSH_CONNECTION} ] && local ps1='%F{246}%n%F{grey}@%F{green}%m'
    local user_host='%F{246}%n%F{grey}@%F{green}%m%F{white}:'

    # git info
    if ! $_IMPURE_GIT_INFO_RPROMPT; then
        local git_info="$_impure_git_prompt"
    fi

    # background jobs
    local bg_jobs='%F{cyan}'$_impure_bg_jobs

    # command execution time
    local exec_time='%F{yellow}'$_impure_exec_time

    # current working directory - this will be truncated if needed
    # regex to remove elements that take no space (i.e. strip formatting)
    local zero_len='%([BSUbfksu]|([FB]|){*})'
    local user_host_width=${#${(S%)user_host//$~zero_len/}}
    local git_info_width=${#${(S%)git_info//$~zero_len/}}
    local bg_jobs_width=${#${(S%)bg_jobs//$~zero_len/}}
    local exec_time_width=${#${(S%)exec_time//$~zero_len/}}

    local path_len_max=$((
        COLUMNS
        - user_host_width
        - git_info_width
        - bg_jobs_width
        - exec_time_width
        - 3)) # 3 for visible newline character
    local path_tail='%F{blue}%'$path_len_max'<…<%(4c:…/:)%3~%<<'

    # dynamic multiline prompt
    # construct prompt before any potential newline split
    local ps1="${user_host}${path_tail}${git_info}${bg_jobs}${exec_time}"
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
