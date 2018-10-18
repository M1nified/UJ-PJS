#!/bin/tcsh

foreach a (`seq 0 9`)
	foreach b (`seq 0 9`)
		@ tmp = $a * $b
		echo -n "$a x $b = $tmp\t"
	end
	echo
end

