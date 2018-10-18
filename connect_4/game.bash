#!/bin/bash

declare -g -A board

player_1_mark="a"
player_2_mark="b"

function display_board {
    echo -n '|'
    for x in {1..7}; do
        echo -n "--"
    done
    echo '-|'
    echo -n '|'
    for x in {1..7}; do
        echo -n " $x"
    done
    echo ' |'
    for y in {0..5}; do
        echo -n '|'
        for x in {0..6}; do
            echo -n " ${board[$x,$y]}"
        done
        echo ' |'
    done
    echo -n '|'
    for x in {1..7}; do
        echo -n " $x"
    done
    echo ' |'
    echo -n '|'
    for x in {1..7}; do
        echo -n "--"
    done
    echo '-|'
}

function empty_board {
    for y in {0..5}; do
        for x in {0..6}; do 
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
    local y=5
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
    if [[ $x < 0 || $x > 6 || $y < 0 || $y > 5 ]] ; then
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
    for x in {0..6} ; do
        for y in {0..5} ; do
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
    empty_board
    display_board

    active_player=$player_1_mark

    game_on=0

    while [[ $game_on -eq 0 ]]; do
        echo "Waiting for player: $active_player"
        col=$(get_col)
        echo "col: $col"
        drop_in $col $active_player
        drop_result=$?
        display_board
        check_for_win $active_player
        win_len=$?
        if [[ $win_len -ge 4 ]] ; then
            echo "!YOU WON!"
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

game
