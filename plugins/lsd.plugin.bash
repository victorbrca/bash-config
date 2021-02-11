#
## about:lsd aliases
#

if command -v lsd > /dev/null ; then
  
  # help:l1:ls -1
  alias l1='lsd -1'
  
  # help:ll:Lists files with indicator
  alias ll='lsd -l' 

  # help:la:Lists all files with indicator
  alias la='lsd -la' 

  # help:ltr:Lists files by time in reverse order with indicator
  alias ltr='lsd -ltr' 

  # help:ltra:Lists all files by time in reverse order with indicator
  alias ltra='lsd -ltra' 
else
  echo "[bash-config] lsd is not installed"
fi