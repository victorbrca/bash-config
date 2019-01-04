#
## about:Misc media manipulation aliases
#

# Media manipulation
# help:renpic:Rename files to in directory to [number].jpg
alias renpic='e="1"; for i in `ls` ; do mv "$i" "$e.jpg" ; e=$(( e + 1 )) ; done'

# help:rezpic50:Resize images in a folder to 50%
alias rezpic50='for i in * ; do convert -resize 50% "$i" "$i" ; done'

# help:rezpic75:Resize images in a folder to 75%
alias rezpic75='for i in * ; do convert -resize 75% "$i" "$i" ; done'

# help:rezpic20:Resize images in a folder to 20%
alias rezpic20='for i in * ; do convert -resize 20% "$i" "$i" ; done'

# help:playm:Play video with mplayer
alias playm='mplayer -vo xv '

# help:playmrt:Play video rotated with mplayer
alias playmrt='mplayer -vo xv -vf rotate '

# help:rotate270:Rotates specified pictures 270 degrees
rotate270 ()
{ 
  for i in "$@" ; do
    convert -rotate 270 "$i" "$i"
  done
}

# help:rezmovie:Shrinks movie to 50% (with a new name)
rezmovie ()
{
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

# help:cannon-raw:Converts canon raw file to jpg in a folder
canon-raw ()
{
  for i in *.CR2
    do dcraw -c -w $i | ppmtojpeg > `basename $i CR2`jpg
    echo $i done
  done
}