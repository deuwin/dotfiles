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


####
# sudo
# enable aliases to be sudo’ed
#
alias sudo="sudo "


####
# Edit and Source Configs
#
alias ec="$EDITOR $ZDOTDIR/zshrc"
alias ea="$EDITOR $ZDOTDIR/rc/07-aliases.zsh"
alias et="$EDITOR $HOME/.config/tmux/tmux.conf"
alias ev="$EDITOR $HOME/.config/vim/vimrc"
alias sc="exec zsh"


####
# Navigation and Listing
#
alias d="dirs -v"
for idx in {1..9}; do
    alias "$idx"="cd -${idx}"
done
unset idx

alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

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
    alias ls="lsd --color=auto --group-directories-first"
    alias l.="la --ignore-glob='[a-zA-Z]*'"
    alias lt='ls --tree'
else
    alias ls="ls --classify --color=auto --group-directories-first"
    alias l.="la --ignore='[a-zA-Z]*'"
fi
alias la="ls --almost-all -v"
alias ll="ls --human-readable -l"
alias lla="ll --almost-all -v"

# Change dir and list contents
cl() {
    builtin cd "${1}" && ls
}


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
alias rd="rmdir"
alias ln="ln --verbose --interactive"
alias chown="chown --verbose"
alias chmod="chmod --verbose"


####
# Utilities
#
alias curl="noglob curl"
alias df="df --human-readable"
alias diff="diff --color=auto"
alias ip="ip --color"
alias wget="wget --hsts-file=$HOME/.config/wget-hsts"
alias tarx="tar -xvf"
alias tailf="tail -F"
alias cmx="chmod u+x"
# dud - disk usage directories
if is_command dust; then
    alias du="dust"
    alias dud="dust --depth 1 --only-dir"
else
    alias du="du --human-readable --total"
    alias dud="du --max-depth=1"
fi
if is_command nala; then
    alias apt="echo 'Don\'t you mean nala?'"
    alias apt-get="apt"
fi
if is_command fzf; then
    export FZF_DEFAULT_OPTS="--layout=reverse --color=border:245"
    fman() {
        typeset -la preview=(
            "echo {} | tr --delete '()' | "
            "awk '{printf \"%s \", \$2} {print \$1}' | "
            "xargs --no-run-if-empty man"
        )
        man --apropos . | \
            fzf --nth="1,2" \
                --prompt="man> " \
                --preview="$preview" | \
            tr --delete '()' | \
            awk '{printf "%s ", $2} {print $1}' | \
            xargs --no-run-if-empty man
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
        # page automatically if outputting to a terminal
        if [ -t 1 ];then
            command rg --smart-case --pretty $@ | less --RAW-CONTROL-CHARS
        else
            command rg --smart-case --pretty $@
        fi
    }
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
# Pagers
#
# less - see zshenv
# or for syntax highlighting and extra overhead you can use vim as a pager
alias vless="/usr/share/vim/vim90/macros/less.sh"
# or you could use `view` which is equal to `vim -R`


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
