#
## about:Ansible aliases
#

# help:ansi-play:ansible-playbook
alias ansi-play='ansible-playbook'

# help:ansi-init:Creates an Ansible role folder
ansi-init ()
{
  local usage
  usage="Usage: ansi-init {simple} [role]"

  if [ $# -lt 1 ] || [[ "$1" == "-h" ]] ; then
    echo "$usage"
    return 1
  elif [ $# -eq 2 ] && [[ "$1" == "simple" ]] ; then
    if [ -d "$2" ] ; then
      echo "The file/folder \"$1\" already exists"
      return 1
    fi
    mkdir -p "${2}"/{tasks,vars}
    touch "${2}"/{tasks,vars}/main.yaml
    echo -e "---\n# vars file for $2" > "${2}"/vars/main.yaml
    echo -e "---\n# tasks file for $2" > "${2}"/tasks/main.yaml
  else
    if [ -d "$1" ] ; then
      echo "The file/folder \"$1\" already exists"
      return 1
    fi
    ansible-galaxy init "$1"
  fi 
}

# help:ansi-playlist:ansible-playbook --list-hosts
ansi-playlist () {
  if [[ $# -ne 1 ]] ; then
    echo "Please provide a playbook"
    return 1
  elif [ ! -f "$1" ] ; then
    echo "The file \"${1}\" is not valid"
    return 1
  else
    ansible-playbook "$1" --list-hosts
  fi
}

# help:ansiconstruct:gets specific information about a system
ansi-construct ()
{
  ansi_user="$2"

echo "
- name: Creates user $ansi_user
  user:
    name: $ansi_user
    uid: $(id -u $ansi_user)
    group: $(id -gn $ansi_user)
    groups: $(id -Gn $ansi_user | tr ' ' ',')
    state: present
"
}

# ansiconstruct ()
# {
#   file="$1"
#   if [ -h "$file" ] ; then
#     state=link
#   elif [ -d "$file" ] ; then
#     state=directory
#   else
#     state=present
#   fi

# echo "
# - name: Creates file $file
#   file:
#     path: $(readlink -f $file)
#     mode: 0$(stat -c '%a %n' $file  | cut -f 1 -d ' ')
#     owner: $(ls -ld $file | cut -f3 -d ' ')
#     group: $(ls -ld $file | cut -f4 -d ' ')
#     state: $state"
# }

complete -W 'user path file' ansiconstruct
