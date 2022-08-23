import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:vtablet/storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'dart:developer' as developer;

class VTabletWS {
  static late WebSocketChannel channel;
  static ValueNotifier<bool> isConnected = ValueNotifier(false);
  static ValueNotifier<int> delay = ValueNotifier(-1);

  static Timer pingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (autoPing) {
      ping();
    }
  });
  static bool autoPing = false;

  static conncet(String uristr) {
    try {
      disconnect();
      var uri = Uri.parse("ws://$uristr/digi");

      developer.log("Connceting to $uristr");
      channel = WebSocketChannel.connect(uri);

      channel.stream.listen((message) {
        developer.log(message);
        var value = int.tryParse(message);
        if (value != null) {
          delay.value = (DateTime.now().millisecondsSinceEpoch) + value;
          StateManager.setConfig("delay", delay.value);
          isConnected.value = true;
          ConfigManager.setConfig("server.last", uristr);
          developer.log(StateManager.getConfig("delay", -1).toString());
        }
      }, onError: disconnectErr, onDone: disconnect);
      Timer(const Duration(milliseconds: 1000), () {
        isConnected.value = true;
        ping();
        ping();
        autoPing = true;
        developer.log("${pingTimer.isActive}");
      });
    } catch (e) {
      disconnect();
    }
  }

  static disconnectErr(e) {
    developer.log("WS err");
    developer.log(e.toString());
    disconnect();
  }

  static disconnect() {
    autoPing = false;
    isConnected.value = false;
    try {
      channel.sink.close();
      developer.log("Conncetion closed.");
    } catch (e) {
      // Ignore
    }
  }

  static ping() {
    send((0 - DateTime.now().millisecondsSinceEpoch).toString());
  }

  static sendDigi(int x, int y, int pressure) {
    if (ConfigManager.getConfig("input.ignoreClick", false)) {
      pressure = 0;
    }
    send("$x,$y,$pressure");
  }

  static send(String str) {
    try {
      if (isConnected.value) {
        channel.sink.add(str);
      }
    } catch (e) {
      disconnect();
      developer.log(e.toString());
    }
  }
}
