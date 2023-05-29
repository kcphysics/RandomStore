#!/bin/bash

CMD=$1

start_debug(){
  echo "Starting Debug"
  while sleep 1000; do :; done
}

case "$CMD" in
  debug)
    start_debug
    ;;
  *)
    $CMD
    ;;
esac