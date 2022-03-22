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

# VMULTI_DLL = CDLL(os.path.join(DATA_PATH, 'vTabletDriverDll.dll'))
# 
# class VMulti:
#     def __init__(self):
#         try:
#             VMULTI_DLL.vMulti_connect.restype = c_uint64
#             self.controller = VMULTI_DLL.vMulti_connect()
#             print(self.controller)
#         except:
#             print('no vMulti devices')
#             pass
#     def update_digi(self, x, y, p, b):
#         if not self.is_connected():
#             return False
#         VMULTI_DLL.vMulti_updateDigi(c_uint64(self.controller), c_ushort(x), c_ushort(y), c_double(p), c_char(b))
#     def is_connected(self):
#         return VMULTI_DLL.vMulti_isOpened(c_uint64(self.controller))
# 
# vmulti = VMulti()

def save_setting(data):
    with open(SETTING_FILE, 'w') as f:
        f.write(data)
    print("Saved")


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
        print(">> Connected! ")
        # print(session.request.path_values)

    def on_close(self, session: WebsocketSession, reason: str):
        print(">> Closeed Connect::")
        # print(reason)

    def on_text_message(self, session: WebsocketSession, message: str):
        # print(">> Got text message: ")
        # print(message)

        data = json.loads(message)

        if data["type"] == "move":
            # print(float(data['x']) * HEIGHT, float(data['y']) * WIDTH)
            mouse.move(float(data['x']) * HEIGHT, float(data['y']) * WIDTH)

        elif data["type"] == "click":
            if data["action"] == "down":
                mouse.press()
            elif data["action"] == "up":
                mouse.release()

        # elif data["type"] == "digi":
        #     x = data['x']
        #     y = data['y']
        #     pressure = data['pressure']
        #     bottom = data['bottom']
        #     print(x, y, pressure, bottom)
        #     is_success = vmulti.update_digi(x, y, pressure, bottom)

        elif data["type"] == "save_setting":
            save_setting(data["setting"])

        elif data["type"] == "load_setting":
            session.send(json.dumps({"setting": load_setting()}))
            return


def main(*args):
    server.start(port=8888)


if __name__ == "__main__":
    main()
