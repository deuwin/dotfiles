#!/usr/bin/env zsh
set -e

while read state pid cmd; do
    if [[ $state == *+ ]]; then
        fg_cmd="[${cmd#-}] $pid"
    elif [[ $cmd != -zsh ]]; then
        bg_pids+=($pid)
    fi
done <<< $(ps --format stat,pid,cmd --no-heading --sort -pid --tty $1)
print -n -- "$fg_cmd" "${bg_pids:+(${(j:, :)bg_pids}) }"
