import 'dart:convert';

import 'package:flutter/foundation.dart'
    show DiagnosticLevel, FlutterError, FlutterErrorDetails, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:saber/service/crashlytics/utils.dart';

import '../../common/config.dart';
import '../../common/constant.dart';
import '../log/log.dart';

class Crashlytics {
  /// Submits a Crashlytics report of a caught error.
  static Future<void> recordError(dynamic exception, StackTrace? stack,
      {dynamic reason,
        Iterable<Object> information = const [],
        bool? printDetails,
        bool fatal = false}) async {
    // Use the debug flag if printDetails is not provided
    printDetails ??= kDebugMode;

    final String info = information.isEmpty
        ? ''
        : (StringBuffer()..writeAll(information, '\n')).toString();

    if (printDetails) {
      // ignore: avoid_print
      print('----------------FIREBASE CRASHLYTICS----------------');

      // If available, give a reason to the exception.
      if (reason != null) {
        // ignore: avoid_print
        print('The following exception was thrown $reason:');
      }

      // Need to print the exception to explain why the exception was thrown.
      // ignore: avoid_print
      print(exception);

      // Print information provided by the Flutter framework about the exception.
      // ignore: avoid_print
      if (info.isNotEmpty) print('\n$info');

      // Not using Trace.format here to stick to the default stack trace format
      // that Flutter developers are used to seeing.
      // ignore: avoid_print
      if (stack != null) print('\n$stack');
      // ignore: avoid_print
      print('----------------------------------------------------');
    }

    // Replace null or empty stack traces with the current stack trace.
    final StackTrace stackTrace = (stack == null || stack.toString().isEmpty)
        ? StackTrace.current
        : stack;

    // Report error.
    final List<Map<String, String>> stackTraceElements =
    getStackTraceElements(stackTrace);
    final String? buildId = getBuildId(stackTrace);
    final List<String> loadingUnits = getLoadingUnits(stackTrace);

    return _uploadError(
      exception: exception.toString(),
      reason: reason?.toString(),
      information: info,
      stackTraceElements: stackTraceElements,
      buildId: buildId,
      loadingUnits: loadingUnits,
      fatal: fatal,
    );
  }

  /// Submits a Crashlytics report of a fatal error caught by the Flutter framework.
  static Future<void> recordFlutterFatalError(
      FlutterErrorDetails flutterErrorDetails) {
    return recordFlutterError(flutterErrorDetails, fatal: true);
  }

  /// Submits a Crashlytics report of an error caught by the Flutter framework.
  /// Use [fatal] to indicate whether the error is a fatal or not.
  static Future<void> recordFlutterError(FlutterErrorDetails flutterErrorDetails,
      {bool fatal = false}) {
    FlutterError.presentError(flutterErrorDetails);

    final information = flutterErrorDetails.informationCollector?.call() ?? [];

    return recordError(
      flutterErrorDetails.exceptionAsString(),
      flutterErrorDetails.stack,
      reason: flutterErrorDetails.context
          ?.toStringDeep(minLevel: DiagnosticLevel.info)
          .trim(),
      information: information,
      printDetails: false,
      fatal: fatal,
    );
  }

  // 真正的上传服务
  static Future<void> _uploadError(
      {required String exception,
      required String? reason,
      required String information,
      required List<Map<String, String>> stackTraceElements,
      required String? buildId,
      required List<String> loadingUnits,
      required bool fatal}) async {
    if (kDebugMode) {
      return;
    }

    final url = Uri.parse(Cfg.urlCrashlytics);

    // 真正上报的数据，限制 1M
    Map<String, dynamic> data = {
      "exception": exception,
      "reason": reason,
      "information": information,
      "stackTraceElements": stackTraceElements,
      "buildId": buildId,
      "loadingUnits": loadingUnits,
      "fatal": fatal,
      // 自动添加包信息相关的数据
      "packageName": G.pkg.packageName,
      "buildNumber": G.pkg.buildNumber,
      "buildVersion": G.pkg.version,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        Log.d('Log sent successfully');
      } else {
        Log.w('Failed to send log: ${response.statusCode}');
      }
    } catch (e) {
      Log.e('Error sending log: $e');
    }
  }
}