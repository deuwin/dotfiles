####
# Completion
#

# zsh-autocomplete
# https://github.com/marlonrichert/zsh-autocomplete
source $ZDOTDIR/third_party/zsh-autocomplete/zsh-autocomplete.plugin.zsh
## tab inserts common substring
# all Tab widgets
zstyle ":autocomplete:*complete*:*" insert-unambiguous yes
# all history widgets
zstyle ":autocomplete:*history*:*" insert-unambiguous yes
# limit completions and history search to a third of the screen
zstyle -e ":autocomplete:*" list-lines "reply=( $((LINES / 3)) )"
# don't show completions that begin with two or more dots
zstyle ":autocomplete:*" ignored-input "..##"

# autosuggestions
# https://github.com/zsh-users/zsh-autosuggestions
source $ZDOTDIR/third_party/zsh-autosuggestions/zsh-autosuggestions.zsh
