####
# Restart zsh or Reload Settings
# Initial idea/implementation from:
# https://ruderich.org/simon/config/zshrc
#

zmodload -F zsh/stat b:zstat
autoload -Uz add-zsh-hook
zmodload zsh/datetime

_zshrc_reload_log() {
    print -P "    $1"
    local zero_len='%([BSUbfksu]|([FB]|){*})'
    _impure_info "${(S%)1//$~zero_len/}"
}


####
# Restart Settings
# restart if zshrc or associated files change
#

# auto-restart setting
_zshrc_disable_restart=""

# remember startup time
_zshrc_start_time=$EPOCHSECONDS

# files to track
typeset -a _zshrc_watch_files=(
    "zshrc"
    "colours/*"
    "rc/*"
    "prompt/*"
    "scripts/*"
)

_zshrc_restart_precmd() {
    # get modified time of zsh configs and report any changes
    local mtime changed_file="" files file
    for files in $(printf "$ZDOTDIR/%s\n" ${_zshrc_watch_files}); do
        for file in ${~files}; do
            zstat -A mtime +mtime $file
            if ((mtime > _zshrc_start_time)); then
                changed_file=$file
                break 2
            fi
        done
    done

    if [[ -z $changed_file ]]; then
        return
    fi

    local startup
    strftime -s startup '%Y-%m-%d %H:%M:%S' $_zshrc_start_time

    _zshrc_reload_log \
        "%F{cyan}${changed_file#$ZDOTDIR/} modified since startup ($startup)%f"

    # check if disabled
    if [[ -n $_zshrc_disable_restart ]]; then
        _zshrc_reload_log "Automatic restart disabled."
        return
    fi

    # Don't exec if we have background processes as we will lose control over
    # them
    if [[ ${#${(k)jobstates}} -ne 0 ]]; then
        _zshrc_reload_log "Active background jobs, no restart"
        return
    fi

    # Try to start a new interactive shell. If it fails, something is wrong.
    # Don't kill our current session by execing it, abort instead.
    zsh -i -c "exit 42"
    if [[ $? -ne 42 ]]; then
        _zshrc_reload_log "%F{red}%BFailed to start new zsh!%f%b"
        return
    fi

    _zshrc_reload_log "Restarting zsh..."
    exec zsh
}
add-zsh-hook precmd _zshrc_restart_precmd


####
# Reload Settings
# automatically source zshenv when the file changes (and exists)
#
_zshenv_reload_time=0 # load before first command
_zshenv_boot_time=$(date -d "$(uptime -s)" '+%s') # uptime in epoch seconds

_zshenv_reload_preexec() {
    local zshenv=$ZDOTDIR/zshenv

    local mtime
    if ! zstat -A mtime +mtime $zshenv 2>/dev/null; then
        return
    fi
    # File was modified before reboot. Skip it to prevent loading of old
    # values.
    if [[ $mtime -lt $_zshenv_boot_time ]]; then
        return
    fi
    # File wasn't modified, nothing to do.
    if [[ $mtime -le $_zshenv_reload_time ]]; then
        return
    fi
    _zshenv_reload_time=$EPOCHSECONDS

    _impure_info "zshenv modified. Reloading..."
    unsetopt warn_create_global
    source $zshenv
    setopt warn_create_global
}
add-zsh-hook preexec _zshenv_reload_preexec
