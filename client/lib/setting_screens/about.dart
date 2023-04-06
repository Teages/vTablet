import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:mdi/mdi.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../components/setting_card.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...SettingCard(
                      "软件信息",
                      [
                        const Text(
                          'v3.0.0 by Teages',
                        ),
                        const SizedBox(
                          height: 35,
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50),
                            backgroundColor: Theme.of(context).primaryColor,
                          ),
                          onPressed: () {
                            launchUrlString('https://github.com/Teages/vTablet',
                                mode: LaunchMode.externalApplication);
                          },
                          icon: const Icon(
                            Mdi.github,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Get more from GitHub',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                      context,
                    ),
                    Text(
                      'Copyright © Teages. All rights reserved.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    // ...SettingCard(
                    //   "更新检查",
                    //   [],
                    //   context,
                    // ),
                    // ...SettingCard(
                    //   "捐赠",
                    //   [],
                    //   context,
                    // ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}

class AboutDestination extends StatelessWidget {
  const AboutDestination({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const NavigationDestination(
      icon: Icon(Icons.info_outline),
      selectedIcon: Icon(Icons.info),
      label: '关于',
    );
  }
}

NavigationRailDestination AboutRailDestination() {
  return const NavigationRailDestination(
    icon: Icon(Icons.info_outline),
    selectedIcon: Icon(Icons.info),
    label: Text('关于'),
  );
}
