#
## about:Aliases for yay 
#

# help:aur:Handler for yay
aur ()
{
  local usage aur_log package update_count

  usage="aur {install|update|upgrade|search|info}"

  if [ -d "${HOME}/bin/var/log" ] ; then
    aur_log=${HOME}/bin/var/log/$(hostname)-pacman-install.log
  else
    aur_log="/dev/null"
  fi

  case $1 in
      install)
        shift
        /usr/bin/yay -Say --answerupgrade none --answerclean all --answerdiff none --answeredit none "$@"
        if [[ $? -eq 0 ]] ; then
          echo -e "\n** Logging installed packages"
          for package in "$@" ; do
            echo -e "\t- Logging $package... \c"
            grep -q "$package" "$aur_log"
            if [[ $? -eq 0 ]] ; then
              echo "Already logged"
            else
              echo -e "$(date)\t-\tInstalled package: $package" >> "$aur_log"
              echo "ok"
            fi
          done
        fi
        ;;
      search)
        shift
        for package in "$@" ; do
          /usr/bin/yay -Ssa --sortby votes --topdown "$package"
        done
        ;;
      info) shift ; /usr/bin/yay -Sia mplayer "$@" ;;
      update)
          if [[ $# -gt 1 ]] ; then
            shift
            /usr/bin/yay -Sa --answerupgrade none --answerclean none --answerdiff none --answeredit none "$@"
          else
            /usr/bin/yay -Sya
            update_count=$(yay -Qum | wc -l)
            if (( update_count > 0 )) ; then
              echo -e "\nThere are $update_count AUR packages waiting to be updated. Would you like to go ahead?"
              read -p "[y|n]: " answr
              case $answr in
                y|Y|yes|YES) yes | /usr/bin/yay -Sua --answerupgrade none --answerclean none --answerdiff none --answeredit none ;;
              esac
            fi
          fi
          ;;
      upgrade) shift ; yes | /usr/bin/yay -Syua --answerupgrade none --answerclean none --answerdiff none --answeredit none ;;
      *) 
        echo "Invalid option"
        echo "$usage"
        return 1
        ;;
  esac
}

# help:checkupdates-aur:Shows available updates for aur
alias checkupdates-aur='yay -Qum'

complete -W 'install update search list remove upgrade' aur
