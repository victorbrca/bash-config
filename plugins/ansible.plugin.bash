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
  local usage
  usage="Usage: ansi-playlist [playbook]"
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
ansi-get ()
{
  local usage ansi_user file state
  usage="Usage: ansi-get user file"

  if [[ $# -lt 2 ]] ; then
    echo "$usage"
    return 0
  fi

  case "$1" in
    user)
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
      ;;
    file)
      file="$2"
      if [ -h "$file" ] ; then
        state=link
      elif [ -d "$file" ] ; then
        state=directory
      elif [ -f "$file" ] ; then
        state=present
      else
        echo "The file \"$file\" does not exist"
        return 1
      fi

      mode=$(stat -c '%a %n' $file  | cut -f 1 -d ' ')
      if [[ ${#mode} -eq 3 ]] ; then
        mode="0${mode}"
      fi

      echo "
- name: Creates ${state/present/file} $file
  file:
    path: $(readlink -f $file)
    mode: $mode
    owner: $(ls -ld $file | cut -f3 -d ' ')
    group: $(ls -ld $file | cut -f4 -d ' ')
    state: $state
"
      ;;
  esac
}


# help:ansi-template:Creates module templates
ansi-template ()
{
  local usage avalable_modules cat_cmd
  usage="Usage ansi-create [list|module]"

  if [[ $# -ne 1 ]] ; then
    echo "$usage"
    return 0
  fi

  avalable_modules="archive,fetch,file,copy,user,group,template,service,shell,synchronize,systemd,unarchive"

  # Let's see if we have highlight
  if command -v highlight > /dev/null ; then
    cat_cmd="highlight -O ansi --force -S yaml"
  else
    cat_cmd="/usr/bin/cat"
  fi

  case $1 in
    -h)
      echo "$usage"
      return 0
      ;;
    list)
      echo "Here are the available modules:"
      echo "$avalable_modules" | tr ',' '\n' | sort | awk '{print "-" , $1}'
      echo
      ;;
    archive)
      echo "
- name: Creates a compressed archive of one or more files or trees
  archive:
    path: /etc/foo               # Remote absolute path, glob, or list of paths or globs for the file or files to compress or archive.
    dest: /etc/foo               # The file name of the destination archive
    format: bz2|gz*|tar|xz|zip   # The type of compression to use
    owner: foo                   # Name of the user that should own the file/directory, as would be fed to chown
    group: foo                   # Name of the group that should own the file/directory, as would be fed to chown
    mode: 0755                   # Mode the file or directory should be
    exclude: foo                 # Remote absolute path, glob, or list of paths or globs for the file or files to exclude from the archive
    remove: no*|yes              # Remove any added source files and trees after adding to archive.
  become: yes                    # Run actions as root
" | $cat_cmd
      ;;
    file)
      echo "
- name: Sets attributes of files, symlinks, and directories, or removes files/symlinks/directories 
  file:
    path: /etc/foo.conf                   # Path to the file being managed.
    state: [present|directory|file|link]  
    owner: foo                            # Name of the user that should own the file
    group: foo                            # Name of the group that should own the file    
    mode: 0755                            # Mode the file or directory should be
    recurse: no*|yes                      # Recursively set the specified file attributes
  become: yes                             # Run actions as root
" | $cat_cmd
      ;;
    copy)
      echo "
- name: Copies files to remote locations
  copy:
    src: ~/sample.txt     # Local path to a file to copy to the remote server
    dest: /etc/foo.conf   # Remote absolute path where the file should be copied to
    force: yes*|no        # Replaces the remote file when contents are different than the source
    owner: foo            # Name of the user that should own the file
    group: foo            # Name of the group that should own the file
    mode: 0755            # Mode the file or directory should be
    remote_src: no*|yes   # If no, it will search for src at originating/master machine
    backup: no*|yes       # Create a backup file including the timestamp information
  become: yes             # Run actions as root
" | $cat_cmd
      ;;
    user)
      echo "
- name: Manage user accounts and user attributes.
  user:
    name: foo                   # Name of the user to act on
    comment: foor bar           # Optionally sets the description (aka GECOS) of user account
    uid: 1000                   # Optionally sets the UID of the user
    shell: /bin/bash            # Optionally set the user's shell
    create_home: yes*|no        # Unless set to no, a home directory will be made for the user when the account is created or if the home directory does not exist
    home: /home/foo             # Optionally set the user's home directory.
    password: \"{{ var }}\"       # Optionally set the user's password to this crypted value
    group: foo                  # Optionally sets the user's primary group (takes a group name).
    groups: freedom,beer   # List of groups user will be added to
    append: yes                 # If yes, add the user to the groups specified in groups. If no, user will only be added to the groups specified in groups, removing them from all other groups.
    state: present*|absent      # Whether the account should exist or not
  become: yes                   # Run actions as root
