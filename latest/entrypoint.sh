#!/bin/bash

OPTIONS=$@

DEBUG=FALSE

if [ $DEBUG == "TRUE" ] ; then
KNOWNHOSTFILE="./known_hosts";
else
KNOWNHOSTFILE="${HOME}/.ssh/known_hosts";
fi

while [ "$1" != "" ]; do
  case "$1" in
    --add-known-host ) echo "Get SSH-Key from $2"; 
      ssh-keyscan $2 > $KNOWNHOSTFILE;
      shift 2 ;;
    * ) shift;;
  esac

done

duplicity $OPTIONS

exit 0
