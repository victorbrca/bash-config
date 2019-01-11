#
## about:Aliases for markdown files
#

if ! command -v pandoc > /dev/null ; then
  echo "[bash-config] Please install pandoc before enabling the markdown plugin"
  return 0
elif ! command -v lynx > /dev/null ; then
  echo "[bash-config] Please install lynx before enabling the markdown plugin"
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
    pandoc $1 | lynx -stdin -scrollbar on -vikeys
  fi
}

# Set up bash completion
complete -f -X '!*.md' readmd