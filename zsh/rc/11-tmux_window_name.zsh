####
# tmux window name
#
# Inspired by tmux-window-name (https://github.com/ofirgall/tmux-window-name)
# this script sets the names the tmux windows using the current running command
# and directory.
#
# The main difference is that this uses zsh hooks to trigger name changes, which
# offers immediate response to command, directory, and pane changes. It also
# allows the window name to display user aliases.
#
if [[ -z $TMUX ]]; then
    return
fi

_impure_window_name_set() {
    # store new name
    tmux set-option -p "@impure_window_name" "$1"

    # check if set by user
    if [[ -z $(tmux display-message -p "#{@impure_window_name_user}") ]]; then
        tmux set-option -w "@impure_window_name_script" "true"
        print -n "\ek$1\e\\"
        tmux set-option -w "@impure_window_name_script" ""
    fi
}

####
# set name while command is running
#
_impure_window_name_preexec() {
    local cmd_full=(${(z)1})
    local cmd_idx=1 name=""

    # using sudo?
    if [[ $cmd_full[1] == "sudo" ]]; then
        name="sudo "
        ((cmd_idx++))
    fi

    # some commands have subcommands that we also wish to show
    local subcommand=(apt git nala)
    if ((subcommand[(Ie)${cmd_full[$cmd_idx]}])); then
        name+="${cmd_full[$cmd_idx]} "
        ((cmd_idx++))
    fi
    name+=$cmd_full[$cmd_idx]

    # path
    name+=$(print -P ':%1~')

    _impure_window_name_set $name
}

####
# set name when at command prompt
#
_impure_window_name_precmd() {
    # clear the pane title in case it was set by a running program
    print -n "\e]2;\e\\"

    _impure_window_name_set $(print -P "zsh:%1~")
}

####
# setup
#
get_free_hook_index() {
    local hooks_set=(${(f)"$(tmux show-hooks -gw $1)"})
    local index
    if [[ ${hooks_set[-1]} =~ "\[([[:digit:]]+)\]" ]]; then
        index=$((match + 1))
    else
        index=0
    fi
    print $index
}

set_tmux_hooks() {
    local set_flag="@impure_window_name_hooks_set"
    if [[ -n $(tmux display-message -p "#{$set_flag}") ]]; then
        return
    fi

    local -A hooks

    # update the title when the pane changes, unless it has been set by the user
    print -v "hooks[window-pane-changed]" \
        'if-shell -F "#{@impure_window_name_user}" {'\
        '}{' \
            'rename-window "#{@impure_window_name}";' \
        '}'

    # checks if the rename event was trigged by the user or the script and
    # restores the generated name if the user clears their custom name
    print -v "hooks[window-renamed]" \
        'if-shell -F "#{@impure_window_name_script}" {' \
            'set-option -w "@impure_window_name_script" ""' \
        '}{' \
            'if-shell -F "#{window_name}" {' \
                'set-option -w "@impure_window_name_user" "true"' \
            '}{' \
                'set-option -w "@impure_window_name_user" "";' \
                'rename-window "#{@impure_window_name}";' \
            '}' \
        '}'

    local hook cmd index
    for hook cmd in ${(kv)hooks[@]}; do
        index=$(get_free_hook_index $hook)
        tmux set-hook -g $hook"["$index"]" "$cmd"
    done
    tmux set-option -g $set_flag "true"
}

() {
    # allow programs running in panes to set window names
    # disable tmux automatic renaming
    tmux \
        set-option -g allow-rename on\; \
        set-option -g automatic-rename off
    set_tmux_hooks

    # initial flag values
    tmux \
        set-option -w "@impure_window_name_script" "" \; \
        set-option -w "@impure_window_name_user" \
            "$(tmux display-message -p '#{@impure_window_name_user}')"

    # add hooks
    add-zsh-hook preexec _impure_window_name_preexec
    add-zsh-hook precmd _impure_window_name_precmd

    # clean up
    unfunction set_tmux_hooks
    unfunction get_free_hook_index 
}
