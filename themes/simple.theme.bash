#
## about:Displays a simple prompt
#

# ~/bin ✓ $

if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
  PS1="\h:\w \`if [ \$? = 0 ]; then echo ${green_color}✓${reset_color}; else echo ${red_color}✗${reset_color}; fi\` \$ "
else
  PS1="\w \`if [ \$? = 0 ]; then echo ${green_color}✓${reset_color}; else echo ${red_color}✗${reset_color}; fi\` \$ "
fi
