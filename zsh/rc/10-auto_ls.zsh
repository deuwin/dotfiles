# auto-ls
# automatically list directory contents on directory change
# 
# Notes:
# use `cd -q`, `pushd -q`, or `popd -q` to change directories in aliases or
# functions without invoking chpwd hooks
#

_impure_auto_ls_chpwd() {
    local ls_cmd=${aliases[ls]:-ls}
    local ls_lines=(
        ${(f@)"$(script --quiet --command $ls_cmd --log-out /dev/null)"})
    local ls_height=${#ls_lines}
    if ((ls_height > LINES / 2)); then
        print "Auto-ls output suppressed"
    elif ((ls_height == 0)); then
        print "Empty directory"
    else
        print -l -- $ls_lines
    fi
}

autoload -Uz add-zsh-hook
add-zsh-hook chpwd _impure_auto_ls_chpwd

