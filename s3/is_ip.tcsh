#!/bin/tcsh

if ( $# != 1 ) then
    echo "Use like: $0 <ip address or hostname>"
    exit 2
endif

set ip = `dig +short $1`

echo $ip

if ( $ip == "" ) then
    exit 1
else
    exit 0
endif
