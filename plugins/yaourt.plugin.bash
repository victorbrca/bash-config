#
## about:Aliases for yaourt
#

# help:aur:Handler for yaourt
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
        yaourt -Sy "$@"
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
          /usr/bin/yaourt -Ss "$package"
        done
        ;;
      info) shift ; /usr/bin/yaourt -Si "$@" ;;
      update) 
          /usr/bin/yaourt -Sy --aur
          update_count=$(yaourt -Qu -a | grep aur | grep -E -v "($(grep '^IgnorePkg' /etc/pacman.conf | awk -F"=" '{print $2}' | sed 's/^ //' | sed 's/ /|/g'))" | wc -l)
          if (( update_count > 0 )) ; then
            echo -e "\nThere are $update_count AUR packages waiting to be updated. Would you like to go ahead?"
            read -p "[y|n]: " answr
            case $answr in
              y|Y|yes|YES) /usr/bin/yaourt -Sua ;;
            esac
          fi
          ;;
      upgrade) shift ; /usr/bin/yaourt -Syua ;;
      *) 
        echo "Invalid option"
        echo "$usage"
        return 1
        ;;
  esac
}


complete -W 'install update search list remove upgrade' aur
