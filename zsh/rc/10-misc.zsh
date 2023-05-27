###
# Miscellaneous
#

# automatically escape pasted URLs
autoload -Uz url-quote-magic bracketed-paste-magic
zle -N self-insert url-quote-magic
zle -N bracketed-paste bracketed-paste-magic

# Clean up helpers and log any commands not found
if ((${#command_missing} > 0)); then
    _impure_warning "Command(s) not found: ${(j:, :)command_missing}"
fi
unset command_missing
unfunction is_command is_function
