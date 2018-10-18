#!/bin/bash

for a in {0..9}; do for b in {0..9}; do
	echo -en "$a x $b = $(($a*$b))\t";
done; echo; done
