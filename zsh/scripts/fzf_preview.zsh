#!/usr/bin/env zsh

local p_pos=""
local p_change="--bind=ctrl-/:change-preview-window(top,50%|hidden|)"
# Inconsolata is roughly 0.44 with my current terminal/screen/etc...
if ((LINES > COLUMNS * 0.4)); then
    p_pos="--preview-window=top"
    p_change="--bind=ctrl-/:change-preview-window(right,50%|hidden|)"
fi
