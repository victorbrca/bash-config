#
## about:Aliases for yay 
#

# help:aur:Handler for yay
aur ()
{
  local usage aur_log package update_count

  usage="aur {install|update|upgrade|search|info}"

  # Setup log folder
  if [ -d "${HOME}/bin/var/log" ] ; then
    aur_log=${HOME}/bin/var/log/$(hostname)-pacman-install.log
  else
    aur_log="/dev/null"
  fi

  # Checks if we are using a aur_builder user
  if [ $(id aur_builder &> /dev/null ; echo $?) -eq 0 ] ; then
    command_yay="/usr/bin/sudo -u aur_builder /usr/bin/yay"
  else
    command_yay="/usr/bin/yay"
  fi

  case $1 in
      install)
        shift
        $command_yay -Say --answerupgrade none --answerclean all --answerdiff none --answeredit none "$@"
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
          $command_yay -Ssa --sortby votes --topdown "$package"
        done
        ;;
      info) shift ; $command_yay -Sia mplayer "$@" ;;
      update)
          if [[ $# -gt 1 ]] ; then
            shift
            $command_yay -Sa --answerupgrade none --answerclean none --answerdiff none --answeredit none "$@"
          else
            $command_yay -Sya
            update_count=$(yay -Qum | wc -l)
            if (( update_count > 0 )) ; then
              echo -e "\nThere are $update_count AUR packages waiting to be updated. Would you like to go ahead?"
              read -p "[y|n]: " answr
              case $answr in
                y|Y|yes|YES) yes | $command_yay -Sua --answerupgrade none --answerclean none --answerdiff none --answeredit none ;;
              esac
            fi
          fi
          ;;
      upgrade) shift ; yes | $command_yay -Syua --answerupgrade none --answerclean none --answerdiff none --answeredit none ;;
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
