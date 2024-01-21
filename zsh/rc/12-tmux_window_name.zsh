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

_impure:wn:is_active_pane() {
    [[ $TMUX_PANE == \
        $(tmux list-panes \
            -t $IMPURE_RENAME_TARGET \
            -f "#{pane_active}" \
            -F "#{pane_id}") ]]
}

_impure:wn:is_option_set() {
    # $1 - tmux option name
    # $2 - scope: pane, window, etc (optional)
    [[ -n $(tmux show-options -qv$2 -t $TMUX_PANE $1) ]]
}

####
# set_name
# Renames window if the pane is active and hasn't been set by the user. New name
# is saved in case it is needed by change pane hook or if the user's window name
# is cleared
_impure:wn:set_name() {
    if [[ -n $TMUX ]]; then
        _impure:wn:set_name() {
            tmux set-option -p -t $TMUX_PANE "@impure_window_name" "$1"
            if _impure:wn:is_active_pane && \
              ! _impure:wn:is_option_set @iwn_user w; then
                tmux \
                    set-option -w "@iwn_script" "true" \; \
                    rename-window -t "$IMPURE_RENAME_TARGET" "$1"
            fi
        }
    else
        _impure:wn:set_name() {
            print -n "\e]0;$1\a"
        }
    fi
    _impure:wn:set_name "$1"
}

####
# set name while command is running
#
# Notes:
# If one runs `tmux split-window <cmd>` i.e. running a command in a pane without
# invoking the shell, then the window name is blank. A bit of a corner case as I
# basically never do that.
#
# fg resumption isn't foolproof and will show the command being run instead of
# the alias (if it was initially called with one)
#
_impure:wn:preexec() {
    local cmd_full=(${(z)1})
    local cmd_idx=1
    local sudo cmd arg dir
    local match mbegin mend

    # check for special commands:
    #   `r` for repeat
    #   `fg` resume background command
    if [[ $cmd_full == "r" ]]; then
        cmd_full=(${(z)$(fc -nl -1)})
    elif [[ $cmd_full == fg ]]; then
        cmd_full=($jobtexts[%+])
    fi

    # using sudo?
    if [[ $cmd_full[1] == "sudo" ]]; then
        sudo="sudo "
        ((cmd_idx++))
    fi

    # command
    cmd=$cmd_full[$cmd_idx]

    # show first argument?
    local show_args="apt|git|nala|man"
    if [[ $cmd =~ $show_args ]]; then
        arg=" $cmd_full[$((cmd_idx + 1))]"
    fi

    # show directory command was run in?
    local show_dir="n?vim|rf([[:lower:]]+)?|rg([[:lower:]]+)?|fd([[:lower:]]+)?"
    if [[ $cmd =~ $show_dir ]]; then
        _impure:wn:set_name \
            "$(print -P "$sudo$cmd$arg:%$IMPURE_WINDOW_NAME_LIMIT<…<%3~%")"
    else
        _impure:wn:set_name "$sudo$cmd$arg"
    fi
}

####
# set name when at command prompt
#
_impure:wn:precmd() {
    # clear the pane title in case it was set by a running program
    print -n "\e]2;\e\\"
    _impure:wn:set_name "$(print -P "zsh:%$IMPURE_WINDOW_NAME_LIMIT<…<%3~%")"
}

####
# setup
#
set_tmux_options() {
    local options_set="@iwn_options_set"
    if _impure:wn:is_option_set $options_set g; then
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
            'rename-window "#{@impure_window_name}"' \
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
        tmux set-hook -ag $hook $cmd
    done
    tmux set-option -g $options_set "true"
}

() {
    if [[ -n $TMUX ]]; then
        set_tmux_options
        export IMPURE_RENAME_TARGET=$(\
            tmux display-message -p "#{window_id}")
        export IMPURE_WINDOW_NAME_LIMIT=20
    fi

    # add zsh hooks
    add-zsh-hook preexec _impure:wn:preexec
    add-zsh-hook precmd _impure:wn:precmd

    # clean up
    unfunction set_tmux_options
}
