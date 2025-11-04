/// Application-wide logging configuration and convenience methods.
library;

import 'dart:developer' as developer;
import 'dart:io' show Platform, stdout;

import 'package:logging/logging.dart';

class AppLogger {
  final Logger _logger = Logger('AppLogger');

  AppLogger._internal();

  static final AppLogger _instance = AppLogger._internal();

  factory AppLogger() => _instance;

  static void init({Level level = Level.ALL}) {
    hierarchicalLoggingEnabled = true;
    Logger.root.level = level;
    Logger.root.onRecord.listen((record) {
      final String message =
          '[${record.loggerName}] ${record.level.name}: ${record.time.toIso8601String()}: ${record.message}';

      // Use developer.log so tools like logcat/Xcode console preserve levels
      developer.log(
        message,
        name: record.loggerName,
        level: record.level.value,
        error: record.error,
        stackTrace: record.stackTrace,
      );

      // Optionally mirror to stdout on desktop/server targets where developer.log
      // may not be visible depending on run configuration
      if(Platform.isLinux || Platform.isMacOS || Platform.isWindows) {
        stdout.writeln(message);
      }
    });
  }

  void debug(String message) => _logger.fine(message);
  void info(String message) => _logger.info(message);
  void warning(String message) => _logger.warning(message);
  void error(String message, [Object? error, StackTrace? stackTrace]) =>
      _logger.severe(message, error, stackTrace);
}