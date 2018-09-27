#
## about:Aliases for pacman
#

# help:pac:Front end for pacman
pac ()
{
  local usage pac_log package answr

  usage="pac {install|remove|update|upgrade|search{info|files}|list{info|files}}"

  if [ -d "${HOME}/bin/var/log" ] ; then
    pac_log=${HOME}/bin/var/log/$(hostname)-pacman-install.log
  else
    pac_log="/dev/null"
  fi

  if (( $# < 1 )) && [[ $1 != "list" ]] ; then
    echo -e "$usage"
    return 0
  fi

  case $1 in
      install)
        if [ -f "$2" ] ; then
          shift
          sudo /usr/bin/pacman -U "$@"
        else
          shift
          sudo /usr/bin/pacman -Sy
          sudo /usr/bin/pacman -S "$@"
        fi
        if [[ $? -eq 0 ]] ; then
          echo -e "\n** Logging installed packages"
          for package in "$@" ; do
            echo -e "\t- Logging $package... \c"
            grep -q "$package" "$pac_log"
            if [[ $? -eq 0 ]] ; then
              echo "Already logged"
            else
              echo -e "$(date)\t-\tInstalled package: $package" >> "$pac_log"
              echo "ok"
            fi
          done
        fi
        ;;
      remove) shift ; sudo /usr/bin/pacman -Rs "$@";;
      update)
          sudo /usr/bin/pacman -Sy
          if [[ $(/usr/bin/pacman -Qu &> /dev/null ; echo $?) -eq 0 ]] ; then
            echo -e "\nThere are packages waiting to be updated. Would you like to go ahead?"
            read -p "[y|n]: " answr
            case $answr in
              y|Y|yes|YES) sudo /usr/bin/pacman -Syu ;;
            esac
          fi
          ;;
      upgrade) sudo /usr/bin/pacman -Syyu ;;
      search)
          case $2 in
            info) shift 2 ; /usr/bin/pacman -Si "$@" ;;
            files) shift 2 ; /usr/bin/pacman -Fl "$@" ;;
            *) 
              shift
              for package in "$@" ; do
                /usr/bin/pacman -Ss "$package"
                if (( $? != 0 )) ; then
                  echo -e "\n** Could not find $package in main repos. Searching AUR **"
                  yaourt -Ss $package
                fi
              done
              ;;
          esac
          ;;
      list) 
          case $2 in
            info) shift 2 ; /usr/bin/pacman -Qi "$@" ;;
            files) shift 2 ; /usr/bin/pacman -Ql "$@" ;;
            *) shift ; /usr/bin/pacman -Qs "$@" ;;
          esac
          ;;
      owns) shift ; sudo /usr/bin/pacman -Qo "$@";;
      *) echo "Invalid option" ; echo "$usage" ; return 1 ;;
  esac
}

