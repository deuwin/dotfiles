#!/usr/bin/zsh
set -e
pane_pid=$1
pane_cmd=$2

processes="$(ps --format stat=,pid=,args= --ppid ${pane_pid})"

fg_proc=(${(@f)$(awk 'ORS=" " { if ($0 !~ /^T|zsh$/) print $0 }' <<< $processes)})
if [[ -n ${fg_proc[2]} ]]; then
    print -nPv cmd "[%20>…>${fg_proc[3,-1]/#$HOME/~}%<<] ${fg_proc[2]}"
else
    cmd="[${pane_cmd}]"
fi

# get pids, remove foreground pid, and trim whitespace
bg_pids=${${(@f)$(awk 'ORS=" " {if ($0 !~ /zsh$/) print $2}' <<< $processes)}:#${fg_proc[2]}}

print -n "${cmd}"
[[ -n $bg_pids ]] && print -n " ($bg_pids)"

