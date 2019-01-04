#
## about:Settings for Bash
#

# Let's setup the search path for the cd command
export CDPATH='.:~'

# Set history size to 10k (10000)
export HISTSIZE=10000
export HISTFILESIZE=10000

# Sets up time for history
export HISTTIMEFORMAT="+%Y/%m/%d %T "

# Avoid duplicates
export HISTCONTROL=ignoredups:erasedups

# When the shell exits, append to the history file instead of overwriting it
shopt -s histappend

# Less Colors for Man Pages
export LESS_TERMCAP_mb=$'\e[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\e[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\e[0m'           # end mode
export LESS_TERMCAP_se=$'\e[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\E[30;47m'       # highlights - Black on white
export LESS_TERMCAP_ue=$'\e[0m'           # end underline
export LESS_TERMCAP_us=$'\e[04;38;5;146m' # begin underline