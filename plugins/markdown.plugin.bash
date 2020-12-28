#
## about:Aliases for markdown files
#

if ! command -v glow > /dev/null ; then
  echo "[bash-config] Please install glow before enabling the markdown plugin"
  return 0
fi

# help:readmd:Viewer for markdown files
readmd ()
{
  if [[ $# -ne 1 ]] ; then
    echo "Please provide a file"
  elif [ ! -f "$1" ] ; then
    echo "$1 is not a file"
  else
    glow -p $1
  fi
}

# Set up bash completion
complete -f -X '!*.md' readmd
