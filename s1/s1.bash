#!/bin/bash

function help {
  echo "Options:"
  echo -e "\t-h\tDisplays this help"
  echo -e "\t-q\tQuiet mode"
}

while getopts "hq" opt 2>/dev/null; do
  case $opt in
    h)
        help
	exit 0
;;
    q)
        exit 0
;;
    ?)
        echo "Unknown option!"
        help
	exit 0
;;
  esac
done

login=$(whoami)
name=$(getent passwd $login | awk -F : '{print $5}' | awk -F , '{print $1}')

echo $login
echo $name

