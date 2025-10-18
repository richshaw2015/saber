import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:saber/components/theming/font_fallbacks.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:saber/service/log/log.dart';

class DynamicMaterialApp extends StatefulWidget {
  const DynamicMaterialApp({
    super.key,
    required this.title,
    required this.router,
    this.defaultSwatch = Colors.yellow,
  });

  final String title;
  final Color defaultSwatch;
  final GoRouter router;

  static final ValueNotifier<bool> _isFullscreen = ValueNotifier(false);
  static bool get isFullscreen => _isFullscreen.value;

  static void setFullscreen(bool value, {required bool updateSystem}) {
    Log.d('Set fullscreen: $value, updateSystem: $updateSystem');

    _isFullscreen.value = value;
    if (!updateSystem) return;

    if (value) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    }
    // SystemChrome.setEnabledSystemUIMode(
    //     value ? SystemUiMode.immersive : SystemUiMode.edgeToEdge);
  }

  static void addFullscreenListener(void Function() listener) {
    _isFullscreen.addListener(listener);
  }

  static void removeFullscreenListener(void Function() listener) {
    _isFullscreen.removeListener(listener);
  }

  @override
  State<DynamicMaterialApp> createState() => _DynamicMaterialAppState();
}

class _DynamicMaterialAppState extends State<DynamicMaterialApp> {
  /// Synced with [PageTransitionsTheme._defaultBuilders]
  /// but with PredictiveBackPageTransitionsBuilder for Android.
  // static const _pageTransitionsTheme = PageTransitionsTheme(
  //   builders: {
  //     TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
  //     TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
  //     TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
  //     TargetPlatform.windows: ZoomPageTransitionsBuilder(),
  //     TargetPlatform.linux: ZoomPageTransitionsBuilder(),
  //   },
  // );

  @override
  void initState() {
    super.initState();

    Log.i(Get.size);

    stows.appTheme.addListener(onChanged);
    stows.accentColor.addListener(onChanged);
    stows.hyperlegibleFont.addListener(onChanged);
    stows.locale.addListener(onChanged);  // 监听语言变化

    SystemChrome.setSystemUIChangeCallback(_onFullscreenChange);
  }

  void onChanged() {
    setState(() {});
  }

  Future<void> _onFullscreenChange(bool systemOverlaysAreVisible) async {
    DynamicMaterialApp.setFullscreen(!systemOverlaysAreVisible,
        updateSystem: false);
  }

  TextTheme? getTextTheme(Brightness brightness) {
    if (stows.hyperlegibleFont.value) {
      return ThemeData(brightness: brightness).textTheme.withFont(
            fontFamily: 'AtkinsonHyperlegibleNext',
            fontFamilyFallback: saberSansSerifFontFallbacks,
          );
    } else {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color seedColor;
    final ColorScheme lightColorScheme;
    final ColorScheme darkColorScheme;

    // 简化颜色选择逻辑：自定义颜色 -> 默认颜色
    final chosenAccentColor = stows.accentColor.value;
    if (chosenAccentColor != null &&
        chosenAccentColor != Colors.transparent) {
      seedColor = chosenAccentColor;
    } else {
      seedColor = widget.defaultSwatch;
    }

    lightColorScheme = ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: seedColor,
    );
    darkColorScheme = ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: seedColor,
    );

    // TODO 低版本的 flutter 暂不支持 contrastLevel 属性
    final highContrastLightColorScheme = ColorScheme.fromSeed(
      brightness: Brightness.light,
      seedColor: seedColor,
      surface: Colors.white,
      // contrastLevel: 1,
    );
    final highContrastDarkColorScheme = ColorScheme.fromSeed(
      brightness: Brightness.dark,
      seedColor: seedColor,
      surface: Colors.black,
      // contrastLevel: 1,
    );

    // 固定主题类型，不支持自定义
    const platform = TargetPlatform.iOS;
    // final platform = switch (stows.platform.value) {
    //   TargetPlatform.iOS => TargetPlatform.iOS,
    //   TargetPlatform.android => TargetPlatform.android,
    //   TargetPlatform.linux => TargetPlatform.linux,
    //   _ => defaultTargetPlatform,
    // };

    return MaterialApp.router(
      routeInformationProvider: widget.router.routeInformationProvider,
      routeInformationParser: widget.router.routeInformationParser,
      routerDelegate: widget.router.routerDelegate,
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: const [
        ...GlobalMaterialLocalizations.delegates,
        FlutterQuillLocalizations.delegate,
      ],
      title: widget.title,
      themeMode: stows.appTheme.loaded
          ? stows.appTheme.value
          : ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme,
        textTheme: getTextTheme(Brightness.light),
        scaffoldBackgroundColor: lightColorScheme.surface,
        platform: platform,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: darkColorScheme,
        textTheme: getTextTheme(Brightness.dark),
        scaffoldBackgroundColor: darkColorScheme.surface,
        platform: platform,
      ),
      highContrastTheme: ThemeData(
        useMaterial3: true,
        colorScheme: highContrastLightColorScheme,
        textTheme: getTextTheme(Brightness.light),
        scaffoldBackgroundColor: highContrastLightColorScheme.surface,
        platform: platform,
      ),
      highContrastDarkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: highContrastDarkColorScheme,
        textTheme: getTextTheme(Brightness.dark),
        scaffoldBackgroundColor: highContrastDarkColorScheme.surface,
        platform: platform,
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  @override
  void dispose() {
    stows.appTheme.removeListener(onChanged);
    stows.accentColor.removeListener(onChanged);
    stows.hyperlegibleFont.removeListener(onChanged);
    stows.locale.removeListener(onChanged);  // 移除语言变化监听

    SystemChrome.setSystemUIChangeCallback(null);

    super.dispose();
  }
}
