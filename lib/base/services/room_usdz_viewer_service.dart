import "dart:io";

import "package:dio/dio.dart";
import "package:flutter/services.dart";
import "package:path_provider/path_provider.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/utils/ios_device.dart";

/// iOS: download USDZ then present custom SceneKit viewer (object-only, no Quick Look AR tab).
class RoomUsdzViewerService {
  RoomUsdzViewerService._();

  static const MethodChannel _channel = MethodChannel("uydosh/room_usdz_viewer");

  static String _rgbHex6(Color color) {
    final v = color.toARGB32();
    return (v & 0xFFFFFF).toRadixString(16).padLeft(6, "0");
  }

  /// Returns true if the native viewer was presented.
  /// [languageCode] app language (`en`, `ru`, `uz`) — native UI uses [L10n] strings for that locale.
  static Future<bool> downloadAndPresent(
    String absoluteUrl, {
    required int listingId,
    required String languageCode,
  }) async {
    if (!isIOSDevice) return false;
    final temp = await getTemporaryDirectory();
    final file = File("${temp.path}/uydosh_room_$listingId.usdz");
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 45),
        receiveTimeout: const Duration(minutes: 2),
        responseType: ResponseType.stream,
      ),
    );
    try {
      await dio.download(absoluteUrl, file.path);
    } catch (e, st) {
      logger.d("USDZ download failed: $e\n$st");
      rethrow;
    }
    if (!file.existsSync() || file.lengthSync() == 0) {
      throw StateError("Downloaded USDZ is missing or empty");
    }
    final strings = <String, String>{
      "title": L10n.getForLanguage("room_3d_viewer_title", languageCode),
      "dimensionsCaption":
          L10n.getForLanguage("room_3d_dimensions_caption", languageCode),
      "dimensionsLineTemplate":
          L10n.getForLanguage("room_3d_dimensions_line_template", languageCode),
      "gestureHint": L10n.getForLanguage("room_3d_gesture_hint", languageCode),
      "loadErrorTitle":
          L10n.getForLanguage("room_3d_load_error_title", languageCode),
      "alertOk": L10n.getForLanguage("ok", languageCode),
      "floorOnlyButton":
          L10n.getForLanguage("room_3d_floor_only_button", languageCode),
      "fullRoomButton":
          L10n.getForLanguage("room_3d_full_room_button", languageCode),
      "floorOnlyUnavailable":
          L10n.getForLanguage("room_3d_floor_only_unavailable", languageCode),
      "onFloorTintRgb": _rgbHex6(AppColors.floorObject3dTint),
    };
    final ok = await _channel.invokeMethod<bool>("presentLocalFile", <String, dynamic>{
      "path": file.path,
      "strings": strings,
    });
    return ok ?? false;
  }
}
