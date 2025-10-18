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
              methodCount: 4,
              errorMethodCount: 8,
              lineLength: 100,
              colors: false,
              printEmojis: true),
          output: ConsoleOutput())
      : Logger(
          filter: ProductionFilter(),
          level: Level.warning,
          printer: PrettyPrinter(
            methodCount: 8,
            errorMethodCount: 12,
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
  // 日志队列，确保按顺序发送
  final List<Map<String, dynamic>> _logQueue = [];
  bool _isProcessing = false;
  
  Future<void> _logRemote(String level, String log) async {
    // 添加到队列
    _logQueue.add({
      'level': level,
      'log': log,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'packageName': G.pkg.packageName,
      'buildNumber': G.pkg.buildNumber,
      'buildVersion': G.pkg.version,
    });
    
    // 如果没有在处理，开始处理队列
    if (!_isProcessing) {
      _processQueue();
    }
  }
  
  Future<void> _processQueue() async {
    _isProcessing = true;
    
    while (_logQueue.isNotEmpty) {
      final logData = _logQueue.removeAt(0);
      
      try {
        await http.post(
          Uri.parse(Cfg.urlRemoteLog),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(logData),
        );
      } catch (e) {
        print('Remote log failed: $e');
      }
      
      // 避免过于频繁的请求
      await Future.delayed(const Duration(milliseconds: 50));
    }
    
    _isProcessing = false;
  }
  
  @override
  void output(OutputEvent event) {
    if (Cfg.enableRemoteLog) {
      _logRemote(event.level.name, event.lines.join('\n'));
    }
  }
}
