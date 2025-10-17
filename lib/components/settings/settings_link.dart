import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SettingsLink extends StatelessWidget {
  const SettingsLink({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      leading: Icon(icon),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
        ),
      ),
      trailing: const Icon(CupertinoIcons.chevron_right),
      onTap: onTap
    );
  }
}
