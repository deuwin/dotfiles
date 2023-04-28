####
# Appearance
#

# prompt
source $ZDOTDIR/prompt/impure.zsh

# colours
# generate default with `dircolors --print-database > dircolors_database`
eval "$(dircolors --bourne-shell $ZDOTDIR/colours/dircolors_database)"

# menu
# colour matches with LS_COLORS
# selected menu item with bold white and blue background
zstyle ":completion:*:*:*:*:default" list-colors ${(s.:.)LS_COLORS} "ma=38;5;15;48;5;4;1"

# syntax highlighting
# https://github.com/zdharma-continuum/fast-syntax-highlighting
# like zsh-syntax-highlighting but better in a few cases
source $ZDOTDIR/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
