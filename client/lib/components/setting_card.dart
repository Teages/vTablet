import 'package:flutter/material.dart';

List<Widget> createSettingCard(
    String title, List<Widget> content, BuildContext context) {
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
