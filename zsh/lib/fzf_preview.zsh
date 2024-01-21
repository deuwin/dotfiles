# smart preview window position
readonly size_up="60%"
readonly size_right="50%"

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
preview_window+=$window_append

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

local echo_set="echo {1}; [[ -v TMUX ]] && tmux set-buffer -w {1}"
local fzf_preview=(
    fzf --ansi --disabled --query "$query"
        --bind="start:reload:$search_cmd"
        --bind="change:reload:sleep 0.1; $search_cmd || true"
        --preview="$preview_cmd"
        --bind="ctrl-l:execute:${full_preview_cmd:-$preview_cmd}"
        --color="hl:-1:underline,hl+:-1:underline:reverse"
        --prompt="$search_prompt"
        --bind="alt-enter:unbind(change,alt-enter)"
        --bind="alt-enter:+change-prompt(2. fzf> )"
        --bind="alt-enter:+enable-search+clear-query"
        --bind="enter:become:($echo_set)"
        $preview_args
)
