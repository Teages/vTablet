import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/localizations.dart';

class AppearancePage extends StatelessWidget {
  const AppearancePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: Text(AppLocalizations.of(context)!.appearancePageContext),
    );
  }
}

class AppearanceDestination extends StatelessWidget {
  const AppearanceDestination({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationDestination(
      icon: const Icon(Icons.color_lens_outlined),
      selectedIcon: const Icon(Icons.color_lens),
      label: AppLocalizations.of(context)!.appearancePageTitle,
    );
  }
}

NavigationRailDestination appearanceRailDestination(BuildContext context) {
  return NavigationRailDestination(
    icon: const Icon(Icons.color_lens_outlined),
    selectedIcon: const Icon(Icons.color_lens),
    label: Text(AppLocalizations.of(context)!.appearancePageTitle),
  );
}
