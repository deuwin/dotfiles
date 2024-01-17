#!/usr/bin/zsh

# for min()
autoload zmathfunc
zmathfunc

# for int()
zmodload zsh/mathfunc

# define custom mathematical function
# https://zsh.sourceforge.io/Doc/Release/Shell-Builtin-Commands.html#index-functions-1
round() {
    (( int( (10*($1 + 0.5)) / 10) ))
    true
}
functions -M round

# the operations here deserve some explanation, a simpler idea is the common
# idiom:
#   `: ${param:=value}`
# here we have a no-op command `:` followed by variable substitution the overall
# result is to set `param` to `value` if `param` is unset.
#
# `(P)` is a parameter expansion flag allowing one to indirectly reference a
# variable much like Bash's namerefs. For example, if you have `foo=bar` and
# `bar=baz`, the string `${(P)foo}` will expand to `baz`.
#
# `::=` is used here so that something like `${param::=value}` will always set
# `param` to `value`.
#
# https://zsh.sourceforge.io/Guide/zshguide03.html#l33
# https://zsh.sourceforge.io/Doc/Release/Expansion.html#Parameter-Expansion-1
# https://zsh.sourceforge.io/Doc/Release/Expansion.html#index-substitution_002c-parameter_002c-flags
# https://www.zsh.org/mla/workers/2021/msg01011.html
# https://unix.stackexchange.com/questions/707464/zsh-pass-variable-by-reference-and-modify-its-value-like-bashs-local-n-name
trim_element() {
    if [[ $1 == dir ]]; then
        : ${(P)1::=…${(P)1[$(($2 + 2)),-1]}}
    else
        : ${(P)1::=${(P)1[1,-$(($2 + 2))]}…}
    fi
}

trimmable=(title fg_cmd dir)
trim_border_text() {
    # force floating point operation so that int/int = float
    # e.g 1/2 = 0.5 instead of being truncated to 0
    setopt localoptions force_float

    local ele
    typeset -Al elements
    for ele in $trimmable; do
        elements[${#${(P)ele}}]+="$ele "
    done

    local element_lens=(${(nOk)elements})
    local elements_trim=(${(s: :)elements[$element_lens[1]]})
    local trim=$(( round( (border_len - border_limit)/${#elements_trim} ) ))

    # if trim has been rounded down to zero something needs trimmed by just one
    if ((trim == 0)); then
        trim_element $elements_trim[1] 1
        return
    fi

    if [[ -n $element_lens[2] ]]; then
        trim=$((min(trim, element_lens[1] - element_lens[2])))
    fi
    for ele in $elements_trim; do
        trim_element $ele $trim
    done
}

get_border_text() {
    print -nv border_text -- \
        "" \
        \#$idx \
        $title \
        \[$fg_cmd\] \
        $fg_pid \
        $bg_pids \
        $dir \
        $alt \
        ""
    border_len=${#border_text}
}

# $1 - pane_width
# $2 - pane_idx
# $3 - pane_title
# $4 - pane_tty
# $5 - pane_current_path
# $6 - alternate_on
border_limit=$((round($1 * 3 / 4)))
idx=$2
title=$3
tty=$4
print -Dv dir -- $5 # replace prefixes with ~ as appropriate
(($6)) && alt="<Alt Mode>"

while read state pid cmd; do
    if [[ $state == *+ ]]; then
        fg_cmd=${cmd#-}
        fg_pid=$pid
    elif [[ $cmd != -zsh ]]; then
        bg_pids+=($pid)
    fi
done <<< $(ps --format stat,pid,cmd --no-heading --sort -pid --tty $tty)
bg_pids=${bg_pids:+(${(j:, :)bg_pids})}

get_border_text
while ((border_len > border_limit)); do
    trim_border_text
    get_border_text
done

print -n $border_text

