#!/usr/bin/env zsh

# Impure Git Repository Information
#
# with ideas stolen/borrowed from:
#    https://github.com/therealklanni/purity
#    https://github.com/sindresorhus/pure
#    https://github.com/vincentbernat/zshrc
#    https://github.com/zsh-users/zsh/blob/master/Misc/vcs_info-examples
#

# TODO
#   could probably tweak _impure_git_get_extra_info to be faster
#

####
# Appearance
#
readonly _IMPURE_NUMBERED_INDICATORS=true
readonly _IMPURE_GIT_INFO_RPROMPT=false

# Uncomment to remove rprompt after a command is run
# setopt transient_rprompt

typeset -rgA _ig_formats=(
    [bracket]=%F{default}
    [repo_name]=%F{default}
    [branch]=%F{5}
    [misc]=%F{green}
    [action]=%F{cyan}
)

typeset -rgA _ig_symbols=(
    [branch]=%F{208}
    [staged]=%F{green}∆
    [unstaged]=%F{166}∆
    [untracked]=%F{yellow}?
    [stashed]=%F{cyan}≡
    [behind]=%F{red}⇣
    [ahead]=%F{green}⇡
    [deleted]=%F{red}✗
    [renamed]=%F{166}»
)

####
# Debugging
#
_impure_async_bug() {
    # should never happen but if it does you prolly should report it
    # https://github.com/mafredri/zsh-async#async_process_results-worker_name-callback_function
    print "\e[38;5;1mImpure Async Bug\e[0m" >&2
    print "$funcstack" >&2
}

####
# Async helpers
#

# to prevent background processes interfering with user commands
# https://git-scm.com/docs/git#Documentation/git.txt-codeGITOPTIONALLOCKScode
_impure_git() {
    git --no-optional-locks $@
}

_impure_git_append() {
    # format=$1 count=$2
    if $_IMPURE_NUMBERED_INDICATORS; then
        _impure_git_append() {
            local msg=""
            (($2)) && msg="$1" && (($2 > 1)) && msg+="$2"
            print $msg
        }
    else
        _impure_git_append() {
            (($2)) && print $1
        }
    fi
    _impure_git_append $@
}

if $_IMPURE_GIT_INFO_RPROMPT; then
    typeset -g _impure_git_rprompt
    _impure_git_render_info() {
        if [ -z $1 ]; then
            _impure_git_rprompt=""
            return
        fi

        _impure_git_rprompt="${_ig_formats[bracket]}["
        _impure_git_rprompt+="$_ig_formats[repo_name]$_ig_vcs_info[repo_name]"
        _impure_git_rprompt+=" $_ig_symbols[branch]"
        _impure_git_rprompt+=" $_ig_formats[branch]$_ig_vcs_info[branch]"
        [[ -n $_ig_vcs_info[action] ]] && \
            _impure_git_rprompt+=" $_ig_formats[action]$_ig_vcs_info[action]"
        [[ -n $_ig_change_info ]] && \
            _impure_git_rprompt+=" $_ig_change_info"
        _impure_git_rprompt+="${_ig_formats[bracket]}]"
    }
else
    typeset -g _impure_git_prompt
    _impure_git_render_info() {
        _impure_git_prompt=""
        if [ -z $1 ]; then
            return
        fi

        [[ $1 != $_ig_vcs_info[repo_name] ]] && \
            _impure_git_prompt+=" $_ig_formats[repo_name]$_ig_vcs_info[repo_name]"
        _impure_git_prompt+=" $_ig_symbols[branch]"
        _impure_git_prompt+=" $_ig_formats[branch]$_ig_vcs_info[branch]"
        [[ -n $_ig_vcs_info[action] ]] && \
            _impure_git_prompt+=" $_ig_formats[action]$_ig_vcs_info[action]"
        [[ -n $_ig_change_info ]] && \
            _impure_git_prompt+=" ${_ig_formats[bracket]}[" && \
            _impure_git_prompt+="$_ig_change_info" && \
            _impure_git_prompt+="${_ig_formats[bracket]}]"
    }
fi

_impure_git_update_prompt() {
    if [[ $_ig_prev_vcs_info == $_ig_vcs_info ]] && \
       [[ $_ig_prev_change_info == $_ig_change_info ]]; then
        return
    fi

    _impure_git_render_info $_ig_vcs_info[cwd]
    zle reset-prompt
}

