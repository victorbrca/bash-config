#!/bin/bash

################################################################################
################################################################################
# Name:        bash-config.sh
# Usage:
# Description: Sets up bash options
# Created:     2018-09-10
# Copyright 2014, Victor Mendonca - http://victormendonca.com
#                                 - https://github.com/victorbrca
# License: Released under the terms of the GNU GPL license v3
################################################################################
################################################################################

<<COMMENT_USAGE
  bash-config enable -t [theme]
  bash-config enable -p [plugin]
  bash-config disable -t [theme]
  bash-config disable -p [plugin]
  bash-config list
  bash-config install
  bash-config aliases {plugin|alias}
COMMENT_USAGE

#-------------------------------------------------------------------------------
# Sets variables
#-------------------------------------------------------------------------------

bash_config_dir="${HOME}/.bash-config"
bash_config_plugins_folder="${bash_config_dir}/plugins"
bash_config_themes_folder="${bash_config_dir}/themes"

# Bash Colors
if [ -f "${bash_config_dir}/lib/bash-colors" ] ; then
  . "${bash_config_dir}/lib/bash-colors"
fi

# Sets up usage
usage="${BWhite}bash-config${Color_Off} [install|upgrade|list|enable|disable|aliases] \
{-p [plugin1,plugin2]|-t [theme1,theme2]}"


#-------------------------------------------------------------------------------
# Functions
#-------------------------------------------------------------------------------

_enable () 
{
  local OPT file_type file_to_enable files_to_enable dest_file source_file

  OPTERR=0
  while getopts "t:p:" OPT ; do
    case $OPT in
      t) 
        file_type="themes"
        files_to_enable="$OPTARG"
        ;;
      p)
        file_type="plugins"
        files_to_enable="$OPTARG"
        ;;
      \?) 
        echo "Wrong option -${OPT}"
        echo -e "$usage"
        exit 1
        ;;
      :)
        echo "Missing argument"
        echo -e "$usage"
        exit 1
        ;;
    esac
  done

  old_ifs="$IFS"
  IFS=,

  for file_to_enable in $files_to_enable ; do
    dest_file="${bash_config_dir}/${file_type}/enabled/${file_to_enable}.${file_type/s/}.bash"
    source_file="${bash_config_dir}/${file_type}/${file_to_enable}.${file_type/s/}.bash"

    if [ ! -e "$source_file" ] ; then
      echo "The ${file_type/s/} \"$file_to_enable\" doesn't exist"
      # exit 1
    elif [ -e "$dest_file" ] ; then
      echo "The ${file_type/s/} \"$file_to_enable\" is already enabled, skipping"
    else
      # Disable current theme
      if [ "$file_type" = "themes" ] ; then
        current_enabled_theme="$(find ${bash_config_dir}/${file_type}/enabled -type l)"
        if [ -L "$current_enabled_theme" ] ; then
          echo "Disabling the current theme first"
          unlink "$current_enabled_theme"
        fi
      fi
      ln -sf "$source_file" "$dest_file"
      echo "Enabled the ${file_type/s/} \"$file_to_enable\""
    fi
  done

  IFS="$old_ifs"
  # sleep 1.5
  # _list_plugins_and_themes
}

_disable ()
{
  local OPT file_type file_to_disable files_to_disable dest_file source_file

  OPTERR=0
  while getopts "t:p:" OPT ; do
    case $OPT in
      t) 
        file_type="themes"
        files_to_disable="$OPTARG"
        ;;
      p)
        file_type="plugins"
        files_to_disable="$OPTARG"
        ;;
      \?) 
        echo "Wrong option -${OPT}"
        echo -e "$usage"
        exit 1
        ;;
      :)
        echo "Missing argument"
        echo -e "$usage"
        exit 1
        ;;
    esac
  done

  old_ifs="$IFS"
  IFS=,

  for file_to_disable in $files_to_disable ; do
    dest_file="${bash_config_dir}/${file_type}/enabled/${file_to_disable}.${file_type/s/}.bash"

    if [ ! -e "$dest_file" ] ; then
      echo "The ${file_type/s/} \"$file_to_disable\" doesn't seem to be enabled"
      # exit 1
    else
      unlink "$dest_file"
      echo "Disabled the ${file_type/s/} \"$file_to_disable\""
    fi
  done

  IFS="$old_ifs"
  # sleep 1.5
  # _list_plugins_and_themes
}

