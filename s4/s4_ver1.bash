#!/bin/bash

function is_ip {
	if [[ "$1" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]] ; then
		echo 0
	else
		echo 1
	fi
}

function increment_ip {
	arr=($(echo $1 | tr '.' "\n"))

	arr[3]=$((${arr[3]}+1))

	for i in {3..1} ; do
		if [[ "${arr[$i]}" -gt "255" ]] ; then
			arr[$i]=0
			arr[$(($i-1))]=$((arr[$(($i-1))]+1))
		fi
	done

	echo ${arr[0]}.${arr[1]}.${arr[2]}.${arr[3]}
}

function analyze {
	ip=$1

	ping -c 1 -W 2 $ip > /dev/null 2> /dev/null
	ping_status=$?
	if [[ $ping_status -eq 0 ]] ; then
		echo -en "$ip: "
		for port in "${ports[@]}" ; do
			echo -n "$port "
			timeout 2 bash -c "</dev/tcp/$ip/$port" 2> /dev/null
			status=$?
			if [[ "$status" -ne "0" ]] ; then
				echo -n "closed "
			else
				info=$(timeout 2 bash -c "exec 3<>/dev/tcp/$ip/$port && head -n 1 <&3")
				if [[ "$info" == "" ]] ; then
					info=$(timeout 2 bash -c "exec 3<>/dev/tcp/$ip/$port && echo \"HEAD / HTTP/1.1\" >&3 && cat <&3 | grep 'Server:' | cut -d ':' -f 2")
				fi
				info=$(echo $info | tr -d '\r')
				if [[ "$info" != "" ]] ; then
					echo -n "$info "
				else
					echo -n "open "
				fi
			fi
		done
		echo
	else
		echo -e "$ip: unreachable"
	fi
}

function name_to_ip {
	ip=$(dig +short $1)
	echo $ip
}

if [[ "$#" -lt "3" ]] ; then
	echo "$0 <first IP address or hostname> <second IP address or hostname> <port numbers>"
	exit 2
fi

ips="${@:1:2}"

for i in $ips ; do
	if [[ "$(name_to_ip $i)" == "" ]] ; then
		echo "$i is neither an IP address nor a hostname"
		exit 1
	fi
#	if [[ "$(is_ip $i)" -eq "1" ]] ; then
#		echo "$i is not a valid IP address"
#		exit 1
#	fi	
done

is_connected=1
# for file in /sys/class/net/* ; do
# 	if [[ "$(cat $file/operstate)" -eq "up" ]] ; then
# 		is_connected=0
# 		break
# 	fi
# done

def_gate=$(ip r | grep default | grep -o -e '\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}')
ping -c 1 -W 2 $def_gate > /dev/null
ping_status=$?
if [[ "$ping_status" -eq "0" ]] ; then
	is_connected=0
fi

if [[ "$is_connected" -ne "0" ]] ; then
	echo "Neither of the interfaces is connected"
	exit 3
fi

first=$(name_to_ip $1)
second=$(name_to_ip $2)

from=$(echo -e "$first\n$second" | sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4 | head -n 1)
to=$(echo -e "$first\n$second" | sort -n -t . -k 1,1 -k 2,2 -k 3,3 -k 4,4 | tail -1)

ports=($(echo $3 | tr ',' '\n'))

curr_ip=$from
while [[ "$curr_ip" != "$to" ]] ; do
	analyze $curr_ip
	curr_ip=$(increment_ip $curr_ip)
done
analyze $curr_ip

exit 0
