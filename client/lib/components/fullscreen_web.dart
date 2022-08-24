import 'package:vtablet/components/fullscreen_interface.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:developer' as developer;

class WebFullscreenManager implements FullscreenManager {
  @override
  enter() {
    developer.log("enterFullscreen: Web");
    document.documentElement?.requestFullscreen();
  }

  @override
  exit() {
    developer.log("exitFullscreen: Web");
    document.exitFullscreen();
  }
}

FullscreenManager getFullscreenManager() => WebFullscreenManager();
