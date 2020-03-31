#
## about:Aliases for Bash
#

# regex highlight for grep
alias grep='grep --color=auto'

# Setup the tree command
if command -v tree > /dev/null ; then
  tree_cmd () {
    tree -L 1 -tF
  }
else
  tree_cmd () {
    echo "."
    ls --color=always -1F | awk -v lcnt="$line_cnt" '{if(NR!=lcnt){print "├── " $0;}else{print "└── " $0;}}'
    echo
  }
fi

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
    command cd ; tree_cmd
  else
    command cd "$1" ; tree_cmd
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
alias cd='_cd__add__history'

# help:hcd:Shows or selects cd history 
alias hcd='_cd__history'

# help:cdh:Shows or selects cd history 
alias cdh='_cd__history'

# help:mkcd:Creates a folder and cd's into it
mkcd ()
{
  if [ $# -ne 1 ] ; then
    echo "Please provide a folder name"
    return 1
  elif [ -d "$1" ] ; then
    echo "The folder already exists"
    cd "$1"
  else
    mkdir "$1" && cd "$1"
  fi
}

# help:fpath:Shows full path of given file
alias fpath='readlink -f'

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
  local lenght usage special_char OPTIND

  usage='genpass -l [lenght] -n <no special char>'
  lenght=24
  OPTERR=0

  while getopts "nhl:" OPT ; do
    case $OPT in
      l) lenght=$OPTARG ;;
      n) special_char=no ;;
      h) echo "$usage" ; return 0 ;;
      \?)
        echo "Wrong option ${OPTARG}"
        echo "$usage"
        return 1
        ;;
      :) 
        echo "Missing argument for $OPTARG"
        echo "$usage"
        return 1
        ;;
    esac
  done

  if [[ $# -eq 1 ]] && [[ $1 =~ [0-9]{1,2} ]] ; then
    lenght=$1
  fi

  case $special_char in
    no) tr -dc A-Za-z0-9 < /dev/urandom | head -c ${lenght} ; echo ;;
    *) tr -dc A-Za-z0-9*_$^! < /dev/urandom | head -c ${lenght} ; echo ;;
  esac
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

# help:diff:Changes diff to use color, diff-so-fancy and bat
diff () {
  if command -v diff-so-fancy > /dev/null && command -v bat > /dev/null ; then
    command diff -u --color=always "$1" "$2" | diff-so-fancy | bat
  elif command -v diff-so-fancy > /dev/null && ! command -v bat > /dev/null ; then
    command diff -u --color=always "$1" "$2" | diff-so-fancy
  elif ! command -v diff-so-fancy > /dev/null && command -v bat > /dev/null ; then
    command diff -u --color=always "$1" "$2" | bat
  else
    command diff -u --color=always "$1" "$2"
  fi
}

# help:aliases:Show loaded aliases
aliases ()
{
  alias | sed 's/^alias //' | sed "s/='/ /" | awk '{printf "%-15s", $1 ; $1=""; print $0}' | sed "s/'$//"
}

if command -v figlet > /dev/null ; then

  # help:banner:Displays a banner with figlet and a 3d font
  # Font available at https://github.com/xero/figlet-fonts
  if [ -f ~/.local/share/fonts/3d.flf ] ; then
    banner () { echo ; figlet -f ~/.local/share/fonts/3d.flf -w $(tput cols) $* ; echo ; }
  else
    banner () { echo ; figlet -w $(tput cols) $* ; echo ; }
  fi

  # help:lolbanner:Colorized banner
  if command -v lolcat > /dev/null ; then
    if [ -f ~/.local/share/fonts/3d.flf ] ; then
      lolbanner () { echo ; figlet -f ~/.local/share/fonts/3d.flf -w $(tput cols) $* | lolcat ; echo ; }
    else
      lolbanner () { echo ; figlet -w $(tput cols) $* | lolcat ; echo ; }
    fi
  fi
fi

# help:resu:Re-run last command with sudo
alias resu='sudo $(fc -ln -1)'

# help:mem_usage:Shows memory utilization
mem_usage ()
{
  local opt

  if [[ $# -eq 0 ]] ; then
    opt=full
  elif [[ "$1" == "-c" ]] ; then
    opt=cmd
  elif [[ "$1" == "-f" ]] ; then
    opt=full
  else
    echo "usage: mem_usage -[f|c]"
    return 0
  fi

  case $opt in
    full)
      ps -eo pid,ppid,comm,%mem,vsz,rss,%cpu --sort=-%mem | head | numfmt --header --from-unit=1024 \
        --to=iec --field 5 | numfmt --header --from-unit=1024 --to=iec --field 6 | column -t
      ;;
    cmd)
      ps -eo pid,ppid,cmd:60,comm,%mem,rss,%cpu --sort=-%mem | head
      ;;
  esac
}

# help:mem_top:Like top, but for memory utilization
mem_top ()
{
  local opt

  if [[ $# -eq 0 ]] ; then
    opt=full
  elif [[ "$1" == "-c" ]] ; then
    opt=cmd
  elif [[ "$1" == "-f" ]] ; then
    opt=full
  else
    echo "usage: mem_top -[f|c]"
    return 0
  fi

  case $opt in
    full)
      while true ; do
        clear
        date
        ps -eo pid,ppid,comm,%mem,vsz,rss,%cpu --sort=-%mem | numfmt --header --from-unit=1024 \
         --to=iec --field 5 | numfmt --header --from-unit=1024 --to=iec --field 6 | column -t | head -$(echo $(tput lines) - 2 | bc)
        sleep 3
      done
      ;;
    cmd)
      while true ; do
        clear
        date
        ps -eo pid,ppid,cmd:60,comm,%mem,rss,%cpu --sort=-%mem | head -$(echo $(tput lines) - 2 | bc)
        sleep 3
      done
      ;;
  esac
}

# help:date-fmt:Displays a list of date and time formats
alias date-fmt='date --help | grep %'
