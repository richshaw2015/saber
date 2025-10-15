import 'package:flutter/material.dart';

class AdaptiveIcon extends StatelessWidget {
  const AdaptiveIcon({
    super.key,
    required this.icon,
    required this.cupertinoIcon,
    this.size,
  });

  final IconData icon;
  final IconData? cupertinoIcon;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Icon(cupertinoIcon ?? icon, size: size);
  }
}