_impure_git_get_info() {
    cd -q $1
    vcs_info

    typeset -A msg
    msg[cwd]=${1:t}
    msg[repo_name]=$vcs_info_msg_0_
    msg[branch]=$vcs_info_msg_1_
    msg[action]=$vcs_info_msg_2_
    msg[misc]=$vcs_info_msg_3_

    # for k v in ${(@kv)msg}; do
    #     _impure_debug "msg: $k -> $v"
    # done

    print -r "${(@qkv)msg}"
}

_impure_git_get_extra_info() {
    cd -q $1

    # grab status
    local git_status
    git_status="$(_impure_git status --porcelain 2> /dev/null)" || return 1

    local msg=""

    # behind/ahead
    local -a ahead_behind=(
        $(_impure_git rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)
    )
    msg+=$(_impure_git_append ${_ig_symbols[behind]} ${ahead_behind[2]})
    msg+=$(_impure_git_append ${_ig_symbols[ahead]} ${ahead_behind[1]})

    # staged - renamed and deleted files count as a staged change
    local count
    count=$(grep --count -E "^(A  )|(R  )|(M. )|(D  )" <<< $git_status)
    msg+=$(_impure_git_append ${_ig_symbols[staged]} $count)

    # unstaged
    count=$(grep --count "^.M " <<< $git_status)
    msg+=$(_impure_git_append ${_ig_symbols[unstaged]} $count)

    # deleted - counts deletions in staged and unstaged
    count=$(grep --count -E "^( D )" <<< $git_status)
    msg+=$(_impure_git_append ${_ig_symbols[deleted]} $count)

    # stashed
    count=$(_impure_git rev-list --walk-reflogs --count refs/stash 2> /dev/null)
    msg+=$(_impure_git_append ${_ig_symbols[stashed]} $count)

    # untracked
    count=$(grep --count "^?? " <<< $git_status)
    msg+=$(_impure_git_append ${_ig_symbols[untracked]} $count)

    print $msg
}

_impure_git_callback() {
    local job_name=$1 return_code=$2 stdout=$3 stderr=$5 more=$6
    # local exec_time=$4

    [[ -n $stderr ]] && _impure_error "$job_name: $stderr"

    # hopefully won't happen
    ((return_code == -1)) && _impure_async_bug && return

    case $job_name in
        "[async]")
            if ((return_code == 2)) || ((return_code == 3)) || ((return_code == 130)) ; then
                _impure_warning "Worker restart: $return_code"
                async_stop_worker impure_git_status
                _impure_git_start_async
                return
            fi
            ;;
        "_impure_git_get_info")
            typeset -Ag _ig_vcs_info _ig_prev_vcs_info
            _ig_prev_vcs_info=$_ig_vcs_info
            _ig_vcs_info=("${(@Q)${(z)stdout}}")
            ;;
        "_impure_git_get_extra_info")
            typeset -g _ig_change_info _ig_prev_change_info
            _ig_prev_change_info=$_ig_change_info
            _ig_change_info=$stdout
            ;;
    esac

    # no more updates? refresh prompt
    ((more)) || _impure_git_update_prompt
}

_impure_git_start_async() {
    async_start_worker impure_git_status
    async_register_callback impure_git_status _impure_git_callback
}

####
# Hooks
#
_impure_git_precmd() {
    if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
        _impure_git_render_info ${PWD:t}
        async_flush_jobs impure_git_status
        async_job impure_git_status _impure_git_get_info $PWD
        async_job impure_git_status _impure_git_get_extra_info $PWD
    else
        _impure_git_render_info
    fi
}

####
# Setup
#
_impure_git_setup() {
    # initialise version control monitoring
    autoload -Uz vcs_info
    zstyle ":vcs_info:*" enable git
    zstyle ":vcs_info:*" use-simple
    # zstyle ":vcs_info:*+*:*" debug true

    # no idea what misc info git provides here, so let's just leave it in and see
    zstyle ":vcs_info:*"     max-exports   4
    zstyle ":vcs_info:git:*" formats       "%r" "%b" "%a" "%m"
    zstyle ":vcs_info:git:*" actionformats "%r" "%b" "%a" "%m"

    # asynchronous VCS status
    source $ZDOTDIR/third_party/zsh-async/async.zsh
    async_init
    _impure_git_start_async
    autoload -Uz add-zsh-hook
    add-zsh-hook precmd _impure_git_precmd
}
_impure_git_setup
