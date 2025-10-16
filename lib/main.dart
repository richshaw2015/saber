import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:path_to_regexp/path_to_regexp.dart';
import 'package:printing/printing.dart';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'package:saber/common/constant.dart';
import 'package:saber/common/strings.dart';
import 'package:saber/components/canvas/pencil_shader.dart';
import 'package:saber/components/theming/dynamic_material_app.dart';
import 'package:saber/data/editor/pencil_sound.dart';
import 'package:saber/data/file_manager/file_manager.dart';
import 'package:saber/data/prefs.dart';
import 'package:saber/data/routes.dart';
import 'package:saber/data/tools/stroke_properties.dart';
import 'package:saber/i18n/strings.g.dart';
import 'package:saber/pages/editor/editor.dart';
import 'package:saber/pages/home/home.dart';
import 'package:saber/pages/logs.dart';
import 'package:saber/pages/user/login.dart';
import 'package:saber/service/crashlytics/crash.dart';
import 'package:worker_manager/worker_manager.dart';
// import 'package:workmanager/workmanager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 方便截图
  // if (kDebugMode) {
  //   await SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  // }

  // 初始化全局设置
  await G.initGlobals();

  // 崩溃及异常上报
  FlutterError.onError = Crashlytics.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    Crashlytics.recordError(error, stack, fatal: true);
    return true;
  };

  await appRunner();
}

Future<void> appRunner() async {
  StrokeOptionsExtension.setDefaults();
  Stows.markAsOnMainIsolate();

  await workerManager.init();
  await stows.locale.waitUntilRead();
  await PencilShader.init();
  await PencilSound.preload();

  Printing.info().then((info) {
    Editor.canRasterPdf = info.canRaster;
  });

  setLocale();
  stows.locale.addListener(setLocale);
  // stows.customDataDir.addListener(FileManager.migrateDataDir);

  // HttpOverrides.global = NcHttpOverrides();

  runApp(TranslationProvider(child: const App()));

  // startSyncAfterLoaded();
  // setupBackgroundSync();
}

// void startSyncAfterLoaded() async {
//   await stows.username.waitUntilRead();
//   await stows.encPassword.waitUntilRead();
//
//   stows.username.removeListener(startSyncAfterLoaded);
//   stows.encPassword.removeListener(startSyncAfterLoaded);
//   if (!stows.loggedIn) {
//     // try again when logged in
//     stows.username.addListener(startSyncAfterLoaded);
//     stows.encPassword.addListener(startSyncAfterLoaded);
//     return;
//   }
//
//   // wait for other prefs to load
//   await Future.delayed(const Duration(milliseconds: 100));
//
//   // start syncing
//   syncer.downloader.refresh();
//   syncer.uploader.refresh();
// }

void setLocale() {
  if (stows.locale.value.isNotEmpty &&
      AppLocaleUtils.supportedLocalesRaw.contains(stows.locale.value)) {
    LocaleSettings.setLocaleRaw(stows.locale.value);
  } else {
    LocaleSettings.useDeviceLocale();
  }
}

// void setupBackgroundSync() {
//   if (!Platform.isAndroid && !Platform.isIOS) return;
//   if (!stows.syncInBackground.loaded) {
//     return stows.syncInBackground.addListener(setupBackgroundSync);
//   } else {
//     stows.syncInBackground.removeListener(setupBackgroundSync);
//   }
//   if (!stows.syncInBackground.value) return;
//
//   Workmanager().initialize(doBackgroundSync);
//   const uniqueName = 'background-sync';
//   const initialDelay = Duration(hours: 12);
//   final constraints = Constraints(
//     networkType: NetworkType.unmetered,
//     requiresBatteryNotLow: true,
//     requiresCharging: false,
//     requiresDeviceIdle: true,
//     requiresStorageNotLow: true,
//   );
//
//   if (Platform.isAndroid)
//     Workmanager().registerPeriodicTask(uniqueName, uniqueName,
//         frequency: initialDelay,
//         initialDelay: initialDelay,
//         constraints: constraints);
//   else if (Platform.isIOS)
//     Workmanager().registerOneOffTask(uniqueName, uniqueName,
//         initialDelay: initialDelay, constraints: constraints);
// }

