import "dart:developer" as developer;

import "package:flutter/foundation.dart";
import "package:uy_dosh/base/logger/log_config.dart";

/// Lightweight in-house logger built on `dart:developer`.
///
/// Historically this wrapped `package:logger`, which gave us colored output
/// and emoji prefixes but cost ~70 KB Dart AOT for features we mostly didn't
/// use in production. The replacement preserves the call surface used
/// throughout the app — `logger.d/i/w/e/f/v(message, [error, stackTrace])` —
/// but routes everything through `developer.log` (a per-isolate logger
/// integrated with the Dart VM service / DevTools) and drops the dependency.
///
/// Behavioral parity with the previous wrapper:
/// * `v` (verbose) and `d` (debug) are no-ops outside debug builds.
/// * All levels respect the threshold configured by [LogConfig.logLevel];
///   anything below the threshold is dropped silently.
/// * `error` / `stackTrace` are forwarded so DevTools surfaces them under
///   the right log entry.
final logger = _AppLogger();

class _AppLogger {
  /// Verbose / trace — debug builds only.
  void v(dynamic message, {Object? error, StackTrace? stackTrace}) {
    if (!kDebugMode) return;
    _emit(_LogLevel.trace, message, error, stackTrace);
  }

  /// Debug — debug builds only.
  void d(dynamic message, {Object? error, StackTrace? stackTrace}) {
    if (!kDebugMode) return;
    _emit(_LogLevel.debug, message, error, stackTrace);
  }

  void i(dynamic message, {Object? error, StackTrace? stackTrace}) =>
      _emit(_LogLevel.info, message, error, stackTrace);

  void w(dynamic message, {Object? error, StackTrace? stackTrace}) =>
      _emit(_LogLevel.warning, message, error, stackTrace);

  void e(dynamic message, {Object? error, StackTrace? stackTrace}) =>
      _emit(_LogLevel.error, message, error, stackTrace);

  void f(dynamic message, {Object? error, StackTrace? stackTrace}) =>
      _emit(_LogLevel.fatal, message, error, stackTrace);

  static void _emit(
    _LogLevel level,
    dynamic message,
    Object? error,
    StackTrace? stackTrace,
  ) {
    // Bail early if this level falls below the configured threshold —
    // matches the level filtering `package:logger` did internally.
    if (level.value < LogConfig.instance.logLevel.thresholdValue) return;

    developer.log(
      message?.toString() ?? "",
      name: "uydosh",
      level: level.developerLevel,
      error: error,
      stackTrace: stackTrace,
    );
  }
}

/// Internal mapping table between our [AppLogLevel] (public, in [LogConfig])
/// and the standard `dart:developer` numeric levels.
enum _LogLevel {
  trace(0, 300),
  debug(1, 500),
  info(2, 800),
  warning(3, 900),
  error(4, 1000),
  fatal(5, 1200);

  const _LogLevel(this.value, this.developerLevel);

  /// Internal ordering — higher means more severe.
  final int value;

  /// Maps to `package:logging` numeric levels (also used by DevTools).
  /// 300=FINE, 500=FINER->INFO, 800=INFO, 900=WARNING, 1000=SEVERE, 1200=SHOUT.
  final int developerLevel;
}

/// Bridges the public [AppLogLevel] to the internal numeric threshold so
/// [_AppLogger._emit] can do a single integer comparison per call.
extension AppLogLevelThreshold on AppLogLevel {
  int get thresholdValue {
    switch (this) {
      case AppLogLevel.verbose:
        return _LogLevel.trace.value;
      case AppLogLevel.debug:
        return _LogLevel.debug.value;
      case AppLogLevel.info:
        return _LogLevel.info.value;
      case AppLogLevel.warning:
        return _LogLevel.warning.value;
      case AppLogLevel.error:
        return _LogLevel.error.value;
      case AppLogLevel.fatal:
        return _LogLevel.fatal.value;
      case AppLogLevel.nothing:
        return 1 << 30; // higher than any level — always filters
    }
  }
}
