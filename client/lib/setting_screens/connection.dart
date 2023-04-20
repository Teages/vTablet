// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:vtablet/components/setting_card.dart';
import 'package:vtablet/configs.dart';
import 'package:vtablet/services/connect.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

import '../components/delay.dart';

class ConnectionPage extends StatelessWidget {
  const ConnectionPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Column(
          children: [
            ConnectionStateBanner(),
            Container(
              padding: const EdgeInsets.all(20),
              constraints: BoxConstraints(maxWidth: 640),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConnectionFirstCard(),
                    ConnectionSelectScreenCard(),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}

class ConnectionSelectScreenCard extends StatefulWidget {
  const ConnectionSelectScreenCard({
    super.key,
  });

  @override
  State<ConnectionSelectScreenCard> createState() =>
      _ConnectionSelectScreenCardState();
}

class _ConnectionSelectScreenCardState
    extends State<ConnectionSelectScreenCard> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Services.screens,
      builder: (context, value, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (value.isNotEmpty)
              CardWithTitle(
                title: AppLocalizations.of(context)!.connectionState,
                content: [
                  DropdownButton<ScreenData>(
                      isExpanded: true,
                      value: () {
                        var screenUid = Configs.screenUid.get();
                        if (screenUid == "") {
                          var screen = value[0];
                          screenUid = screen.uid;
                          return screen;
                        } else {
                          for (final screen in value) {
                            if (screen.uid == screenUid) {
                              return screen;
                            }
                          }
                        }
                      }(),
                      items: () {
                        final List<DropdownMenuItem<ScreenData>> ans = [];
                        for (final ScreenData data in value) {
                          ans.add(
                            DropdownMenuItem<ScreenData>(
                              value: data,
                              child: Text(AppLocalizations.of(context)!
                                  .connectionMonitor(
                                      data.uid, data.width, data.height)),
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
                    height: 60,
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
                            for (final screen in value) {
                              if (screen.uid == screenUid) {
                                screen.connect();
                              }
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}

class ConnectionFirstCard extends StatefulWidget {
  const ConnectionFirstCard({
    super.key,
  });

  @override
  State<ConnectionFirstCard> createState() => _ConnectionFirstCardState();
}

class _ConnectionFirstCardState extends State<ConnectionFirstCard> {
  @override
  Widget build(BuildContext context) {
    return CardWithTitle(
      title: AppLocalizations.of(context)!.connectionFirstTitle,
      content: [
        ValueListenableBuilder(
          valueListenable: VTabletWS.state,
          builder: (context, value, child) {
            return Column(
              children: [
                TextFormField(
                  initialValue: Configs.serverHost.get(),
                  decoration: InputDecoration(
                      labelText:
                          AppLocalizations.of(context)!.connectionServer),
                  readOnly: value != WsConnectionState.disconnected,
                  onChanged: (value) => Configs.serverHost.set(value),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (value != WsConnectionState.disconnected)
                      TextButton(
                        style: TextButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.error),
                        child: Text(AppLocalizations.of(context)!
                            .connectionDisconnectBtn),
                        onPressed: () async {
                          await Services.reset();
                          setState(() {});
                        },
                      ),
                    const Spacer(),
                    TextButton(
                      child: Text(
                          AppLocalizations.of(context)!.connectionConnectBtn),
                      onPressed: () async {
                        var ans = await Services.fetchData();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(ans
                                ? AppLocalizations.of(context)!
                                    .succeedConnected(Configs.serverHost.get())
                                : AppLocalizations.of(context)!
                                    .failedConnected(Configs.serverHost.get())),
                            duration: const Duration(seconds: 1),
                          ));
                        }
                        setState(() {});
                      },
                    ),
                  ],
                )
              ],
            );
          },
        ),
      ],
    );
  }
}

class ConnectionStateBanner extends StatelessWidget {
  const ConnectionStateBanner({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: VTabletWS.state,
        builder: (context, value, child) {
          if (value == WsConnectionState.connected) {
            return MaterialBanner(
              content: Text(
                AppLocalizations.of(context)!.connectionStateConnected,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSecondary),
              ),
              leading: Icon(
                Icons.sensors,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor:
                          Theme.of(context).colorScheme.onSecondary),
                  onPressed: () {
                    launchUrlString(
                      'https://github.com/Teages/vTablet#help',
                      mode: LaunchMode.externalApplication,
                    );
                  },
                  child: Text(AppLocalizations.of(context)!.helpBtn),
                ),
              ],
            );
          } else {
            return MaterialBanner(
              content: Text(
                AppLocalizations.of(context)!.connectionStateDisconnected,
                style: TextStyle(color: Theme.of(context).colorScheme.onError),
              ),
              leading: Icon(
                Icons.sensors_off,
                color: Theme.of(context).colorScheme.onError,
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
              actions: <Widget>[
                TextButton(
                  style: TextButton.styleFrom(
                      foregroundColor:
                          Theme.of(context).colorScheme.onSecondary),
                  onPressed: () {
                    launchUrlString(
                      'https://github.com/Teages/vTablet#help',
                      mode: LaunchMode.externalApplication,
                    );
                  },
                  child: Text(AppLocalizations.of(context)!.helpBtn),
                ),
              ],
            );
          }
        });
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
