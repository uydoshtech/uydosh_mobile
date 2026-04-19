import "dart:math";

import "package:device_info_plus/device_info_plus.dart";
import "package:flutter/foundation.dart"
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import "package:package_info_plus/package_info_plus.dart";
import "package:shared_preferences/shared_preferences.dart";

/// Describes the physical device the app is running on. Sent alongside the
/// FCM token so the backend can upsert by (user_id, device_id), prune stale
/// tokens, and let admins see which device/OS/app version a user is on.
class DeviceInfoSnapshot {
  const DeviceInfoSnapshot({
    required this.deviceId,
    this.deviceModel,
    this.osVersion,
    this.appVersion,
  });

  final String deviceId;
  final String? deviceModel;
  final String? osVersion;
  final String? appVersion;
}

/// Collects and caches device metadata.
///
/// The `deviceId` is an app-generated UUIDv4 persisted in shared preferences.
/// We deliberately avoid `identifierForVendor` / `androidId` as the primary
/// identifier: the former resets when the last vendor app is uninstalled on
/// iOS, and the latter is unstable across factory resets / OS versions on
/// Android. A generated UUID keyed to our own storage gives us a stable
/// identifier for the lifetime of the app install.
class DeviceInfoService {
  DeviceInfoService._();

  static const String _deviceIdKey = "uydosh.device_id";
  static DeviceInfoSnapshot? _cached;

  static Future<DeviceInfoSnapshot> get() async {
    final cached = _cached;
    if (cached != null) return cached;

    final deviceId = await _getOrCreateDeviceId();
    final appVersion = await _readAppVersion();
    final (model, os) = await _readDeviceAndOs();

    final snapshot = DeviceInfoSnapshot(
      deviceId: deviceId,
      deviceModel: model,
      osVersion: os,
      appVersion: appVersion,
    );
    _cached = snapshot;
    return snapshot;
  }

  static Future<String> _getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_deviceIdKey);
    if (existing != null && existing.trim().isNotEmpty) {
      return existing;
    }
    final generated = _generateUuidV4();
    await prefs.setString(_deviceIdKey, generated);
    return generated;
  }

  static Future<String?> _readAppVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final v = info.version;
      final b = info.buildNumber;
      if (v.isEmpty) return null;
      return b.isEmpty ? v : "$v+$b";
    } catch (_) {
      return null;
    }
  }

  static Future<(String?, String?)> _readDeviceAndOs() async {
    if (kIsWeb) return (null, null);
    try {
      final plugin = DeviceInfoPlugin();
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        final info = await plugin.iosInfo;
        final model =
            info.utsname.machine.isNotEmpty ? info.utsname.machine : info.model;
        return (model, "iOS ${info.systemVersion}");
      }
      if (defaultTargetPlatform == TargetPlatform.android) {
        final info = await plugin.androidInfo;
        final model = "${info.manufacturer} ${info.model}".trim();
        return (model, "Android ${info.version.release}");
      }
      return (null, null);
    } catch (_) {
      return (null, null);
    }
  }

  static String _generateUuidV4() {
    final rnd = Random.secure();
    final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, "0")).join();
    return "${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}";
  }
}
