# tweak fzf-git
#   - remove browser shortcut
#   - use delta to render diffs if available
if is_function _fzf_git_files; then
    _fzf_git_files() {
        local gdiff="git diff --no-ext-diff --color=always -- {-1} | "
        () {
            if command -v delta > /dev/null; then
                gdiff+="delta"
            else
                gdiff+="sed 1,4d"
            fi
        }

        _fzf_git_check || return
        (
            git -c color.status=always status --short
            git ls-files --others \
                | grep --invert-match --line-regexp --fixed-strings \
                    --file=<(
                        git status --short | grep '^[^?]' | cut -c4-; echo :) \
                | sed 's/^/   /'
        ) | \
            _fzf_git_fzf --multi --ansi --nth 2..,.. \
                --border-label "📁 Files" \
                --header "ALT-E (open in editor)"$'\n\n' \
                --bind "alt-e:execute:${EDITOR:-vim} {-1} > /dev/tty" \
                --preview "$gdiff; $_fzf_git_cat {-1}" "$@" \
                | cut -c4- | sed 's/.* -> //'
    }
fi
