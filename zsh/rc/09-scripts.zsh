#!/usr/bin/env zsh

####
# Scripts
#   ssh_agent.zsh - for ssh keys
#   fzf-git.sh    - https://github.com/junegunn/fzf-git.sh
#
typeset -a scripts=(
    ssh_agent.zsh
)
is_command fzf && scripts+=(fzf-git.sh/fzf-git.sh)

for s in "$scripts[@]"; do
    if [[ -f $ZSCRIPTS/$s ]]; then
        source $ZSCRIPTS/$s
    else
        _impure_warning "Could not source: $s"
    fi
done
unset scripts s

# Tweak fzf-git
if is_function _fzf_git_files; then
    _fzf_git_files() {
        local gdiff="git diff --no-ext-diff --color=always -- {-1} | "
        if command -v delta > /dev/null; then
            gdiff+="delta"
        else
            gdiff+="sed 1,4d"
        fi

        _fzf_git_check || return
        (
            git -c color.status=always status --short
            git ls-files --others | \
                grep --invert-match --line-regexp --fixed-strings \
                    --file=<(git status --short | grep '^[^?]' | cut -c4-;
                                echo :) | \
                sed 's/^/   /'
        ) | \
            _fzf_git_fzf --multi --ansi --nth 2..,.. \
                --border-label "📁 Files" \
                --header "ALT-E (open in editor)" \
                --bind "alt-e:execute:${EDITOR:-vim} {-1} > /dev/tty" \
                --preview "$gdiff; $_fzf_git_cat {-1}" "$@" |
            cut -c4- | sed 's/.* -> //'
    }
fi
