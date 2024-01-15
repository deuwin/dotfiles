# auto-ls
# automatically list directory contents if the prompt working directory has
# changed since the previous command

_impure_auto_ls_preexec() {
    typeset -g _impure_auto_ls_cwd=$PWD
}

_impure_auto_ls_precmd() {
    if [[ -n $_impure_auto_ls_cwd ]] && [[ $_impure_auto_ls_cwd != $PWD ]]; then
        local ls_cmd=${aliases[ls]:-ls}
        local ls_lines=(
            ${(f@)"$(script --quiet --command $ls_cmd --log-out /dev/null)"})
        local ls_height=${#ls_lines}
        if ((ls_height > LINES / 2)); then
            print "Auto-ls output suppressed"
        elif ((ls_height == 0)); then
            print "Empty directory"
        else
            print -l ${ls_lines[@]}
        fi
        unset _impure_auto_ls_cwd
    fi
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd _impure_auto_ls_precmd
add-zsh-hook preexec _impure_auto_ls_preexec

