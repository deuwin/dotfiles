###
# Clean up
#

# Clean up helpers and log any commands not found
if ((${#command_missing} > 0)); then
    _impure_warning "Command(s) not found: ${(j:, :)command_missing}"
fi
unset command_missing

# automatic unfunction of helpers
() {
    local line
    typeset -al helpers
    {
        # skip preamble
        while IFS= read -r line; do
            [ "$line" = "# Generic Helpers" ] && break
        done

        # find helpers
        while IFS= read -r "line"; do
            case $line in
                "# Logging")
                    break
                    ;;
                *\(\)*)
                    helpers+=(${line%%\(*})
                    ;;
            esac
        done

        # unfunction
        local h
        for h in ${helpers[@]}; do
            unfunction $h
        done
    } < "$ZDOTDIR/rc/01-helpers.zsh"
}

