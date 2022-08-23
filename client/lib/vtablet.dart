import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:vtablet/components/delay.dart';

import 'dart:developer' as developer;

import 'package:wakelock/wakelock.dart';

import 'package:vtablet/storage.dart';
import 'package:vtablet/web.dart';

// ignore: must_be_immutable
class VTabletPage extends StatelessWidget {
  final GlobalKey boxKey = GlobalKey();
  final GlobalKey ariaKey = GlobalKey();

  // Aria settings
  double scale = ConfigManager.getConfig("aria.scale", 0.5);
  double ratio = StateManager.getConfig("aria.ratio", 16 / 9);
  double offsetX = ConfigManager.getConfig("aria.offset.x", 0.5);
  double offsetY = ConfigManager.getConfig("aria.offset.y", 0.5);

  // Input settings
  bool enableMouse = ConfigManager.getConfig("input.enable.mouse", false);
  bool enableTouch = ConfigManager.getConfig("input.enable.touch", false);
  bool enablePen = ConfigManager.getConfig("input.enable.pen", true);

  // UI settings
  bool pureBackground = ConfigManager.getConfig("ui.pureBackground", false);
  bool showDelay = ConfigManager.getConfig("ui.showDelay", true);

  // Other settings
  bool preventSleep = ConfigManager.getConfig("other.preventSleep", true);

  late BuildContext buildContext;

  // init
  VTabletPage({
    Key? key,
  }) : super(key: key) {
    // show dialog when disconnect
    lostConncet() {
      if (VTabletWS.isConnected.value == false) {
        Wakelock.disable();
        VTabletWS.isConnected.removeListener(lostConncet);
        developer.log("Disconnceted.");

        showDialog(
          context: buildContext,
          builder: (BuildContext context) {
            return AlertDialog(
              content: SingleChildScrollView(
                  child: ListBody(
                children: const [Text("Lost connect to server.")],
              )),
              actions: <Widget>[
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.pop(buildContext);
                    readyExit();
                    Navigator.pop(buildContext);
                  },
                )
              ],
            );
          },
        );
      }
    }

    VTabletWS.isConnected.addListener(lostConncet);
    VTabletWS.autoPing = showDelay;
  }

  pointerEventHandler(PointerEvent event) {
    // developer.log(
    //     "${event.pressure} : (${event.position.dx}, ${event.position.dy}) ");
    var rawX = event.position.dx;
    var rawY = event.position.dy;
    var rawPressure = event.pressure;
    var rawType = event.kind;

    var boxWidth = boxKey.currentContext!.size!.width;
    var boxHeight = boxKey.currentContext!.size!.height;
    var ariaWidth = ariaKey.currentContext!.size!.width;
    var ariaHeight = ariaKey.currentContext!.size!.height;

    int screenToDigi(double position, double airaOffsetProporte,
        double ariaSize, double boxSize) {
      double airaOffset = (airaOffsetProporte + 1) * (boxSize - ariaSize) * 0.5;

      return 32767 * (position - airaOffset) ~/ ariaSize;
    }

    int pointerX = screenToDigi(rawX, offsetX, ariaWidth, boxWidth);
    int pointerY = screenToDigi(rawY, offsetY, ariaHeight, boxHeight);
    int pressure = (8192 * rawPressure).toInt();
    developer.log('Pointer($pointerX, $pointerY) $pressure by $rawType');

    switch (rawType) {
      case PointerDeviceKind.mouse:
        if (enableMouse) {
          VTabletWS.sendDigi(pointerX, pointerY, pressure);
        }
        break;
      case PointerDeviceKind.touch:
        if (enableTouch) {
          VTabletWS.sendDigi(pointerX, pointerY, pressure);
        }
        break;
      case PointerDeviceKind.stylus:
        if (enablePen) {
          VTabletWS.sendDigi(pointerX, pointerY, pressure);
        }
        break;
      default:
        developer.log("Unknown input devices $rawType");
    }
  }

  int lastClickExit = 0;
  @override
  Widget build(BuildContext context) {
    buildContext = context;
    return WillPopScope(
      onWillPop: () async {
        readyExit();
        return true;
      },
      child: Scaffold(
        appBar: null,
        floatingActionButton: showDelay
            ? Opacity(
                opacity: 0.25,
                child: DelayDialog(
                  onClick: () {
                    if (DateTime.now().millisecondsSinceEpoch - lastClickExit <
                        1500) {
                      readyExit();
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Click again to exit."),
                        duration: Duration(seconds: 1),
                      ));
                    }
                    lastClickExit = DateTime.now().millisecondsSinceEpoch;
                  },
                ),
              )
            : null,
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniStartFloat,
        body: Center(
          child: Listener(
            onPointerMove: (event) => pointerEventHandler(event),
            onPointerHover: (event) => pointerEventHandler(event),
            onPointerDown: (event) => pointerEventHandler(event),
            onPointerUp: (event) => pointerEventHandler(event),
            onPointerCancel: (event) => pointerEventHandler(event),
            child: Container(
              key: boxKey,
              color: Colors.black,
              height: double.infinity,
              width: double.infinity,
              child: FractionallySizedBox(
                alignment: Alignment(offsetX, offsetY),
                widthFactor: scale,
                heightFactor: scale,
                child: Container(
                  alignment: Alignment(offsetX, offsetY),
                  child: AspectRatio(
                    aspectRatio: ratio,
                    child: Container(
                      key: ariaKey,
                      color: Color.fromARGB(
                          pureBackground ? 0 : 30, 255, 255, 255),
                      // child: Text(log),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void readyExit() {
    VTabletWS.autoPing = true;
    Wakelock.disable();
  }
}