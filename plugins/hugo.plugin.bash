#
## about:Hugo aliases
#

# help:hugo-update:Runs hugo, git add/commit/push
hugo-update () 
{
  if [[ "$1" == "-h" ]] ; then
    echo "Usage: hugo-update \"commit message\""
    return 0
  fi

  if [[ ! -d public ]] ; then
    echo "This does not seem like a hugo folder. Please change into the proper location or run \"hugo\" manually once."
    return 1
  fi

  if [[ $# -ne 1 ]] ; then
    echo "Commit message will be \"Rebuilding site $(date)\""
    sleep 2
    commit_message="Rebuilding site $(date)"
  else
    commit_message="$1"
  fi

  UYellow='\e[4;33m'
  Red='\e[0;31m'
  Color_Off='\e[0m'
  UGreen='\e[4;32m'

  echo -e "\n${UYellow}Running hugo${Color_Off}"
  hugo || { echo -e "${Red}failed${Color_Off}" ; return 1 ; }
  sleep .5
  echo -e "\n${UYellow}Changing to public${Color_Off}"
  command cd public || { echo -e "${Red}failed${Color_Off}" ; return 1 ; }
  sleep .5
  echo -e "\n${UYellow}Adding public${Color_Off}"
  git add . -v || { echo -e "${Red}failed${Color_Off}" ; return 1 ; }
  sleep .5
  echo -e "\n${UYellow}Commiting public with \"${commit_message}${Color_Off}\""
  git commit -m "commit_message" -v || { echo -e "${Red}failed${Color_Off}" ; return 1 ; }
  sleep .5
  echo -e "\n${UYellow}Pushing public${Color_Off}"
  git push -u origin master -v || { echo -e "${Red}failed${Color_Off}" ; return 1 ; }
  sleep .5
  echo -e "\n${UYellow}Changing to main folder${Color_Off}"
  command cd ../ || { echo -e "${Red}failed${Color_Off}" ; return 1 ; }
  sleep .5
  echo -e "\n${UYellow}Adding main${Color_Off}"
  git add . -v || { echo -e "${Red}failed${Color_Off}" ; return 1 ; }
  sleep .5
  echo -e "\n${UYellow}Commiting main with \"${commit_message}${Color_Off}\""
  git commit -m "$commit_message" -v || { echo -e "${Red}failed${Color_Off}" ; return 1 ; }
  sleep .5
  echo -e "\n${UYellow}Pushing main${Color_Off}"
  git push -u origin master -v || { echo -e "${Red}failed${Color_Off}" ; return 1 ; }
  # read -p "Update public [y]? " answr
  # [[ "$answr" != "y" ]] && return 1
  echo -e "\n${UGreen}Done${Color_Off}"
}