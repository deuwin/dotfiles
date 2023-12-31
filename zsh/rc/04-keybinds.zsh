####
# Keybinds
#
# Notes
#   - `bindkey -l` gives you a list of existing keymap names
#   - `bindkey -M <keymap>` lists the bindings in a given keymap
#
# Useful defaults you'll forget
#   Esc-.  : insert last word of previous command
#   Alt+f  : forward over whole path
#   Alt+b  : backward over whole path
#   Ctrl+q : push-line - cuts current command, which reappears after another command
#            https://zsh.sourceforge.io/Guide/zshguide04.html#l102
#

# emacs keys at prompt
bindkey -e

# fzf keybinds
source $ZDOTDIR/third_party/fzf_key_bindings.zsh

# additional keybinds not provided by /etc/zsh/zshrc
key[Control+Left]="${terminfo[kLFT5]}"
key[Control+Right]="${terminfo[kRIT5]}"

# a couple of tweaks for zsh-autocomplete history navigation
# accept current completion and move to beginning of line
_accept_and_begin() {
    zle .accept-line
    zle .beginning-of-line
}
zle -N _accept_and_begin
zmodload zsh/complist
bindkey -M menuselect "$key[Home]" _accept_and_begin

# accept current completion and move back one word
_accept_and_back_word() {
    zle .accept-line
    zle .backward-word
}
zle -N _accept_and_back_word
bindkey -M menuselect "$key[Control+Left]" _accept_and_back_word

# accept current completion and move back one character
_accept_and_back_char() {
    zle .accept-line
    zle .backward-char
}
zle -N _accept_and_back_char
bindkey -M menuselect "$key[Left]" _accept_and_back_char

# Delete from cursor to:
#   start of line: Ctrl+u
#   end of line:   Ctrl+k
# with copy to clipboard cos that's kinda handy
if is_command xsel; then
    _forward-kill-line() {
        zle kill-line
        echo -n "${CUTBUFFER}" | xsel --input --clipboard
    }
    _backward-kill-line() {
        zle backward-kill-line
        echo -n "${CUTBUFFER}" | xsel --input --clipboard
    }
    zle -N _forward-kill-line
    bindkey "^K" _forward-kill-line
else
    _backward-kill-line() {
        zle backward-kill-line
    }
fi
zle -N _backward-kill-line
bindkey "^U" _backward-kill-line

# Move backwards and forwards by Word with custom delimiters
_backward-word() {
    local WORDCHARS='*?[]~=&;!#$%^(){}<>'
    zle backward-word
}
_forward-word() {
    local WORDCHARS='*?[]~=&;!#$%^(){}<>'
    zle forward-word
}
zle -N _forward-word
zle -N _backward-word
bindkey "$key[Control+Left]"  _backward-word
bindkey "$key[Control+Right]" _forward-word

# Ctrl+Backspace - delete previous word
_backward-kill-word() {
    local WORDCHARS='*?[]~=&;!#$%^(){}<>'
    zle backward-kill-word
    zle -f kill
}
zle -N _backward-kill-word
bindkey "^H" _backward-kill-word

# Alt+Backspace - delete to previous /
_backward-kill-dir() {
    local WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
    zle backward-kill-word
    zle -f kill
}
zle -N _backward-kill-dir
bindkey "^[^?" _backward-kill-dir

# edit current command in $EDITOR
# Ctrl+x Ctrl+e
autoload -z edit-command-line
zle -N edit-command-line
bindkey "^X^E" edit-command-line
