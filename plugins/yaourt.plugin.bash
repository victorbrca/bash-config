#
## about:Aliases for yaourt
#

# help:aur:Handler for yaourt
aur ()
{
  local usage aur_log package

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
          if [[ $(/usr/bin/yaourt -Qu --aur | grep aur &> /dev/null ; echo $?) -eq 0 ]] ; then
            echo -e "\nThere are AUR packages waiting to be updated. Would you like to go ahead?"
            read -p "[y|n]: " answr
            case $answr in
              y|Y|yes|YES) /usr/bin/yaourt -Syua ;;
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
