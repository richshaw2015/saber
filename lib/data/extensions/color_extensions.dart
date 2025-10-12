import 'package:flutter/material.dart';

extension ColorExtensions on Color {
  /// Inverts the color's HSL lightness if [invert] is true.
  /// This does not affect the hue or saturation.
  Color withInversion([bool invert = true]) {
    if (!invert) return this;

    final HSLColor hsl = HSLColor.fromColor(this);
    return hsl.withLightness(1 - hsl.lightness).toColor();
  }

  /// Multiplies the color's HSL saturation by [saturationMultiplier].
  Color withSaturation(double saturationMultiplier) {
    final HSLColor hsl = HSLColor.fromColor(this);
    return hsl.withSaturation(hsl.saturation * saturationMultiplier).toColor();
  }

  /// Creates a new color with the specified values.
  /// This method provides compatibility with older Flutter versions
  /// that don't have the built-in withValues method.
  /// 
  /// Parameters can be null to keep the original value.
  Color withValues({
    double? alpha,
    double? red,
    double? green,
    double? blue,
  }) {
    return Color.fromARGB(
      alpha != null ? (alpha * 255).round() : this.alpha,
      red != null ? (red * 255).round() : this.red,
      green != null ? (green * 255).round() : this.green,
      blue != null ? (blue * 255).round() : this.blue,
    );
  }

  /// Red component as a double between 0.0 and 1.0.
  /// Provides compatibility with older Flutter versions.
  double get r => red / 255.0;

  /// Green component as a double between 0.0 and 1.0.
  /// Provides compatibility with older Flutter versions.
  double get g => green / 255.0;

  /// Blue component as a double between 0.0 and 1.0.
  /// Provides compatibility with older Flutter versions.
  double get b => blue / 255.0;

  /// Alpha component as a double between 0.0 and 1.0.
  /// Provides compatibility with older Flutter versions.
  double get a => alpha / 255.0;

  /// Returns the color as a 32-bit ARGB value.
  /// Provides compatibility with older Flutter versions.
  /// 
  /// The format is 0xAARRGGBB where:
  /// - AA is the alpha channel (0x00 to 0xFF)
  /// - RR is the red channel (0x00 to 0xFF)
  /// - GG is the green channel (0x00 to 0xFF)
  /// - BB is the blue channel (0x00 to 0xFF)
  int toARGB32() => value;
}
