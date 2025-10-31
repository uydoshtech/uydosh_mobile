import "package:flutter/foundation.dart";
import "package:logger/logger.dart";
import "package:uy_dosh/base/logger/log_config.dart";

// Main logger instance with configuration-based setup
final logger = Logger(
  level: LogConfig.instance.loggerLevel,
  printer: LogConfig.instance.printerConfig,
);

// Convenience methods for different log levels
extension LoggerExtension on Logger {
  // Verbose logging (only in debug mode)
  void v(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      log(Level.trace, message, error: error, stackTrace: stackTrace);
    }
  }

  // Debug logging (only in debug mode)
  void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      log(Level.debug, message, error: error, stackTrace: stackTrace);
    }
  }

  // Info logging
  void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    log(Level.info, message, error: error, stackTrace: stackTrace);
  }

  // Warning logging
  void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    log(Level.warning, message, error: error, stackTrace: stackTrace);
  }

  // Error logging
  void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    log(Level.error, message, error: error, stackTrace: stackTrace);
  }

  // Fatal logging
  void f(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    log(Level.fatal, message, error: error, stackTrace: stackTrace);
  }
}
