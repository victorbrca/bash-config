#
## about:Aliases for SSL
#

# help:ressh:Attempts to reconnect a SSH connection when exits with error
# By Nobert V.
ressh () 
{
  while ! ssh $* ; do
    echo "Attempting to re-connect to $1"   
    sleep .5
  done
}
