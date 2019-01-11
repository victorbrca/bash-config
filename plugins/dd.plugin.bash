#
## about:dd aliases
#

#help:dd_iso:Writes image to device
dd_iso ()
{
  usage="usage: dd_iso [image] [device]"

  if [[ $# -lt 2 ]] ; then
    echo "$usage"
    return 0
  elif [[ $# -eq 2 ]] ; then
    iso="$1"
    device="$2"
  fi

  if [[ "${iso##*.}" != "iso" ]] ; then
    echo "The first parameter should be an iso"
    return 1
  elif [[ ! -b "$device" ]] ; then
    echo "The second parameter needs to be a device"
    return 1
  fi

  device_type="$(basename "$(readlink -f "/sys/class/block/${device##*/}/..")")"
  if [[ "$device_type" != "block" ]] ; then
    echo "Do not specify a parition as the device"
    return 1
  fi

  sudo dd bs=4M if="$iso" of="$device" status=progress oflag=sync
}

