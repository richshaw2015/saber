import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

import 'package:saber/common/config.dart';
import 'package:saber/common/constant.dart';

class Log {
  static final Logger _logger = kDebugMode
      ? Logger(
          filter: DevelopmentFilter(),
          level: Level.debug,
          printer: PrettyPrinter(
              methodCount: 2,
              errorMethodCount: 8,
              lineLength: 100,
              colors: false,
              printEmojis: true),
          output: ConsoleOutput())
      : Logger(
          filter: ProductionFilter(),
          level: Level.warning,
          printer: PrettyPrinter(
            methodCount: 4,
            errorMethodCount: 8,
            lineLength: 100,
            colors: false,
            printEmojis: false,
            noBoxingByDefault: true,
          ),
          output: RemoteOutput());

  static void d(dynamic message) => _logger.d(message);
  static void i(dynamic message) => _logger.i(message);
  static void w(dynamic message) => _logger.w(message);
  static void e(dynamic message, [Object? error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}


class RemoteOutput extends LogOutput {
  
  Future<void> _logRemote(String level, String log) async {
    try {
      await http.post(
        Uri.parse(Cfg.urlRemoteLog),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'level': level,
          'log': log,
          // 自动添加包信息相关的数据
          'packageName': G.pkg.packageName,
          'buildNumber': G.pkg.buildNumber,
          'buildVersion': G.pkg.version,
        }),
      );
    } catch (e) {
      Log.d(e);
    }
  }
  
  @override
  void output(OutputEvent event) {
    if (Cfg.enableRemoteLog) {
      _logRemote(event.level.name, event.lines.join('\n'));
    }
  }
}
