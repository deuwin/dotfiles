#!/usr/bin/env zsh
set -e

# don't run if inside tmux
if [[ -n $TMUX ]]; then
    echo "Running inside tmux session! Exiting..."
    return 1
fi

# grab session info, run tmux on failure
session_format=$(printf "%s"\
    "#{session_id}:" \
    "#{session_name}:" \
    "#{session_windows}:" \
    "#{session_created}:" \
    "#{session_attached}:" \
    "#{session_activity}")
sessions=("${(@f)$(tmux list-sessions -F $session_format 2> /dev/null)}") || exec tmux

# only one? just attach
session_no=${#sessions[@]}
if [[ $session_no == 1 ]]; then
    exec tmux attach-session
fi

# create session options
typeset -a map_idx_name
option_idx=1
recent_idx=0
recent_time=0
session_table=""
for session in "${sessions[@]}"; do
    typeset -a session_info
    session_info=(${(@s<:>)session})

    # index/name mapping
    map_idx_name+=($session_info[1])

    # formatting
    session_table+="    $((option_idx)).\t"
    # session name, trimming the overly long
    session_table+="["$(echo "$session_info[2]" | sed 's|\(.\{25\}\).*|\1\\u2026|')"]\t"
    # number of windows
    session_table+="$session_info[3] window"
    if [[ $session_info[3] != 1 ]]; then
        session_table+="s"
    fi
    session_table+="\t"
    # creation date
    session_table+="(Created $(date -d @$session_info[4] +"%a %d %b %H:%M:%S %Z %Y"))"
    # attached state
    if [[ $session_info[5] == 1 ]]; then
        session_table+=" (attached)"
    elif [[ $recent_time -lt $session_info[6] ]]; then
        # candidate for default attach
        recent_time=$session_info[6]
        recent_idx=$option_idx
    fi
    session_table+="\n"
    ((option_idx++))
done

# display options
echo "tmux session select"
echo $session_table |\
    column --table --separator $'\t' --output-separator " "
echo "    $((option_idx++)). Create new session"
echo "    $((option_idx)). Shell without tmux"

# prompt user
input_prompt=$'\n'"Select 1-$((session_no + 3)) [$recent_idx]: "
read -r "input?$input_prompt"

# without input we'll use the shown default selection which is tmux's default,
# the most recent unattached session
if [[ -z $input ]]; then
    exec tmux attach-session
fi

# check input
if ! [[ $input =~ ^[0-9]+$ ]]; then
    echo "Invalid selection!"
    return 1
fi

# act on selection
if ((input > 0)) && ((input <= session_no)); then
    exec tmux attach-session -t $map_idx_name[$input]
elif ((input == session_no + 1)); then
    exec tmux new-session
fi

