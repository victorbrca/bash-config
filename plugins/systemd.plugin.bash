#
## about:SystemD aliases
#

if command -v systemctl > /dev/null ; then
  # help:sc:systemctl
  alias sc='systemctl'
  
  # help:scr:systemctl restart
  alias scr='systemctl restart'
  
  # help:scdr:systemctl daemon-reload
  alias scdr='systemctl daemon-reload'
  
  # help:scu:systemctl --user
  alias scu='systemctl --user'
  
  # help:scur:systemctl --user restart
  alias scur='systemctl --user restart'
  
  # help:scudr:systemctl --user daemon-reload
  alias scudr='systemctl --user daemon-reload'
  
  # help:scst:systemctl status
  alias scst='systemctl status'
  
  # help:scust:systemctl --user status
  alias scust='systemctl --user status'
  
  # help:sce:systemctl stop
  alias sce='systemctl stop'
  
  # help:scue:systemctl --user stop
  alias scue='systemctl --user stop'
  
  # help:scs:systemctl start
  alias scs='systemctl start'

  # help:scus:systemctl --user start
  alias scus='systemctl --user start'
fi