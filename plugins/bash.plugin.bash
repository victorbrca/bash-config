#
## about:Settings for Bash
#

# Helps mispeling of dirs
shopt -s cdspell

# Let's setup the search path for the cd command
CDPATH=.

# Ignores case for auto completion
bind "set completion-ignore-case on"

## History search and bash completion settings
# Checks if .inputrc exists first
# if [ ! -f $HOME/.inputrc ] ; then
#   # It doesn't, so let's create it
#   STOP. COPY CURRENT INPUTRC HERE
# fi