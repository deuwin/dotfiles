####
# Options
#
# Notes
# when inspecting options use `set -o` which will also show the default options
#

####
# Behaviour
#
setopt correct              # correct spelling mistakes
setopt interactive_comments # allow comments at shell prompt
setopt longlistjobs         # also display PID when suspending a process
setopt notify               # report status of background jobs immediately
setopt extended_glob        # allow use of ‘#’, ‘~’ and ‘^’ in globbing (assuming I remember...)

# disable flow control - reclaim Ctrl+s and Ctrl+q for bindkey
# Also so you don't accidentally stop terminal output with Ctrl+s
# For reference Ctrl+q restores terminal output
unsetopt flow_control

# print warning when function creates global variable
setopt warn_create_global


####
# History
#
# Useful history expansions
#   !! - previous command in full
#   !0 - first input word (command).
#   !* - all arguments of previous command
#   !^ - first argument of previous command
#   !$ - last argument of previous command
#   !n - nth argument of previous command
#
setopt   append_history         # append to history file, not replace
setopt   inc_append_history     # append immediately to history file
unsetopt share_history          # don't share history between terminal sessions
setopt   extended_history       # write the history file in the ':start:elapsed;command' format
setopt   hist_expire_dups_first # expire a duplicate event first when trimming history
setopt   hist_ignore_all_dups   # delete an old recorded event if a new event is a duplicate
setopt   hist_find_no_dups      # do not display a previously found event
setopt   hist_ignore_space      # do not record an event starting with a space
setopt   hist_save_no_dups      # do not write a duplicate event to the history file
setopt   hist_verify            # do not execute immediately upon history expansion


####
# Navigation
#
setopt auto_cd           # cd without cd
setopt auto_pushd        # Push visited directories to the stack
setopt pushd_ignore_dups # Don't store duplicates in the stack
setopt pushd_minus       # Reverse meaning of `+` and `-`, more consistent with `cd -`
setopt pushd_silent      # Don't print the directory stack after pushd or popd
