#!/bin/bash
#set -o xtrace

if [[ $# -ne 1 ]]
then
  echo "Usage: loop.sh [application]"
  exit
fi

APPLICATION=${1}

PORT=9090
case ${APPLICATION} in
  pingperf )
    ENDPOINT=ping/greeting
    ;;
  rest_crud )
    ENDPOINT=fruits
    ;;
esac

while [[ $(curl -s -o /dev/null -w ''%{http_code}'' 127.0.0.1:9090/${ENDPOINT}) != 200 ]] 
do
  sleep 0.001
done
date +"%Y-%m-%d %H:%M:%S.%N" > output2



