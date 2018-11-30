#!/usr/bin/python3

import argparse
import os
import pickle
import subprocess
from threading import Thread

script_dir = os.path.dirname(os.path.realpath(__file__)) + '/'
# print(script_dir)

def save_obj(obj, name):
    global script_dir
    with open(script_dir + name + '.pkl', 'wb') as f:
        pickle.dump(obj, f, pickle.HIGHEST_PROTOCOL)


def load_obj(name):
    global script_dir
    file_name = script_dir + name + '.pkl'
    if os.path.isfile(file_name):
        with open(file_name, 'rb') as f:
            try:
                return pickle.load(f)
            except:
                return False
    else:
        return False


parser = argparse.ArgumentParser(
    description="Returns next move for a given player at the a given board state.")
parser.add_argument('-b', '--board', help="Board state",
                    required=True, dest='board')
parser.add_argument('-p', '--player', help='Player\nE.g. -p a',
                    required=True, dest='player')
parser.add_argument('-v', '--verbose', help='Display log',
                    required=False, dest='verbose', action='store_true')

args = parser.parse_args()
args = vars(args)

board = args['board']
player = args['player']
verbose = args['verbose']
board = subprocess.check_output(
    script_dir + "game_engine.sh -0 -b " + board, shell=True).decode().split("\n")[0]

if player == 'b':
    board = board.replace("b,", "c,").replace(",b", ",c").replace(
        "a,", "b,").replace(",a", ",b").replace("c,", "a,").replace(",c", ",a")
    player = 'a'

tmp = board.split(':')
board_x = int(tmp[1])
board_y = int(tmp[2])

calls = 0
working_threads = 0
working_threads_max = 10


def is_won(result_str):
    lines = result_str.splitlines(False)
    if len(lines) > 1:
        potential_won_by = lines[1]
        if potential_won_by.split(":")[0] == "won_by":
            return potential_won_by.split(":")[1]
        else:
            return False
    return None


def get_board_row(result_str):
    lines = result_str.splitlines(False)
    if len(lines) > 0:
        board = lines[0]
        if board.split(":")[0] == "board":
            return board
    return None


def get_current_player_row(result_str):
    lines = result_str.splitlines(False)
    if len(lines) > 1:
        current_player = lines[1]
        if current_player.split(":")[0] == "current_player":
            return current_player
    return None


def get_current_player(result_str):
    row = get_current_player_row(result_str)
    if row != None:
        return row.split(":")[1]
    return None


def oponent_of(player):
    if(player == 'a'):
        return 'b'
    else:
        return 'a'


def get_move_result(player, board, move_col):
    global script_dir
    command = script_dir + "game_engine.sh -s -b " + \
        board + " -m " + player + ":" + str(move_col)
    result = subprocess.check_output(command, shell=True).decode()
    return result


def prevent_instant_lose(player, board):
    global board_x
    for col in range(1, board_x + 1):
        test = get_move_result(oponent_of(player), board, col)
        if is_won(test) == oponent_of(player):
            return col
    return None


def ensure_instant_win(player, board):
    global board_x
    for col in range(1, board_x + 1):
        test = get_move_result(player, board, col)
        if is_won(test) == player:
            return col
    return None


def find_next_move(player, board, levels_to_go):
    # print(player, board)
    global board_x
    states = []
    for col in range(1, board_x + 1):
        move1 = get_move_result(player, board, col)
        if get_current_player(move1) == oponent_of(player):
            board1 = get_board_row(move1)
            moves = []
            for col2 in range(1, board_x + 1):
                move2 = get_move_result(oponent_of(player), board1, col2)
                if get_current_player(move2) == player:
                    moves.append(move2)
            states.append((col, moves))
    # print("STATES", states)
    cols_ok = []
    cols_bad = []
    for col, states2 in states:
        # print(col)
        for state in states2:
            # print(state)
            res, col2 = find_move(player, get_board_row(state), levels_to_go - 1)
            if res == 'win':
                return 'win', col
            elif res == 'lose':
                cols_bad.append(col)
            else:
                cols_ok.append(col)
    if len(cols_ok) > 0:
        return 'move', cols_ok[0]
    elif len(cols_bad) > 0:
        return 'move', cols_bad[0]
    else:
        return 'move', 1



def find_move(player, board, levels_to_go = 1):
    if levels_to_go <= 0:
        return 'max_level', None
    col = ensure_instant_win(player, board)
    if col != None:
        return 'win', col
    col = prevent_instant_lose(player, board)
    if col != None:
        return 'lose', col
    return find_next_move(player, board, levels_to_go)


def find_move_0():
    global player, board
    _, col = find_move(player, board)
    return col


move = find_move_0()
print(move, end='')
