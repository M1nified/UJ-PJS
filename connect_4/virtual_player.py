#!/usr/bin/python3

import argparse
import subprocess
from threading import Thread

parser = argparse.ArgumentParser()
parser.add_argument('-b', '--board', help='Board state', required=True, dest='board')
parser.add_argument('-p', '--player', help='Player', required=True, dest='player')

args = parser.parse_args()
args = vars(args)

player = args['player']
board = args['board']

tmp = board.split(':')
board_x = int(tmp[1])
board_y = int(tmp[2])


def try_move(player0, board, player, depth = 0, column = -1, results = [None]):
    if(depth > 5):
        return ("too_deep", -1, 0)
    # print(player)
    if column == -1:
        results = [None] * board_x
        threads = [None] * board_x
        for col in range(1, board_x + 1):
            threads[col-1] = Thread(target=try_move, args=(player0, board, player, depth + 1, col, results))
            threads[col-1].start()

        for i in range(len(threads)):
            # print(i)
            threads[i].join()

        best_final = "lost"
        best_move = -1
        best_count = -1
        for i in range(len(results)):
            (final, move, count) = results[i]
            if best_final == "lost" and final != "lost":
                best_final = final
                best_move = move
                best_count = count
            elif final == "won" and count < best_count:
                best_final = final
                best_move = move
                best_count = count
            elif final == "stuck" and best_final != "won" and count < best_count:
                best_final = final
                best_move = move
                best_count = count
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
                    results[column-1] = ("stuck", column, 1)
                else:
                    (final, move, count) = try_move(player0, res_board, tmp[1], depth + 1)
                    # results[column-1] = ("next", column, 1)
                    results[column-1] = (final, column, count + 1)
            elif tmp[0] == 'won_by':
                if tmp[1] == player0:
                    results[column-1] = ("won", column, 1)
                else:
                    results[column-1] = ("lost", column, 1)

(final, move, count) = try_move(player, board, player)

print(final)
print(move)
print(count)
