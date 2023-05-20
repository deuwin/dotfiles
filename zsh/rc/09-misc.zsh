###
# Miscellaneous
#

# automatically escape pasted URLs
autoload -Uz url-quote-magic bracketed-paste-magic
zle -N self-insert url-quote-magic
zle -N bracketed-paste bracketed-paste-magic

# source scripts
#   ssh_agent.zsh - for ssh keys
#   fzf-git.sh    - https://github.com/junegunn/fzf-git.sh
script_dir="$ZDOTDIR/scripts"
typeset -a scripts=(
    ssh_agent.zsh
)
is_command fzf && scripts+=(fzf-git.sh/fzf-git.sh)

for s in "$scripts[@]"; do
    if [[ -f $script_dir/$s ]]; then
        source $script_dir/$s
    else
        _impure_warning "Could not source: $s"
    fi
done
unset script_dir scripts s

# Clean up is_command and log any commands not found
if ((${#command_missing} > 0)); then
    _impure_warning "Command(s) not found: ${(j:, :)command_missing}"
fi
unset command_missing
unfunction is_command

