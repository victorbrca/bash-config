#
## about:Aliases for less
#

# help:less:Sets less with syntax highlight
less() {
  # Requires package source-highlight
  if command -v source-highlight &>/dev/null; then
    cmd_less="$(which less)"
    export PAGER="less"
    export LESS="-R"

    if [ -f "/usr/share/source-highlight/src-hilite-lesspipe.sh" ]; then
      # Ubuntu
      export LESSOPEN="| /usr/share/source-highlight/src-hilite-lesspipe.sh %s"
    elif [ -f "/usr/bin/src-hilite-lesspipe.sh" ]; then
      # Fedora/Arch
      export LESSOPEN="| /usr/bin/src-hilite-lesspipe.sh %s"
    fi
    if [ -p /dev/stdin ]; then
      cat | "$cmd_less"
    else
      "$cmd_less" "$1"
    fi
  elif command -v vim &>/dev/null; then
    if [ -p /dev/stdin ]; then
      cat | vim -R -
    else
      vim -R "$1"
    fi
  fi
}
