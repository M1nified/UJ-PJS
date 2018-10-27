#!/bin/tcsh

set ip = $1

ping -c 1 -W 2 $ip > /dev/null
set ping_status = $?

if ($ping_status == 0) then
    echo "$ip is alive"
else
    echo "$ip is unreachable"
endif

exit 0
