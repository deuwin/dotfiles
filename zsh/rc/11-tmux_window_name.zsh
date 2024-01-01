####
# tmux window name
#
# Inspired by tmux-window-name (https://github.com/ofirgall/tmux-window-name)
# this script sets the names of tmux windows using the current running command
# and directory.
#
# The main difference is that this uses zsh hooks to trigger name changes, which
# offers immediate response to command, directory, and pane changes. It also
# allows the window name to display user aliases.
#
# If tmux is not active the title of the terminal emulator is updated using the
# same rules as for tmux window names.
#

####
# set name
# function defines itself depending on if this zsh instance is within a tmux
# session
#
_impure_window_name_set() {
    if [[ -n $TMUX ]]; then
        _impure_window_name_set() {
            # store new name
            tmux set-option -p "@impure_window_name" "$1"
            # check if set by user
            if [[ -z $(tmux display-message -p "#{@iwn_user}") ]]; then
                tmux \
                    set-option -w "@iwn_script" "true" \; \
                    rename-window "$1"
            fi
        }
    else
        _impure_window_name_set() {
            print -n "\e]0;$1\a"
        }
    fi
    _impure_window_name_set "$1"
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
    local active_hooks=(${(f)"$(tmux show-hooks -gw $1)"})
    local index
    if [[ ${active_hooks[-1]} =~ "\[([[:digit:]]+)\]" ]]; then
        index=$((match + 1))
    else
        index=0
    fi
    print $index
}

set_tmux_options() {
    local options_set="@iwn_options_set"
    if [[ -n $(tmux display-message -p "#{$options_set}") ]]; then
        return
    fi

    # disallow programs running in panes to set window names and
    # disable tmux automatic renaming
    tmux \
        set-option -g allow-rename off \; \
        set-option -g automatic-rename off

    local -A hooks

    # update the title when the pane changes, unless it has been set by the user
    print -v "hooks[window-pane-changed]" \
        'if-shell -F "#{@iwn_user}" {'\
        '}{' \
            'rename-window "#{@impure_window_name}";' \
        '}'

    # check if the rename event was trigged by the user or the script and
    # restore the generated name if the user has cleared their custom name
    print -v "hooks[window-renamed]" \
        'if-shell -F "#{@iwn_script}" {' \
            'set-option -w "@iwn_script" ""' \
        '}{' \
            'if-shell -F "#{window_name}" {' \
                'set-option -w "@iwn_user" "true"' \
            '}{' \
                'set-option -w "@iwn_user" "";' \
                'rename-window "#{@impure_window_name}";' \
            '}' \
        '}'

    local hook cmd index
    for hook cmd in ${(kv)hooks[@]}; do
        index=$(get_free_hook_index $hook)
        tmux set-hook -g $hook"["$index"]" "$cmd"
    done
    tmux set-option -g $options_set "true"
}

() {
    if [[ -n $TMUX ]]; then
        set_tmux_options
    fi

    # add zsh hooks
    add-zsh-hook preexec _impure_window_name_preexec
    add-zsh-hook precmd _impure_window_name_precmd

    # clean up
    unfunction set_tmux_options
    unfunction get_free_hook_index 
}
