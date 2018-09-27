#
## about:Aliases for yum
#

# help:yumdate:Updates package list
alias yumdate='sudo yum check-update'

# help:yumgrade:Updates all packages
alias yumgrade='sudo yum update'

# help:yumse:Search for package
alias yumse='yum search'

# help:yumrm:Removes package
alias yumrm='sudo yum remove'

# help:yuminst:yum install
yuminst ()
{
  local log
  
  if [ -d "${HOME}/bin/var/log" ] ; then
    log=${HOME}/bin/var/log/$(hostname)-package-install.log
  fi

  echo -e "$(date)\t-\tInstalling packages: $*" >> "$log"
  sudo yum install "$*"
}
