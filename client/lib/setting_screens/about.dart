import 'package:flutter/material.dart';

import 'package:mdi/mdi.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

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
                    ...createSettingCard(
                      AppLocalizations.of(context)!.aboutSoftwareInfoTitle,
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
                    //   AppLocalizations.of(context)!.aboutUpdateCheckTitle,
                    //   [],
                    //   context,
                    // ),
                    // ...SettingCard(
                    //   AppLocalizations.of(context)!.aboutDonateTitle,
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
    return NavigationDestination(
      icon: const Icon(Icons.info_outline),
      selectedIcon: const Icon(Icons.info),
      label: AppLocalizations.of(context)!.aboutPageTitle,
    );
  }
}

NavigationRailDestination aboutRailDestination(BuildContext context) {
  return NavigationRailDestination(
    icon: const Icon(Icons.info_outline),
    selectedIcon: const Icon(Icons.info),
    label: Text(AppLocalizations.of(context)!.aboutPageTitle),
  );
}
