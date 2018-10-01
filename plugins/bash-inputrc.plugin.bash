#
## about:Configs for Bash's inputrc
#

# Helps mispeling of dirs
shopt -s cdspell

# Let's setup the search path for the cd command
CDPATH=.

# Ignores case for auto completion
bind "set completion-ignore-case on"

# Sets up arrow to search history
bind '"\e[A": history-search-backward'

# Sets down arrow to search history backwards
bind '"\e[B":history-search-forward'

# Shows possible matches instead of ringing bell
set show-all-if-ambiguous on

# Ignores case for auto completion
set completion-ignore-case on

# Matches hidden files (usually already enabled)
set match-hidden-files on

# Sets tab to cycle through auto complete
bind TAB:menu-complete
# reverse with shift
bind '"\e[Z": "\e-1\C-i"'

# Sets color for file types
set colored-stats on
