#
## about:Misc notification aliases
#

# help:notify-audio:Displays a notification and an alert
notify-audio () {
  if [ $# -lt 1 -o $# -gt 2 ] ; then
   echo "Please give a message as parameter:"
   echo "> notify-audio \"{Title}\" \"my message\""
   return 0
  elif [ $# -eq 1 ] ; then
    notify-send "Notify Audio" "$1"
    paplay /usr/share/sounds/freedesktop/stereo/complete.oga
  elif [ $# -eq 2 ] ; then
    notify-send "$1" "$2"
    paplay /usr/share/sounds/freedesktop/stereo/complete.oga
  fi
}

# help:notify-me:Sends notification via simplepush
notify-me () {
  if [ ! -x "${HOME}/bin/simplepush.sh" ] ; then
    echo "Missing simplepush.sh"
    return 1
  fi

  if [ $# -ne 2 ] ; then
   echo "Please give a message as parameter:"
   echo "> notify-me \"Title\" \"my message\""
   return 0
  else
    ${HOME}/bin/simplepush.sh "$1" "$2"
  fi
}

# help:notify-script:Sends simplepush notification of script
notify-script () {
  last_command_exit_status="$?"
  local last_command

  if [ ! -x "${HOME}/bin/simplepush.sh" ] ; then
    echo "Missing simplepush.sh"
    return 1
  fi

  last_command="$(history | tail -1 | sed 's/[0-9]\{1,5\}//' | sed -e 's/[0-9]\{1,2\}:[0-9]\{1,2\}//' | awk '{print $1}')"

  ${HOME}/bin/simplepush.sh  "$HOSTNAME" "The script \"$last_command\" has finished with exit code: $last_command_exit_status"
}
