#!/bin/bash

FILE_NAME='/tmp/connect4_webserver.pid'

function start {
    if [ ! -f $FILE_NAME ] ; then
        ./webserver.py start &> /dev/null &
        pid=$!
        echo $pid > $FILE_NAME
        echo "Connect4 webserver started!"
    fi
}

function stop {
    if [ -f $FILE_NAME ] ; then
        pid=$(<$FILE_NAME)
        kill -9 $pid
        rm $FILE_NAME
        echo "Connect4 webserver stopped!"
    fi
}

if [[ "$1" == "start" ]] ; then
    start
elif [[ "$1" == "stop" ]] ; then
    stop
elif [[ "$1" == "restart" ]] ; then
    stop
    start
fi
