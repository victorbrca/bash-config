#
## about:Ansible aliases
#

# help:ansi-play:ansible-playbook
alias ansi-play='ansible-playbook'

# help:ansi-init:Creates an Ansible role folder
ansi-init () {
  local usage
  usage="Usage: ansi-init {simple} [role]"

  if [ $# -lt 1 ] || [[ "$1" == "-h" ]] ; then
    echo "$usage"
    return 0
  elif [ $# -eq 2 ] && [[ "$1" == "simple" ]] ; then
    if [ -d "$2" ] ; then
      echo "The file/folder \"$1\" already exists"
      return 1
    fi
    mkdir -p "${2}"/{tasks,vars}
    touch "${2}"/{tasks,vars}/main.yaml
    echo -e "---\n# vars file for $2" > "${2}"/vars/main.yaml
    echo -e "---\n# tasks file for $2" > "${2}"/tasks/main.yaml

    # Gets README file
    wget -q https://raw.githubusercontent.com/ansible/ansible/devel/lib/ansible/galaxy/data/default/role/README.md \
      -O "${2}/README.md"

    # Add static badges
    badges="[passing](https://i.imgur.com/aWfHWAS.png?1) [testing](https://i.imgur.com/kFpR3ez.png?1) [failure](https://i.imgur.com/6NO538f.png?1)"
    sed -i "/^===/a $badges" "${2}/README.md"
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


# help:ansible-template:Creates module templates
ansible-template ()
{
  local usage available_modules cat_cmd output_option
  usage="Usage ansible-template {--no-comment|-n} {--skeleton|-s} [list|module]"

  if [[ $# -lt 1 || $# -gt 2 ]] ; then
    echo "$usage"
    return 0
  fi

  available_modules="archive,blockinfile,command,copy,fetch,file,get_url,group,lineinfile,replace,script,service,shell,synchronize,systemd,template,unarchive,user"

  # Let's see if we have highlight
  if command -v highlight > /dev/null ; then
    cat_cmd="highlight -O ansi --force -S yaml"
  else
    cat_cmd="/usr/bin/cat"
  fi

  if [[ $# -eq 2 ]] ; then
    case $1 in
      --no-comment|-n)
        output_option=no_comment
        shift
        ;;
      --skeleton|-s)
        output_option=skeleton
        shift
        ;;
    esac
  elif [[ $# -eq 1 ]] ; then
    case $1 in
      -h)
        echo "$usage"
        return 0
        ;;
      list)
        echo "Here are the available modules:"
        echo "$available_modules" | tr ',' '\n' | sort | awk '{print "-" , $1}'
        echo
        return 0
        ;;
    esac
  fi

  case $1 in
    archive)
      module_description="
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
"
      ;;
    blockinfile)
      module_description="
- name:                                   # Insert/update/remove a text block surrounded by marker lines
  blockinfile:
    path: /etc/foo.conf                   # The file to modify
    create: yes|no*                       # Create a new file if it doesn't exist.
    owner: foo                            # Name of the user that should own the file
    group: foo                            # Name of the group that should own the file
    mode: 0755                            # Mode the file or directory should be
    marker: \"# {mark} ANSIBLE BLOCK ##\"   # The marker line template. \"{mark}\" will be replaced with the values in marker_begin (default=\"BEGIN\") and marker_end (default="END").
    insertafter: \"<body>\"                 # If specified, the block will be inserted after the last match of specified regular expression.
    block: |                              # The text to insert inside the marker lines
      <h1>Welcome to {{ ansible_hostname }}</h1>
      <p>Last updated on {{ ansible_date_time.iso8601 }}</p>
"
      ;;
    command)
      module_description="
- name: Executes a command on a remote node. It will not be processed through the shell, so variables like $HOME and operations like \"<\", \">\", \"|\", \";\" and \"&\" will not work
  command: foo
    argv:            # Allows the user to provide the command as a list vs. a string
      - foo
      - bar
    chdir: /etc/foo  # Change into this directory before running the command
    creates: /bar    # A filename or (since 2.0) glob pattern. If it already exists, this step won't be run
    removes: /foo    # A filename or (since 2.0) glob pattern. If it already exists, this step will be run
    stdin:           # Set the stdin of the command directly to the specified value.
"
      ;;
    copy)
      module_description="
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
"
      ;;
    fetch)
      module_description="
- name: Fetches a file from remote nodes
  fetch:
    src: /tmp/uniquefile   # The file on the remote system to fetch. This must be a file, not a directory.
    dest: /tmp/special/    # A directory to save the file into. File will saved with [dest]/[src_hostname]/[absolut src]
    flat: yes              # Allows you to override the default behavior of appending hostname/path/to/file to the destination
  become: yes              # Run actions as root
"
      ;;
    file)
      module_description="
- name: Sets attributes of files, symlinks, and directories, or removes files/symlinks/directories
  file:
    path: /etc/foo.conf                   # Path to the file being managed.
    state: [present|directory|file|link]
    owner: foo                            # Name of the user that should own the file
    group: foo                            # Name of the group that should own the file
    mode: 0755                            # Mode the file or directory should be
    recurse: no*|yes                      # Recursively set the specified file attributes
  become: yes                             # Run actions as root
"
      ;;
    get_url)
      module_description="
