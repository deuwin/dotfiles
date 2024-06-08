# tweak fzf-git
#   - remove browser shortcut
#   - use delta to render diffs if available
if is_function _fzf_git_files; then
    _fzf_git_files() {
        _fzf_git_check || return
        local root query
        root=$(git rev-parse --show-toplevel)
        [[ $root != "$PWD" ]] && query='!../ '

        local gdiff="git diff --no-ext-diff --color=always -- {-1} | "
        if command -v delta > /dev/null; then
            gdiff+="delta"
        else
            gdiff+="sed 1,4d"
        fi

        (
            git -c color.status=$(__fzf_git_color) status --short --no-branch
            git ls-files "$root" \
                | grep -vxFf <(git status -s | grep '^[^?]' | cut -c4-; echo :) \
                | sed 's/^/   /'
        ) \
            | _fzf_git_fzf -m --ansi --nth 2..,.. \
                --border-label '📁 Files' \
                --header $'ALT-E (open in editor)\n\n' \
                --bind "alt-e:execute:${EDITOR:-vim} {-1} > /dev/tty" \
                --query "$query" \
                --preview "$gdiff; $(__fzf_git_cat) {-1}" "$@" \
                | cut -c4- | sed 's/.* -> //'
    }
fi
