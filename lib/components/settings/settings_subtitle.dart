import 'package:flutter/material.dart';

class SettingsSubtitle extends StatelessWidget {
  const SettingsSubtitle({
    super.key,
    required this.subtitle,
    this.topPadding = true,
  });

  final String subtitle;
  final bool topPadding;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(
        top: topPadding ? 32 : 0,
        left: 16,
        right: 16,
        bottom: 0,
      ),
      child: Text(
        subtitle,
        style: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
