
_git_branch () 
{
  local gitbranch gitstatus modified


  gitbranch=$(git branch 2> /dev/null | grep '\*' | sed -e 's/* \(.*\)/\1/')

  if [ "$gitbranch" ] ; then
    gitbranch="${gitbranch} "
    gitstatus=$(git status -s)
    modified="✚$(git status -s | wc -l)"

    if [ "$gitstatus" ] ; then
      printf " ${gitbranch} ${modified} "
    else
      printf " ${gitbranch} ✔ "
    fi
  fi
}
