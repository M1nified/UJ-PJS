#!/bin/tcsh

set ip = $1

set ports = (`echo $2 | tr ',' '\n'`)

ping -c 1 -W 2 $ip > /dev/null
set ping_status = $?

if ($ping_status == 0) then
    echo -n "$ip : "
    foreach port ($ports)
        echo -n "$port "
        set info = `nc -w 2 $ip $port `
	set nc_status = $?
	if ($nc_status != 0) then
		echo -n "closed "
	else
		if ("$info" == "") then
			set info = `echo "HEAD / HTTP/1.1" | nc -w 2 $ip $port | grep "Server:" | cut -d ':' -f 2`
		endif
	        set info = `echo $info | tr -d '\r'`
		if ("$info" == "") then
			echo -n "open "
	       	else
		        echo -n "$info "
		endif
	endif
    end
    echo
else
    echo "$ip : unreachable"
endif

exit 0
