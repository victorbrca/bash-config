#
## about:Git aliases
#

# help:gitst:git status
alias gitst='git status'

# help:gitst:git status -v
alias gitstv='git status -v'

# help:gitcmt:git commit
alias gitcmt='git commit'

# help:gtcmtdate:git commit -m "$(date)"
alias gitcmtdate='git commit -m "`date`"'

# help:gitpushom:git push -u origin master
alias gitpushom='git push -u origin master'

# help:git-update:Adds, commits and push files on a Git repo 
git-update ()
{
  local Green Yellow Red Color_Off UYellow UGreen Blinking_White Blinking_Red \
  commit_file commit_message

  usage="git-update [-h]{commit} {file}"
  Red='\e[0;31m'
  Yellow='\e[0;33m'
  Green='\e[0;32m'
  UYellow='\e[4;33m'
  UGreen='\e[4;32m' 
  Blinking_White='\e[5;37;40m'
  Blinking_Red='\e[5;31;40m'
  Color_Off='\e[0m'

  if [[ $# -eq 0 ]] ; then
    commit_message="$(date)"
  elif [[ $# -eq 1 ]] ; then
    if [[ "$1" == "-h" ]] ; then
      echo "$usage"
      return 0
    elif [ -f "$1" ] ; then
      commit_file="$1"
    else
      commit_message="$1"
  elif [[ $# -eq 2 ]] ; then
    if [ -f "$1" ] ; then
      commit_file="$1"
      commit_message="$2"
    elif [ -f "$2" ] ; then
      commit_file="$2"
      commit_message="$1"
    else
      echo "Wrong file"
      echo "$usage"
      return 1
    fi
  fi

  echo -e "\n${Blinking_White}Updating git Repo${Color_Off}\n"

  echo -e "Commit message will be ${commit_message}\n"
  read -p "Hit \"Enter\" to continue or \"Ctrl+c\" to quit: "

  # add local changes
  if (( $(git status -s | wc -l) > 0  )) ; then
    echo -e "\n${UYellow}Adding modified files${Color_Off}"
    git add . -v || { echo -e "${Red}Failed${Color_Off}" ; return 1 ; }

    sleep .5

    echo -e "\n${UYellow}Comitting changes${Color_Off}"
    git commit -m "$commit_message" -v "$commit_file" || { echo -e "${Red}Failed${Color_Off}" ; return 1 ; }
  else
    echo -e "\n${UGreen}No local modified files to add"
  fi

  sleep .5

  # Getting remote branch changes
  echo -e "\n${UYellow}Checking for changes on remote branch${Color_Off}"
  git remote update &> /dev/null || { echo -e "${Red}Failed${Color_Off}" ; return 1 ; }

  sleep .5

  # Remote Branch status
  echo -e "\n${UYellow}Pushing needed changes${Color_Off}" 
  git_remote_status=$(git status | grep "Your branch is" | awk '{print $4}')
  case $git_remote_status in
    ahead) git push -u origin master -v || \
       { echo -e "${Red}Failed${Color_Off}" ; return 1 ; }
      ;;
    behind) echo -e "${Blinking_Red}Please run git pull manually${Color_Off}\n" 
      return 0
     ;;
    *) echo -e "Nothing to update" ;;
  esac

  git config credential.helper store
  echo -e "\n${UGreen}Complete${Color_Off}\n"
}
