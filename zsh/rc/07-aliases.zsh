#!/use/bin/env zsh
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
alias ec="$EDITOR $ZDOTDIR/zshrc"
alias ea="$EDITOR $ZDOTDIR/rc/07-aliases.zsh"
alias et="$EDITOR $HOME/.config/tmux/tmux.conf"
alias ev="$EDITOR $HOME/.config/vim/vimrc"
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
for idx in {1..9}; do
    alias "$idx"="cd -${idx}"
done
unset idx

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
    alias apt="nala"
    alias apt-get="apt"
fi
if is_command fzf; then
    printf -v FZF_DEFAULT_OPTS "%s " \
        "--layout=reverse --color=border:245 --ellipsis=… --cycle"
    export FZF_DEFAULT_OPTS

    # https://github.com/junegunn/fzf/wiki/Examples
    # fman: Fuzzy search manpage titles
    fman() {
        typeset -la view=(
            "echo {} | tr --delete '()' | "
            "awk '{printf \"%s \", \$2} {print \$1}' | "
            "xargs --no-run-if-empty man --pager=\"less -+--quit-if-one-screen\""
        )
        local query="${*:-}"
        source "$ZSCRIPTS/fzf_preview.zsh"
        man --apropos . | \
            fzf --query "$query" \
                --nth="1,2" \
                --prompt="man> " \
                --preview="$view" \
                --bind "enter:execute:$view" \
                $p_pos \
                $p_change
    }

    # fkill: Fuzzy search processes to kill
    fkill() {
        local pid
        if [ "$UID" != "0" ]; then
            pid=$(ps -f -u $UID | sed 1d | fzf --multi | awk '{print $2}')
        else
            pid=$(ps -ef | sed 1d | fzf --multi | awk '{print $2}')
        fi

        if [[ -n $pid ]]; then
            local cmd="\"$(ps --pid $pid --format args=)\""
            if [ -z $cmd ]; then
                print "Exit"
                return 0
            fi
            local prompt="Do you want to kill $cmd? [N/y] "
            local confirm=""
            read -q "confirm?$prompt"
            if [ $confirm = "y" ]; then
                print "\nKilling [$pid] $cmd..."
                echo $pid | xargs kill -${1:-9}
            else
                print ${confirm:1:1}
                print "Cancelling..."
            fi
        else
            print "Exiting"
        fi
    }

    # preview files - inspired by:
    # https://github.com/nickjj/dotfiles/blob/master/.config/zsh/.aliases
    pf() {
        source "$ZSCRIPTS/fzf_preview.zsh"
        {
            pf_clip () {
                local input="$1"
                if command -v xsel > /dev/null; then
                    print -n "$input" | xsel --clipboard
                else
                    print "$input"
                fi
            }
            local filename
            filename=$(
                fzf --preview="less {}" $p_pos $p_change \
                    --bind "ctrl-l:execute:less --clear-screen \
                            -+--quit-if-one-screen {}")
            pf_clip "$filename"
        } always {
            unfunction pf_clip
        }
    }
fi
if is_command bat; then
    alias cat="bat --style=plain --paging=never"
    # bat-help: Colourises help output by piping it through bat
    bh() {
        $1 --help | bat --language=help --style=plain
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
    _rg() {
        # page automatically if outputting to a terminal
        if [ -t 1 ]; then
            rg --smart-case --pretty $@ | less --RAW-CONTROL-CHARS
        else
            rg --smart-case --pretty $@
        fi
    }
    alias rg="noglob _rg"
    alias rgu="rg --unrestricted --unrestricted"
    alias rgl="rg --fixed-strings"
    alias rglu="rgl --unrestricted --unrestricted"

    if is_command fzf && is_command bat; then
        # ripgrep and fzf integration based on code from:
        # https://github.com/junegunn/fzf/blob/master/ADVANCED.md#ripgrep-integration
        _rf() {
            local rg_flags="$1" initial_query="$2" 

            local rg_cmd alt_enter
            printf -v rg_cmd '%s' "rg --column --line-number --no-heading " \
                "--color=always --smart-case $rg_flags"
            printf -v alt_enter '%s' "alt-enter:unbind(change,alt-enter)" \
                "+change-prompt(2. fzf> )+enable-search+clear-query"

            local bat_cmd escape_dots pager_opts bat_full
            bat_cmd="bat --color=always --highlight-line={2}"

            # Escape dots in filename, otherwise they are interpreted as part
            # of an if statement used by --prompt option in less
            escape_dots="f={1}; f=\${f/./\\\.};"

            # Pager option passed to bat. Values for less' --prompt flag can be
            # found in the man page for less under the section on PROMPTS
            printf -v pager_opts '%s ' \
                "--pager=\"less +G +{2} -+--quit-if-one-screen " \
                    "--prompt='M\$f lines %lt-%lb?L/%L. ?pB%pB\% .?e(END) %t'\""

            printf -v bat_full '%s ' $escape_dots $bat_cmd $pager_opts

            : | fzf --ansi --disabled --query "$initial_query" \
                --bind "start:reload:$rg_cmd {q}" \
                --bind "change:reload:sleep 0.1; $rg_cmd {q} || true" \
                --bind $alt_enter \
                --color "hl:-1:underline,hl+:-1:underline:reverse" \
                --prompt "1. ripgrep> " \
                --delimiter : \
                --preview "$bat_cmd {1}" \
                --preview-window "up,60%,border-bottom,+{2}+3/3,~3" \
                --bind "ctrl-l:execute($bat_full {1})" \
                --bind "ctrl-e:become(vim {1} +{2})"
        }
        alias rf="noglob _rf \"\""
        alias rfu="noglob _rf \"--unrestricted --unrestricted\""
        alias rfl="noglob _rf --fixed-strings"
        alias rful="noglob _rf \"--unrestricted ---unrestricted -fixed-strings\""
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
is_command mpv && alias mpvt="mpv --vo=tct"
