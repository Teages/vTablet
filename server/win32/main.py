# coding=utf-8
from ctypes import CDLL, c_uint64, c_char, c_double, c_ushort, windll
import mouse
import json
import sys
import pyautogui
import os.path
from simple_http_server import WebsocketHandler, WebsocketRequest, WebsocketSession, websocket_handler, request_map
import simple_http_server.server as server

DATA_PATH = os.path.split(os.path.realpath(__file__))[0]
CLIENT_FILE = os.path.join(DATA_PATH, "index.html")
HEIGHT, WIDTH = pyautogui.size()
SETTING_FILE = "settings.json"

try: 
    VMULTI_DLL = CDLL(os.path.join(DATA_PATH, 'vTabletDriverDll.dll'))
except:
    VMULTI_DLL = None

IS_DEBUG = 0

def log(msg, type="info"):
    if type == "info":
        print('\033[1;34;40m INFO \033[0m: ' + msg + '\033[0m \n')
    elif type == "debug":
        if IS_DEBUG == 1:
            print('\033[1;36;40m DEBUG \033[0m: ' + msg + '\033[0m \n')
        else:
            print(IS_DEBUG)
    elif type == "error":
        print('\033[1;31;40m ERR \033[0m: ' + msg + '\033[0m \n')
    elif type == "warn":
        print('\033[1;33;40m WARN \033[0m: ' + msg + '\033[0m \n')

class VMulti:
    def __init__(self):
        try:
            VMULTI_DLL.vMulti_connect.restype = c_uint64
            self.controller = VMULTI_DLL.vMulti_connect()
            print('\n')
            log("Connected to vMulti: {}.".format(self.controller))
        except:
            log('no vMulti devices', "error")
            pass
    def update_digi(self, x, y, p, b):
        if not self.is_connected():
            return False
        VMULTI_DLL.vMulti_updateDigi(c_uint64(self.controller), c_ushort(x), c_ushort(y), c_double(p), c_char(b))
    def is_connected(self):
        return VMULTI_DLL.vMulti_isOpened(c_uint64(self.controller))

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


# Client
@request_map("/")
def frontend_ctroller_function():
    data = ""
    if os.path.isfile(CLIENT_FILE):
        with open(CLIENT_FILE, 'r', encoding='utf-8') as f:
            data = f.read()
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

        if data["type"] == "move":
            # log(float(data['x']) * HEIGHT, float(data['y']) * WIDTH)
            mouse.move(float(data['x']) * HEIGHT, float(data['y']) * WIDTH)

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
            is_success = vmulti.update_digi(x, y, pressure, bottom)

        elif data["type"] == "save_setting":
            save_setting(data["setting"])

        elif data["type"] == "load_setting":
            session.send(json.dumps({"setting": load_setting()}))
            return


def main(args):
    arg = "".join(str(args))
    if arg.find('-debug'):
        global IS_DEBUG
        IS_DEBUG += 1
    log("{}".format(args), "debug")
    log("Server running")
    log("Debug mode", "debug")
    server.start(port=8888)


if __name__ == "__main__":
    main(sys.argv[1:])
