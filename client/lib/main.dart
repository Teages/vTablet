// ignore_for_file: prefer_const_constructors, unused_field, todo, prefer_const_literals_to_create_immutables

import 'dart:developer' as developer;
import 'dart:io';
import 'package:mdi/mdi.dart';

import 'package:flutter/material.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:vtablet/components/delay.dart';
import 'package:vtablet/storage.dart';
import 'package:vtablet/vtablet.dart';
import 'package:vtablet/web.dart';
import 'package:wakelock/wakelock.dart';

void main() {
  () {
    ConfigManager.initManager();
    runApp(const VTabletApp());
  }();
}

class VTabletApp extends StatelessWidget {
  const VTabletApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'vTablet',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
      ),
      home: const SettingPage(title: 'vTablet'),
    );
  }
}

class SettingPage extends StatefulWidget {
  const SettingPage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  var hostInpuutController = TextEditingController();

  _SettingPageState() : super() {
    () async {
      try {
        var startUrl = await getInitialUri();
        var server = startUrl?.queryParameters["server"] ??
            ConfigManager.getConfig("server.last", "localhost:23052");
        setState(() {
          StateManager.setConfig("server.host", server);
          hostInpuutController.text = server;
        });
        developer.log("link: $startUrl");
        // developer.log("link...");
      } catch (e) {
        // Ignore
      }
    }();
  }

