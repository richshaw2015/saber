import 'package:flutter/material.dart';

const saberSansSerifFontFallbacks = [
  'Adwaita Sans',
  'Inter',
  'Noto Sans',
  'Roboto',
  'Droid Sans',
  'Liberation Sans',
  'Fira Sans',
  'Cantarell',
  'system-ui',
  'Atkinson Hyperlegible Next',
  'AtkinsonHyperlegibleNext',
  'Atkinson Hyperlegible',
  'AtkinsonHyperlegible',
  'sans-serif',
  '.SF Pro Display',
  '.SF Pro Text',
  '.SF UI Display',
  '.SF UI Text',
  'Neucha',
  'Dekko',
];
const saberMonoFontFallbacks = [
  'Fira Mono',
  'ui-monospace',
  'Cascadia Code',
  'Source Code Pro',
  'Menlo',
  'Consolas',
  'DejaVu Sans Mono',
  'monospace',
];
const saberHandwritingFontFallbacks = [
  'Neucha',
  'Dekko',
  // Fallback fonts from https://github.com/system-fonts/modern-font-stacks#handwritten
  'Segoe Print',
  'Bradley Hand',
  'Chilanka',
  'TSCu_Comic',
  'Coming Soon',
  'casual',
  'cursive',
  'handwriting',
  ...saberSansSerifFontFallbacks,
];

extension TextThemeExtension on TextTheme {
  /// 便捷方法：从 context 获取 TextTheme
  /// 用法: TextTheme.of(context)
  static TextTheme of(BuildContext context) {
    return Theme.of(context).textTheme;
  }

  TextTheme withFont({
    required String? fontFamily,
    required List<String>? fontFamilyFallback,
  }) =>
      copyWith(
        displayLarge: displayLarge?.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
        displayMedium: displayMedium?.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
        displaySmall: displaySmall?.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
        headlineLarge: headlineLarge?.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
        headlineMedium: headlineMedium?.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
        headlineSmall: headlineSmall?.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
        titleLarge: titleLarge?.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
        titleMedium: titleMedium?.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
        titleSmall: titleSmall?.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
        bodyLarge: bodyLarge?.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
        bodyMedium: bodyMedium?.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
        bodySmall: bodySmall?.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
        labelLarge: labelLarge?.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
        labelMedium: labelMedium?.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
        labelSmall: labelSmall?.copyWith(
            fontFamily: fontFamily, fontFamilyFallback: fontFamilyFallback),
      );
}
