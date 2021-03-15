#!/bin/bash

: ${SLEEP_LENGTH:=2}
: ${TIMEOUT_LENGTH:=300}

# Much of this section was influenced by: https://stackoverflow.com/a/26756839
declare -a pids
waitPids() {
    while [ ${#pids[@]} -ne 0 ]; do
        for i in ${!pids[@]}; do
            if ! kill -0 ${pids[$i]} 2> /dev/null; then
                unset pids[$i] #Done 
            fi
        done
        pids=("${pids[@]}") # Expunge nulls created by unset.
        sleep $SLEEP_LENGTH
    done
    echo "Done!"
}

addPid() {
  local pid=$1
  pids=(${pids[@]} $pid)
}

wait_for() {
  START=$(date +%s)
  echo "Checking if $1 is listening on $2..."
  while ! nc -z $1 $2;
    do
    if [ $(($(date +%s) - $START)) -gt $TIMEOUT_LENGTH ]; then
        echo "Service $1:$2 did not start within $TIMEOUT_LENGTH seconds. Aborting..."
        exit 1
    fi
    echo "Waiting for $1 to listen on $2..."
    sleep $SLEEP_LENGTH
  done
  echo "Service $1:$2 is available!"
}

for var in "$@"
do
  host=${var%:*}
  port=${var#*:}
  wait_for $host $port &
  addPid $!
done

waitPids
