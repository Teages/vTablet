import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:vtablet/configs.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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

  List<Object> get props => [uid];

  connect() {
    VTabletWS.connect(Configs.serverHostSaved.get(), path);
    Configs.screenUid.set(uid);
    Configs.screenUidSaved.set(uid);
    Configs.ariaRatio.set(width / height);
  }
}

class Services {
  // static List<ScreenData> screens = [];
  static ValueNotifierList<ScreenData> screens = ValueNotifierList([]);

  static Future<bool> fetchData() async {
    VTabletWS.disconnect();

    var serverUrl = Configs.serverHost.get();
    screens.removeAll();
    try {
      final response = await http.get(Uri.parse('http://$serverUrl/connect'));
      if (response.statusCode == 200) {
        List ans = jsonDecode(response.body);
        for (dynamic originalData in ans) {
          screens.add(ScreenData.fromJson(originalData));
        }
        Configs.serverHostSaved.set(serverUrl);

        // auto connect
        var lastScreen = Configs.screenUidSaved.get();
        Logger().d(lastScreen);
        for (final screen in screens.value) {
          if (screen.uid == lastScreen) {
            () {
              screen.connect();
              screens.forceUpdate();
            }();
          }
        }
        if (VTabletWS.state.value != WsConnectionState.connected) {
          screens.value[0].connect();
        }
      }
      return true;
    } catch (e) {
      Logger().e(e);
    }
    return false;
  }

  static reset() async {
    await VTabletWS.disconnect();
    screens.removeAll();
  }
}

class WsClient {
  late WebSocketChannel channel;
  WsConnectionState state = WsConnectionState.disconnected;
  final Function(WsConnectionState) _onStateChange;

  int baseTime = DateTime.now().millisecondsSinceEpoch;

  WsClient.connect(String host, String path, Function(int) onDelay,
      Function(WsConnectionState) onStateChange)
      : _onStateChange = onStateChange {
    var uri = Uri.parse("ws://$host$path");

    Map<String, dynamic> headers = {};
    headers['origin'] = 'https://vtablet.teages.xyz';
    _setState(WsConnectionState.pending);
    if (kIsWeb) {
      channel = WebSocketChannel.connect(uri);
      channel.sink.add('0000');
    } else {
      channel = IOWebSocketChannel.connect(uri, headers: headers);
    }

    channel.stream.listen(
      (message) {
        if (state == WsConnectionState.pending) {
          _setState(WsConnectionState.connected);
        }
        var value = int.tryParse(message);
        if (value != null) {
          var delay = (((timeFromBase()) + value) / 2).ceil();
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
    _sendBlob(buildMessage(
      EventType.EvSyn.value,
      Syn.Ping.value,
      0 - timeFromBase(),
    ));
  }

  sendDigi(int x, int y, int pressure, double tiltX, double tiltY) {
    var inputIgnoreClick = Configs.inputIgnoreClick.get();
    var msg = [
      buildMessage(
        EventType.EvAbs.value,
        Abs.X.value,
        x,
      ),
      buildMessage(
        EventType.EvAbs.value,
        Abs.Y.value,
        y,
      ),
      buildMessage(
        EventType.EvAbs.value,
        Abs.Pressure.value,
        inputIgnoreClick ? 0 : pressure,
      ),
      buildMessage(
        EventType.EvAbs.value,
        Abs.TiltX.value,
        (tiltX * 32767 / 90).floor(),
      ),
      buildMessage(
        EventType.EvAbs.value,
        Abs.TiltY.value,
        (tiltY * 32767 / 90).floor(),
      ),
      buildMessage(
        EventType.EvSyn.value,
        Syn.Report.value,
        0,
      )
    ];

    _sendBlob(Uint8List.fromList(msg.expand((x) => x).toList()));
  }

  _sendBlob(Uint8List blob) {
    try {
      channel.sink.add(blob);
    } catch (e) {
      disconnect();
    }
  }

  static Uint8List buildMessage(int motionType, int motionCode, int value) {
    var bytes = Uint8List(8);

    bytes[0] = (motionType >> 8) & 0xff;
    bytes[1] = motionType & 0xff;

    bytes[2] = (motionCode >> 8) & 0xff;
    bytes[3] = motionCode & 0xff;

    bytes[4] = (value >> 24) & 0xff;
    bytes[5] = (value >> 16) & 0xff;

    bytes[6] = (value >> 8) & 0xff;
    bytes[7] = value & 0xff;

    return bytes;
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

  int timeFromBase() {
    return (DateTime.now().millisecondsSinceEpoch - baseTime) % 0x100000000;
  }
}

class VTabletWS {
  static ValueNotifier<WsConnectionState> state =
      ValueNotifier(WsConnectionState.disconnected);
  static ValueNotifier<int> delay = ValueNotifier(-1);

  static WsClient? client;

  static connect(String host, String path) {
    client = WsClient.connect(
      host,
      path,
      (delayVal) {
        delay.value = delayVal;
        // Logger().d(delayVal, path);
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

  static sendDigi(int x, int y, int pressure, double tiltX, double tiltY) {
    if (state.value == WsConnectionState.connected) {
      // Logger().d("$x, $y, $pressure");
      client?.sendDigi(x, y, pressure, tiltX, tiltY);
    }
  }
}

enum WsConnectionState { pending, connected, disconnected, deprecated }

class ValueNotifierList<T> extends ValueNotifier<List<T>> {
  ValueNotifierList(List<T> initValue) : super(initValue);

  void add(T item) {
    value.add(item);
    _copyValue();
  }

  void removeAll() {
    value.clear();
    _copyValue();
  }

  void forceUpdate() {
    _copyValue();
  }

  void _copyValue() {
    value = [...value];
  }
}

enum EventType {
  EvSyn,
  EvAbs,
}

enum Syn {
  Report,
  Ping,
}

enum Abs {
  X,
  Y,
  Pressure,
  TiltX,
  TiltY,
}

extension EventTypeExtension on EventType {
  int get value {
    switch (this) {
      case EventType.EvSyn:
        return 0x0000;
      case EventType.EvAbs:
        return 0x0003;
      default:
        throw Exception('Invalid EventType');
    }
  }
}

extension SynExtension on Syn {
  int get value {
    switch (this) {
      case Syn.Report:
        return 0x0000;
      case Syn.Ping:
        return 0xffff;
      default:
        throw Exception('Invalid Syn');
    }
  }
}

extension AbsExtension on Abs {
  int get value {
    switch (this) {
      case Abs.X:
        return 0x0000;
      case Abs.Y:
        return 0x0001;
      case Abs.Pressure:
        return 0x0018;
      case Abs.TiltX:
        return 0x001a;
      case Abs.TiltY:
        return 0x001b;
      default:
        throw Exception('Invalid Abs');
    }
  }
}
