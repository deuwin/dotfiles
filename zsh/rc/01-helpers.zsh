####
# Generic Helpers
#
typeset -aU command_missing
is_command() {
    if ! command -v $1 > /dev/null; then
        command_missing+=($1)
        false
    else
        true
    fi
}

is_function() {
    typeset -f "$1" > /dev/null
}

# greater than or equal to
is_version_gte() {
    if [ -z $1 ] || [ -z $2 ]; then
        print "You must supply two version strings!"
        return 2
    fi
    print "$2\n$1" | sort --version-sort --check=quiet
}

# less than or equal to
is_version_lte() {
    is_version_gte $2 $1
}

# greater than
is_version_gt() {
    ! is_version_gte $2 $1
}

# less than
is_version_lt() {
    ! is_version_gte $1 $2
}


####
# Logging
#
if [[ $ZSH_EXECUTION_STRING == "exit 42" ]]; then
    _IMPURE_LOGGING=false
else
    _IMPURE_LOGGING=true
fi
_IMPURE_LOGDIR="$HOME/.local/state/impure/logs"
_IMPURE_LOGFILE="$_IMPURE_LOGDIR/impure.log"
_IMPURE_LAST_ROTATE="$_IMPURE_LOGDIR/last_rotate"

zmodload zsh/datetime
zmodload zsh/system

_impure_rotate_logs() {
    # Check for last log rotation. If non-existent I guess we're starting afresh
    if [[ ! -f $_IMPURE_LAST_ROTATE ]]; then
        print $EPOCHSECONDS >| $_IMPURE_LAST_ROTATE
        return
    fi

    # When was midnight?
    local today midnight
    strftime -s today %F
    strftime -rs midnight %F ${today}

    # Last rotation
    local last_rotate
    last_rotate=$(<$_IMPURE_LAST_ROTATE)
    ((last_rotate > midnight)) && return

    # Lock logfile, if it exists
    if [[ ! -f $_IMPURE_LOGFILE ]]; then
        return
    fi
    zsystem flock $_IMPURE_LOGFILE

    # Move logs
    local _MAX_LOGFILES=5 ii
    for ii in {$((_MAX_LOGFILES - 1))..1}; do
        [[ -f $_IMPURE_LOGFILE.$ii ]] && \
            command mv -f "$_IMPURE_LOGFILE.$ii" "$_IMPURE_LOGFILE.$((ii + 1))"
    done
    command mv -f "$_IMPURE_LOGFILE" "$_IMPURE_LOGFILE.1"

    print $EPOCHSECONDS >| $_IMPURE_LAST_ROTATE
}

if $_IMPURE_LOGGING; then
    if [[ -n $_IMPURE_LOGFILE ]]; then
        if [ ! -d $_IMPURE_LOGDIR ]; then
            mkdir -p $_IMPURE_LOGDIR
        fi

        # Check if we should rotate the logs. Ran in subshell, for automatic
        # release of lock
        (_impure_rotate_logs)

        _impure_log() {
            local level="$1" msg="$2" caller
            if [[ -n "$3" ]]; then
                caller="$3"
            else
                caller="${funcstack[3]:t}"
            fi
            # In subshell, for automatic release of lock
            (
                [[ -f $_IMPURE_LOGFILE ]] && zsystem flock $_IMPURE_LOGFILE
                print -P "[%D{%F %T.%.}][$level] $TTY:" \
                    "$caller" "\"$msg\"" >>| "$_IMPURE_LOGFILE"
            )
        }

        # logging parameters
        # $1 - message
        #   text to be displayed in log file
        # $2 - caller (optional)
        #   automatically generated if blank, but provided if an override is
        #   required to provide a more useful context for the log
        _impure_error() {
            _impure_log "Error" "$1" "$2"
        }
        _impure_warning() {
            _impure_log "Warn " "$1" "$2"
        }
        _impure_info() {
            _impure_log "Info " "$1" "$2"
        }
        _impure_debug() {
            _impure_log "Debug" "$1" "$2"
        }
    else
        _impure_error() {
            print "\e[38;5;1mImpure Error\e[0m: $1" >&2
        }
        _impure_warning() {
            print "\e[38;5;3mImpure Warning\e[0m: $1" >&2
        }
        _impure_info() {
            print "\e[38;5;4mImpure Info\e[0m: $1" >&2
        }
        _impure_debug() {
            print "\e[38;5;6mImpure Debug\e[0m: $1" >&2
        }
    fi
else
    _impure_error() { : }
    _impure_warning() { : }
    _impure_info() { : }
    _impure_debug() { : }
fi

