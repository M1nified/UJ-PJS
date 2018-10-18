#!/bin/tcsh

if ($# < 2 ) then
	echo "At least two arguments are required!";
	exit 3
endif

echo $1 | grep -q -e '^[+-]\?[0-9]\+$'
if ($? != 0) then
	echo "'$1' is not an integer"
	exit 1
endif

echo $2 | grep -q -e '^[+-]\?[0-9]\+$'
if ( $? !~ 0 ) then
	echo "'$2' is not an integer"
	exit 2
endif

foreach a (`seq $1 $2`)
	foreach b (`seq $1 $2`)
		@ tmp = $a * $b
		echo -n "$a x $b = $tmp\t"
	end
	echo
end

