#!/bin/bash

if ! [[ $# -eq 3 ]]; then
	echo "$0 <left argument> <right argument> <operator>";
	exit 3;
fi

if ! [[ $1 =~ ^[\+-]?[0-9]+$ ]]; then
	echo "'$1' is not a number";
	exit 1;
fi

if ! [[ $2 =~ ^[\+-]?[0-9]+$ ]]; then
	echo "'$2' is not a number";
	exit 2;
fi	

case $3 in
	+)
		echo $(($1 + $2)) ;;
	-)
		echo $(($1 - $2)) ;;
	\*)
		echo $(($1 * $2)) ;;
	/)
		echo $(($1 / $2)) ;;
	^)
		echo $(($1 ** $2)) ;;
	%)
		echo $(($1 % $2)) ;;
esac
