#
## about:Aliases for GNU Screen
#

# help:getScreens:Connects to the first detached screen
getScreens ()
{
  _screens=$(screen -ls | grep 'Detached' | awk '{ print $1 }')
  if [ -n "$_screens" ] ; then
    screen -r "$_screens"
  else
    echo "No screens running"
  fi
}

# help:lscreen:Lists all screens
alias lscreen='screen -ls'