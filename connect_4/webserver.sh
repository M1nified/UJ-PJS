#!/bin/bash

echo $1

if [[ "$1" -eq "start" ]] ; then
    ./webserver.py start &> /dev/null &
    pid=$!
    echo $pid
fi
