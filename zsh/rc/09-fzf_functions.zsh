####
# fzf functions
# https://github.com/junegunn/fzf/
#
# Some wrappers around various tools to help do things more quickly
#
# The following urls are a good place to seek inspiration/steal from: 
#   - https://github.com/junegunn/fzf/wiki/Examples
#   - https://github.com/junegunn/fzf/blob/master/ADVANCED.md
#

if ! is_command fzf; then
    return
fi

print -v FZF_DEFAULT_OPTS -- \
    "--layout=reverse --color=border:245 --ellipsis=… --cycle" \
    "--scroll-off=2"
export FZF_DEFAULT_OPTS


####
# fman: Fuzzy search manpage titles
#
fman() {
    typeset -la man_cmd=(
        "echo {} | tr --delete '()'"
        " | awk '{printf \"%s \", \$2} {print \$1}'"
        " | xargs --no-run-if-empty man"
    )
    local query="${*:-}"
    source "$ZDOTDIR/lib/fzf_preview.zsh"
    FZF_DEFAULT_COMMAND="man --apropos ." \
        fzf --query "$query" \
            --nth="1,2" \
            --prompt="man> " \
            --preview="$man_cmd" \
            --bind "enter:execute:$man_cmd" \
            $preview_args
}


# https://github.com/dalance/procs
####
# fkill: Fuzzy search processes to kill
#
fkill() {
    local query=$1
    local ps_args
    if [[ "$UID" != "0" ]]; then
        ps_args="-u $UID"
    else
        ps_args="-e"
    fi

    # the CMD header is padded with a non-breaking space so we have a line
    # across the whole screen, minus 40 to account for the other headings
    local cmd_width=$((COLUMNS - 40))
    local cmd_header=CMD${(r:$cmd_width:: :)}

    local pid=$( \
        ps --format=user,pid,ppid,tname,cmd=$cmd_header ${=ps_args} \
            | fzf --header-lines=1 --color=header:underline --query=$query \
            | awk '{print $2}')

    if [[ -n $pid ]]; then
        local cmd="\"$(ps --pid $pid --format args=)\""
        if [[ -z $cmd ]]; then
            print "error: Empty command!"
            return 1
        fi

        local confirm=""
        if read -q "confirm?Do you want to kill $cmd? [N/y] "; then
            print "\nKilling [$pid] $cmd..."
            builtin kill -s SIGKILL $pid 
        else
            print "\nCancelled"
        fi
    else
        print "Exit"
    fi
}


####
# pf: preview files
# inspired by: https://github.com/nickjj/dotfiles/blob/master/.config/zsh/.aliases
# although possibly a little silly if lf is installed
#
pf() {
    local fzf_default_command="ls -1 --color=always --group-directories-first"
    local filename_idx=1
    if command -v lsd > /dev/null; then
        fzf_default_command="lsd --oneline --color=always --icon=always"
        filename_idx=2
    fi

    source "$ZDOTDIR/lib/fzf_preview.zsh"
    local filename=$(
        FZF_DEFAULT_COMMAND=$fzf_default_command \
            fzf \
                $preview_args \
                --ansi \
                --preview="less {$filename_idx}" \
                --bind="ctrl-l:execute:less --clear-screen {$filename_idx}" \
                --header="$(print -P current dir: %3~)" \
                --bind="enter:become:(echo {$filename_idx})"
    )
    print -z -- $filename
    if [[ -v TMUX ]]; then
        tmux set-buffer -w $filename
    fi
}


####
# helpers to automatically create aliases based on those defined previously
#
expand_alias() {
    local cmd=$1 expansion
    expansion=${aliases[$cmd]}
    if [[ -n $expansion ]]; then
        local head=${expansion%%\ *}
        local tail=${expansion#$head}
        expand_alias $head
        new_aliases[$cmd]="$new_aliases[$head]$tail"
    fi
}

create_aliases() {
    local parent=$1 base=$2 alias_
    typeset -lA new_aliases
    for alias_ in ${(M)${(k)aliases}##$parent*}; do
        expand_alias ${alias_}
        alias $base${alias_##$parent}="$base$new_aliases[$alias_]"
    done
}


####
# ffd: Fuzzy find
# Primarally this is to provide a preview of the found files but also allows
# secondary filtering using fzf.
#
if is_command fdfind; then
    ffd() {
        local options=$@[1,-2]
        local query=$@[-1]

        local search_cmd="fdfind --color=always $options -- {q}"
        local search_prompt="1. fd> "
        local preview_cmd="less --clear-screen {1}"

        source "$ZDOTDIR/lib/fzf_preview.zsh"
        $fzf_preview
    }
    compdef ffd=fd

    # add ffd* aliases by cycling through and expanding the fd* aliases
    # specified previously
    create_aliases fd ffd
fi


####
# rf: ripgrep fuzzy
# Primarally this is to provide a preview of the ripgrep results with a bit of
# context but also allows secondary filtering using fzf.
#
if is_command rg; then
    rf() {
        local options=$@[1,-2]
        local query=${(b)@[-1]}

        # quote options only if set, otherwise we get '' which is interpreted as
        # an empty positional argument
        options=${options:+${(b)options}}

        local rg_common_opts="--smart-case --pretty --line-number --no-heading"
        local search_cmd="rg $rg_common_opts $options -- {q}"
        local search_prompt="1. ripgrep> "

        local preview_cmd
        local window_append=",+{2}+3/3"
        if command -v bat > /dev/null; then
            # override LESSOPEN so we can highlight the matching line if the
            # selected file is opened with less
            local bat_cmd=(
                "bat --color=always --style=header,grid,numbers"
                "--highlight-line={2}")
            local full_preview_cmd=(
                "LESSOPEN='| $bat_cmd %s'; LESSCLOSE='';"
                "less --file-size --jump-target=.2 +G{2} {1}")
            preview_cmd="$bat_cmd {1}"
            window_append+=",~3"
        else
            # kinda ugly but usable
            preview_cmd="rg $rg_common_opts --passthru -- {q} {1}"
        fi

        source "$ZDOTDIR/lib/fzf_preview.zsh"
        $fzf_preview --delimiter=:
    }
    compdef rf=rg

    # add rf* aliases by cycling through and expanding the rg* aliases
    # specified previously
    create_aliases rg rf
fi

# clean up helpers
unfunction create_aliases expand_alias
