import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

import 'package:uni_links/uni_links.dart';

import 'package:fullscreen_window/fullscreen_window.dart';
import 'package:vtablet/configs.dart';
import 'package:vtablet/services/connect.dart';
import 'package:vtablet/setting_screens/about.dart';
import 'package:vtablet/setting_screens/appearance.dart';
import 'package:vtablet/setting_screens/control.dart';
import 'package:vtablet/vtablet.dart';
import 'package:wakelock/wakelock.dart';

import 'setting_screens/connection.dart';

class Home extends StatefulWidget {
  const Home({
    super.key,
    required this.title,
    required this.handleBrightnessChange,
  });

  final String title;
  final void Function() handleBrightnessChange;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int currentPageIndex = 0;

  _HomeState() : super() {
    () async {
      try {
        var startUrl = await getInitialUri();
        var server = startUrl?.queryParameters["server"] ??
            Configs.serverHostSaved.get();
        setState(() {
          Configs.serverHost.set(server);
        });
        await Services.fetchData();
        setState(() {});
        // developer.log("link...");
      } catch (e) {
        // Ignore
      }
    }();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: widget.handleBrightnessChange,
              icon: const Icon(Icons.dark_mode))
        ],
      ),
      floatingActionButton: currentPageIndex == 0
          ? ValueListenableBuilder(
              valueListenable: VTabletWS.state,
              builder: (context, value, child) {
                return FloatingActionButton.extended(
                  onPressed: () {
                    if (VTabletWS.state.value == WsConnectionState.connected) {
                      Wakelock.toggle(enable: Configs.preventSleep.get());
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VTabletPage(),
                        ),
                      );
                      FullScreenWindow.setFullScreen(true);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              AppLocalizations.of(context)!.connectFirstPlease),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    }
                  },
                  label: const Text('Start'),
                  icon: const Icon(Icons.play_arrow),
                  backgroundColor:
                      VTabletWS.state.value == WsConnectionState.connected
                          ? Theme.of(context).primaryColor
                          // : Theme.of(context).disabledColor,
                          : Colors.grey,
                );
              },
            )
          : null,
      bottomNavigationBar: MediaQuery.of(context).size.width < 640
          ? NavigationBar(
              onDestinationSelected: (int index) {
                setState(() {
                  currentPageIndex = index;
                });
              },
              selectedIndex: currentPageIndex,
              destinations: const <Widget>[
                ConnectionDestination(),
                ControlDestination(),
                AppearanceDestination(),
                AboutDestination(),
              ],
            )
          : null,
      body: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          if (MediaQuery.of(context).size.width >= 640)
            NavigationRail(
              selectedIndex: currentPageIndex,
              onDestinationSelected: (int index) {
                setState(() {
                  currentPageIndex = index;
                });
              },
              labelType: NavigationRailLabelType.all,
              // navigation rail items
              destinations: [
                connectionRailDestination(context),
                controlRailDestination(context),
                appearanceRailDestination(context),
                aboutRailDestination(context),
              ],
            ),
          Expanded(
            child: <Widget>[
              const ConnectionPage(),
              const ControlPage(),
              const AppearancePage(),
              const AboutPage(),
            ][currentPageIndex],
          ),
        ],
      ),
    );
  }
}
