#
## about:Converts rm to use trash-cli
#

# help:rm:Hardcoded to the real rm
alias rrm='$(which rm)' 

# help:rm:rm with trash-cli
rm () { 
  local opt_flag_used

  # Gets real rm command location
  rm_command="$(which rm)"

  # Do we have trash-cli
  if command -v trash-put &> /dev/null ; then

    # 1 argument = trash-put
    if [ $# -eq 1 ] ; then
       echo "Removed \"$1\" with trash-cli"
       trash-put "$1"

    # multiple arguments, do we have flags? 
    elif [ $# -gt 1 ] ; then
      for check_opt in $@ ; do
        if [[ "${check_opt::1}" = "-" ]] ; then
          opt_flag_used="y"
          break
        fi
      done

      if [[ "$opt_flag_used" = "y" ]] ; then
        echo "Removed with real rm"
        $rm_command -i "$@"
      else
        for file in "$@" ; do
          echo "Removed \"$file\" with trash-cli"
          trash-put "$file"
        done
      fi
    fi
  fi
}
