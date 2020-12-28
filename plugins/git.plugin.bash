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
gitpushom ()
{
  git_branch="$(git branch | grep '*' | awk '{print $2}')"
  if [ ! "$git_branch" ] ; then
    echo "Could not find the branch"
    return 1
  elif ! [[ $git_branch =~ (main|master) ]] ; then
    echo "The branch \"$git_branch\" is not \"main\" or \"master\""
    return 1
  fi

  echo "Pushing to $git_branch"
  sleep 2
  git push -u origin "$git_branch"
}

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
    fi
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

  echo -e "Commit message will be \"${commit_message}\"\n"
  read -p "Hit \"Enter\" to continue or \"Ctrl+c\" to quit: "

  # Figure out git brach. We only work with master or main
  git_branch="$(git branch | grep '*' | awk '{print $2}')"
  if [ ! "$git_branch" ] ; then
    echo "Could not find the branch"
    return 1
  fi
  if ! [[ $git_branch =~ (main|master) ]] ; then
    echo "The branch \"$git_branch\" is not \"main\" or \"master\""
    return 1
  fi

  # add local changes
  if (( $(git status -s | wc -l) > 0  )) ; then
    echo -e "\n${UYellow}Adding modified files${Color_Off}"
    git add . -v || { echo -e "${Red}Failed${Color_Off}" ; return 1 ; }

    sleep .5

    echo -e "\n${UYellow}Comitting changes${Color_Off}"
    git commit -m "$commit_message" -v "${commit_file:-.}" || { echo -e "${Red}Failed${Color_Off}" ; return 1 ; }
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
    ahead) git push -u origin $git_branch -v || \
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

if command -v fzf > /dev/null ; then
  # help:git-commit-show:fzf show commits in directory
  git-commit-show () 
  {
    git log --graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr"  | \
     fzf --ansi --no-sort --reverse --tiebreak=index --preview \
     'f() { set -- $(echo -- "$@" | grep -o "[a-f0-9]\{7\}"); [ $# -eq 0 ] || git show --color=always $1 ; }; f {}' \
     --header "Git commit browser" \
     --bind "j:down,k:up,alt-j:preview-down,alt-k:preview-up,ctrl-f:preview-page-down,ctrl-b:preview-page-up,q:abort,ctrl-m:execute:
                  (grep -o '[a-f0-9]\{7\}' | head -1 |
                  xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                  {}
  FZF-EOF" --preview-window=right:60%
  }

  # help:gitcmtshow:fzf show commits in directory
  alias gitcmtshow='git-commit-show'

  # help:git-log-show:fzf show files and then commits in directory
  git-file-show ()
  {
    trap "return 1" INT SIGINT
    while true ; do
      get_commit_hash=$(fzf --ansi --no-sort --reverse --tiebreak=index --preview 'git log --graph --color=always {}' --preview-window=right:60% \
      --header "File list" \
      --bind 'j:down,k:up,alt-j:preview-down,alt-k:preview-up,ctrl-f:preview-page-down,ctrl-b:preview-page-up,q:abort' | \
       xargs git log --format="%h [%ar] %-s%w(0,0,9)" --follow --all 2> /dev/null)
      if [ ! "$get_commit_hash" ] ; then
        return 1
      fi
      
      echo "$get_commit_hash" | fzf --ansi --no-sort --reverse --tiebreak=index --preview='git show --color=always {1}' --preview-window=right:60% \
      --header "Hash list" \
      --bind 'j:down,k:up,alt-j:preview-down,alt-k:preview-up,ctrl-f:preview-page-down,ctrl-b:preview-page-up,q:abort'

    done
  }

  # help:gitlogshow:fzf show files and then commits in directory
  alias gitfileshow='git-file-show'

  # help:git-diff-show:fzf show changed files with diff-so-fancy
  git-diff-show ()
  {
    local dif_file commt_msg  

    while true ; do
      dif_file=$(git status -s | fzf --ansi --no-sort --reverse --tiebreak=index --preview='git diff --color {2} | diff-so-fancy' \
      --preview-window=right:60% --header "Diff list" \
      --bind 'j:down,k:up,alt-j:preview-down,alt-k:preview-up,ctrl-f:preview-page-down,ctrl-b:preview-page-up,q:abort'| awk '{print $2}')

      if [ "$dif_file" ] ; then
        echo "Would you like to commit changes to \"${dif_file}\""
        read -p "[y|n]: "
        if [ "$REPLY" = "y" ] ; then
          echo "Type in commit message or enter for date string"
          read -p "[commit message]: " commt_msg
          git commit -m "${commt_msg:-$(date)}" "${dif_file}"
          sleep .5
        else
          return 0
        fi
      else
        return 0
      fi
    done
  }

  # help:git-diff-show:fzf show changed files with diff-so-fancy
  alias gitdifshow='git-diff-show'
else
  echo "[bash-config: git] fzf is not installed"
fi
