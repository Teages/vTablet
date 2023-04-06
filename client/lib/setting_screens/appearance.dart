import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class AppearancePage extends StatelessWidget {
  const AppearancePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: const Text('外观设置正在准备中'),
    );
  }
}

class AppearanceDestination extends StatelessWidget {
  const AppearanceDestination({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const NavigationDestination(
      icon: Icon(Icons.color_lens_outlined),
      selectedIcon: Icon(Icons.color_lens),
      label: '外观',
    );
  }
}

NavigationRailDestination AppearanceRailDestination() {
  return const NavigationRailDestination(
    icon: Icon(Icons.color_lens_outlined),
    selectedIcon: Icon(Icons.color_lens),
    label: Text('外观'),
  );
}
