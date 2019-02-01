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
battery_info="n"
sudo_info="y"
# Choose from: ⌚, ⏳, ✰, ⵌ, ✷
sudo_icon="⚙"

#Colors
PS_Green='\[\e[32m\]'
PS_Red='\[\e[31m\]'
PS_Purple='\[\e[35m\]'
PS_Color_Off='\[\e[0m\]'
PS_On_Gray='\[\e[48;5;241m\]'
PS_Gray='\[\e[38;5;241m\]'
PS_Black='\[\e[0;30m\]'
PS_On_White='\[\e[47m\]'
PS_Blue='\[\e[0;34m\]'
PS_On_Blue='\[\e[44m\]'
PS_White='\[\e[0;37m\]'
PS_On_Black='\[\e[40m\]'

_sudo_status () {
  # Background
  On_Black='\001\e[40m\002'
  On_Gray='\001\e[48;5;240m\002'

  # Foreground
  Yellow='\001\e[0;33m\002'

  sudo -n uptime 2>&1 | grep -q "load"
  if [[ $? -eq 0 ]] ; then
    sudo_status="${PS_Black}${PS_White}${PS_On_Black} $sudo_icon ${PS_Color_Off}${PS_On_Black}"
    let ps1l_cnt+=5
  else
    unset sudo_status
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

    # Get the full statu${PS_Color_Off}${PS_On_Black}s
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

    #let ps1l_cnt+=${#gitinfo}
    #let ps1l_cnt+=2
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
  let ps1l_cnt+=${#git_status}

  if [ "$git_status" ] ; then
    if [[ "$(echo $git_status | grep -q ✔ ; echo $?)" -eq 1 ]] ; then
      git_prompt_info="${Blue}${On_Purple}${White}${On_Purple}${git_status}${Purple}${Color_Off}"
      let ps1l_cnt+=3
    else
      git_prompt_info="${Blue}${On_Green}${Black}${On_Green}${git_status}${Green}${Color_Off}"
      let ps1l_cnt+=3
    fi
  else
    git_prompt_info="${Blue}"
    let ps1l_cnt+=1
  fi

  # Add spaces
  let ps1l_cnt+=1
}

_get_battery_info () {
  local Yellow Red On_Gray On_Black Green ac_adapter_disconnected battery_icon \
    battery_prefix battery_percentage

  # Background
  On_Black='\001\e[40m\002'
  On_Gray='\001\e[48;5;240m\002'
  Gray='\001\e[38;5;241m\002'

  # Foreground
  Green='\001\e[0;32m\002'
  Blinking_Green='\001\e[5;32;40m\002'
  Yellow='\001\e[0;33m\002'
  Red='\001\e[0;31m\002'

  ac_adapter_info="$(upower -i $(upower -e | grep BAT) |  egrep '(state|percentage)')"
  ac_adapter_disconnected=$(echo "$ac_adapter_info" | grep 'state' | grep -q 'discharging' ; echo $?)
  ac_adapter_connected=$(echo "$ac_adapter_info" | grep 'state' | grep -q 'charging' ; echo $?)

  if [ "$sudo_status" ] ; then
    battery_prefix="${Black}${On_Black}"
    let ps1r_cnt+=1
  else
    battery_prefix="${Black}${On_Black} "
    let ps1r_cnt+=2
  fi

  battery_percentage="$(echo "$ac_adapter_info" | grep percentage | grep -o "[0-9]\+")"
  if (( battery_percentage == 100 )) ; then
    battery_status="${battery_prefix}${White}${On_Black}${battery_percentage}% "
    let ps1r_cnt+=5
  elif (( battery_percentage > 70 )) ; then
    battery_status="${battery_prefix}${White}${On_Black}${battery_percentage}% "
    let ps1r_cnt+=4
  elif (( battery_percentage < 70 )) && (( battery_percentage > 40 )) ; then
    battery_status="${battery_prefix}${Yellow}${On_Black}${battery_percentage}% "
    let ps1r_cnt+=4
  elif (( battery_percentage < 40 )) ; then
    battery_status="${battery_prefix}${Red}${On_Black}${battery_percentage}% "
    let ps1r_cnt+=4
  fi
}

_last_exit_status ()
{
  if [ $? = 0 ] ; then
    exit_status=$(echo -e "${PS_Green}✓${PS_Color_Off}")
  else
    exit_status=$(echo -e "${PS_Red}✗${PS_Color_Off}")
  fi

  # Add space before exit status
  let ps1l_cnt+=2
}

_setup_ssh_prompt ()
{
  local char_cnt

  if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    ps1_header="\u@\h"
    char_cnt=$((${#USER}+${#HOSTNAME}+1))
  else
    ps1_header="\u"
    char_cnt=$((${#USER}))
  fi

  let ps1l_cnt+=${char_cnt}

  # Add spaces before and after username
  let ps1l_cnt+=2
}

_prompt_left ()
{
  _last_exit_status
  _setup_ssh_prompt
  _git_colors
  # Convert prompt
  PWD_HOME="${PWD/\/home\/victor/\~}"
  let ps1l_cnt+=${#PWD_HOME}

  # Add spaces before and after pwd
  let ps1l_cnt+=1

  # Add spaces for special chars
  let ps1l_cnt+=2

  PS1L="${PS_White}${PS_On_Gray} ${exit_status}${PS_White}${PS_On_Gray} $ps1_header \
${PS_Gray}${PS_On_Blue}${PS_Blue}${PS_On_Blue}\
${PS_White}${PS_On_Blue}\w ${git_prompt_info}${PS_Color_Off}"
}

_date ()
{
  local date_now preffix
  date_now="$(date '+%H:%M%P')"
  ps1r_cnt=${#date_now}
  let ps1r_cnt+=2
  if [[ "$battery_info" = "y" || "$sudo_status" ]] ; then
    preffix="${PS_White}${On_Black}"
  else
    preffix="${PS_White}"
  fi
  date_str="${preffix}${PS_Black}${PS_On_White} ${date_now} ${PS_Color_Off}"
}

_prompt_right ()
{
  _date
  if [[ "$battery_info" = "y" ]] ; then
    _get_battery_info
  fi
  if [[ "$sudo_info" = "y" ]] ; then
    _sudo_status
  fi
  PS1R="${sudo_status}${battery_status}${date_str}"
  unset sudo_status battery_status date_str
}

_prompt ()
{
  _prompt_left
  _prompt_right
  indent=$(($COLUMNS-${ps1r_cnt}-${ps1l_cnt}))
  indent_spaces="$(printf '%0.s ' $(seq 1 $indent))"
  PS1=$(printf "%s${indent_spaces}%s\n\$ " "$PS1L" "$PS1R")
  unset ps1l_cnt
  unset ps1r_cnt
}

PROMPT_COMMAND=_prompt

export PS2="${PS_Green}>>${PS_Color_Off} "
export PS4="${PS_Purple}++${PS_Color_Off} "
