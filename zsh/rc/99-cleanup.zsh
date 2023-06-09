#!/usr/bin/env zsh

###
# Clean up
#

# Clean up helpers and log any commands not found
if ((${#command_missing} > 0)); then
    _impure_warning "Command(s) not found: ${(j:, :)command_missing}"
fi
unset command_missing
unfunction is_command is_function is_version_gt
