// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:vtablet/components/setting_card.dart';
import 'package:vtablet/configs.dart';
import 'package:vtablet/services/connect.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

import '../components/delay.dart';

class ConnectionPage extends StatefulWidget {
  const ConnectionPage({
    super.key,
  });

  @override
  State<ConnectionPage> createState() => _ConnectionPageState();
}

class _ConnectionPageState extends State<ConnectionPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Column(
          children: [
            ValueListenableBuilder(
                valueListenable: VTabletWS.state,
                builder: (context, value, child) {
                  if (value == WsConnectionState.connected) {
                    return MaterialBanner(
                      content: Text(
                        AppLocalizations.of(context)!.connectionStateConnected,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondary),
                      ),
                      leading: Icon(
                        Icons.sensors_off,
                        color: Theme.of(context).colorScheme.onSecondary,
                      ),
                      backgroundColor: Theme.of(context).colorScheme.secondary,
                      actions: <Widget>[
                        TextButton(
                          onPressed: null,
                          child: Text(''),
                        ),
                      ],
                    );
                  } else {
                    return MaterialBanner(
                      content: Text(
                        AppLocalizations.of(context)!
                            .connectionStateDisconnected,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onError),
                      ),
                      leading: Icon(
                        Icons.sensors_off,
                        color: Theme.of(context).colorScheme.onError,
                      ),
                      backgroundColor: Theme.of(context).colorScheme.error,
                      actions: <Widget>[
                        TextButton(
                          onPressed: null,
                          child: Text(''),
                        ),
                      ],
                    );
                  }
                }),
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...createSettingCard(
                      AppLocalizations.of(context)!.connectionFirstTitle,
                      [
                        TextFormField(
                          initialValue: Configs.serverHost.get(),
                          decoration: InputDecoration(
                              labelText: AppLocalizations.of(context)!
                                  .connectionServer),
                          readOnly: false,
                          onChanged: (value) => Configs.serverHost.set(value),
                        ),
                        const SizedBox(
                          height: 70,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Spacer(),
                            TextButton(
                              child: Text(AppLocalizations.of(context)!
                                  .connectionConnectBtn),
                              onPressed: () async {
                                await Services.fetchData();
                                setState(() {});
                              },
                            ),
                          ],
                        )
                      ],
                      context,
                    ),
                    if (Services.screens.isNotEmpty)
                      ...createSettingCard(
                        AppLocalizations.of(context)!.connectionState,
                        [
                          DropdownButton<ScreenData>(
                              isExpanded: true,
                              value: () {
                                var screenUid = Configs.screenUid.get();
                                if (screenUid == "") {
                                  var screen = Services.screens[0];
                                  screenUid = screen.uid;
                                  setState(() {
                                    Configs.screenUid.set(screenUid);
                                  });
                                  return screen;
                                } else {
                                  for (final screen in Services.screens) {
                                    if (screen.uid == screenUid) {
                                      return screen;
                                    }
                                  }
                                }
                              }(),
                              items: () {
                                final List<DropdownMenuItem<ScreenData>> ans =
                                    [];
                                for (final ScreenData data
                                    in Services.screens) {
                                  ans.add(
                                    DropdownMenuItem<ScreenData>(
                                      value: data,
                                      child: Text(AppLocalizations.of(context)!
                                          .connectionMonitor(data.uid,
                                              data.width, data.height)),
                                    ),
                                  );
                                }
                                return ans;
                              }(),
                              onChanged: (screen) {
                                VTabletWS.disconnect();
                                if (screen != null) {
                                  setState(() {
                                    Configs.screenUid.set(screen.uid);
                                  });
                                  screen.connect();
                                } else {
                                  setState(() {
                                    Configs.screenUid.set("");
                                  });
                                }
                              }),
                          const SizedBox(
                            height: 70,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              DelayDialog(),
                              const Spacer(),
                              TextButton(
                                child: Text(AppLocalizations.of(context)!
                                    .connectionReconnectBtn),
                                onPressed: () {
                                  var screenUid = Configs.screenUid.get();
                                  if (screenUid != "") {
                                    for (final screen in Services.screens) {
                                      if (screen.uid == screenUid) {
                                        screen.connect();
                                      }
                                    }
                                  }
                                },
                              ),
                            ],
                          )
                        ],
                        context,
                      ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}

// Icons
class ConnectionDestination extends StatelessWidget {
  const ConnectionDestination({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationDestination(
      icon: Icon(Icons.sensors),
      selectedIcon: Icon(Icons.sensors),
      label: AppLocalizations.of(context)!.connectionPageTitle,
    );
  }
}

NavigationRailDestination connectionRailDestination(BuildContext context) {
  return NavigationRailDestination(
    icon: Icon(Icons.sensors),
    selectedIcon: Icon(Icons.sensors),
    label: Text(AppLocalizations.of(context)!.connectionPageTitle),
  );
}