" | $cat_cmd
      ;;
    group)
      echo "
- name: Add or remove groups
  group:
    name: foo                # Name of the group to act on
    gid: 1000                # Optional GID to set for the group
    system: no*|yes          # If yes, indicates that the group created is a system group
    state: present*|absent   # Whether the account should exist or not
  become: yes                # Run actions as root
" | $cat_cmd
      ;;
    template)
      echo "
- name: Templates a file out to a remote server
  template:
    src: /mytemplates/foo.j2            # Path of a Jinja2 formatted template on the Ansible controller
    dest: /etc/foo.conf                 # Location to render the template to on the remote machine
    owner: foo                          # Name of the user that should own the file
    group: foo                          # Name of the group that should own the file
    mode: 0755                          # Mode the file or directory should be
    backup: no*|yes                     # Create a backup file including the timestamp information
    validate: /usr/sbin/sshd -t -f %s   # The validation command to run before copying into place
  become: yes                           # Run actions as root
" | $cat_cmd
      ;;
    service)
      echo "
- name: Manage services
  systemd: 
    name: foo.service                         # Name of the service
    state: reloaded|restart|started|stopped   # 
    enabled: no|yes                           # Whether the service should start on boot
  become: yes                                 # Run actions as root
" | $cat_cmd
      ;;
    systemd)
      echo "
- name: Manage services
  systemd: 
    name: foo.service                         # Name of the service
    state: reloaded|restart|started|stopped   # 
    enabled: no|yes                           # Whether the service should start on boot
    scope: system*|user|global                # run systemctl within a given service manager scope
    daemon_reload: no*|yes                    # run daemon-reload before doing any other operations, to make sure systemd has read any changes
  become: yes                                 # Run actions as root
" | $cat_cmd
      ;;
    unarchive)
      echo "
- name: Unpacks an archive after (optionally) copying it from the local machine
  unarchive:
    src: ~/sample.zip     # Local path to a archive file to copy to the remote server
    dest: /etc/foo        # Remote absolute path where the archive should be unpacked
    owner: foo            # Name of the user that should own the file/directory, as would be fed to chown
    group: foo            # Name of the group that should own the file/directory, as would be fed to chown
    mode: 0755            # Mode the file or directory should be
    remote_src: no*|yes   # Set to yes to indicate the archived file is already on the remote system and not local to the Ansible controller
    keep_newer: no*|yes   # Do not replace existing files that are newer than files from the archive
    exclude: foo, bar     # List the directory and file entries that you would like to exclude from the unarchive action
  become: yes             # Run actions as root
" | $cat_cmd
      ;;
    fetch)
      echo "
- name: Fetches a file from remote nodes
  fetch:
    src: /tmp/uniquefile   # The file on the remote system to fetch. This must be a file, not a directory.
    dest: /tmp/special/    # A directory to save the file into. File will saved with [dest]/[src_hostname]/[absolut src]
    flat: yes              # Allows you to override the default behavior of appending hostname/path/to/file to the destination
  become: yes              # Run actions as root
" | $cat_cmd
      ;;
    synchronize)
      echo "
- name: A wrapper around rsync to make common tasks in your playbooks quick and easy
  synchronize:
    src: some/relative/path     # Path on the source host that will be synchronized to the destination
    dest: /some/absolute/path   # Path on the destination host that will be synchronized from the source
    recursive: no|yes           # Recurse into directories
    mode: push*|pull            # Specify the direction of the synchronization (push: localhost=>remote)
    owner: no|yes               # Preserve owner (super user only)
    checksum: no*|yes           # Skip based on checksum, rather than mod-time & size
    perms: no|yes               # Preserve permissions
    links: no|yes               # Copy symlinks as symlinks.
    archive: no*|yes            # Mirrors the rsync archive flag, enables recursive, links, perms, times, owner, group flags and -D
  become: no                    # stops synchronize trying to sudo locally
" | $cat_cmd
      ;;
    shell)
      echo "
- name: Execute commands in nodes
  shell: somescript.sh >> somelog.txt   # The command to be run. Use \"|\" for multiline commands
  args:
    chdir: somedir/                     # cd into this directory before running the command
    creates: somelog.txt                # A filename, when it already exists, this step will not be run
    removes: somelog.txt                # A filename, when it does not exist, this step will not be run
  become: yes                           # Enable the become flag
  become_user: foo                      # Run actions as foo
" | $cat_cmd
      ;;
  esac
}

# help:ansi-tmplt:Same as ansi-template
alias ansi-tmplt='ansi-template'

complete -W 'user file' ansi-get
complete -W 'archive copy fetch file group service systemd shell synchronize template unarchive user' ansi-template ansi-tmplt
