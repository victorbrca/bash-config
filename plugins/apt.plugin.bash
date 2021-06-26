#
## about:apt and dpkg aliases
#


# help:aptdate:Updates package list
alias aptdate='sudo apt update'

# help:aptgrade:Updates all packages
alias aptgrade='sudo apt upgrade'

# help:apts:Search for package
alias apts='apt search'

# help:aptrm:Removes package
alias aptrm='sudo apt remove'


# help:aptinst:Install apt packages
aptinst ()
{                                
  if [ -d "${HOME}/bin/var/log" ] ; then
    apt_log=${HOME}/bin/var/log/$(hostname)-apt-install.log
  else
    apt_log="/dev/null"
  fi

  sudo apt install "$@"

  if [[ $? -eq 0 ]] ; then
    echo -e "\n** Logging installed packages"
    for package in "$@" ; do
      echo -e "\t- Logging $package... \c"
      grep -q "$package" "$apt_log"
      if [[ $? -eq 0 ]] ; then
        echo "Already logged"
      else
        echo -e "$(date)\t-\tInstalled package: $package" >> "$apt_log"
        echo "ok"
      fi
    done
  fi
}


# help:debinst:# help: Install deb packages
debinst ()
{
  if [ ! -f "$@" ] ; then
    echo "file not found"
    return 1
  fi
  if [ -d "${HOME}/bin/var/log" ] ; then
    dpkg_log=${HOME}/bin/var/log/$(hostname)-dpkg-install.log
  fi

  sudo /usr/bin/dpkg -i "$@"

  if [[ $? -eq 0 ]] ; then
    echo -e "\n** Logging installed packages"
    for package in "$@" ; do
      package_name="$(basename $package)"
      echo -e "\t- Logging $package_name... \c"
      grep -q "$package_name" "$dpkg_log"
      if [[ $? -eq 0 ]] ; then
        echo "Already logged"
      else
        echo -e "$(date)\t-\tInstalled package: $package_name" >> "$dpkg_log"
        echo "ok"
      fi
    done
  fi
}