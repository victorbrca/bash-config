#
## about:Aliases for Bash
#

# regex highlight for grep
alias grep='grep --color=auto'

_cd__add__history ()
{
  ## Adding elements
  currentdir=$(pwd)
  # Only add if not in history
  if [[ "$(echo ${dirhistory[*]} | grep -q $currentdir ; echo $?)" -eq 1 ]] ; then
    dirhistory=( "$currentdir" "${dirhistory[@]}" )
  fi
  # dirhistory=( "${dirhistory[@]/$currentdir/}" )

  ## Remove last element
  if [[ "${#dirhistory[@]}" -gt 5 ]] ; then
    # Counts the words in the array
    arrayLength="${#dirhistory[@]}"

    # Subtracts 1
    let arrayLength=-1

    # Remove that address from the array
    unset dirhistory["$arrayLength"]
  fi

  ## Changes the directory
  if [ "$1x" = "x" ] ; then
    command cd ; tree -L 1 -tF
  else
    command cd "$1" ; tree -L 1 -tF
  fi
}

_cd__history ()
{
  local arg1
  if [[ $# -eq 0 ]] ; then
    arg1="-l"
  elif [[ $# -ne 1 ]] ; then
    echo -e "usage: hcd {-h|-l|[1-5]}"
    return 0
  elif [[ "$1" == "-h" ]] ; then
    echo -e "usage: hcd {-h|-l|[1-5]}\n  h\thelp\n  l\tLists folders\n  [1-5]\tSelect folder"
    return 0
  fi

  arg1="${arg1:-$1}"
  case $arg1 in
    [1-5])
        let arg1-=1
        command cd "${dirhistory[arg1]}"
        ;;
    "-l")
        echo -e "\nDirectories in your history are:"
        echo "${dirhistory[*]}" | tr ' ' '\n' | nl
        ;;
  esac
}

# help:cd:Changes cd to save history
alias cd='_cd__add__history $1'

# help:hcd:Shows or selects cd history 
alias hcd='_cd__history'

# help:cdh:Shows or selects cd history 
alias cdh='_cd__history'

# help:datef:Shows date as YYYY-MM-DD
alias datef='date +%Y-%m-%d'

# help:dateu:Shows date as YYYYMMDD
alias dateu='date +%Y%m%d'

# help:psg:Alias for 'ps -ef | grep'
psg ()
{
  HEADER=$(ps -ef | head -n 1)
  RESULTS=$(ps -ef | grep $1 | grep -v grep)
  echo -e "$HEADER\n$RESULTS"
}

# help:lsofgraph:Creates graphic from the ouput of lsof (requires https://github.com/zevv/lsofgraph)
alias lsofgraph='sudo lsof -n -F | ${HOME}/bin/programs/lsofgraph | dot -Tjpg > /tmp/a.jpg'

# help:var:Displays var value; case insensitive
var ()
{
  _var="$1"

  if [ -n "${!_var}" ] ; then
    echo ${!_var}
  else
    _var=$(echo "$_var" | tr 'a-z' 'A-Z')
    echo ${!_var}
  fi
}

# help:genpass:Generates alpha numeric password
# To add:
#   . option for alfa, numeric or both
genpass ()
{
  local p=$1
  [ "$p" == "" ] && p=16
  tr -dc A-Za-z0-9_ < /dev/urandom | head -c ${p} | xargs
}

# help:lowerit:Converts given string to lower case
lowerit ()
{
  BASH_MAIN_VERSION=$(echo $BASH_VERSION | awk -F. '{print $1}')
  if [[ $BASH_MAIN_VERSION -lt 4 ]] ; then
    echo "Not supported with your version of bash"
    return
  fi

  lowerit_help="lowerit [string]"
  if [ "$1" ] ; then
    echo ${1,,}
  fi
}

# help:upperit:Converts give string to upper case
upperit ()
{
  BASH_MAIN_VERSION=$(echo $BASH_VERSION | awk -F. '{print $1}')
  if [[ $BASH_MAIN_VERSION -lt 4 ]] ; then
    echo "Not supported with your version of bash"
    return
  fi

  upperit_help="upperit [string]"
  if [ "$1" ] ; then
    echo ${1^^}
  fi
}

# help:loopme:Loops a command (similar to watch)
loopme ()
{
  local usage OPTIND OPTERR comand interval
  usage="loopme -c [command] -n [interval]"

  if [[ $# -gt 0 ]] ; then
    OPTERR=0
    while getopts "hc:n:" opt ; do
      case "$opt" in
        h) echo -e "$usage" && return 0 ;;
        c) comand="$OPTARG" ;;
        n) interval="$OPTARG" ;;
        \?) echo "Invalid option" ; return 1 ;;
      esac
    done
  else
    read -p "Enter Command: " comand
    read -p "Enter refresh (sec): " interval
  fi

  while : ; do
    clear
    date
    bash -c "$comand"
    sleep "$interval"
  done
}

# help:win_name:Displays process name and PID of clicked window
win_name ()
{
  window_pid=$(xprop _NET_WM_PID | cut -d' ' -f3)
  echo "Process Name: $(ps -fp $window_pid | tail -1 | awk '{print $8}') (PID: $window_pid)"
}

# help:weather:Shows the weather on a terminal window
_weather ()
{
  # change Toronto to your default location
  curl -H "Accept-Language: ${LANG%_*}" wttr.in/"${1:-Toronto}"
}

# help:transfer:Uploads file to https://transfer.sh/
transfer ()
{
  # Creates a temp file to store output
  tmpfile=$( mktemp -t transferXXX )

  # Uploads file
  if tty -s ; then
    if [ $# -eq 0 ]; then
      echo "Please give a file as parameter:"
      echo "Example: _transfer \"file\""
      return 0
    fi

    # Follows symlink if needed
    if [ -L "$1" ] ; then
      path_file=$(readlink -f "$1")
    else
      path_file="$1"
    fi

    # Let's remove special characters
    basefile=$(basename "$1" | sed -e 's/[^a-zA-Z0-9._-]/-/g')

    # Now for hidden files
    basefile=$(echo "$basefile" | sed 's/^\.//')

    # Checks if argument is a text file and change upload extension to text
    file_type=$(file -i "$path_file" | awk -F"=" '{print $2}')
    if [ "$file_type" = "us-ascii" -o "$file_type" = "utf-8" ] ; then
      basefile="${basefile}.txt"
    fi

    curl --progress-bar --upload-file "$1" "https://transfer.sh/$basefile" >> "$tmpfile"

  # Uploads redirects
  else
    basefile=$(basename "$tmpfile")
    curl --progress-bar --upload-file "-" "https://transfer.sh/${basefile}.txt" >> "$tmpfile"
  fi

  # Prints output and deletes file
  cat "$tmpfile"
  rm -f "$tmpfile"
}