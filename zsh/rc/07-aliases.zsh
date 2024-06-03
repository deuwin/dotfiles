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
# Editors
#
() {
    local vimrc="$HOME/.config/vim/vimrc"
    if [[ -e $vimrc ]]; then
        alias vim="VIMINIT='source $vimrc' vim"
    fi
}


####
# Edit and Source Configs
#
alias ez="cd -q $ZDOTDIR && $EDITOR && cd -q -"
alias et="cd -q $HOME/.config/tmux && $EDITOR && cd -q -"
alias ev="cd -q $HOME/.config/$EDITOR && $EDITOR && cd -q -"
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
    alias ls="command lsd --color=auto --group-directories-first"
    alias l.="la --ignore-glob='[a-zA-Z]*'"
    alias lt="ls --tree"
    alias lsd="ls --directory-only"
else
    alias ls="ls --classify --color=auto --group-directories-first"
    alias l.="la --ignore='[a-zA-Z]*'"
    alias lsd="ls --directory"
fi
alias la="ls --almost-all -v"
alias ll="ls --human-readable -l"
alias lla="ll --almost-all -v"
alias ll.="l. -l"


####
# File Manipulation
#
alias cp="cp --interactive --verbose"
alias cpv="rsync --archive --partial --human-readable --info=stats1,progress2 --modify-window=1"
alias mv="mv --interactive --verbose"
alias rm="rm --interactive=once --verbose"
alias mkdir="mkdir --verbose"
alias md="mkdir --parents"
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
            if [ -d "$dir" ] && [ "$dir" != "$(pwd)" ]; then
                cd "$dir"
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
if is_command trash; then
    alias del="trash"
fi


####
# Pagers
#

## less
# Default options are defined as environment variables (see: ~/.config/zsh/zshenv)
# and are picked up when less is invoked via a script or other function. The
# alias applies when ran directly.

# print output if it fits on screen and calculate file size upon opening
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
alias ipa="ip address"
alias wget="wget --hsts-file=$HOME/.config/wget-hsts"
alias tailf="command tail --follow=name --retry"
alias tf="tailf"
alias h="head"
alias tarx="tar --extract --verbose --file"
alias cmx="chmod u+x"
alias psg="ps -ef | grep --ignore-case"
if is_command bat; then
    _head_tail() {
        local cmd_bat="bat --style=plain" arg
        for arg in ${argv[2,-1]}; do
            if [[ -a $arg ]]; then
                cmd_bat+=" --file-name $arg"
            fi
        done
        command ${argv[1]} ${argv[2,-1]} | ${=cmd_bat}
    }
    head() {
        _head_tail head $@
    }
    tail() {
        _head_tail tail $@
    }
fi

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

# generic colourisation supplied by grc
# https://github.com/garabik/grc
GRC_ALIASES=true
[[ -s "/etc/grc.zsh" ]] && source /etc/grc.zsh


####
# Find Files
# pre-filled with oft used arguments and prefixed with
# noglob cos I'm sick of quoting
#
if is_command fdfind; then
    fd() {
        # page automatically if needed
        command fdfind --color=always $@ | less
    }
    alias fdf="fd --type=f"
    alias fdd="fd --type=d"
    alias fdu="fd --unrestricted"
    alias fdfu="fdf --unrestricted"
    alias fduf="fdfu"
    alias fddu="fdd --unrestricted"
    alias fdud="fddu"
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
fi
if is_command ack; then
    alias ack="ack --smart-case --pager=less"
fi
alias grep="grep --color=auto"
alias grepi="grep -i"


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
if is_command bat; then
    alias -g \?="--help | bat --style=plain --language help"
fi


####
# Shits and Giggles
#
is_command cmatrix && alias cmatrix="cmatrix -baC blue"
alias party-time="curl parrot.live"
is_command mpv && alias mpvt="mpv --vo=tct"
