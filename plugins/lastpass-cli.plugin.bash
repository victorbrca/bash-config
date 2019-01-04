#
## about:Aliases for lastpass-cli
#

if command -v lpass > /dev/null ; then
  # help:lpasl:lpass list
  alias lpasl='lpass ls'

  # help:lpas:lpass search
  alias lpas='lpass show -G'

  # help:lpasc:lpass copy password
  alias lpascp='lpass show --password -G -c'
fi
