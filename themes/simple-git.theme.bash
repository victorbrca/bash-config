#
## about:Displays a simple prompt with Git info
#

# ~/bin  master  ✚2 ✓ $

. ${bash_config_themes_folder}/lib/git-status.theme.bash

# Sets up the prompt for SSH and root
if [[ $(id -u) -eq 0  && (-n "$SSH_CLIENT" || -n "$SSH_TTY") ]] ; then
  ps1_header="\u\h:\w"
elif [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ] ; then
  ps1_header="\u@\h"
elif [[ $(id -u) -eq 0 ]] ; then
  ps1_header="\u:\w"
else
  ps1_header="\w"
fi

export PS1="${ps1_header} \`_git_branch\`\`if [ \$? = 0 ]; then echo ${green_color}✓${reset_color}; else echo ${red_color}✗${reset_color}; fi\` \$ "

export PS2=">> "
export PS4="++ "