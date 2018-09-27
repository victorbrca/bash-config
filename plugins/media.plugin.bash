#
## about:Misc media manipulation aliases
#

# Media manipulation
# help:renpic:
alias renpic='e="1"; for i in `ls` ; do mv "$i" "$e.jpg" ; e=$(( e + 1 )) ; done'

# help:rezpic50:
alias rezpic50='for i in * ; do convert -resize 50% "$i" "$i" ; done'

# help:rezpic75:
alias rezpic75='for i in * ; do convert -resize 75% "$i" "$i" ; done'

# help:rezpic20:
alias rezpic20='for i in * ; do convert -resize 20% "$i" "$i" ; done'

# help:playm:
alias playm='mplayer -vo xv '

# help:playmrt:
alias playmrt='mplayer -vo xv -vf rotate '

# help:rotate270:Rotates specified pictures 270 degrees
rotate270 () { 
  for i in "$@" ; do
    convert -rotate 270 "$i" "$i"
  done
}

# help:rezmovie:Shrinks movie to 50% (with a new name)
rezmovie () {
  unset file
  if [ "$#" -ne 1 ] ; then
    echo "Please provide a filename"
    echo "Usage: rezmovie [file_name]"
    return 0
  fi

  file="$1"

  if [ ! -f "$file" ] ; then
    echo "Not a file"
    return 1
  fi

  extension=$(basename "$file" | awk -F . '{print "."$NF}')
  filename=$(basename "$file" | awk -F$extension '{print $1}')
  ffmpeg -i "$file" -vf scale=iw/2:-1 "${filename}_lowrez${extension}"
}