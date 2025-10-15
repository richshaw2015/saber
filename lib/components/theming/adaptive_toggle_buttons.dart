import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AdaptiveToggleButtons<T extends Object> extends StatelessWidget {
  const AdaptiveToggleButtons({
    super.key,
    required this.value,
    required this.options,
    required this.onChange,
    this.optionsWidth = 72,
    this.optionsHeight = 40,
  })  : assert(optionsWidth > 0),
        assert(optionsHeight > 0);

  final T value;
  final List<ToggleButtonsOption<T>> options;
  final ValueChanged<T?> onChange;

  final double optionsWidth, optionsHeight;

  @override
  Widget build(BuildContext context) {
    return _buildCupertino(context);
  }

  Widget _buildCupertino(BuildContext context) {
    return CupertinoSlidingSegmentedControl<T>(
      children: options.asMap().map((_, ToggleButtonsOption option) =>
          MapEntry<T, Widget>(option.value, option.widget)),
      groupValue: value,
      onValueChanged: onChange,
      padding: const EdgeInsets.all(8),
    );
  }
}

class ToggleButtonsOption<T> {
  final T value;
  final Widget widget;

  const ToggleButtonsOption(this.value, this.widget);
}
