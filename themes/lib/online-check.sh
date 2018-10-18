#!/bin/bash

mkdir -p /tmp/bash-config

offline=$(dig 8.8.8.8 +time=1 +short google.com A | grep -c "no servers could be reached")
if [[ "$offline" == "0" ]] ; then
  if [ -f "/tmp/bash-config/offline" ] ; then
    rm /tmp/bash-config/offline
  fi
else
  touch /tmp/bash-config/offline
fi
