#!/usr/bin/zsh
set -e
setopt extended_glob
pane_pid=$1
pane_cmd=$2

processes="$(ps --format stat=,pid=,args= --ppid ${pane_pid})"

fg_proc=(${(@f)$(awk 'ORS=" " { if ($0 !~ /^T|zsh$/) print $0 }' <<< $processes)})
if [[ -n ${fg_proc[2]} ]]; then
    print -nPv cmd "[%20>…>${fg_proc[3,-1]/#$HOME/~}%<<] ${fg_proc[2]}"
else
    cmd="[${pane_cmd}]"
fi

# get pids and remove foreground pid
pids=${(@f)$(awk 'ORS=" " {if ($0 !~ /zsh$/) print $2}' <<< $processes)}
bg_pids=${pids/${fg_proc[2]}/}
# trim leading or trailing whitespace
bg_pids=${${bg_pids%%[[:space:]]##}##[[:space:]]##}
# separate with commas
bg_pids=${bg_pids/\ /,\ }

print -n "${cmd}"
[[ -n $bg_pids ]] && print -n " ($bg_pids)"

