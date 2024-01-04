# smart preview window position
readonly size_up="60%"
readonly size_right="55%"

# Inconsolata has a width:height ratio of roughly 0.44 with my current
# terminal/screen/etc...
local pos_start pos_change
if ((LINES > COLUMNS * 0.4)); then
    pos_start="up"
    pos_change="right,$size_right"
else
    pos_start="right"
    pos_change="up,$size_up"
fi
local preview_window="--preview-window=$pos_start,${(P)${:-size_${pos_start}}}"

# common arguments
local preview_args=(
    # binding to manually change preview window position
    "--bind=ctrl-/:change-preview-window:$pos_change|hidden|"
    # suppress exit code 130 when hitting escape or ctrl-c
    "--bind=esc:become:"
    "--bind=ctrl-c:become:"
    # preview window position
    $preview_window
)
