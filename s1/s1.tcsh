#!/bin/tcsh

set opts=(`getopt -q -s tcsh -o hq -- $argv`)
set getopt_status=$?

if ($getopt_status == 1) then
	echo "Unknown option!"
	goto help
endif

foreach opt ($opts)
	if ($opt == -h) then
		goto help;
	endif
end
	
foreach opt ($opts)
	switch($opt)
	case -q:
		exit 0;
	case --:
		breaksw;
	endsw
end

meat:
set username=$USER
echo $username
getent passwd $username | awk -F : '{print $5}' | awk -F , '{print $1}'

exit 0

help:
echo "Options:"
echo "\t-h\tDisplays this help"
echo "\t-q\tQuiet mode"
exit 0;