// @pragma('vm:entry-point')
// void doBackgroundSync() {
//   Workmanager().executeTask((_, __) async {
//     // FlavorConfig.setupFromEnvironment();
//     StrokeOptionsExtension.setDefaults();
//     Editor.canRasterPdf = false;
//
//     await Future.wait([
//       FileManager.init(),
//       workerManager.init(),
//       stows.url.waitUntilRead(),
//       stows.allowInsecureConnections.waitUntilRead(),
//     ]);
//
//     /// Only sync a few files to avoid using too much data/battery
//     const maxFilesSynced = 10;
//     var filesSynced = 0;
//     final completer = Completer<bool>();
//     late final StreamSubscription<SaberSyncFile> transferSubscription;
//     void transferListener([_]) {
//       filesSynced++;
//       if (filesSynced >= maxFilesSynced ||
//           syncer.downloader.numPending <= 0 ||
//           completer.isCompleted) {
//         transferSubscription.cancel();
//         if (!completer.isCompleted) completer.complete(filesSynced > 0);
//       }
//     }
//
//     transferSubscription =
//         syncer.downloader.transferStream.listen(transferListener);
//     return completer.future;
//   });
// }

class App extends StatefulWidget {
  const App({super.key});

  static final log = Logger('App');

  static String initialLocation =
      pathToFunction(RoutePaths.home)({'subpage': HomePage.recentSubpage});
  static final GoRouter _router = GoRouter(
    initialLocation: initialLocation,
    routes: <GoRoute>[
      GoRoute(
        path: '/',
        redirect: (context, state) => initialLocation,
      ),
      GoRoute(
        path: RoutePaths.home,
        builder: (context, state) => HomePage(
          subpage: state.pathParameters['subpage'] ?? HomePage.recentSubpage,
          path: state.uri.queryParameters['path'],
        ),
      ),
      GoRoute(
        path: RoutePaths.edit,
        builder: (context, state) => Editor(
          path: state.uri.queryParameters['path'],
          pdfPath: state.uri.queryParameters['pdfPath'],
        ),
      ),
      GoRoute(
        path: RoutePaths.login,
        builder: (context, state) => const NcLoginPage(),
      ),
      GoRoute(
        path: '/profile',
        redirect: (context, state) => RoutePaths.login,
      ),
      GoRoute(
        path: RoutePaths.logs,
        builder: (context, state) => const LogsPage(),
      ),
    ],
  );

  static void openFile(SharedMediaFile file) async {
    log.info('Opening file: (${file.type}) ${file.path}');

    if (file.type != SharedMediaType.file) return;

    final String extension;
    if (file.path.contains('.')) {
      extension = file.path.split('.').last.toLowerCase();
    } else {
      extension = 'sbn2';
    }

    if (extension == 'sbn' || extension == 'sbn2' || extension == 'sba') {
      final String? path = await FileManager.importFile(
        file.path,
        null,
        extension: '.$extension',
      );
      if (path == null) return;

      // allow file to finish writing
      await Future.delayed(const Duration(milliseconds: 100));

      _router.push(RoutePaths.editFilePath(path));
    } else if (extension == 'pdf' && Editor.canRasterPdf) {
      final fileNameWithoutExtension = file.path
          .split(RegExp(r'[\\/]'))
          .last
          .substring(0, file.path.length - '.pdf'.length);
      final sbnFilePath = await FileManager.suffixFilePathToMakeItUnique(
        '/$fileNameWithoutExtension',
      );
      _router.push(RoutePaths.editImportPdf(sbnFilePath, file.path));
    } else {
      log.warning('openFile: Unsupported file type: $extension');
    }
  }

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  StreamSubscription? _intentDataStreamSubscription;

  @override
  void initState() {
    setupSharingIntent();
    super.initState();
  }

  void setupSharingIntent() {
    // for files opened while the app is closed
    ReceiveSharingIntent.instance
        .getInitialMedia()
        .then((List<SharedMediaFile> files) {
      for (final file in files) {
        App.openFile(file);
      }
    });

    // for files opened while the app is open
    final stream = ReceiveSharingIntent.instance.getMediaStream();
    _intentDataStreamSubscription =
        stream.listen((List<SharedMediaFile> files) {
      for (final file in files) {
        App.openFile(file);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: Strings.appName,
      debugShowCheckedModeBanner: false,
      home: DynamicMaterialApp(
        title: Strings.appName,
        router: App._router,
      ),
      localizationsDelegates: const [
        DefaultCupertinoLocalizations.delegate,
        DefaultMaterialLocalizations.delegate,
        DefaultWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
    );
  }

  @override
  void dispose() {
    _intentDataStreamSubscription?.cancel();
    super.dispose();
  }
}
