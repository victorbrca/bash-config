#
## about:Settings for Bash
#

# Let's setup the search path for the cd command
export CDPATH='.:~'

# Sets up time for history
export HISTTIMEFORMAT="+%Y/%m/%d %T "

# Avoid duplicates
export HISTCONTROL=ignoredups:erasedups

# When the shell exits, append to the history file instead of overwriting it
shopt -s histappend