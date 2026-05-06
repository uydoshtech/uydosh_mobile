import "package:flutter/foundation.dart";

/// Application logging configuration.
///
/// Used to be the place where the `package:logger` instance was wired up.
/// We now have an in-house logger (`base/logger/logger.dart`) that runs on
/// `dart:developer`, but the surface that other code reads — `logLevel`,
/// `enableRequestResponse`, [printConfig], [setProductionMode] etc. — is
/// kept to avoid a sprawling refactor.
class LogConfig {
  LogConfig._();

  static final LogConfig _instance = LogConfig._();
  static LogConfig get instance => _instance;

  AppLogLevel logLevel = _getDefaultLogLevel();

  bool enableColors = true;
  bool enableEmojis = true;
  bool enableMethodCount = false;
  bool enableTimestamps = true;
  int maxLineLength = 120;
  int errorMethodCount = 0;

  bool enableConsoleOutput = true;
  bool enableFileOutput = false;
  String consolePrefix = "";
  bool enableStackTrace = false;
  bool enableRequestResponse = false;

  static AppLogLevel _getDefaultLogLevel() {
    if (kReleaseMode) {
      return AppLogLevel.warning;
    } else if (kDebugMode) {
      return AppLogLevel.verbose;
    } else {
      return AppLogLevel.info;
    }
  }

  void setProductionMode() {
    logLevel = AppLogLevel.warning;
    enableColors = false;
    enableEmojis = false;
    enableMethodCount = false;
    enableTimestamps = false;
  }

  void setDebugMode() {
    logLevel = AppLogLevel.verbose;
    enableColors = true;
    enableEmojis = true;
    enableMethodCount = true;
    enableTimestamps = true;
  }

  void setProfileMode() {
    logLevel = AppLogLevel.info;
    enableColors = false;
    enableEmojis = false;
    enableMethodCount = false;
    enableTimestamps = true;
  }

  void setConsoleVerbose() {
    logLevel = AppLogLevel.verbose;
    enableColors = true;
    enableEmojis = true;
    enableMethodCount = true;
    enableTimestamps = true;
    enableStackTrace = true;
    enableRequestResponse = true;
    consolePrefix = "🔍";
  }

  void setConsoleMinimal() {
    logLevel = AppLogLevel.info;
    enableColors = false;
    enableEmojis = false;
    enableMethodCount = false;
    enableTimestamps = true;
    enableStackTrace = false;
    enableRequestResponse = false;
    consolePrefix = "";
  }

  void setConsoleDebug() {
    logLevel = AppLogLevel.debug;
    enableColors = true;
    enableEmojis = true;
    enableMethodCount = true;
    enableTimestamps = true;
    enableStackTrace = true;
    enableRequestResponse = false;
    consolePrefix = "🐛";
  }

  /// Print current configuration. No-op outside debug builds — these `print`
  /// calls go straight to the OS log even in release otherwise (they aren't
  /// routed through the gated `logger.d` extension).
  void printConfig() {
    if (!kDebugMode) return;
    debugPrint("=== LOG CONFIGURATION ===");
    debugPrint("Log Level: $logLevel");
    debugPrint("Colors: $enableColors");
    debugPrint("Emojis: $enableEmojis");
    debugPrint("Method Count: $enableMethodCount");
    debugPrint("Timestamps: $enableTimestamps");
    debugPrint("Max Line Length: $maxLineLength");
    debugPrint("Error Method Count: $errorMethodCount");
    debugPrint("Console Output: $enableConsoleOutput");
    debugPrint("File Output: $enableFileOutput");
    debugPrint("Console Prefix: $consolePrefix");
    debugPrint("Stack Trace: $enableStackTrace");
    debugPrint("Request/Response: $enableRequestResponse");
    debugPrint(
      "Environment: ${kReleaseMode
          ? "RELEASE"
          : kDebugMode
          ? "DEBUG"
          : "PROFILE"}",
    );
    debugPrint("=======================");
  }
}

enum AppLogLevel { verbose, debug, info, warning, error, fatal, nothing }
