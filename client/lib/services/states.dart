import 'dart:convert';
import 'dart:developer' as developer;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class ConfigManager {
  static Map<String, dynamic> localStroage = {};
  static SharedPreferences preferences = {} as SharedPreferences;

  static initManager() async {
    preferences = await SharedPreferences.getInstance();
    try {
      var configStr = preferences.getString("appConfig");
      configStr ??= "{}";
      localStroage = json.decode(configStr);
    } catch (e) {
      // ignore
    }
  }

  static getConfig(String key, dynamic defaultValue) {
    var value = localStroage[key];
    var valueType = value.runtimeType;
    if (value != null) {
      if (valueType == defaultValue.runtimeType) {
        return value;
      } else if (valueType == (1).runtimeType ||
          defaultValue.runtimeType == (1).runtimeType) {
        return value;
      } else {
        if (kDebugMode) {
          var expectType = defaultValue.runtimeType;
          developer.log("Wrong type $valueType, expected $expectType.\n");
        }
      }
    }
    return defaultValue;
  }

  static setConfig(String key, dynamic value) {
    localStroage[key] = value;
    () async {
      String str = json.encode(localStroage);
      await preferences.setString("appConfig", str);
    }();
  }
}

class StateManager {
  static Map<String, dynamic> localStroage = {};

  static getConfig(String key, dynamic defaultValue) {
    var value = localStroage[key];
    var valueType = value.runtimeType;
    if (value != null) {
      if (valueType == defaultValue.runtimeType) {
        return value;
      } else {
        if (kDebugMode) {
          var expectType = defaultValue.runtimeType;
          developer.log("Wrong type$valueType, expected $expectType.\n");
        }
      }
    }
    return defaultValue;
  }

  static setConfig(String key, dynamic value) {
    return localStroage[key] = value;
  }
}
