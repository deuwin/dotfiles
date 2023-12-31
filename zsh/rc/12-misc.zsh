###
# Miscellaneous
#

# automatically escape pasted URLs
autoload -Uz url-quote-magic bracketed-paste-magic
zle -N self-insert url-quote-magic
zle -N bracketed-paste bracketed-paste-magic

# let zsh's autocomplete select files and directories
if is_command delta; then
    compdef _files delta
fi

# fzf-git.sh: https://github.com/junegunn/fzf-git.sh
# browse git objects using fzf
is_command fzf && source $ZDOTDIR/third_party/fzf-git.sh/fzf-git.sh

