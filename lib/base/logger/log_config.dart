import "package:flutter/foundation.dart";
import "package:logger/logger.dart";

/// Configuration class for application logging
class LogConfig {
  LogConfig._();

  // Singleton instance
  static final LogConfig _instance = LogConfig._();
  static LogConfig get instance => _instance;

  // Log level configuration
  AppLogLevel _logLevel = _getDefaultLogLevel();

  // Getter for current log level
  AppLogLevel get logLevel => _logLevel;

  // Setter for log level (can be called at runtime)
  set logLevel(AppLogLevel level) {
    _logLevel = level;
    _updateLoggerLevel();
  }

  // Logging features configuration
  bool _enableColors = true;
  bool _enableEmojis = true;
  bool _enableMethodCount = false;
  bool _enableTimestamps = true;
  int _maxLineLength = 120;
  int _errorMethodCount = 0;

  // Console-specific configuration
  bool _enableConsoleOutput = true;
  bool _enableFileOutput = false;
  String _consolePrefix = "";
  bool _enableStackTrace = false;
  bool _enableRequestResponse = false;

  // Getters and setters for logging features
  bool get enableColors => _enableColors;
  set enableColors(bool value) {
    _enableColors = value;
    _updateLoggerPrinter();
  }

  bool get enableEmojis => _enableEmojis;
  set enableEmojis(bool value) {
    _enableEmojis = value;
    _updateLoggerPrinter();
  }

  bool get enableMethodCount => _enableMethodCount;
  set enableMethodCount(bool value) {
    _enableMethodCount = value;
    _updateLoggerPrinter();
  }

  bool get enableTimestamps => _enableTimestamps;
  set enableTimestamps(bool value) {
    _enableTimestamps = value;
    _updateLoggerPrinter();
  }

  int get maxLineLength => _maxLineLength;
  set maxLineLength(int value) {
    _maxLineLength = value;
    _updateLoggerPrinter();
  }

  int get errorMethodCount => _errorMethodCount;
  set errorMethodCount(int value) {
    _errorMethodCount = value;
    _updateLoggerPrinter();
  }

  // Console-specific getters and setters
  bool get enableConsoleOutput => _enableConsoleOutput;
  set enableConsoleOutput(bool value) {
    _enableConsoleOutput = value;
    _updateLoggerPrinter();
  }

  bool get enableFileOutput => _enableFileOutput;
  set enableFileOutput(bool value) {
    _enableFileOutput = value;
    _updateLoggerPrinter();
  }

  String get consolePrefix => _consolePrefix;
  set consolePrefix(String value) {
    _consolePrefix = value;
    _updateLoggerPrinter();
  }

  bool get enableStackTrace => _enableStackTrace;
  set enableStackTrace(bool value) {
    _enableStackTrace = value;
    _updateLoggerPrinter();
  }

  bool get enableRequestResponse => _enableRequestResponse;
  set enableRequestResponse(bool value) {
    _enableRequestResponse = value;
    _updateLoggerPrinter();
  }

  // Get default log level based on environment
  static AppLogLevel _getDefaultLogLevel() {
    if (kReleaseMode) {
      // Production: only errors and warnings
      return AppLogLevel.warning;
    } else if (kDebugMode) {
      // Debug: full logging
      return AppLogLevel.verbose;
    } else {
      // Profile: limited logging
      return AppLogLevel.info;
    }
  }

  // Convert AppLogLevel to Logger level
  Level _convertToLoggerLevel(AppLogLevel level) {
    switch (level) {
      case AppLogLevel.verbose:
        return Level.trace;
      case AppLogLevel.debug:
        return Level.debug;
      case AppLogLevel.info:
        return Level.info;
      case AppLogLevel.warning:
        return Level.warning;
      case AppLogLevel.error:
        return Level.error;
      case AppLogLevel.fatal:
        return Level.fatal;
      case AppLogLevel.nothing:
        return Level.off;
    }
  }

  // Update logger level
  void _updateLoggerLevel() {
    // This will be called when the logger instance is updated
  }

  // Update logger printer
  void _updateLoggerPrinter() {
    // This will be called when the printer configuration is updated
  }

  // Get printer configuration
  PrettyPrinter get printerConfig => PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 0,
    lineLength: _maxLineLength,
    colors: _enableColors,
    printEmojis: _enableEmojis,
    dateTimeFormat:
        _enableTimestamps
            ? DateTimeFormat.onlyTimeAndSinceStart
            : DateTimeFormat.onlyTime,
  );

  // Get current logger level
  Level get loggerLevel => _convertToLoggerLevel(_logLevel);

  // Convenience methods for quick configuration
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

  // Console-specific configuration methods
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

  // Print current configuration. No-op outside debug builds — these `print`
  // calls go straight to the OS log even in release otherwise (they aren't
  // routed through the gated `logger.d` extension).
  void printConfig() {
    if (!kDebugMode) return;
    print("=== LOG CONFIGURATION ===");
    print("Log Level: $_logLevel");
    print("Colors: $_enableColors");
    print("Emojis: $_enableEmojis");
    print("Method Count: $_enableMethodCount");
    print("Timestamps: $_enableTimestamps");
    print("Max Line Length: $_maxLineLength");
    print("Error Method Count: $_errorMethodCount");
    print("Console Output: $_enableConsoleOutput");
    print("File Output: $_enableFileOutput");
    print("Console Prefix: $_consolePrefix");
    print("Stack Trace: $_enableStackTrace");
    print("Request/Response: $_enableRequestResponse");
    print(
      "Environment: ${kReleaseMode
          ? "RELEASE"
          : kDebugMode
          ? "DEBUG"
          : "PROFILE"}",
    );
    print("=======================");
  }
}

// Export the enum for use in other files
enum AppLogLevel { verbose, debug, info, warning, error, fatal, nothing }
