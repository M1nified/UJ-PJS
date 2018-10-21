#!/bin/bash

if ! [[ $# -gt 1 ]]; then
	echo "At least two arguments are required!";
	exit 3;
fi

if ! [[ $1 =~ ^[+-]?[0-9]+$ ]]; then
	echo "'$1' is not an integer";
	exit 1;
fi

if ! [[ $2 =~ ^[+-]?[0-9]+$ ]]; then
	echo "'$2' is not an integer";
	exit 2;
fi

from=$1
to=$2

if [[ $to < $from ]]; then
	tmp=$to
	to=$from
	from=$tmp
fi

for a in $(seq $from $to); do for b in $(seq $from $to); do
	echo -en "$a x $b = $(($a*$b))\t";
done; echo; done
