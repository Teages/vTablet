import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:logger/logger.dart';
import 'package:vtablet/configs.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';

class ScreenData {
  final String uid;
  final String path;
  final int width;
  final int height;

  ScreenData(this.uid, this.path, this.width, this.height);

  ScreenData.fromJson(Map<String, dynamic> json)
      : uid = json['uid'],
        path = json['path'],
        width = json['width'],
        height = json['height'];

  @override
  List<Object> get props => [uid];

  connect() {
    Configs.ariaRatio.set(width / height);
    VTabletWS.conncet(Configs.serverHostSaved.get(), path);
  }
}

class Services {
  static List<ScreenData> screens = [];

  static fetchData() async {
    VTabletWS.disconnect();

    var serverUrl = Configs.serverHost.get();
    screens = [];
    try {
      final response = await http.get(Uri.parse('http://$serverUrl/connect'));
      if (response.statusCode == 200) {
        List ans = jsonDecode(response.body);
        for (dynamic originalData in ans) {
          screens.add(ScreenData.fromJson(originalData));
        }
        Configs.serverHostSaved.set(serverUrl);

        // auto connect
        var lastScreen = Configs.screenUid.get();
        for (final screen in screens) {
          if (screen.uid == lastScreen) {
            screen.connect();
          }
        }
        if (VTabletWS.state.value != WsConnectionState.connected) {
          screens[0].connect();
        }
      }
    } catch (e) {
      Logger().e(e);
    }
  }
}

class WsClient {
  late IOWebSocketChannel channel;
  WsConnectionState state = WsConnectionState.disconnected;
  final Function(WsConnectionState) _onStateChange;

  WsClient.connect(String host, String path, Function(int) onDelay,
      Function(WsConnectionState) onStateChange)
      : _onStateChange = onStateChange {
    var uri = Uri.parse("ws://$host$path");

    Map<String, dynamic> headers = {};
    headers['origin'] = 'https://vtablet.teages.xyz';
    _setState(WsConnectionState.pending);
    channel = IOWebSocketChannel.connect(uri, headers: headers);

    var l = channel.stream.listen(
      (message) {
        if (state == WsConnectionState.pending) {
          _setState(WsConnectionState.connected);
        }
        var value = int.tryParse(message);
        if (value != null) {
          var delay = (DateTime.now().millisecondsSinceEpoch) + value;
          if (state == WsConnectionState.connected) {
            onDelay(delay);
          }
        }
      },
      onError: _disconnectErr,
      onDone: disconnect,
    );
    Timer(const Duration(milliseconds: 1000), () {
      _ping();
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state == WsConnectionState.connected) {
        _ping();
      }
    });
  }

  _setState(WsConnectionState newState) {
    if (state != WsConnectionState.deprecated) {
      _onStateChange(newState);
      state = newState;
    }
  }

  _ping() {
    _send((0 - DateTime.now().millisecondsSinceEpoch).toString());
  }

  sendDigi(int x, int y, int pressure) {
    if (Configs.inputIgnoreClick.get()) {
      pressure = 0;
    }
    _send("$x,$y,$pressure");
  }

  _send(String str) {
    try {
      channel.sink.add(str);
    } catch (e) {
      disconnect();
      Logger().d(e.toString());
    }
  }

  _disconnectErr(e) {
    Logger().d("WS err");
    Logger().d(e.toString());
    disconnect();
  }

  disconnect() async {
    _setState(WsConnectionState.deprecated);
    try {
      await channel.sink.close();
    } catch (e) {
      // Ignore
    }
  }
}

class VTabletWS {
  static ValueNotifier<WsConnectionState> state =
      ValueNotifier(WsConnectionState.disconnected);
  static ValueNotifier<int> delay = ValueNotifier(-1);

  static WsClient? client;

  static conncet(String host, String path) {
    client = WsClient.connect(
      host,
      path,
      (delayVal) {
        delay.value = delayVal;
        Logger().d(delayVal, path);
      },
      (stateVal) {
        state.value = stateVal;
        if (stateVal == WsConnectionState.disconnected ||
            stateVal == WsConnectionState.deprecated) {
          delay.value = -1;
        }
      },
    );

    state.value = WsConnectionState.connected;
  }

  static disconnect() async {
    client?.disconnect();
    state.value = WsConnectionState.disconnected;
    client = null;
  }

  static sendDigi(int x, int y, int pressure) {
    if (state.value == WsConnectionState.connected) {
      client?.sendDigi(x, y, pressure);
    }
  }
}

enum WsConnectionState { pending, connected, disconnected, deprecated }
