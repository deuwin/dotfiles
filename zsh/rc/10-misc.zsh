#!/usr/bin/env zsh

###
# Miscellaneous
#

# automatically escape pasted URLs
autoload -Uz url-quote-magic bracketed-paste-magic
zle -N self-insert url-quote-magic
zle -N bracketed-paste bracketed-paste-magic
