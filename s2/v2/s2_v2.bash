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

for a in $(seq $1 $2); do for b in $(seq $1 $2); do
	echo -en "$a x $b = $(($a*$b))\t";
done; echo; done
