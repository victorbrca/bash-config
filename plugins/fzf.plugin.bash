#
## about:fzf aliases
#

## Additional options not enabled
# Shows dir on local with depth 1
# _fzf_compgen_dir() {
#   fd --type d -i --hidden --follow -d 1 --exclude ".git" . "$1"
# }

# # Shows file on local depth 1
# _fzf_compgen_path() {
#   fd --hidden --follow -d 1 --exclude ".git" . "$1"
# }

# # Modifies the defaul command to use 'fd'
# export FZF_DEFAULT_COMMAND='fd --type f'
# # Modifies the defaul command to use 'fd' with depth 1
# export FZF_DEFAULT_COMMAND='fd --type d -i --follow -d 1 --exclude .git'

# Settings for fzf
if command -v fzf > /dev/null ; then
  export FZF_COMPLETION_TRIGGER='**'
  # Cycle with tab
  export FZF_DEFAULT_OPTS='--bind tab:down --cycle'
  [ -f /usr/share/fzf/key-bindings.bash ] && . /usr/share/fzf/key-bindings.bash
  [ -f /usr/share/fzf/completion.bash ] && . /usr/share/fzf/completion.bash
  [ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && . /usr/share/doc/fzf/examples/key-bindings.bash
  [ -f /usr/share/doc/fzf/examples/completion.bash ] && . /usr/share/doc/fzf/examples/completion.bash
  # help:preview:Interactive preview for files in a folder
  preview () 
  {
    fd -d 1 -t f | fzf --preview 'bat --color "always" --wrap "auto" {}' \
    --bind 'alt-j:preview-down,alt-k:preview-up,ctrl-f:preview-page-down,ctrl-b:preview-page-up,ctrl-q:abort,ctrl-m:execute:(bat --paging=always \
    {} < /dev/tty)' --preview-window=right:70%
  }
else
  echo "[bash-config: fzf] fzf is not installed"
fi
