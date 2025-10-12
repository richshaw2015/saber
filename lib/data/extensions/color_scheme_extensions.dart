import 'package:flutter/material.dart';

extension ColorSchemeExtensions on ColorScheme {
  /// Link color for hyperlinks and interactive text.
  /// Provides compatibility with older Flutter versions.
  /// 
  /// In newer Flutter versions, this is a built-in property.
  /// For older versions, we use the primary color as a fallback,
  /// with slight adjustments based on brightness.
  Color get link {
    // 在新版本中，link 通常是 primary 的变体
    // 我们根据亮度模式进行微调
    if (brightness == Brightness.light) {
      // 浅色模式：使用稍深的 primary
      return primary;
    } else {
      // 深色模式：使用稍亮的 primary
      return primaryContainer;
    }
  }
}
