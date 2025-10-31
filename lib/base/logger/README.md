# Enhanced Logging System

This project uses the `logger` package with enhanced configuration and convenience methods for better log level control.

## Features

- **Environment-based logging**: Automatically adjusts log levels based on build mode
- **Configurable output**: Control colors, emojis, method counts, and timestamps
- **Convenience methods**: Short methods for different log levels
- **Runtime configuration**: Change logging behavior at runtime

## Usage

### Basic Logging

```dart
import 'package:uy_dosh/base/logger/logger.dart';

// Different log levels
logger.v('Verbose message');     // Only in debug mode
logger.d('Debug message');       // Only in debug mode
logger.i('Info message');        // Always logged
logger.w('Warning message');     // Always logged
logger.e('Error message');       // Always logged
logger.f('Fatal message');       // Always logged

// With error and stack trace
logger.e('Error occurred', error: exception, stackTrace: stackTrace);
```

### Configuration

```dart
import 'package:uy_dosh/base/logger/log_config.dart';

// Quick mode setup
LogConfig.instance.setDebugMode();      // Full logging for development
LogConfig.instance.setProfileMode();    // Limited logging for profiling
LogConfig.instance.setProductionMode(); // Minimal logging for production

// Custom configuration
LogConfig.instance.logLevel = AppLogLevel.info;
LogConfig.instance.enableColors = false;
LogConfig.instance.enableEmojis = false;
LogConfig.instance.enableMethodCount = true;
LogConfig.instance.maxLineLength = 80;

// Print current configuration
LogConfig.instance.printConfig();
```

### Log Levels

- **verbose**: Most detailed logging (debug mode only)
- **debug**: Debug information (debug mode only)
- **info**: General information
- **warning**: Warning messages
- **error**: Error messages
- **fatal**: Fatal errors
- **nothing**: No logging

### Environment Behavior

- **Debug Mode**: Full verbose logging with colors and emojis
- **Profile Mode**: Info level and above, minimal formatting
- **Release Mode**: Warning level and above, no colors or emojis

## Integration

The logger is automatically configured in:
- `AppBlocObserver` for BLoC state changes
- `CustomOAuthInterceptor` for API authentication
- `PublicDioConfigurator` for HTTP requests

## Best Practices

1. **Use appropriate log levels**:
   - `v()` for detailed debugging
   - `d()` for general debugging
   - `i()` for important information
   - `w()` for warnings
   - `e()` for errors
   - `f()` for fatal errors

2. **Include context**:
   ```dart
   logger.i('User logged in', error: null, stackTrace: null);
   logger.e('API request failed', error: exception, stackTrace: stackTrace);
   ```

3. **Performance considerations**:
   - Verbose and debug logs are automatically disabled in release mode
   - Use string interpolation sparingly in verbose logs
   - Consider using `logger.isLogLevelEnabled(Level.verbose)` for expensive operations

4. **Production logging**:
   - Set to warning level or higher
   - Disable colors and emojis
   - Keep method counts minimal
