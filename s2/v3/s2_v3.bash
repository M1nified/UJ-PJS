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

from=$1
to=$2

if [[ $to < $from ]] ; then
	tmp=$to
	to=$from
	from=$tmp
fi

for a in $(seq $from $to) ; do for b in $(seq $from $to); do

	case $3 in
		+)
			echo -en "$a + $b = $(($a + $b))\t" ;;
		-)
			echo -en "$a - $b = $(($a - $b))\t" ;;
		\*)
			echo -en "$a * $b = $(($a * $b))\t" ;;
		/)
			echo -en "$a / $b = $(($a / $b))\t" ;;
		^)
			echo -en "$a ^ $b = $(($a ** $b))\t" ;;
		%)
			echo -en "$a % $b = $(($a % $b))\t" ;;
	esac

done; echo; done

