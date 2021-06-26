#
## about:Aliases for pacman
#

# help:pac:Front end for pacman
pac ()
{
  local usage pac_log package answr update_count search_lines

  usage="pac {install|remove|update|upgrade|search{info|files}|list{info|files}|clean{check}}"

  if ! command -v checkupdates > /dev/null ; then
    echo "[bash-config: pacman] pacman-contrib is not installed"
    #return 1
  fi

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
          # let's update first
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
              echo -e "$(date)\t-\tInstalled pacman package: $package" >> "$pac_log"
              echo "ok"
            fi
          done
        # elif [[ $? -eq 0 ]] ; then
        #   # let's see if we can find one item
        #   search_lines=$(/usr/bin/pacman -Ss $1 | egrep '.*/.*[0-9]' | wc -l)
        #   if (( search_lines = 1 )) ; then
        #     prompt_package="$(/usr/bin/pacman -Ss $1 | egrep '.*/.*[0-9]' | awk '{print $1}' | awk -F"/" '{print $2}')"
            
        #     echo "Did you mean"
        fi
        ;;
      remove) shift ; sudo /usr/bin/pacman -Rs "$@";;
      update)
          echo "Updating package list"
          sudo /usr/bin/pacman -Sy
          update_count=$(checkupdates 2> /dev/null | wc -l)

          if (( update_count > 0 )) ; then
            echo -e "\nThere are $update_count packages waiting to be updated. Would you like to go ahead?"
            read -p "[y|n]: " answr
            case $answr in
              y|Y|yes|YES) sudo /usr/bin/pacman -Su ;;
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
                  aur search $package
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
      clean)
          if [[ $# -eq 2 ]] ; then
            case $2 in
                check)
                    echo "** Old packages"
                    paccache -dv | tail -1
                    echo "** Stale packages"
                    paccache -dvu | tail -1
                    ;;
                *) echo $usage ;;
            esac
          else
            echo "** Cleaning old packages (keep 3)"
            paccache -rv | tail -1
            echo -e "\n** Cleaning stale packages"
            paccache -rvu | tail -1
          fi
          ;;
      *) echo "Invalid option" ; echo "$usage" ; return 1 ;;
  esac
}

# help:last_installed:List pacman installed packages
last_installed ()
{
  if [ -f "${HOME}/bin/var/log/$(hostname)-pacman-install.log" ] ; then
    tail -n20 "${HOME}/bin/var/log/$(hostname)-pacman-install.log"
  else
    echo "Could not find install packages personal log. Will display system install"
    cat /var/log/pacman.log | grep -i installed | tail -n20
  fi
}

complete -W 'install update search list remove upgrade clean' pac

# shellcheck disable=SC2120
checkupdates ()
{
  local opt

  # Check if 'checkupdates' is installed
  if ! command -v checkupdates > /dev/null ; then
    echo "[bash-config: pacman] pacman-contrib is not installed"
    return 1
  fi

  # checks if we are using pacaur or yay for AUR helper
  if command -v yay > /dev/null ; then
    checkupdates_aur="yay -Qum"
  elif command -v pacaur > /dev/null ; then
    checkupdates_aur="pacaur -Qum"
  else
    checkupdates_aur="[bash-config: pacman] Could not find an AUR helper. Will not show AUR update"
  fi

  # checks arguments
  if [[ $# -eq 1 ]] ; then
    if [[ "$1" == "-l" ]] ; then
      opt="long"
    elif [[ "$1" == "-a" ]] ; then
      opt="aur"
    else
      echo "Wrong option \"$1\""
      echo "Usage: checkupdates {-l long|-a aur}"
      return 1
    fi
  fi

  # Runs for aur only
  if [[ "$opt" == "aur" ]] ; then
    $checkupdates_aur
  # No option or long option
  else
    pac_update_text="$(/usr/bin/checkupdates)"
    aur_update_text="$($checkupdates_aur | grep -v bash-config)"
    # Adds count to output, including a 0
    pac_updates=$(echo "$pac_update_text" | grep '[a-z]' | wc -l)
    aur_updates=$(echo "$aur_update_text" | grep '[a-z]' | wc -l)
    total_updates=$(( pac_updates + aur_updates))
    if [[ "$opt" != "long" ]] ; then
      echo "There are a total of $total_updates packages to be updated"
      echo "Arch: $pac_updates"
      echo "AUR:  $aur_updates"
    elif [[ "$opt" == "long" ]] ; then
      if [[ $pac_updates -ne 0 ]] ; then
        echo "------------------------------"
        echo "Pacman: $pac_updates updates"
        echo "------------------------------"
        echo "$pac_update_text"
        echo ""
      fi

      if [[ $aur_updates -ne 0 ]] ; then
        echo "------------------------------"
        echo "AUR: $aur_updates updates"
        echo "------------------------------"
        echo "$aur_update_text"
      fi
    fi
  fi
}
