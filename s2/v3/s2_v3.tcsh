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

switch ("$3")
	case '\+':
		@ result = $1 + $2
		breaksw;
	case '-':
		@ result = $1 - $2
		breaksw;
	case '[\\*]':
		@ result = $1 * $2
		breaksw;
	case '/':
		@ result = $1 / $2
		breaksw;
	case '[\\^]':
		@ result = $1
		@ base = $result
		@ step = 1
		while ( $step < $2 )
			@ result *= $base
			@ step++
		end
		breaksw;
	case '[%%]':
		@ result = $1 % $2
		breaksw;
	default:
		echo "'$3' operator is not supported"
endsw
echo $result

