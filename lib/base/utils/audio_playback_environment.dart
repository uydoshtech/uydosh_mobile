import "package:device_info_plus/device_info_plus.dart";
import "package:flutter/foundation.dart"
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

/// Runtime checks for whether app audio playback should be attempted.
abstract final class AudioPlaybackEnvironment {
  static Future<bool>? _skipAudioPlaybackFuture;

  static Future<bool> shouldSkipAudioPlayback() {
    return _skipAudioPlaybackFuture ??= _isSimulatorOrEmulator();
  }

  static Future<bool> _isSimulatorOrEmulator() async {
    if (kIsWeb) return false;
    try {
      final plugin = DeviceInfoPlugin();
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final info = await plugin.iosInfo;
        return !info.isPhysicalDevice;
      }
      if (defaultTargetPlatform == TargetPlatform.android) {
        final info = await plugin.androidInfo;
        return !info.isPhysicalDevice;
      }
    } catch (_) {
      // If detection fails, keep existing behavior and let audio calls fail softly.
    }
    return false;
  }
}
