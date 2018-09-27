#
## about:exa aliases
#


if command -v exa > /dev/null ; then
  export EXA_COLORS="hd=1;4;33:ur=37.1:uw=37.1:ux=37.1:ue=37.1:gr=37.1:gw=37.1:gx=37.1:tr=37.1:tw=37.1:tx=37.1:uu=36:gu=36:sn=37.1:sb=37.1:da=37.1"

  # help:l:ls -l
  alias l='exa -lhg'
  
  # help:l1:ls -1
  alias l1='exa -1'
  
  # help:ll:Lists files with indicator
  alias ll='exa -lhg' 

  # help:la:Lists all files with indicator
  alias la='exa -lhga' 

  # help:ltr:Lists files by time in reverse order with indicator
  alias ltr='exa -lhgs modified' 

  # help:ltra:Lists all files by time in reverse order with indicator
  alias ltra='exa -lhgas modified' 
else
  echo "[bash-config] exa is not installed"
fi