- name: Downloads files from HTTP, HTTPS, or FTP to node
  get_url:
    url: http://example.com/path/file.conf  # HTTP, HTTPS, or FTP URL in the form (http|https|ftp)://[user[:pass]]@host.domain[:port]/path
    url_username:                           # The username for use in HTTP basic authentication.
    url_password:                           # The password for use in HTTP basic authentication.
    use_proxy: no|yes*                      # If no, it will not use a proxy, even if one is defined in an environment variable on the target hosts.
    validate_certs: no|yes*                 # If no, SSL certificates will not be validated.
    timeout: 10*                            # Timeout in seconds for URL request.
    dest: /etc/foo.conf                     # Absolute path of where to download the file to.
    owner: foo                              # Name of the user that should own the file/directory, as would be fed to chown
    group: foo                              # Name of the group that should own the file/directory, as would be fed to chown
    mode: 0755                              # Mode the file or directory should be
    backup:                                 # Create a backup file including the timestamp information so you can get the original file back if you somehow clobbered it incorrectly.
    backup_file:                            # Name of backup file created after download
    checksum: md5:hash                      # If a checksum is passed to this parameter, the digest of the destination file will be calculated after it is downloaded to ensure its integrity and verify that the transfer completed successfully
    force: no*|yes                          # If yes and dest is not a directory, will download the file every time and replace the file if the contents change
"
      ;;
    group)
      module_description="
- name: Add or remove groups
  group:
    name: foo                # Name of the group to act on
    gid: 1000                # Optional GID to set for the group
    system: no*|yes          # If yes, indicates that the group created is a system group
    state: present*|absent   # Whether the account should exist or not
  become: yes                # Run actions as root
"
      ;;
    lineinfile)
      module_description="
- name: Manage lines in text files
  lineinfile:
    path: /etc/foo         # The file to modify
    owner: foo             # Name of the user that should own the file/directory, as would be fed to chown
    group: foo             # Name of the group that should own the file/directory, as would be fed to chown
    mode: 0755             # Mode the file or directory should be
    state: absent|present* # Whether the line should be there or not.
    line: 'Hello World'    # The line to insert/replace into the file
    regex: '^Hello World'  # The regular expression to look for in every line of the file.
    insertbefore: '^foo'   # If specified, the line will be inserted before the last match of specified regular expression
    insertafter: '^bar'    # If specified, the line will be inserted after the last match of specified regular expression.
    validate:              # The validation command to run before copying into place.
"
      ;;
    replace)
      module_description="
- name: Replace all instances of a particular string in a file using a back-referenced regular expression
  replace:
    path: /foo/bar                        # The file to modify
    backup: no*|yes                       # Create a backup file including the timestamp information
    after: #foo                           # If specified, only content after this match will be replaced/removed.
    before: #bar                          # If specified, only content before this match will be replaced/removed.
    regexp: '^foobar$'                    # The regular expression to look for in the contents of the file
    replace: 'barfoo'                     # The string to replace regexp matches
    owner: foo                            # Name of the user that should own the file
    group: foo                            # Name of the group that should own the file
    mode: 0755                            # Mode the file or directory should be
    validate: /usr/bin/grep -q barfoo %s  # The validation command to run before copying into place
"
      ;;
    service)
      module_description="
- name: Manage services
  systemd:
    name: foo.service                         # Name of the service
    state: reloaded|restart|started|stopped   #
    enabled: no|yes                           # Whether the service should start on boot
  become: yes                                 # Run actions as root
"
      ;;
    script)
      module_description="
- name: Runs a local script on a remote node after transferring it
  script: foo_bar.sh
    chdir: /etc/foo        # Change into this directory before running the script
    creates: /bar          # A filename or (since 2.0) glob pattern. If it already exists, this step won't be run
    removes: /foo          # A filename or (since 2.0) glob pattern. If it already exists, this step will be run
    executable: /bin/bash  # Name or path of a executable to invoke the script with
"
      ;;
    shell)
      module_description="
- name: Execute commands in nodes
  shell: somescript.sh >> somelog.txt   # The command to be run. Use \"|\" for multiline commands
  args:
    chdir: somedir/                     # cd into this directory before running the command
    creates: somelog.txt                # A filename, when it already exists, this step will not be run
    removes: somelog.txt                # A filename, when it does not exist, this step will not be run
  become: yes                           # Enable the become flag
  become_user: foo                      # Run actions as foo
"
      ;;
    synchronize)
      module_description="
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
"
      ;;
    systemd)
      module_description="
- name: Manage services
  systemd:
    name: foo.service                         # Name of the service
    state: reloaded|restart|started|stopped   #
    enabled: no|yes                           # Whether the service should start on boot
    scope: system*|user|global                # run systemctl within a given service manager scope
    daemon_reload: no*|yes                    # run daemon-reload before doing any other operations, to make sure systemd has read any changes
  become: yes                                 # Run actions as root
"
      ;;
    template)
      module_description="
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
"
      ;;
    unarchive)
      module_description="
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
"
      ;;
    user)
      module_description="
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
    groups: freedom,beer        # List of groups user will be added to
    append: yes|no*             # If yes, add the user to the groups specified in groups, otherwise overwrite using specified list in groups
    state: present*|absent      # Whether the account should exist or not
  become: yes                   # Run actions as root
"
      ;;
    *)
      echo "Unknown option \"$1\""
      return 1
    esac

  case "$output_option" in
    no_comment)
      echo "$module_description" | $cat_cmd | sed "s/#.*$//"
      ;;
    skeleton)
      echo "$module_description" | $cat_cmd | sed "s/:.*$/:/"
      ;;
    *)
      echo "$module_description" | $cat_cmd
    esac
}

# help:ansi-tmplt:Same as ansible-template
alias ansi-tmplt='ansi-template'
# help:ansi-template:Same as ansible-template
alias ansi-template='ansible-template'

complete -W 'user file' ansi-get
complete -W 'list archive blockinfile command copy fetch file get_url group lineinfile replace script service shell synchronize systemd template unarchive user' ansi-template ansible-template ansi-tmplt
