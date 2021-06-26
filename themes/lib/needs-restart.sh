#!/bin/bash

distro="$(grep '^ID=' /etc/os-release | awk -F"=" '{print $2}' | tr -d '"')"
indicator="↺"

# Arch
if [[ "$distro" == "arch" ]] ; then
  current_kernel="$(uname -r)"
  boot_kernel="$(file -bL /boot/vmlinuz-linux | grep -o 'version [^ ]*' | cut -d ' ' -f 2)"
  if [[ "$current_kernel" != "$boot_kernel" ]] ; then
    echo "$indicator"
  fi
  # echo "$indicator"
# Centos or rhel
elif [[ $distro =~ centos|rhel ]] ; then
  needs-restarting -r &> /dev/null
  if [[ $? -eq 1 ]] ; then
    echo "$indicator"
  fi
# Ubuntu
elif [[ "$distro" == "ubuntu" ]] ; then
  if [ -f /var/run/reboot-required ] ; then
    echo "$indicator"
  fi
fi
