#
## about:Aliases for id3 tag an mp3 file
#


_bpmtools () {
  usage="usage: bpm-{read|write} {min} {max} [file_name]"
  if [ "$#" -lt 1 ] ; then
    echo "$usage"
    return 0
  fi

  local OPTIND opt

  while getopts "r:w:h" OPT ; do
    case $OPT in
      h) echo -e "$usage" ; return 0 ;;
      r) action="read" ; shift ;;
      w) action="write" ; shift ;;
      \?) echo "wrong option -${OPTARG}" ; return 1 ;;
    esac
  done

  case "$action" in
    read)
      if [ "$#" -eq 1 ] ; then
        bpm-tag -n "$1"
        read -p "Should we write? [y|n]: " answer
        case $answer in
          y) bpm-tag "$1" ;;
        esac
      elif [ "$#" -eq 2 ] ; then
        echo "Missing or wrong parameter"
        return 1
      elif [ "$#" -eq 3 ] ; then
        bpm-tag -n -m $1 -x $2 "$3"
        read -p "Should we write? [y|n]: " answer
        case $answer in
          y) bpm-tag -m $1 -x $2 "$3" ;;
        esac
      fi
      ;;
    write)
      if [ "$#" -eq 1 ] ; then
        bpm-tag "$1"
      elif [ "$#" -eq 2 ] ; then
        echo "Missing or wrong parameter"
        return 1
      elif [ "$#" -eq 3 ] ; then
        bpm-tag -m $1 -x $2 "$3"
      fi
      ;;
  esac
}

# help:bpm-read:Reads bpm and prompts to write
alias bpm-read='_bpmtools -r'

# help:bpm-read:Reads bpm
alias bpm-write='_bpmtools -w'

# help:bpmtools:bpm-{read|write} {min} {max} [file_name]
alias bpmtools='_bpmtools'