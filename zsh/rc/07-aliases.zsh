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
alias ea="$EDITOR $ZDOTDIR/rc/98-aliases.zsh"
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

if is_command lsd; then
    alias ls="lsd --classify --color=auto --group-directories-first"
    alias l.="la --ignore-glob='[a-zA-Z]*'"
else
    alias ls="ls --classify=auto --color=auto --group-directories-first"
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
alias du="du --human-readable --total"
alias duh="du --max-depth=1"
alias ip="ip --color"
alias wget="wget --hsts-file=$HOME/.config/wget-hsts"
alias tarx="tar -xvf"
alias tailf="tail -F"
if is_command diff-so-fancy; then
    dsf() {
        diff --new-file --text --unified --recursive --show-c-function \
            "$1" "$2" | diff-so-fancy | less
    }
fi


####
# Find Files
# pre-filled with oft used arguments and prefixed with
# noglob cos I'm sick of quoting
#
alias find="noglob find"
alias findn="find . -name"
alias findi="find . -iname"


####
# Find in Files
#
if is_command ack; then
    alias ack="ack --smart-case --pager=less"
fi
alias grep="grep --color=auto"
alias grepi="grep -i"


####
# nala
#
alias apt="echo 'Don\'t you mean nala?'"
alias apt-get="apt"


####
# Convenience Aliases
#
# concise list of mounts
alias mnt="mount | grep -E ^/dev | column -t"
# copying a large amount of data? why not have a progress bar!
alias cpv="rsync --archive --partial --human-readable --info=stats1,progress2 --modify-window=1"
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
