#!/usr/bin/python3

import argparse
import subprocess
from threading import Thread
import pickle
import os


def save_obj(obj, name):
    with open('./' + name + '.pkl', 'wb') as f:
        pickle.dump(obj, f, pickle.HIGHEST_PROTOCOL)


def load_obj(name):
    file_name = './' + name + '.pkl'
    if os.path.isfile(file_name):
        with open(file_name, 'rb') as f:
            try:
                return pickle.load(f)
            except:
                return False
    else:
        return False

parser = argparse.ArgumentParser(description="Returns next move for a given player at the a given board state.")
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
    "./game_engine.sh -0 -b " + board, shell=True).decode().split("\n")[0]

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
    command = "./game_engine.sh -s -b " + \
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


def find_next_move(player, board):
    print(player, board)
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
    print(states)
    for col, states2 in states:
        print(col)
        for state in states2:
            print(state)


def find_move(player, board):
    col = ensure_instant_win(player, board)
    if col != None:
        return col
    col = prevent_instant_lose(player, board)
    if col != None:
        return col
    find_next_move(player, board)


def find_move_0():
    global player, board
    col = find_move(player, board)
    return col


move = find_move_0()
print(move, end='')
