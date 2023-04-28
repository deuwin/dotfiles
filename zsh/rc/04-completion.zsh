####
# Completion
#

# emacs keys at prompt
# should be in keybinds but then zsh-autocomplete's keybinds wouldn't be in
# emacs style
bindkey -e

# zsh-autocomplete
# https://github.com/marlonrichert/zsh-autocomplete
source $ZDOTDIR/plugins/zsh-autocomplete/zsh-autocomplete.plugin.zsh
## tab inserts common substring
# all Tab widgets
zstyle ":autocomplete:*complete*:*" insert-unambiguous yes
# all history widgets
zstyle ":autocomplete:*history*:*" insert-unambiguous yes
# delay in seconds (float) after typing stops before showing completions
zstyle ":autocomplete:*" min-delay 0.125
# limit completions and history search to a third of the screen
zstyle -e ":autocomplete:*" list-lines "reply=( $((LINES / 3)) )"
# <enter>: execute selected item from menu
bindkey -M menuselect '\r' .accept-line


# autosuggestions
# https://github.com/zsh-users/zsh-autosuggestions
source $ZDOTDIR/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
