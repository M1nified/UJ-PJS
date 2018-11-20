#!/bin/bash

declare -g -A board

player_1_mark="a"
player_2_mark="b"

x_max=6
y_max=5

function display_board {
    # ()
    echo -e "board:7:6:"
    for y in $(seq 0 $y_max); do
        for x in $(seq 0 $x_max); do
            echo -n "${board[$x,$y]}:"
        done
        echo
    done
}

function display_board_raw {
    echo -en "board:$(($x_max + 1)):$(($y_max + 1)):"
    for y in $(seq 0 $y_max) ; do
        for x in $(seq 0 $x_max) ; do
            if [[ ${board[$x,$y]} != " " ]] ; then
                echo -n "${board[$x,$y]},"
            else
                echo -n ","
            fi
        done
    done
    echo ":"
}

function empty_board {
    # ()
    for y in $(seq 0 $y_max); do
        for x in $(seq 0 $x_max); do 
            board[$x,$y]=' '
        done
    done
}

function set_board {
    # (x,y,value)
    # echo "$1 $2 $3"
    eval board[$1,$2]=$3
}

function get_move {
    # ()
    read -n 1 -s move
    echo $move
}

function get_col {
    # ()
    move=$(get_move)
    col=$(($move-1))
    echo $col
}

function drop_in {
    # (col_number, value)
    local col_number=$1
    local y=$y_max
    while [[ ${board[$col_number,$y]} != " " && $y -ge 0 ]]; do
        y=$(($y-1))
    done
    if [[ $y -ge 0 ]] ; then
        set_board $col_number $y $2
        return 0 
    else
        return 1
    fi
}

function count_line {
    local direction=$1
    local x=$2
    local y=$3
    local mark=$4
    if [[ $x < 0 || $x > $x_max || $y < 0 || $y > $y_max ]] ; then
        return 0
    fi
    if [[ ${board[$x,$y]} == $mark ]] ; then
        case $direction in
            n)
                local y=$(($y-1)) ;;
            ne)
                local x=$(($x+1))
                local y=$(($y-1)) ;;
            e)
                local x=$(($x+1)) ;;
            se)
                local x=$(($x+1))
                local y=$(($y+1)) ;;
            s)
                local y=$(($y+1)) ;;
            sw)
                local x=$(($x-1))
                local y=$(($y+1)) ;;
            w)
                local x=$(($x-1)) ;;
            nw)
                local x=$(($x-1))
                local y=$(($y-1)) ;;
        esac
        count_line $direction $x $y $mark
        count=$(($?+1))
        return $count
    else
        return 0
    fi
}

function check_for_win {
    local mark=$1
    local win_length=4
    for x in $(seq 0 $x_max) ; do
        for y in $(seq 0 $y_max) ; do
            if [[ ${board[$x,$y]} != ' ' ]] ; then
                for direction in n ne e se s sw w nw ; do
                    count_line $direction $x $y $mark
                    local len=$?
                    if [[ $len -ge $win_length ]] ; then
                        return $len
                    fi
                done
            fi
        done
    done
}

function game {
    # ()
    empty_board
    display_board

    active_player=$player_1_mark

    game_on=0

    while [[ $game_on -eq 0 ]]; do
        echo "current_player:$active_player:"
        col=$(get_col)
        # echo "col: $col"
        drop_in $col $active_player
        drop_result=$?
        display_board
        check_for_win $active_player
        win_len=$?
        if [[ $win_len -ge 4 ]] ; then
            echo "won_by:$active_player:"
            game_on=1
        fi
        if [[ $drop_result == "0" ]] ; then
            if [[ $active_player == $player_1_mark ]] ; then
                active_player=$player_2_mark
            else
                active_player=$player_1_mark
            fi
        fi
    done
}

while getopts "01esb:m:" opt ; do
    case $opt in
        b)
            isb=true
            initial_board=$OPTARG
            ;;
        m)
            move=$OPTARG
            ;;
        s)
            single_move=true
            ;;
        0)
            is0=true
            ;;
    esac
done

if [[ "$is0" == true ]] ; then
    empty_board
fi

if [[ "$isb" == true ]] ; then
    tmp=($(echo -n $initial_board | tr ':' "\n"))
    if [[ "${tmp[0]}" != "board" ]] ; then
        exit 1;
    fi
    x_max=$((${tmp[1]} - 1))
    y_max=$((${tmp[2]} - 1))
    empty_board
    tmp=($(echo -n ${tmp[3]} | sed 's/,,/,_,/g;s/,,/,_,/g;s/^,/_,/g;s/,$//g' | tr ',' "\n"))
    i=0
    for y in $(seq 0 $y_max) ; do
        for x in $(seq 0 $x_max) ; do 
            char=${tmp[$i]}
            # echo "$i $x $y $char"
            if [[ "$char" == "_" || "$char" == "" ]] ; then
                set_board $x $y ' '
                board[$x,$y]=' '
            else
                set_board $x $y $char
                board[$x,$y]=$char
            fi
            i=$(($i + 1))
        done
    done
fi

if [[ "$is0" == true ]] ; then
    display_board_raw
    exit 0
fi

# display_board

if [[ "$single_move" -eq true ]] ; then
    # display_board
    move=($(echo $move | tr ':' "\n"))
    move_player=${move[0]}
    move_col=$((${move[1]} - 1))
    drop_in $move_col $move_player
    drop_result=$?
    display_board_raw
    check_for_win $move_player
    win_len=$?
    if [[ $win_len -ge 4 ]] ; then
        echo "won_by:$move_player:"
    elif [[ "$drop_result" == "0" ]] ; then
        if [[ $move_player == $player_1_mark ]] ; then
            active_player=$player_2_mark
        else
            active_player=$player_1_mark
        fi
        echo "current_player:$active_player:"
    else
        echo "current_player:$move_player:"
    fi
else
    game
fi

# display_board
# ,,,,,,,
# ,,,,,,,
# ,,,,,,,
# ,,,,,,,
# ,,,,,,,
# a,,,,,,,: