#
## about:Aliases for lastpass-cli
#

if command -v lpass > /dev/null ; then
  # help:lpasl:lpass ls
  alias lpasl='lpass ls'

  # help:lpas:lpass show --basic-regexp
  alias lpas='lpass show -G'

  # help:lpasc:lpass show --basic-regexp --clip
  alias lpasc='lpass show -G -c'
fi
