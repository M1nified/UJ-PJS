#!/bin/tcsh

if ( $# != 3 ) then
	echo "$0 <left argument> <right argument> <operator>"
	exit 3
endif

echo $1 | grep -q -e '^[+-]\?[0-9]\+$'
if ( $? != 0 ) then
	echo "'$1' is not a number"
	exit 1
endif

echo $2 | grep -q -e '^[+-]\?[0-9]\+$'
if ( $? != 0 ) then
	echo "'$2' is not a number"
	exit 2
endif

set from = $1
set to = $2

if ( $to < $from ) then
	@ tmp = $to
	@ to = $from
	@ from = $tmp
endif

foreach a (`seq $from $to`)
	foreach b (`seq $from $to`)

		switch ("$3")
			case '\+':
				@ result = $a + $b
				breaksw;
			case '-':
				@ result = $a - $b
				breaksw;
			case '[\\*]':
				@ result = $a * $b
				breaksw;
			case '/':
				@ result = $a / $b
				breaksw;
			case '[\\^]':
				@ result = $a
				@ base = $result
				@ step = 1
				while ( $step < $b )
					@ result *= $base
					@ step++
				end
				breaksw;
			case '[%%]':
				@ result = $a % $b
				breaksw;
			default:
				echo "'$3' operator is not supported"
				exit 4
		endsw
		echo -n "$a $3 $b = $result\t"

	end
	echo
end

