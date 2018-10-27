#!/bin/tcsh

set arr = `echo $1 | tr '.' "\n"`

@ tmp = $arr[4] + 1
set arr = ($arr[1-3] $tmp)

foreach i (`seq 4 -1 2`)

    if ($arr[$i] > 255) then
        @ prev_index = $i - 1
        @ prev_prev_index = $prev_index - 1
        @ next_index = $i + 1
        set arr = ($arr[-$prev_index] 0 $arr[$next_index-])
        @ tmp = $arr[$prev_index] + 1
        set arr = ($arr[-$prev_prev_index] $tmp $arr[$i-])
    endif

end

echo "$arr[1].$arr[2].$arr[3].$arr[4]"

exit 0
