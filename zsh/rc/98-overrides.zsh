####
# Overrides and Extensions
# apply changes to functions, options, or any other setting previously
# established
#
() {
    local override
    setopt localoptions nullglob

    # overrides for third party scripts 
    for override in $ZDOTDIR/third_party/overrides/*.zsh; do
        source $override
    done

    # overrides and extensions specific to this machine
    for override in $ZDOTDIR/local/*.zsh; do
        source $override
    done
}
