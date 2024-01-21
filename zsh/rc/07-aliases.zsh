####
# Aliases and Shell Functions
#
# Notes
#   - `alias` (no args) lists currently defined aliases
#   - \<command> runs a command shadowed by an alias
#     e.g. `\ls` runs ls without the options below
#


####
# Named Directories
# strictly speaking not an alias but a damn handy way to create a directory
# bookmark you can access anywhere.
#
# e.g. use `~my_dir` to get to my_directory
# hash -d my_dir=/path/to/my_directory
hash -d zdd=$ZDOTDIR
hash -d zrc=$ZDOTDIR/rc


####
# Edit and Source Configs
#
alias ez="(cd $ZDOTDIR && $EDITOR)"
alias et="(cd $HOME/.config/tmux && $EDITOR)"
alias ev="(cd $HOME/.config/vim && $EDITOR vimrc)"
alias sc="exec zsh"
alias zrf="touch $ZDOTDIR/zshrc"


####
# Impure Specific
#
alias impure-log="tail -F $_IMPURE_LOGFILE"


####
# sudo
# enable aliases to be sudo’ed
#
alias sudo="sudo "


####
# Navigation and Listing
#
alias d="dirs -v"
() {
    local ii
    for ii in {1..9}; do
        alias "$ii"="cd -${ii}"
    done
}

alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias -- -="cd -"

# Create dir and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1"
}

# Create temporary dir and cd into it
cdt() {
    builtin cd "$(mktemp -d)"
    builtin pwd
}

if is_command lsd; then
    # for default options see: ~/.config/lsd/config.yaml
    alias ls="lsd --color=auto --group-directories-first"
    alias l.="la --ignore-glob='[a-zA-Z]*'"
    alias lt="ls --tree"
else
    alias ls="ls --classify --color=auto --group-directories-first"
    alias l.="la --ignore='[a-zA-Z]*'"
fi
alias la="ls --almost-all -v"
alias ll="ls --human-readable -l"
alias lla="ll --almost-all -v"
alias ll.="l. -l"


####
# File Manipulation
#
alias trash="gio trash"
alias cp="cp --interactive --verbose"
alias cpv="rsync --archive --partial --human-readable --info=stats1,progress2 --modify-window=1"
alias mv="mv --interactive --verbose"
alias rm="rm --interactive=once --verbose"
alias mkdir="mkdir --verbose"
alias md="mkdir -p"
alias rmdir="rmdir --verbose"
alias ln="ln --verbose --interactive"
alias chown="chown --verbose"
alias chmod="chmod --verbose"
if is_command lf; then
    # https://github.com/gokcehan/lf/blob/master/etc/lfcd.sh
    lf() {
        local tmp="$(mktemp)"
        command lf -last-dir-path="$tmp" "$@"
        if [ -f "$tmp" ]; then
            local dir="$(cat "$tmp")"
            command rm -f "$tmp"
            if [ -d "$dir" ]; then
                if [ "$dir" != "$(pwd)" ]; then
                    cd "$dir"
                fi
            fi
        fi
    }
fi
rd() {
    if ! rmdir "$1" && [ -d "$1" ]; then
        rm --interactive=once --recursive "$1"
    fi
}
compdef "_files -/" rd


####
# Pagers
#

## less
# Default options are defined as environment variables (see: ~/.config/zsh/zshenv)
# and are picked up when less is invoked via the functions defined below. The
# alias applies when ran directly

# print output if it fits on screen and calculate the file size upon opening
alias less="less --quit-if-one-screen --file-size"

## bat
# to ensure everything works a symlink batcat -> bat has been created
# for default options see ~/.config/bat/config
if is_command bat; then
    alias cat="bat --style=plain --paging=never"
fi


####
# Utilities
#
alias curl="noglob curl"
alias diff="diff --color=auto"
alias ip="ip --color"
alias wget="wget --hsts-file=$HOME/.config/wget-hsts"
alias tarx="tar -xvf"
alias tailf="tail -F"
alias cmx="chmod u+x"

# replacements
if is_command dust; then
    alias du="dust"
    alias dud="dust --depth 1 --only-dir" # disk usage, directories
else
    alias du="du --human-readable --total"
    alias dud="du --max-depth=1"
fi
if is_command duf; then
    alias df="duf"
else
    alias df="df --human-readable"
fi
if is_command nala; then
    alias apt="nala"
    alias apt-get="apt"
fi

# functions
if is_command fzf; then
    print -v FZF_DEFAULT_OPTS -- \
        "--layout=reverse --color=border:245 --ellipsis=… --cycle" \
        "--scroll-off=2"
    export FZF_DEFAULT_OPTS

    # https://github.com/junegunn/fzf/wiki/Examples
    # fman: Fuzzy search manpage titles
    fman() {
        typeset -la man_cmd=(
            "echo {} | tr --delete '()'"
            " | awk '{printf \"%s \", \$2} {print \$1}'"
            " | xargs --no-run-if-empty man"
        )
        local query="${*:-}"
        source "$ZDOTDIR/lib/fzf_preview_args.zsh"
        FZF_DEFAULT_COMMAND="man --apropos ." \
            fzf --query "$query" \
                --nth="1,2" \
                --prompt="man> " \
                --preview="$man_cmd" \
                --bind "enter:execute:$man_cmd" \
                $preview_args
    }

    # fkill: Fuzzy search processes to kill
    fkill() {
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
                | fzf --header-lines=1 --color=header:underline \
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
                kill --signal SIGKILL $pid 
            else
                print "\nCancelled"
            fi
        else
            print "Exit"
        fi
    }

    # preview files - inspired by:
    # https://github.com/nickjj/dotfiles/blob/master/.config/zsh/.aliases
    # although possibly a little silly if lf is installed
    pf() {
        local fzf_default_command="ls -1 --color=always --group-directories-first"
        local filename_idx=1
        if command -v lsd > /dev/null; then
            fzf_default_command="lsd --oneline --color=always --icon=always"
            filename_idx=2
        fi

        source "$ZDOTDIR/lib/fzf_preview_args.zsh"
        local filename=$(
            FZF_DEFAULT_COMMAND=$fzf_default_command \
                fzf \
                    $preview_args \
                    --ansi \
                    --preview="less {$filename_idx}" \
                    --bind="ctrl-l:execute:less --clear-screen {$filename_idx}" \
                    --header="$(print -P current dir: %3~)"
        )
        print -z -- $filename
        if [[ -v TMUX ]]; then
            tmux set-buffer -w $filename
        fi
    }