_list_plugins_and_themes ()
{
  echo -e "\n${UWhite}bash-config Plugins and Themes${Color_Off}\n"
  echo "Plugins"

  plugins_enabled="$(find ${bash_config_plugins_folder}/enabled -name '*.plugin.bash' 2> /dev/null | sed 's/.*\///')"
  for type in $(find ${bash_config_plugins_folder} -type f -name '*.plugin.bash' | sort) ; do
    description=$(grep '## about' $type | awk -F":" '{print $2}')
    type=$(echo $type | sed 's/.*\///')
    if [[ $(echo "$plugins_enabled" | egrep -q "^${type}" ; echo $?) -eq 0 ]] ; then
      printf '%-30s %s\n' "[x] ${type%%.plugin.bash}" "$description"
    else
      printf '%-30s %s\n' "[ ] ${type%%.plugin.bash}" "$description"
    fi
    unset type description
  done
  echo -e "\nThemes"
  theme_enabled="$(find ${bash_config_themes_folder}/enabled -maxdepth 1 -name '*.theme.bash' 2> /dev/null | sed 's/.*\///')"
  for type in $(find ${bash_config_themes_folder} -maxdepth 1 -type f -name '*.theme.bash' | sort) ; do
    description=$(grep '## about' $type | awk -F":" '{print $2}')
    type="$(echo $type | sed 's/.*\///')"
    if [[ $(echo "$theme_enabled" | egrep -q "^$type" ; echo $?) -eq 0 ]] ; then
      printf '%-30s %s\n' "[x] ${type%%.theme.bash}" "$description"
    else
      printf '%-30s %s\n' "[ ] ${type%%.theme.bash}" "$description"
    fi
    unset type description
  done
  echo
}

_install_bash_config ()
{
  clear
  echo -e 'Warning!! Running the install will overwrite your config with files from the current dir. \nIf this is an upgrade, run "bash-config upgrade".\n'
  read -p "Hit \"Enter\" to continue or \"Ctrl+c\" to quit: "

  if [[ ! -d lib && ( ! -d plugins && ! -d themes) && ( ! -f bash-config.sh && ! -f bash-config.conf ) ]] ; then
    echo "Please run this script from the downloaded directory."
    exit 1
  fi

  echo -e "Creating bash-config dir... \c"
  mkdir -p "$bash_config_dir" && echo "ok" || \
   { echo "failed" ; exit 1 ; }
  echo -e "Copying files... \c"
  cp -a lib plugins themes bash-config.conf "${bash_config_dir}/." && echo ok || \
   { echo "failed" ; exit 1 ; }
  echo -e "Creating the plugins folder... \c"
  mkdir -p "${bash_config_dir}/plugins/enabled" && echo ok || \
   { echo "failed" ; exit 1 ; }
  echo -e "Creating the themes folder... \c"
  mkdir -p "${bash_config_dir}/themes/enabled" && echo ok || \
   { echo "failed" ; exit 1 ; }

  echo -e "Enabling config file... \c"
  grep -q '. ${HOME}/.bash-config/bash-config.conf' "${HOME}/.bashrc" 
  if [[ $? -eq 0 ]] ; then
    echo "already installed"
  else
    echo -e '\n# Load bash-config\n. ${HOME}/.bash-config/bash-config.conf' >> \
     "${HOME}/.bashrc" && echo "ok" || { echo "failed" ; exit 1 ; }
  fi

  echo -e "Copying bash-config.sh to ${HOME}/bin... \c"
  mkdir -p "${HOME}/bin"
  cp bash-config.sh "${HOME}/bin/." && echo "ok" || { echo "failed" ; exit 1 ; }
}

