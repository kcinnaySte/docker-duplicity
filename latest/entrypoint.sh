#!/bin/bash

OPTIONS=$@

DEBUG=FALSE

if [ $DEBUG == "TRUE" ] ; then
KNOWNHOSTFILE="./known_hosts";
else
KNOWNHOSTFILE="${HOME}/.ssh/known_hosts";
fi
ISINITCOMMAND=FALSE

while [ "$1" != "" ]; do
  case "$1" in
    --add-known-host )
      ISINITCOMMAND=TRUE
      shift ;
      echo "Get SSH-Key from $1"; 
      ssh-keyscan $1 > $KNOWNHOSTFILE;
      shift ;;
    --generate-ssh-key )
      ISINITCOMMAND=TRUE;
      echo "Generate SSH-Keys";
      ssh-keygen -b 4096 -t rsa -f "${HOME}/.ssh/id_rsa" -q -N "";
      cat "${HOME}/.ssh/id_rsa.pub";
      shift;;
    * ) shift;;
  esac

done
if [ "$ISINITCOMMAND" == "FALSE" ]; then
duplicity $OPTIONS
fi

exit 0
