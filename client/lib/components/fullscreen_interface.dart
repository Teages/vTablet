// ignore: unused_import
import 'package:vtablet/components/fullscreen_stub.dart'
    // ignore: uri_does_not_exist
    if (dart.library.io) 'package:vtablet/components/fullscreen_mobile.dart'
    // ignore: uri_does_not_exist
    if (dart.library.html) 'package:vtablet/components/fullscreen_web.dart';

abstract class FullscreenManager {
  enter() {}
  exit() {}
  factory FullscreenManager() => getFullscreenManager();
}
