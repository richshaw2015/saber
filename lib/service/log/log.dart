import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

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
          output: ConsoleOutput());

  static void d(dynamic message) => _logger.d(message);
  static void i(dynamic message) => _logger.i(message);
  static void w(dynamic message) => _logger.w(message);
  static void e(dynamic message, [Object? error, StackTrace? stackTrace]) =>
      _logger.e(message, error: error, stackTrace: stackTrace);
}