_upgrade ()
{
  local file_type

  if [[ ! -d lib && ( ! -d plugins && ! -d themes) && ( ! -f bash-config.sh && ! -f bash-config.conf ) ]] ; then
    echo "Please run this script from the downloaded directory."
    exit 1
  elif [ ! -d "$bash_config_dir" ] ; then
    echo "I can't find a bash-config directory. If you are trying to install, use the \"install\" option"
    exit 1
  fi

  mkdir -p /tmp/bash-plugins
  echo -e "Backing up enabled plugins... \c"
  find "${bash_config_plugins_folder}/enabled" -type l | xargs ls -l | awk '{print $9 "\t" $11}' > \
   /tmp/bash-plugins/enabled.plugins && echo "ok" || { echo "failed" ; exit 1 ; }
  echo -e "Backing up enabled themes... \c"
  find "${bash_config_themes_folder}/enabled" -type l | xargs ls -l | awk '{print $9 "\t" $11}' > \
   /tmp/bash-plugins/enabled.themes && echo "ok" || { echo "failed" ; exit 1 ; }

  echo -e "Copying files... \c"
  cp -a lib plugins themes bash-config.conf "${bash_config_dir}/." && echo ok || \
   { echo "failed" ; exit 1 ; }

  echo -e "Copying new bash-config.sh to ${HOME}/bin... \c"
  mkdir -p "${HOME}/bin"
  cp bash-config.sh "${HOME}/bin/." && echo "ok" || { echo "failed" ; exit 1 ; }

  echo -e "\n**Restoring plugins"
  cd "${bash_config_plugins_folder}/enabled"
  cat /tmp/bash-plugins/enabled.plugins | while read line ; do
    plugin_name=$(echo $line | awk '{print $1}' | sed 's/.*\///')
    # plugin_name=${plugin_name%%.plugin.bash}
    ln -sf "$(echo $line | awk '{print $2}')" "$(echo $line | awk '{print $1}')" \
     && echo "Enabled ${plugin_name%%.plugin.bash}" \
     || echo "Could not enable ${plugin_name%%.plugin.bash}"
  done

  # Removing default theme
  cd "${bash_config_themes_folder}/enabled"
  for file in $(find . -type l) ; do 
    unlink $file
  done

  # Restoring
  echo -e "\n**Restoring themes"
  cat /tmp/bash-plugins/enabled.themes | while read line ; do
    plugin_name=$(echo $line | awk '{print $1}')
    ln -sf "$(echo $line | awk '{print $2}')" "$(echo $line | awk '{print $1}')" \
     && echo "Enabled ${plugin_name%%.theme.bash}" \
     || echo "Could not enable ${plugin_name%%.theme.bash}"
  done
}

_display_aliases ()
{
  if [[ $# -eq 1 ]] ; then
    # Display all aliases for a plugin
    if [ -e ${bash_config_plugins_folder}/enabled/${1}.plugin.bash ] ; then
      #echo "Aliases for plugin ${1}"
      echo -e "\n${UWhite}Aliases for plugin ${1}${Color_Off}"
      grep -h '# help:' ${bash_config_plugins_folder}/enabled/${1}.plugin.bash \
       | awk -F":" '{printf "%-15s %s\n" , $2 , substr($0, index($0,$3))}'
    else
      # Search for aliases on all plugins
      echo -e "\n${UWhite}Searching for aliases with \"$1\" on all plugins${Color_Off}"
      grep -h '# help:' ${bash_config_plugins_folder}/enabled/*.plugin.bash 2> /dev/null \
       | grep -h "help:${1}" | awk -F":" '{printf "%-15s %s\n" , $2 , substr($0, index($0,$3))}'
    fi
  elif [[ $# -eq 2 ]] ; then
    # Search for aliases in a plugin
    echo -e "\n${UWhite}Searching for aliases with \"$2\" on plugin \"$1\"${Color_Off}"
    if [ -e ${bash_config_plugins_folder}/enabled/${1}.plugin.bash ] ; then
      grep -h '# help:' ${bash_config_plugins_folder}/enabled/${1}.plugin.bash \
       | grep "help:${2}" | awk -F":" '{printf "%-15s %s\n" , $2 , substr($0, index($0,$3))}'
    else
      echo "Could not find alias \"$2\" on plugin \"$1\""
      exit 1
    fi
  else
    # Shows all aliases
    echo -e "\n${UWhite}Displaying all aliases${Color_Off}"
    grep -h '# help:' ${bash_config_plugins_folder}/enabled/*.plugin.bash 2> /dev/null \
     | awk -F":" '{printf "%-15s %s\n" , $2 , substr($0, index($0,$3))}'
  fi
}


#-------------------------------------------------------------------------------
# Starts script
#-------------------------------------------------------------------------------

if [[ $# -eq 0 ]] ; then
  echo -e "\n$usage\n"
elif [[ $# -eq 1 ]] ; then
  case "$1" in
    list|plugins)
      _list_plugins_and_themes
      ;;
    install)
      _install_bash_config
      ;;
    upgrade)
      _upgrade
      ;;
    aliases) _display_aliases ;;
    -h)
      echo -e "$usage"
      ;;
    *)
      echo "Unknow option"
      echo -e "$usage"
      exit 1
      ;;
  esac
elif [[ $# -gt 1 ]] ; then
  case "$1" in
    enable) _enable "$2" "$3" ;;
    disable) _disable "$2" "$3" ;;
    aliases) shift ; _display_aliases $* ;;
    *) 
      echo "Wrong option"
      echo -e "$usage"
      exit 0
      ;;
  esac
else
  echo "Wrong parameter usage"
  echo -e "$usage"
  exit 1
fi
