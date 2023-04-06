import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:vtablet/configs.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

import 'dart:developer' as developer;

import 'package:wakelock/wakelock.dart';
import 'package:fullscreen_window/fullscreen_window.dart';

import 'package:vtablet/services/states.dart';
import 'package:vtablet/services/connect.dart';
import 'package:vtablet/components/delay.dart';

// ignore: must_be_immutable
class VTabletPage extends StatelessWidget {
  final GlobalKey boxKey = GlobalKey();
  final GlobalKey ariaKey = GlobalKey();

  // Aria settings
  double scale = Configs.ariaScale.get();
  double ratio = Configs.ariaRatio.get();
  double offsetX = Configs.ariaOffsetX.get();
  double offsetY = Configs.ariaOffsetY.get();

  // Input settings
  bool enableMouse = Configs.inputEnableMouse.get();
  bool enableTouch = Configs.inputEnableTouch.get();
  bool enablePen = Configs.inputEnablePen.get();

  // UI settings
  bool pureBackground = false;
  bool showDelay = ConfigManager.getConfig("ui.showDelay", true);

  // Other settings
  bool preventSleep = Configs.preventSleep.get();

  late BuildContext buildContext;

  void lostConnect() {
    if (VTabletWS.state.value != WsConnectionState.connected) {
      Wakelock.disable();
      developer.log("Disconnceted.");
      try {
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
      } catch (e) {
        // Ignore
      }
    }
  }

  // init
  VTabletPage({
    Key? key,
  }) : super(key: key) {
    // show dialog when disconnect

    VTabletWS.state.addListener(lostConnect);
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
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            AppLocalizations.of(context)!.clickAgainToExit),
                        duration: const Duration(seconds: 1),
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
                  // color: Color.fromARGB(40, 244, 67, 54), // Debug
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
    Wakelock.disable();
    VTabletWS.state.removeListener(lostConnect);

    FullScreenWindow.setFullScreen(false);
  }
}
