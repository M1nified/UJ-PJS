#!/usr/bin/python3

import argparse
import subprocess
from threading import Thread
import pickle
import os

def save_obj(obj, name ):
    with open('./'+ name + '.pkl', 'wb') as f:
        pickle.dump(obj, f, pickle.HIGHEST_PROTOCOL)

def load_obj(name ):
    file_name = './' + name + '.pkl'
    if os.path.isfile(file_name):
        with open(file_name, 'rb') as f:
            try:
                return pickle.load(f)
            except:
                return False
    else:
        return False

parser = argparse.ArgumentParser()
parser.add_argument('-b', '--board', help='Board state', required=True, dest='board')
parser.add_argument('-p', '--player', help='Player', required=True, dest='player')

args = parser.parse_args()
args = vars(args)

player = args['player']
board = args['board']
board = subprocess.check_output("./game_engine.bash -0 -b " + board, shell=True).decode().split("\n")[0]

if player == 'b':
    board = board.replace("b,", "c,").replace(",b", ",c").replace("a,", "b,").replace(",a", ",b").replace("c,", "a,").replace(",c", ",a")
    player = 'a'

tmp = board.split(':')
board_x = int(tmp[1])
board_y = int(tmp[2])

calls = 0
working_threads = 0
working_threads_max = 10

moves_map = {}
moves_map_name = 'moves_map_' + str(board_x) + '_' + str(board_y)
tmp = load_obj(moves_map_name)
if tmp != False:
    moves_map = tmp

# print(moves_map)

def try_move(player0, board, player, depth = 0, column = -1, results = None):
    global calls
    global working_threads, working_threads_max
    global board_x, board_y
    global moves_map

    calls += 1

    if board in moves_map:
        return moves_map[board]
    elif column == -1:
        results = [None] * board_x
        threads = [None] * board_x
        if working_threads < working_threads_max:
            for col in range(1, board_x + 1):
                working_threads += 1
                threads[col-1] = Thread(target=try_move, args=(player0, board, player, depth + 1, col, results))
                threads[col-1].start()

            for i in range(len(threads)):
                # print(i)
                threads[i].join()
                working_threads -= 1
        else:
            for col in range(1, board_x + 1):
                # print('local')
                try_move(player0, board, player, depth + 1, col, results)


        # print("joined", depth, calls)
        best_final = "lost"
        best_move = -1
        best_count = -1
        for i in range(len(results)):
            if results[i]:
                (final, move, count) = results[i]
                if best_final != "won" and final == "won" or best_final != "stuck" and final == "stuck":
                    best_final = final
                    best_move = move
                    best_count = count
                if final == "won" and count < best_count:
                    best_move = move
                    best_count = count
                elif best_final != "won" and count < best_count:
                    best_final = final
                    best_move = move
                    best_count = count
        if best_final != "stuck":
            print(board, (best_final, best_move, best_count))
        moves_map[board] = (best_final, best_move, best_count)
        return(best_final, best_move, best_count)
    else:
        command = "./game_engine.bash -s -b " + board + " -m " + player + ":" + str(column)
        # print(command)

        result = subprocess.check_output(command, shell=True)
        # print(result)
        result = result.decode().split("\n")
        # print(result)
        res_board = result[0]
        if result[1] :
            tmp = result[1].split(":")
            # print(tmp)
            if tmp[0] == 'current_player':
                if tmp[1] == player:
                    # print("stuck", calls)
                    results[column-1] = ("stuck", column, 1)
                else:
                    (final, move, count) = try_move(player0, res_board, tmp[1], depth + 1)
                    # results[column-1] = ("next", column, 1)
                    results[column-1] = (final, column, count + 1)
            elif tmp[0] == 'won_by':
                if tmp[1] == player0:
                    # print("won", calls)
                    results[column-1] = ("won", column, 1)
                else:
                    # print("lost", calls)
                    results[column-1] = ("lost", column, 1)
            else:
                results[column-1] = ("stuck", column, 1)
        else:
            results[column-1] = ("stuck", column, 1)

(final, move, count) = try_move(player, board, player)

# print((final, move, count))

print(move)

save_obj(moves_map, moves_map_name)
