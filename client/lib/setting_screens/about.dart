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
              constraints: const BoxConstraints(maxWidth: 640),
              padding: const EdgeInsets.all(20),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CardAboutSoftwareInfo(),
                    Text(
                      'Copyright © Teages. All rights reserved.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ]),
            ),
          ],
        ),
      ),
    );
  }
}

class CardAboutSoftwareInfo extends StatelessWidget {
  const CardAboutSoftwareInfo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CardWithTitle(
      title: AppLocalizations.of(context)!.aboutSoftwareInfoTitle,
      content: [
        const Text(
          'v3.0.0 (Preview 4) by Teages',
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
          label: Text(
            AppLocalizations.of(context)!.aboutGithubBtn,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
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
