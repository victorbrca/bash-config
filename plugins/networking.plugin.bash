#
## about:Mist networking aliases
#

# help:external-ip:Shows external IP
alias external-ip='wget http://checkip.dyndns.org/ -O - -o /dev/null | cut -f7 -d"<" | cut -f2 -d">" '

# help:pping:Prettyping with no legend
pping() {
  if command -v prettyping &> /dev/null; then
    prettyping --nolegend $1
  else
    echo "Please install prettyping"
  fi
}

# help:aping:Audio feedback for ping
aping() {
  ping $1 | awk -F[=\ ] '/me=/{t=$(NF-1);f=3000-14*log(t^20);c="play -q -n synth 1 pl " f;print $0;system(c)}'
}

# help:if0:Displays IP for eth0
if0() {
  if_device="$(ls -1 --color=never /sys/class/net | grep -E -v '(lo|w.*)' | head -1)"
  [ ! "$if_device" ] && {
    echo "Primary eth not installed"
    return 0
  }
  ifconfig "$if_device" | grep 'inet ' | awk -v idevice="$if_device" '{ print idevice ": " $2 }'
}

# help:if0:Sameas if0
alias eth0='if0'

# help:if1:Displays IP for eth1
if1() {
  if1_device="$(ls --color=never /sys/class/net | grep -E -v '(lo|w.*)' | nl | grep -E '^ *2' | awk '{print $2}')"
  [ ! "$if1_device" ] && {
    echo "Secondary eth not installed"
    return 0
  }
  ifconfig "$if1_device" | grep 'inet ' | awk -v i1device="$if1_device" '{ print i1device ": " $2 }'
}

# help:eth1:Same as if1
alias eth1='if1'

# help:wlan0:Displays IP for wlan interface
wlan0() {
  wlan_device="$(ls --color=never /sys/class/net | grep -E -v '(lo|e.*)')"
  [ ! "$wlan_device" ] && {
    echo "No Wireless device installed"
    return 0
  }
  ifconfig "$wlan_device" | grep 'inet ' | awk -v wdevice="$wlan_device" '{ print wdevice ": " $2 }'
}

# help:aps:APs info
aps() {
  wlan_device="$(ls --color=never /sys/class/net | grep -E -v '(lo|e.*)')"
  [ ! "$wlan_device" ] && {
    echo "No Wireless device installed"
    return 0
  }
  iwlist wlan0 scanning | grep -E "ESSID|Channel|Frequency|Encryption|Quality"
}

# help:netgrep:Same as 'netstat -an | grep '
netgrep() {
  _header=$(netstat -an | head -n 2)
  _val=$(netstat -an | grep $1 | grep -v grep)
  echo -e "$_header\n$_val"
  unset _header _val
}

# help:get-ip-info:Gets IP information
get-ip-info() {
  # https://ipwhois.io/documentation
  # Other options - https://ip-api.com/docs/api:json
  if [ ! "$1" ]; then
    echo "Usage: get-ip-info [ipv4]"
    return 0
  fi
  # Makes sure that we have an IP
  if [[ ! $1 =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    echo "Please provide a valid IP"
    return 1
  fi

  curl -s "https://ipwho.is/${1}" | jq -r
}
