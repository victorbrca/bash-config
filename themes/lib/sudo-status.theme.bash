_sudo_status () {
  sudo -n uptime 2>&1 | grep -q "load"
  if [[ $? -eq 0 ]] ; then
    #echo "⌚"
    echo "⏳"
    #echo "✰ "
    #echo "ⵌ "
    #echo "✷ "
  fi
}
