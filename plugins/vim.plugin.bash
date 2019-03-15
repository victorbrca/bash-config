#
## about:Aliases for vim
#

# help:vilf:Vim into the last modified file
vilf () {
  unset FILE
  FILE=$(/bin/ls -1tr | tail -n1)
  vim $FILE
}

if command -v fzf > /dev/null ; then
  # help:vifiles:fzf list to pick files in directory
  vifiles ()
  {
    vim $(fzf --ansi --no-sort --reverse --tiebreak=index --bind 'j:down,k:up')
  }
else
  echo "[bash-config: vim] fzf is not installed"
fi
