import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:saber/service/crashlytics/crash.dart';
import 'package:saber/service/i18n/translation.dart';

import 'common/constant.dart';
import 'common/strings.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 方便截图
  // if (kDebugMode) {
  //   await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  // }

  // 初始化全局设置
  await G.initGlobals();

  // Get.put(ThemeController());

  // 崩溃及异常上报
  FlutterError.onError = Crashlytics.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    Crashlytics.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // final themeController = Get.find<ThemeController>();

    return GetMaterialApp(
      title: Strings.appName,
      // theme: ThemeData(
      //   fontFamily: 'HeiTi',
      //   fontFamilyFallback: const ['SongTi', ],
      //   colorScheme: ColorScheme.fromSeed(
      //     brightness: Brightness.light,
      //     seedColor: Colors.brown,
      //     // 页面背景，米白色
      //     surface: const Color(0xffF9F5F0),
      //     // 背景之上的卡片 bg_tian
      //     surfaceContainer: const Color(0xffffffff),
      //     // 主体文字颜色 main
      //     onSurface: const Color(0xff212121),
      //     // 导航背景，首页专用
      //     primaryContainer: const Color(0xff4f4f4f),
      //     // 主题颜色
      //     primary: const Color(0xffA0522D),
      //     // 主题色的描边
      //     primaryFixed: const Color(0xffD98859),
      //     // 米白色
      //     onPrimary: const Color(0xffF5F0E5),
      //     // 淡化显示 weak
      //     onSecondary: const Color(0xff808080),
      //     // 浅色的背景
      //     onSecondaryContainer: const Color(0xffcecece),
      //     // 分隔符的颜色
      //     onSecondaryFixed: const Color(0x40808080),
      //   ),
      // ),
      // darkTheme: ThemeData(
      //     fontFamily: 'HeiTi',
      //     fontFamilyFallback: const ['SongTi', ],
      //     colorScheme: ColorScheme.fromSeed(
      //       brightness: Brightness.dark,
      //       seedColor: Colors.brown,
      //       surface: const Color(0xff191919),
      //       surfaceContainer: const Color(0xff121212),
      //       onSurface: const Color(0xffd1d1d1),
      //       primaryContainer: const Color(0xff121212),
      //       primary: const Color(0xffA0522D),
      //       primaryFixed: const Color(0xffD98859),
      //       onPrimary: const Color(0xffefefef),
      //       onSecondary: const Color(0xff5e5e5e),
      //       onSecondaryContainer: const Color(0xff252525),
      //       onSecondaryFixed: const Color(0xff252525),
      //     )
      // ),
      // themeMode: ThemeMode.values[themeController.theme.value],
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
      navigatorObservers: const [],
      translations: MyTranslation(),
      // locale: const Locale('zh', 'CN'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

