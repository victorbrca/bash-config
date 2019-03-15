#
## about:SystemD aliases
#

# help:sc:systemctl {user}[service] [start|stop|restart|status|enable|disable]
sc ()
{
  usage="Usage: sc {user}[service] [start|stop|restart|status|enable|disable]"

  if [[ "$1" == "user" ]] ; then
    service="$2"
    action="$3"
    systemctl --user "$action" "$service"
  else
    service="$1"
    action="$2"
    systemctl "$action" "$service"
  fi
}


# Bach completion for sc
__listSystemdServices ()
{
  local cur
  cur=${COMP_WORDS[COMP_CWORD]}

  if [[ "${COMP_WORDS[1]}" = "user" &&  ! "${COMP_WORDS[3]}" || "${COMP_WORDS[1]}" = "$cur" ]] ; then
    case ${COMP_WORDS[1]} in
      user)
        file_list="$(ls /lib/systemd/user/*.service ${HOME}/.config/systemd/user/*.service 2> /dev/null | awk -F"/" '{print $NF}')"
        ;;
      *)  
        file_list="$(ls /lib/systemd/system/*.service /etc/systemd/system/*.service 2> /dev/null | awk -F"/" '{print $NF}')"
        ;;
    esac

    COMPREPLY=($(compgen -W "$file_list" -- "${cur}"))
    set +x
    return 0
  elif [[ "${COMP_WORDS[3]}" = "$cur" || "${COMP_WORDS[2]}" = "$cur" ]] ; then
    COMPREPLY=($(compgen -W "start stop restart status enable disable" "$cur"))
    set +x
    return 0
  fi  
}

complete -F __listSystemdServices -o filenames sc