fi


####
# Find Files
# pre-filled with oft used arguments and prefixed with
# noglob cos I'm sick of quoting
#
if is_command fdfind; then
    alias fd="noglob fdfind"
    alias fdf="fd --type f"
    alias fdd="fd --type d"
    alias fdu="fd --unrestricted"
    alias fdfu="fdf --unrestricted"
    alias fddu="fdd --unrestricted"
else
    alias fd="findi"
fi
alias find="noglob find"
findn() {
    find . -name "*$1*"
}
findi() {
    find . -iname "*$1*"
}


####
# Find in Files
#
if is_command rg; then
    rg() {
        # page automatically if needed
        command rg --smart-case --pretty $@ | less
    }
    alias rgu="rg --unrestricted --unrestricted"
    alias rgl="rg --fixed-strings"
    alias rglu="rgu --fixed-strings"
    alias rgul="rglu"

    if is_command fzf && is_command bat; then
        # ripgrep and fzf integration inspired by:
        # https://github.com/junegunn/fzf/blob/master/ADVANCED.md#ripgrep-integration
        rf() {
            local options=$@[1,-2]
            local query=$@[-1]
            [[ $query[1] == - ]] && query=\\$query

            # construct rg command along with display options for fzf
            local rg_cmd
            print -v rg_cmd -- \
                rg $options \
                    "--smart-case --pretty --column --line-number" \
                    "--no-heading {q}"

            # binding to switch from ripgrep to fzf search mode
            local bind_alt_enter=(
                "--bind=alt-enter:unbind(change,alt-enter)"
                "--bind=alt-enter:+change-prompt(2. fzf> )"
                "--bind=alt-enter:+enable-search+clear-query")

            # override LESSOPEN so we can highlight the matching line if the
            # selected file is opened with less
            local bat_cmd="bat --color=always --highlight-line={2}"
            local less_cmd=(
                "LESSOPEN='| $bat_cmd %s'; LESSCLOSE='';"
                "less --file-size --jump-target=.2 +G{2} {1}")

            source "$ZDOTDIR/lib/fzf_preview_args.zsh"
            preview_window+=",+{2}+3/3,~3"
            fzf --ansi --disabled --query ${query} \
                --bind "start:reload:$rg_cmd" \
                --bind "change:reload:sleep 0.1; $rg_cmd || true" \
                --preview "$bat_cmd {1}" \
                --bind="ctrl-l:execute:$less_cmd" \
                --color "hl:-1:underline,hl+:-1:underline:reverse" \
                --delimiter : \
                --prompt "1. ripgrep> " \
                $bind_alt_enter \
                $preview_args \
                $preview_window
        }
        compdef rf=rg

        expand_rg_alias() {
            local cmd=$1 expansion
            expansion=${aliases[$cmd]}
            if [[ -n $expansion ]]; then
                local head=${expansion%%\ *}
                local tail=${expansion#$head}
                expand_rg_alias $head
                rg_aliases[$cmd]="$rg_aliases[$head]$tail"
            fi
        }

        # add rf* aliases by cycling through and expanding the rg* aliases
        # specified above
        () {
            local alias_
            typeset -lA rg_aliases
            for alias_ in ${(M)${(k)aliases}##rg*}; do
                expand_rg_alias ${alias_}
                alias ${alias_:s/g/f}="rf $rg_aliases[$alias_]"
            done
            unfunction expand_rg_alias
        }
    fi
fi
if is_command ack; then
    alias ack="ack --smart-case --pager=less"
fi
alias grep="grep --color=auto"
alias grepi="grep -i"


####
# Convenience Aliases
#
# concise list of mounts
alias mnt="mount | grep -E ^/dev | column -t"
# list the most commonly used commands
historystat() {
    history 0 | awk '{print $2}' | sort | uniq -c | sort -n -r | head
}


####
# Suffix Aliases
#
# open image in default viewer
_xdg-open() {
    # suppress any terminal messages that may occur
    xdg-open "$1" > /dev/null 2>&1
}
alias -s {gif,jpg,jpeg,png}=_xdg-open


####
# Global Aliases
# handy for those slightly awkward commands you append to other commands
#
alias -g H="| head"
alias -g T="| tail"
alias -g TL="| tail -20"
alias -g L="| less"
alias -g LL="2>&1 | less"
alias -g G="| noglob grep --color=auto -i"
alias -g GE="| noglob grep --color=auto -E"


####
# Shits and Giggles
#
is_command cmatrix && alias cmatrix="cmatrix -baC blue"
alias party-time="curl parrot.live"
is_command mpv && alias mpvt="mpv --vo=tct"
