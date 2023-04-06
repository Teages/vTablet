import 'package:flutter/cupertino.dart';
import 'package:vtablet/services/states.dart';

class Configs {
  static final serverHostSaved =
      _initConfig<String>("server.host", "localhost:23052");
  static final serverHost =
      _initState<String>("server.host", serverHostSaved.get());

  static final preventSleep = _initConfig<bool>("other.preventSleep", true);

  static final screenUid = _initState<String>("aria.screenId", "");

  static final ariaScale = _initConfig<double>("aria.scale", 0.8);
  static final ariaOffsetX = _initConfig<double>("aria.offset.x", 0);
  static final ariaOffsetY = _initConfig<double>("aria.offset.y", 0);
  // static final ariaTransform = _initConfig<double>("aria.transform", 1);
  static final ariaRatio = _initConfig<double>("aria.ratio", 16 / 9);

  static final inputEnablePen = _initConfig<bool>("input.enable.pen", true);
  static final inputEnableTouch =
      _initConfig<bool>("input.enable.touch", false);
  static final inputEnableMouse =
      _initConfig<bool>("input.enable.mouse", false);

  static final inputIgnoreClick = _initConfig<bool>("input.ignoreClick", false);

  static final delay = _initState("delay", -1);

  static _Config<T> _initConfig<T>(String key, T defaultValue) {
    _Config<T> config = _Config(key, defaultValue);
    return config;
  }

  static _State<T> _initState<T>(String key, T defaultValue) {
    _State<T> state = _State(key, defaultValue);
    return state;
  }
}

class _Config<T> {
  String _key;
  T _defaultValue;

  _Config(String key, T defaultValue)
      : _key = key,
        _defaultValue = defaultValue;

  T get() {
    return ConfigManager.getConfig(_key, _defaultValue);
  }

  set(T newValue) {
    ConfigManager.setConfig(_key, newValue);
  }
}

class _State<T> {
  String _key;
  T _defaultValue;

  _State(String key, T defaultValue)
      : _key = key,
        _defaultValue = defaultValue;

  T get() {
    return StateManager.getConfig(_key, _defaultValue);
  }

  set(T newValue) {
    StateManager.setConfig(_key, newValue);
  }
}
