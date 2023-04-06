import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:logger/logger.dart';
import 'package:vtablet/services/states.dart';

import 'home.dart';

void main() {
  runApp(const App());
  ConfigManager.initManager();
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool useMaterial3 = true;
  ThemeMode themeMode = ThemeMode.system;

  bool get useLightMode {
    switch (themeMode) {
      case ThemeMode.system:
        return SchedulerBinding.instance.window.platformBrightness ==
            Brightness.light;
      case ThemeMode.light:
        return true;
      case ThemeMode.dark:
        return false;
    }
  }

  void handleBrightnessChange() {
    setState(() {
      themeMode = useLightMode ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'vTablet',
      themeMode: themeMode,
      theme: ThemeData(
        // colorSchemeSeed: colorSelected.color,
        useMaterial3: useMaterial3,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        // colorSchemeSeed: colorSelected.color,
        useMaterial3: useMaterial3,
        brightness: Brightness.dark,
      ),
      home: Home(
        title: "vTablet",
        handleBrightnessChange: handleBrightnessChange,
      ),
    );
  }
}
