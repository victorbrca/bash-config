#
## about:A simplified powerline prompt
#

#  ✓ victor ⏻ 94% ⏳ ~/bin master  ✔ 
#  |   |    |     |    |     |- Git status
#  |   |    |     |    |- PWD
#  |   |    |     |- sudo status
#  |   |    |- battery indicator and percentage
#  |   |- User
#  |- $?

## User choices
battery_info="y"
sudo_info="y"
# Choose from: ⌚, ⏳, ✰, ⵌ, ✷
sudo_icon="⏳"

#Colors
PS_Green='\[\e[32m\]'
PS_Red='\[\e[31m\]'
PS_Purple='\[\e[35m\]'
PS_Color_Off='\[\e[0m\]'

_sudo_status () {
  # Background
  On_Black='\001\e[40m\002'

  # Foreground
  Yellow='\001\e[0;33m\002'

  sudo -n uptime 2>&1 | grep -q "load"
  if [[ $? -eq 0 ]] ; then
    echo -e "${Yellow}${On_Black}$sudo_icon"
  fi
}

_git_branch () 
{
  local gitbranch gitstatus modified gitinfo ahead_behind

  gitbranch=$(git branch 2> /dev/null | grep '\*' | sed -e 's/* \(.*\)/\1/')

  # We are in a Git folder
  if [ "$gitbranch" ] ; then
    # Get the branch
    gitinfo="${gitbranch} "

    # Get the full status
    gitstatus=$(git status)

    # Get count of modded files
    modified="$(echo "$gitstatus" | grep -P '\t' | wc -l)"
    if (( modified > 0 )) ; then
      gitinfo="${gitinfo} ✚${modified}"
    else
      gitinfo="${gitinfo} ✔"
    fi

    # Get ahead behind
    ahead_behind=$(echo "$gitstatus"  | grep 'Your branch is' | awk '{print $4}')
    case $ahead_behind in
      ahead) gitinfo="${gitinfo} ↥" ;;
      behind) gitinfo="${gitinfo} ↧" ;;
      *) unset ahead_behind ;;
    esac

    printf " ${gitinfo} "
  fi
}

_git_colors () {
  local On_Purple On_Green Black White Purple Green

  # Background
  On_Purple='\001\e[45m\002'
  On_Green='\001\e[42m\002'

  # Foreground
  Black='\001\e[0;30m\002'
  White='\001\e[0;37m\002'
  Purple='\001\e[0;35m\002'
  Green='\001\e[0;32m\002'
  Blue='\001\e[0;34m\002'

  # Reset
  Color_Off='\001\e[0m\002'
  # Color_Off='\[\e[0m\]'

  git_status=$(_git_branch)

  if [ "$git_status" ] ; then
    if [[ "$(echo $git_status | grep -q ✔ ; echo $?)" -eq 1 ]] ; then
      printf "${Blue}${On_Purple}${White}${On_Purple}${git_status}${Purple}${Color_Off}"
    else
      printf "${Blue}${On_Green}${Black}${On_Green}${git_status}${Green}${Color_Off}"
    fi
  else
    printf "${Blue}"
  fi
}

_get_battery_info () {
  local Yellow Red On_Black Green ac_adapter_disconnected

  # Background
  On_Black='\001\e[40m\002'

  # Foreground
  Green='\001\e[0;32m\002'
  Blinking_Green='\001\e[5;32;40m\002'
  Yellow='\001\e[0;33m\002'
  Red='\001\e[0;31m\002'

  ac_adapter_info="$(upower -i $(upower -e | grep BAT) |  egrep '(state|percentage)')"
  ac_adapter_disconnected=$(echo "$ac_adapter_info" | grep 'state' | grep -q 'discharging' ; echo $?)
  ac_adapter_connected=$(echo "$ac_adapter_info" | grep 'state' | grep -q 'charging' ; echo $?)

  if (( ac_adapter_disconnected == 0 )) ; then
    battery_percentage="$(echo "$ac_adapter_info" | grep percentage | grep -o "[0-9]\+")"
    battery_icon="${On_Black}⏻ "
    if (( battery_percentage > 70 )) ; then
      echo -e "${Green}${battery_icon}${battery_percentage}% "
    elif (( battery_percentage < 70 )) && (( battery_percentage > 40 )) ; then
      echo -e "${Yellow}${battery_icon}${battery_percentage}% "
    elif (( battery_percentage < 40 )) ; then
      echo -e "${Red}${battery_icon}${battery_percentage}% "
    fi
  elif (( ac_adapter_connected == 0 )) ; then
    battery_icon="${On_Black}⚡"
    echo -e "${Green}${battery_icon}"
  fi
}

# Sets up the prompt
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
  ps1_header="\u@\h"
else
  ps1_header="\u"
fi

export PS1="${On_Black} \`if [ \$? = 0 ]; then echo ${PS_Green}✓${PS_Color_Off}; \
else echo ${PS_Red}✗${PS_Color_Off}; fi\`${Yellow}${On_Black} $ps1_header \
\`if [ \$battery_info = y ] ; then _get_battery_info ; fi\`\`if [ \$sudo_info \
= y ] ; then _sudo_status ; fi\`${Black}${On_Blue}${Blue}${On_Blue}\
${White}${On_Blue}\w \`_git_colors\`${Color_Off} "

export PS2="${PS_Green}>>${PS_Color_Off} "
export PS4="${PS_Purple}++${PS_Color_Off} "