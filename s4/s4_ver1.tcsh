#!/bin/tcsh

if ( $# < 2 ) then
	echo "$0 <first IP address or hostname> <second IP address or hostname>"
	exit 2
endif

foreach ip ($1 $2)
    if (`./is_ip.tcsh $ip` == "") then
		echo "$ip is neither an IP address nor a hostname"
        exit 1
    endif
end

set is_connected = 1
# foreach file (/sys/class/net/*)
#     if (`cat $file/operstate` == "up") then
#         set is_connected = 0
#         break
#     endif
# end

set def_gate = `ip r | grep default | grep -o -e '\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}'`
ping -c 1 -W 2 -q $def_gate > /dev/null
set ping_status = $?
if ($ping_status == 0) then
    set is_connected = 0
endif

if ($is_connected != 0) then
	echo "Neither of the interfaces is connected"
    exit 3
endif

set first = `./is_ip.tcsh $1`
set second = `./is_ip.tcsh $2`
set from = `echo "$first\n$second" | sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4 | head -n 1`
set to = `echo "$first\n$second" | sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4 | tail -1`

set curr_ip = $from

while ($curr_ip != $to)
    ./analyze.tcsh $curr_ip $3
    set curr_ip = `./increment_ip.tcsh $curr_ip`
end
./analyze $curr_ip $3

exit 0
