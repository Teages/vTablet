import 'package:flutter/services.dart';
import 'package:vtablet/components/fullscreen_interface.dart';

import 'dart:developer' as developer;

class MobileFullscreenManager implements FullscreenManager {
  @override
  enter() {
    developer.log("enterFullscreen: Mobile");
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  }

  @override
  exit() {
    developer.log("exitFullscreen: Mobile");
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
  }
}

FullscreenManager getFullscreenManager() => MobileFullscreenManager();
