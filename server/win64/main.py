# coding=utf-8
from ctypes import CDLL, c_uint32, c_uint64, c_long
import mouse
import json
import sys
import os.path
from simple_http_server import WebsocketHandler, WebsocketRequest, WebsocketSession, websocket_handler, request_map, Headers
import simple_http_server.server as server

from win32api import GetSystemMetrics
from win32con import SM_CXVIRTUALSCREEN, SM_CYVIRTUALSCREEN, SM_XVIRTUALSCREEN, SM_YVIRTUALSCREEN
class Screen():
    size = (0, 0)  # (width, height)
    position = (0, 0)  # (x, y)
    v_size = (0, 0)  # (width, height) for the visual screen

    def __init__(self, size, position, v_size):
        self.size = size
        self.position = position
        self.v_size = v_size
    def v_to_screen_pos_digi(self, v_x, v_y):
        def resize(pos, v_size, offset, size):
            return (pos / 32767) * size + offset
        return (
            int(resize(v_x, self.v_size[0], self.position[0], self.size[0])),
            int(resize(v_y, self.v_size[1], self.position[1], self.size[1]))
        )

    def __str__(self):
        return "Screen <size:{}, position:{}, v_size:{}>".format(self.size, self.position, self.v_size)

def get_main_screen():
    # monitor_number = GetSystemMetrics(SM_CMONITORS)
    main_screen_size = (GetSystemMetrics(0), GetSystemMetrics(1))  # 主屏幕宽, 高
    main_screen_pos = (0 - GetSystemMetrics(SM_XVIRTUALSCREEN), 0 - GetSystemMetrics(SM_YVIRTUALSCREEN))  # 主屏幕宽, 高
    v_screen_size = (GetSystemMetrics(SM_CXVIRTUALSCREEN), GetSystemMetrics(SM_CYVIRTUALSCREEN))

    return Screen(main_screen_size, main_screen_pos, v_screen_size)

SCREEN = get_main_screen()

DATA_PATH = os.path.split(os.path.realpath(__file__))[0]
CLIENT_FILE = os.path.join(DATA_PATH, "index.html")
WIDTH, HEIGHT = SCREEN.size
SETTING_FILE = "settings.json"

try: 
    VMULTI_DLL = CDLL(os.path.join(DATA_PATH, 'vTabletDll.dll'))
except:
    VMULTI_DLL = None

IS_DEBUG = 0

def log(msg, type="info"):
    if type == "info":
        print('\033[1;34;40m INFO \033[0m: ' + msg + '\033[0m \n')
    elif type == "debug":
        if IS_DEBUG == 1:
            print('\033[1;36;40m DEBUG \033[0m: ' + msg + '\033[0m \n')
    elif type == "error":
        print('\033[1;31;40m ERR \033[0m: ' + msg + '\033[0m \n')
    elif type == "warn":
        print('\033[1;33;40m WARN \033[0m: ' + msg + '\033[0m \n')

class VMulti:
    def __init__(self):
        try:
            VMULTI_DLL.setupDigi.restype = c_uint64
            self.controller = VMULTI_DLL.setupDigi()
            log("Connected to vTablet: {}.".format(self.controller))
        except:
            log('Failed to run vTablet', "error")
            pass
    def update_digi(self, x, y, p):
        if not self.is_connected():
            return False
        x, y = SCREEN.v_to_screen_pos_digi(x, y)
        VMULTI_DLL.updateDigi(c_uint64(self.controller), c_long(x), c_long(y), c_uint32(int(p * 1024)))
    def is_connected(self):
        return True

vmulti = VMulti()

def save_setting(data):
    with open(SETTING_FILE, 'w') as f:
        f.write(data)
    log("Saved settings from devices.")


def load_setting():
    data = "{}"
    if os.path.isfile(SETTING_FILE):
        with open(SETTING_FILE) as f:
            data = f.read()
    return data


# Data
@request_map("/server-data")
def frontend_ctroller_functison():
    return Headers({
        "Access-Control-Allow-Origin": "*"
    }), {
        'screen': {
            'width': WIDTH,
            'height': HEIGHT
        }
    }

# Client
@request_map("/")
def frontend_ctroller_function():
    data = ""
    if os.path.isfile(CLIENT_FILE):
        with open(CLIENT_FILE, 'r', encoding='utf-8') as f:
            data = f.read()
    elif os.path.isfile("index.html"):
        log("Finding client file...")
        with open(CLIENT_FILE, 'r', encoding='utf-8') as f:
            data = f.read()
    else:
        log("Client file not found.")
    return data


# WS server
@websocket_handler(endpoint="/ws")
class WSHandler(WebsocketHandler):

    def on_handshake(self, request: WebsocketRequest):
        return 0, {}

    def on_open(self, session: WebsocketSession):
        log(">> Connected! ")
        # log(session.request.path_values)

    def on_close(self, session: WebsocketSession, reason: str):
        log(">> Closeed Connect::")
        # log(reason)

    def on_text_message(self, session: WebsocketSession, message: str):
        # log(">> Got text message: ")
        # log(message)

        data = json.loads(message)

        if data["type"] == "ping":
            session.send(json.dumps({"pong": data}))
            return

        if data["type"] == "move":
            mouse.move(float(data['x']) * WIDTH, float(data['y']) * HEIGHT)

        elif data["type"] == "click":
            if data["action"] == "down":
                mouse.press()
            elif data["action"] == "up":
                mouse.release()

        elif data["type"] == "digi":
            x = data['x']
            y = data['y']
            pressure = data['pressure']
            bottom = data['bottom']
            log("x: {0}, y: {1}, pressure: {2}, b: {3}".format(x, y, pressure, bottom), "debug")
            is_success = vmulti.update_digi(x, y, pressure)

        elif data["type"] == "save_setting":
            save_setting(data["setting"])

        elif data["type"] == "load_setting":
            session.send(json.dumps({"setting": load_setting()}))
            return

def copyRight():
    log("vTablet (c) Teages 2022")
    log("The source code shared with GNU GPLv3")
    log("See: https://github.com/Teages/vTablet")

def main(args):
    copyRight()
    arg = "".join(str(args))
    if arg.find('-debug') > 0 :
        global IS_DEBUG
        IS_DEBUG = 1

    log("{}".format(args), "debug")
    log("Server running")
    log("CLIENT_FILE: {}".format(CLIENT_FILE), 'debug')
    log("Debug mode", "debug")

    server.start(port=8888)


if __name__ == "__main__":
    main(sys.argv[1:])
