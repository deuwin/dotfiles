#!/usr/bin/sh
# generate default keybindings for tmux
# tmux must not be running otherwise user configs may be shown

{
    echo "# tmux default keybinds"
    echo "# version: $(tmux -V)"
    echo ""
    tmux -f /dev/null show-options -s \; show-options -g \; list-keys
} > "./tmux_default.conf"


