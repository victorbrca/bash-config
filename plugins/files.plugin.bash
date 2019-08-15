#
## about:File manipulation aliases
#

# help:bakfile:Backup a file with date
bakfile () {
  FILE="$1"
  if [ -f "$FILE" ] ; then
    cp "$FILE" "${FILE}.$(date +%Y%m%d_%H%M)"
  else
    echo -e "\nError: file \"$FILE\" does not exist!"
  fi

  unset FILE
}

# help:bakfolder:Backup a folder to "[folder].yyyymmdd_hhmm.tar.gz"
bakfolder () {
  local OPTIND usage help_menu cmmd ext bk_dir opt

  usage="bakfolder - -z {zip} -t {tar} -g {tar.gz} -h {help}"

  help_menu="\nbakfolder - Backs up specified folder
\nOptions:
\t-z,{zip}\tBackup and compress with zip (default option)
\t-t,{tar}\tBackup with tar
\t-g,{tar.gz}\tBackup and compress with tar gunzip
\t-h,{help}\tThis help menu"


  if [[ $# -eq 0 ]] ; then
    echo -e "$usage"
    return 0
  elif [[ $# -le 2 ]] ; then
    while getopts "ztgh" opt ; do
      case $opt in
        z) cmmd="zip -r" ; ext="zip" ;;
        t) cmmd="/bin/tar -cvf" ; ext="tar" ;;
        g) cmmd="/bin/tar -czvf" ; ext="tar.gz" ;;
        h) echo -e "$help_menu" ; return 0 ;;
        *) echo "Please provide a valid compress format" ; exit 0
      esac
    done
    [[ $# -eq 2 ]] && bk_dir="$2"
    [[ $# -eq 1 ]] && bk_dir="$1"
  fi

  [[ ! "$cmmd" ]] && cmmd="zip -r"
  [[ ! "$ext" ]] && ext="zip"

  if [ -d "$bk_dir" ] ; then
    bk_dir="${bk_dir%/}"
    $cmmd "${bk_dir}.$(date +%Y%m%d_%H%M).${ext}" "$bk_dir"
  else
    echo -e "Error: Directory \"${bk_dir}\"does not exist"
  fi
}

# help:bakdir:Same as bakdir
alias bakdir='bakfolder'

# help:hidefile:Hides a file by adding a '.'
hidefile () {
  FILE="$1"
  if [ -f "$FILE" ] ; then
    mv "$FILE" ".${FILE}"
  else
    echo -e "\nError: file \"$FILE\" does not exist!"
  fi

  unset FILE
}

# help:catlf:cats the last modified file
catlf () {
  unset FILE
  FILE=$(/bin/ls -1tr | tail -n1)
  cat $FILE
}

# help:chext:Converts extensions on a folder
# NEED TO FIX (BETTER)
chext () {
  if [ "$#" = 2 ] ; then
    #zip chext.bak.$$.zip *${1}
    rename "$1" "$2" *${1}
    #Renamed files to
  else
    echo -e "Usage: chext [.old_ext] [.new_ext]\n"
  fi
}

# help:duch:Displays disk usage by MB or GB - Usage: duch [-G|-M]
duch () {
if [ "$#" = "0" ] ; then
  echo -e "Missing argument\nUsage: duch [-G|-M]\n-M\tFiles with size bigger \
than 100MB\n-G\tFiles with size bigger than 1GB"
elif [ "$1" = "-G" ] ; then
  du -ch | sed 's/\.[0-9]//1' | egrep '^[0-9]{1,4}G' | sort -n
elif [ "$1" = "-M" ] ; then
  du -ch | sed 's/\.[0-9]//1' | egrep '^[0-9]{3,4}M' | sort -nr | less
else
  echo -e "duch: invalid option $1\nUsage: duch [-G|-M]\n-M\tFiles with size \
bigger than 100MB\n-G\tFiles with size bigger than 1GB"
fi
}

# help:dur:Alias for ncdu read only
dur ()
{
  if command -v ncdu > /dev/null ; then
    ncdu -r $*
  fi
}

# help:dud:Alias for ncdu read only
dud ()
{
  if command -v ncdu > /dev/null ; then
    ncdu $*
  fi
}


# help:extract:Extracts multiple compressed formats
extract () {
if [ -f $1 ] ; then
  case $1 in
    *.tar.bz2)   tar -xjvf $1    ;;
    *.tar.gz)    tar -xzvf $1    ;;
    *.tar.xz)    tar -xvf $1     ;;
    *.rar)       unrar x $1      ;;
    *.gz)        gunzip -d $1    ;;
    *.tar)       tar -xvf $1     ;;
    *.tbz2)      tar -xvjf $1    ;;
    *.tgz)       tar -xzvf $1    ;;
    *.xz)        unxz $1         ;;
    *.zip)       unzip $1        ;;
    *)           echo "'$1' cannot be extracted via extract" ;;
  esac
else
  echo "'$1' is not a valid file"
fi
}

# help:path:Shows the content of path in new line
path () {
  echo $PATH | tr ':' '\n'
}

# help:lsf:Shows child folders in new line
lsf () {
  echo */ | tr ' ' '\n'
}

# help:utar:tar -xvf
alias utar='tar -xvf'

# help:utarz:tar -xzvf
alias utarz='tar -xzvf'

# help:tarz:tar -czvf
alias tarz='tar -czvf'

# help:dfh:df -hT
alias dfh='df -hT -x squashfs'

# help:less:Uses vim as less for syntax highlight
#alias less='/usr/share/vim/vim*/macros/less.sh'
alias less='vim -R'
