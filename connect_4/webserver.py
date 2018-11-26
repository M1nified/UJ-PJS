#!/usr/bin/python3

import socket, re, json, sys, os, time, atexit, pipes
from threading import Thread
from signal import SIGTERM

HOST, PORT = '', 8080
PROJECT_ROOT = os.path.dirname(__file__)
PID_FILE = '/tmp/connect4_webserver.pid'
PIPE_FILE = 'webserver.pipe'

pipe = pipes.Template()

board_string = ""
current_player_string = ""

player_a_key = ""
player_b_key = ""

def manage_pipe():
    global board_string
    global current_player_string
    f = pipe.open('webserver.pipe', 'r')
    while True:
        line = f.readline()
        if(line):
            print("PIPE", line)
            if(re.match(r"^board.*$", line)):
                print("PIPE set board")
                board_string = line
            elif(re.match(r"^current_player.*$", line)):
                print("PIPE set current_player")
                current_player_string = line
            elif(re.match(r"^player_key.*$", line)):
                print("PIPE set player_key", line)
                key = line.splitlines(False)[0].split(":")[2]
                if(re.match(r":a:", line)):
                    player_a_key = key
                else:
                    player_b_key = key
                print("PIPE set current_player")
                current_player_string = line
        time.sleep(.25)
    f.close()

def listen():
    listen_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    listen_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
    listen_socket.bind((HOST, PORT))
    listen_socket.listen(1)
    print ('Serving HTTP on port %s ...' % PORT)

    while True:
        clien_connection = False
        client_address = False
        client_connection, client_address = listen_socket.accept()
        Thread(target=client, args=(client_connection, client_address)).start()

def run():
    Thread(target=manage_pipe).start()
    Thread(target=listen).start()

    
def req_method_path(http_req):
    info = re.compile('^(\S+)\s(\S+)\s(HTTP/1.1)\s*$', re.MULTILINE)
    matches = re.search(info, http_req)
    if (matches):
        return (matches.group(1), matches.group(2))
    else:
        return (None, None)

def client(connection, address):
    print (connection, address)
    request = connection.recv(1024).decode()
    # print ('REQUEST: ', request)

    http_response = process_request(request)

    # http_response = "HTTP/1.1 200 OK\r\nContent-type: text/html\r\n\r\nHello, World!\r\n"
    connection.sendall(http_response.encode())
    print ('did send')
    connection.close()
    print ('did close')

def process_request(request):
    try:
        method, _ = req_method_path(request)
        method = method.upper()
        if(method == 'GET'):
            return process_get_request(request)
        elif(method == 'POST'):
            return process_post_request(request)
        else:
            return "HTTP/1.1 405 Method Not Allowed\r\n"
    except:
        return "HTTP/1.1 500 Internal Server Error\r\n"

def process_get_request(request):
    _, path = req_method_path(request)
    print(path)
    if(re.match(r"/api/\S*", path)):
        return process_api_get(request)
    elif(path == '/game.js'):
        with open(PROJECT_ROOT + '/www/game.js', 'r') as indexhtml:
            data = indexhtml.read()
            return "HTTP/1.1 200 OK\r\nContent-type: application/javascript\r\n\r\n" + data + "\r\n"
    else:
        with open(PROJECT_ROOT + '/www/index.html', 'r') as indexhtml:
            data = indexhtml.read()
            return "HTTP/1.1 200 OK\r\nContent-type: text/html\r\n\r\n" + data + "\r\n"

def process_post_request(request):
    _, path = req_method_path(request)
    print(path)
    if(re.match(r"/api/\S*", path)):
        return process_api_post(request)
    else:
        return "HTTP/1.1 404 Not Found\r\n"

def process_api_get(request):
    global board_string
    global current_player_string
    _, path = req_method_path(request)
    print("process_api_get", path)
    if(re.match(r"/api/board/?", path)):
        # board = "board:7:6:,a,,,b,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,:"
        board = board_string
        print(board)
        board = board.split(':')
        boardMap = {
            "x" : board[1],
            "y" : board[2],
            "board" : board[3].split(',')
        }
        boardMap['board'] = [ (1 if x == 'a' else x) for x in boardMap['board'] ]
        boardMap['board'] = [ (2 if x == 'b' else x) for x in boardMap['board'] ]
        boardMap['board'] = [ (0 if x == '' else x) for x in boardMap['board'] ]
        boardJson = json.dumps(boardMap)
        return "HTTP/1.1 200 OK\r\nContent-type: application/javascript\r\n\r\n" + boardJson
    elif(re.match(r"/api/player/current/?", path)):
        player = current_player_string
        print(player)
        player = player.splitlines(False)[0].split(':')
        playerMap = {
            "player" : player[1]
        }
        playerJson = json.dumps(playerMap)
        return "HTTP/1.1 200 OK\r\nContent-type: application/javascript\r\n\r\n" + playerJson
    elif(re.match(r"/api/me/key/?", path)):
        return "HTTP/1.1 200 OK\r\nContent-type: application/javascript\r\n\r\n"
    else:
        return "HTTP/1.1 404 Not Found\r\n"

def process_api_post(request):
    _, path = req_method_path(request)
    if(re.match(r"/api/player/move/?", path)):
        moveJson = request.split("\r\n\r\n")[1]
        move = json.loads(moveJson)
        print(move)
        return "HTTP/1.1 204 No Content\r\n"
    else:
        return "HTTP/1.1 404 Not Found\r\n"

def display_usage():
    print("Usage: %s start|stop|restart|set <setting string>" % sys.argv[0])

run()

# if __name__ == "__main__":
#     if(len(sys.argv) == 2):
#         if(sys.argv[1] == 'start'):
#             run()
#         elif(sys.argv[1] == 'stop'):
#             webserver.exit()
#         elif(sys.argv[1] == 'restart'):
#             webserver.restart()
#         else:
#             display_usage()
#             exit(1)
#     elif(len(sys.argv) == 3 and sys.argv[1] == 'set'):
#         webserver.set(sys.argv[2])
#     else:
#         display_usage()
#         exit(2)
#     exit()