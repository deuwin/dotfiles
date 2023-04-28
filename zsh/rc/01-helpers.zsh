####
# Generic Helpers
#
is_command() {
    command -v $1 > /dev/null
}


####
# Logging
#
_IMPURE_LOGGING=true
_IMPURE_LOGFILE="/tmp/impure.log"

if $_IMPURE_LOGGING; then
    if [[ -n $_IMPURE_LOGFILE ]]; then
        _impure_log() {
            printf "[%s] %s: %s: %s\n" \
                    "$(date '+%Y/%m/%d %H:%M:%S.%N')" \
                    "$1" \
                    $funcstack[3] \
                    "$2" >> $_IMPURE_LOGFILE
        }
        _impure_error() {
            _impure_log "Error" "$1"
        }
        _impure_warning() {
            _impure_log " Warn" "$1"
        }
        _impure_info() {
            _impure_log " Info" "$1"
        }
        _impure_debug() {
            _impure_log "Debug" "$1"
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

