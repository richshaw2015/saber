import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:saber/data/extensions/color_extensions.dart';

class AdaptiveTextField extends StatefulWidget {
  const AdaptiveTextField({
    super.key,
    this.controller,
    this.autofillHints,
    this.placeholder,
    this.prefixIcon,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    required this.focusOrder,
    this.validator,
  });

  final TextEditingController? controller;
  final Iterable<String>? autofillHints;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final NumericFocusOrder focusOrder;
  final String? placeholder;
  final Widget? prefixIcon;
  final bool isPassword;
  final String? Function(String?)? validator;

  @override
  State<StatefulWidget> createState() => _AdaptiveTextFieldState();
}

class _AdaptiveTextFieldState extends State<AdaptiveTextField> {
  bool obscureText = false;
  Widget? get suffixIcon {
    if (!widget.isPassword) return null;
    return IconButton(
      icon: Icon(obscureText ? CupertinoIcons.eye_slash_fill : CupertinoIcons.eye_fill),
      iconSize: 18,
      onPressed: () {
        setState(() {
          obscureText = !obscureText;
        });
      },
    );
  }

  @override
  void initState() {
    obscureText = widget.isPassword;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    TextInputType? keyboardType = widget.keyboardType;
    if (widget.isPassword) {
      if (obscureText) {
        keyboardType = null;
      } else {
        keyboardType = TextInputType.visiblePassword;
      }
    }

    return Row(
      children: [
        Expanded(
          child: FocusTraversalOrder(
            order: widget.focusOrder,
            child: CupertinoTextFormFieldRow(
              controller: widget.controller,
              autofillHints: widget.autofillHints,
              keyboardType: keyboardType,
              textInputAction: widget.textInputAction,
              obscureText: obscureText,
              decoration: BoxDecoration(
                border: Border.all(
                    color: colorScheme.onSurface.withValues(alpha: 0.12)),
                borderRadius: BorderRadius.circular(8),
              ),
              style: TextStyle(color: colorScheme.onSurface),
              placeholder: widget.placeholder,
              prefix: widget.prefixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: widget.prefixIcon,
                    )
                  : null,
              validator: widget.validator,
            ),
          ),
        ),
        if (suffixIcon != null)
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: FocusTraversalOrder(
                order: NumericFocusOrder(widget.focusOrder.order + 100),
                child: suffixIcon!,
              ),
            ),
          )
        else
          const SizedBox(height: 40),
      ],
    );
  }
}