  @override
  Widget build(BuildContext context) {
    // sleep(Duration(milliseconds: 300));
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          child: Container(
            width: 400,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Connection
                ...SettingCard('Connection', <Widget>[
                  ValueListenableBuilder(
                    valueListenable: VTabletWS.isConnected,
                    builder: (context, bool isConnected, child) {
                      return TextField(
                        controller: hostInpuutController,
                        autofocus: false,
                        decoration: InputDecoration(labelText: 'Server'),
                        readOnly: isConnected,
                        onChanged: (String value) {
                          setState(() {
                            StateManager.setConfig("server.host", value);
                          });
                        },
                      );
                    },
                  ),
                  const SizedBox(
                    height: 70,
                  ),
                  ValueListenableBuilder(
                    valueListenable: VTabletWS.isConnected,
                    builder: ((context, bool value, child) {
                      return VTabletWS.isConnected.value
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                DelayDialog(),
                                const Spacer(),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    primary: Colors.red,
                                  ),
                                  child: const Text('Disconnect'),
                                  onPressed: () {
                                    setState(() {
                                      VTabletWS.disconnect();
                                    });
                                  },
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      VTabletWS.conncet(StateManager.getConfig(
                                          "server.host", ""));
                                    });
                                  },
                                  child: const Text('Connect'),
                                ),
                              ],
                            );
                    }),
                  ),
                ]),
                // Aria setting : Synced
                ...SettingCard('Aria', <Widget>[
                  Flex(
                    direction: Axis.horizontal,
                    children: [
                      Text(
                          'Scale: ${ConfigManager.getConfig("aria.scale", 0.5).toStringAsFixed(2)}'),
                      Expanded(
                        child: Slider(
                          value: ConfigManager.getConfig("aria.scale", 0.5),
                          min: 0.1,
                          max: 1.0,
                          divisions: 100,
                          label: ConfigManager.getConfig("aria.scale", 0.5)
                              .toStringAsFixed(2),
                          onChanged: (double value) {
                            setState(() {
                              ConfigManager.setConfig("aria.scale", value);
                            });
                          },
                        ),
                      )
                    ],
                  ),
                  Flex(
                    direction: Axis.horizontal,
                    children: [
                      Text(
                          'Offset X: ${ConfigManager.getConfig("aria.offset.x", 0.0).toStringAsFixed(2)}'),
                      Expanded(
                        child: Slider(
                          value: ConfigManager.getConfig("aria.offset.x", 0.0),
                          min: -1,
                          max: 1,
                          divisions: 100,
                          label: ConfigManager.getConfig("aria.offset.x", 0.0)
                              .toStringAsFixed(2),
                          onChanged: (double value) {
                            setState(() {
                              ConfigManager.setConfig("aria.offset.x", value);
                            });
                          },
                        ),
                      )
                    ],
                  ),
                  Flex(
                    direction: Axis.horizontal,
                    children: [
                      Text(
                          'Offset Y: ${ConfigManager.getConfig("aria.offset.y", 0.0).toStringAsFixed(2)}'),
                      Expanded(
                        child: Slider(
                          value: ConfigManager.getConfig("aria.offset.y", 0.0),
                          min: -1,
                          max: 1,
                          divisions: 100,
                          label: ConfigManager.getConfig("aria.offset.y", 0.0)
                              .toStringAsFixed(2),
                          onChanged: (double value) {
                            setState(() {
                              ConfigManager.setConfig("aria.offset.y", value);
                            });
                          },
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          primary: Colors.red,
                        ),
                        child: const Text('Reset'),
                        onPressed: () {
                          setState(() {
                            ConfigManager.setConfig("aria.scale", 0.5);
                            ConfigManager.setConfig("aria.offset.x", 0.0);
                            ConfigManager.setConfig("aria.offset.y", 0.0);
                          });
                        },
                      ),
                    ],
                  ),
                ]),
                // Input setting : Synced
                ...SettingCard('Input', <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Enable pen input'),
                      Switch(
                          value:
                              ConfigManager.getConfig("input.enable.pen", true),
                          onChanged: (bool on) {
                            setState(() {
                              ConfigManager.setConfig("input.enable.pen", on);
                            });
                          }),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Enable mouse input'),
                      Switch(
                          value: ConfigManager.getConfig(
                              "input.enable.mouse", false),
                          onChanged: (bool on) {
                            setState(() {
                              ConfigManager.setConfig("input.enable.mouse", on);
                            });
                          }),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Enable touch input'),
                      Switch(
                          value: ConfigManager.getConfig(
                              "input.enable.touch", false),
                          onChanged: (bool on) {
                            setState(() {
                              ConfigManager.setConfig("input.enable.touch", on);
                            });
                          }),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ignore click'),
                      Switch(
                          value: ConfigManager.getConfig(
                              "input.ignoreClick", true),
                          onChanged: (bool on) {
                            setState(() {
                              ConfigManager.setConfig("input.ignoreClick", on);
                            });
                          }),
                    ],
                  ),
                ]),
                // UI setting
                ...SettingCard('UI', <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Pure background'),
                      Switch(
                          value: ConfigManager.getConfig(
                              "ui.pureBackground", false),
                          onChanged: (bool on) {
                            setState(() {
                              ConfigManager.setConfig("ui.pureBackground", on);
                            });
                          }),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Show delay'),
                      Switch(
                          value: ConfigManager.getConfig("ui.showDelay", true),
                          onChanged: (bool on) {
                            setState(() {
                              ConfigManager.setConfig("ui.showDelay", on);
                            });
                          }),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Background'),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).primaryColor,
                        ),
                        onPressed: null,
                        child: const Text(
                          'Select',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ]),
                // Other setting
                ...SettingCard('Other', <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Prevent sleep'),
                      Switch(
                          value: ConfigManager.getConfig(
                              "other.preventSleep", true),
                          onChanged: (bool on) {
                            setState(() {
                              ConfigManager.setConfig("other.preventSleep", on);
                            });
                          }),
                    ],
                  ),
                ]),
                // About
                ...SettingCard('About', <Widget>[
                  Text('v2.0.0 (rc.1) - Copyright (c) 2022 Teages'),
                  SizedBox(
                    height: 35,
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      primary: Theme.of(context).primaryColor,
                    ),
                    onPressed: () {
                      launchUrlString('https://github.com/Teages/vTablet',
                          mode: LaunchMode.externalApplication);
                    },
                    icon: Icon(
                      Mdi.github,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Get more from GitHub',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: ValueListenableBuilder(
        valueListenable: VTabletWS.isConnected,
        builder: (context, value, child) {
          return FloatingActionButton.extended(
            onPressed: VTabletWS.isConnected.value || true
                ? () {
                    Wakelock.toggle(
                        enable: ConfigManager.getConfig(
                            "other.preventSleep", true));
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VTabletPage(),
                      ),
                    );
                  }
                : null,
            label: const Text('Start'),
            icon: const Icon(Icons.play_arrow),
            backgroundColor: VTabletWS.isConnected.value
                ? Theme.of(context).primaryColor
                // : Theme.of(context).disabledColor,
                : Colors.grey,
          );
        },
      ),
    );
  }

  // ignore: non_constant_identifier_names
  List<Widget> SettingCard(String title, List<Widget> content) {
    return <Widget>[
      Text(
        title,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      Card(
        elevation: 1.0,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          alignment: Alignment.topLeft,
          child: Wrap(
            spacing: 0,
            children: content,
          ),
        ),
      ),
      const SizedBox(
        height: 20,
      ),
    ];
  }

  Widget showWidget(bool b, Widget w) {
    return b ? w : Container();
  }
}
