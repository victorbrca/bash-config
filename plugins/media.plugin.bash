#
## about:Misc media manipulation aliases
#

if ! command -v convert >/dev/null; then
  echo "[bash-config: media] convert is not installed and it's needed by the media plugin"
  return 1
fi

if ! command -v ffmpeg >/dev/null; then
  echo "[bash-config: media] ffmpeg is not installed and it's needed by the media plugin"
  return 1
fi

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
rotate270() {
  for i in "$@"; do
    convert -rotate 270 "$i" "$i"
  done
}

# help:rezmovie:Shrinks movie to 50% (with a new name)
rezmovie() {
  unset file
  if [ "$#" -ne 1 ]; then
    echo "Please provide a filename"
    echo "Usage: rezmovie [file_name]"
    return 0
  fi

  file="$1"

  if [ ! -f "$file" ]; then
    echo "Not a file"
    return 1
  fi

  extension=$(basename "$file" | awk -F . '{print "."$NF}')
  filename=$(basename "$file" | awk -F$extension '{print $1}')
  ffmpeg -i "$file" -vf scale=iw/2:-1 "${filename}_lowrez${extension}"
}

# help:cannon-raw:Converts canon raw file to jpg in a folder
canon-raw() {
  for i in *.CR2; do
    dcraw -c -w $i | ppmtojpeg >$(basename $i CR2)jpg
    echo $i done
  done
}

# help:convert-mp4-to-mov:Converts mp4 video to mov
convert-mp4-to-mov() {
  local filename

  if [ "$1" ]; then
    filename="$1"
  else
    read -p "File: " filename
  fi

  if [ ! -f "$filename" ]; then
    return 1
  fi

  ffmpeg -i "$filename" -c:v mpeg4 -qscale:v 1 -c:a pcm_s16le -f mov ${filename%.*}.mov
}

# help:convert-mp4-to-mov-hq:Converts mp4 video to mov HQ
convert-mp4-to-mov-hq() {
  local filename

  if [ "$1" ]; then
    filename="$1"
  else
    read -p "File: " filename
  fi

  if [ ! -f "$filename" ]; then
    return 1
  fi

  ffmpeg -i "$filename" -c:v dnxhd -profile:v dnxhr_hq -pix_fmt yuv422p -c:a pcm_s16le -f mov ${filename%.*}.mov
}

# help:convert-all-mp4-to-mov-hq:Converts all mp4 videos in a folder to mov HQ
convert-all-mp4-to-mov-hq() {
  local filename

  for filename in *.mp4; do
    ffmpeg -i "$filename" -c:v dnxhd -profile:v dnxhr_hq -pix_fmt yuv422p -c:a pcm_s16le -f mov ${filename%.*}.mov
  done

  for filename in *.MP4; do
    ffmpeg -i "$filename" -c:v dnxhd -profile:v dnxhr_hq -pix_fmt yuv422p -c:a pcm_s16le -f mov ${filename%.*}.mov
  done

  ls -l
}

# help:convert-mov-to-mp4:Converts mov video to mp4 with AAC
convert-mov-to-mp4() {
  local filename
  if [ "$1" ]; then
    filename="$1"
  else
    read -p "File: " filename
  fi
  if [ ! -f "$filename" ]; then
    return 1
  fi
  ffmpeg -i "$filename" -vcodec h264 -acodec aac ${filename%.*}_h265.mp4
}

# help:convert-mp4-h264-to-h265:Converts mp4 h264 video to h265
convert-mp4-h264-to-h265() {
  local filename
  if [ "$1" ]; then
    filename="$1"
  else
    read -p "File: " filename
  fi
  if [ ! -f "$filename" ]; then
    return 1
  fi
  ffmpeg -i "$filename" -c:v libx265 -vtag hvc1 ${filename%.*}_h265.mp4
}

# help:convert-all-mp4-h264-to-h265:Converts mp4 h264 video to h265
convert-all-mp4-h264-to-h265() {
  local filename
  for filename in *.MP4; do
    if [ -f "$filename" ]; then
      mv "$filename" "${filename%.*}.mp4"
    fi
  done
  for filename in *.mp4; do
    ffmpeg -i "$filename" -c:v libx265 -vtag hvc1 "${filename%.*}_h265.mp4"
  done
  ls --color=auto -l
}
