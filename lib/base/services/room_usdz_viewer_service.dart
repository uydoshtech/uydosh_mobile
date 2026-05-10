import "dart:io";

import "package:dio/dio.dart";
import "package:flutter/services.dart";
import "package:path_provider/path_provider.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/utils/ios_device.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/domain/services/listing_service_common.dart";

/// iOS: download USDZ then present custom SceneKit viewer (object-only, no Quick Look AR tab).
class RoomUsdzViewerService {
  RoomUsdzViewerService._();

  static const MethodChannel _channel = MethodChannel("uydosh/room_usdz_viewer");
  static const MethodChannel _metricsSink = MethodChannel("uydosh/room_scan_metrics_sink");

  static bool _metricsSinkRegistered = false;

  static void _ensureRoomScanMetricsSink() {
    if (_metricsSinkRegistered) {
      return;
    }
    _metricsSinkRegistered = true;
    _metricsSink.setMethodCallHandler((call) async {
      if (call.method != "onComputedMetrics") {
        return;
      }
      final raw = call.arguments;
      if (raw is! Map) {
        return;
      }
      final listingId = (raw["listingId"] as num?)?.toInt();
      final floorLong = (raw["floor_long_m"] as num?)?.toDouble();
      final floorShort = (raw["floor_short_m"] as num?)?.toDouble();
      final height = (raw["height_m"] as num?)?.toDouble();
      final area = (raw["floor_area_m2"] as num?)?.toDouble();
      if (listingId == null ||
          floorLong == null ||
          floorShort == null ||
          height == null ||
          area == null) {
        return;
      }
      try {
        await getIt<IListingService>().patchRoomScanMetricsIfMissing(
          listingId: listingId,
          metrics: RoomScanMetrics(
            floorLongM: floorLong,
            floorShortM: floorShort,
            heightM: height,
            floorAreaM2: area,
          ),
        );
      } catch (e, st) {
        logger.d("Room scan metrics backfill failed: $e\n$st");
      }
    });
  }

  static String _rgbHex6(Color color) {
    final v = color.toARGB32();
    return (v & 0xFFFFFF).toRadixString(16).padLeft(6, "0");
  }

  /// Returns true if the native viewer was presented.
  /// [languageCode] app language (`en`, `ru`, `uz`) — native UI uses [L10n] strings for that locale.
  ///
  /// When [publishMetricsIfMissing] is true (owner + listing still has no stored footprint), iOS
  /// sends computed bounds to Flutter once so the backend can backfill legacy scans.
  static Future<bool> downloadAndPresent(
    String absoluteUrl, {
    required int listingId,
    required String languageCode,
    bool publishMetricsIfMissing = false,
  }) async {
    if (!isIOSDevice) return false;
    if (publishMetricsIfMissing) {
      _ensureRoomScanMetricsSink();
    }
    final temp = await getTemporaryDirectory();
    final file = File("${temp.path}/uydosh_room_$listingId.usdz");
    final sessionToken = await SessionManager.getToken();
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 45),
        receiveTimeout: const Duration(minutes: 2),
        responseType: ResponseType.stream,
        headers: <String, dynamic>{
          if (sessionToken != null && sessionToken.trim().isNotEmpty)
            "Authorization":
                sessionToken.startsWith("Bearer ") ? sessionToken : "Bearer $sessionToken",
        },
      ),
    );
    try {
      await dio.download(absoluteUrl, file.path);
    } on DioException catch (e, st) {
      logger.d(
        "USDZ download failed (status=${e.response?.statusCode}): ${e.message}\n$st",
      );
      rethrow;
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
      "dimensionsLine1Template":
          L10n.getForLanguage("room_3d_dimensions_line1_template", languageCode),
      "dimensionsLine2Template":
          L10n.getForLanguage("room_3d_dimensions_line2_template", languageCode),
      "loadErrorTitle":
          L10n.getForLanguage("room_3d_load_error_title", languageCode),
      "alertOk": L10n.getForLanguage("ok", languageCode),
      "floorOnlyButton":
          L10n.getForLanguage("room_3d_floor_only_button", languageCode),
      "fullRoomButton":
          L10n.getForLanguage("room_3d_full_room_button", languageCode),
      "floorOnlyUnavailable":
          L10n.getForLanguage("room_3d_floor_only_unavailable", languageCode),
      "zoomIn": L10n.getForLanguage("room_3d_zoom_in", languageCode),
      "zoomOut": L10n.getForLanguage("room_3d_zoom_out", languageCode),
      "viewModeLabel":
          L10n.getForLanguage("room_3d_view_mode_label", languageCode),
      "viewModeHint":
          L10n.getForLanguage("room_3d_view_mode_hint", languageCode),
      "materialsStyleLabel":
          L10n.getForLanguage("room_3d_materials_style_label", languageCode),
      "materialsStyleHint":
          L10n.getForLanguage("room_3d_materials_style_hint", languageCode),
      "materialsStylizedValue":
          L10n.getForLanguage("room_3d_materials_style_value_stylized", languageCode),
      "materialsRealValue":
          L10n.getForLanguage("room_3d_materials_style_value_real", languageCode),
      "brandMarkA11yLabel":
          L10n.getForLanguage("app_name", languageCode, fallback: "UyDosh"),
      "onFloorTintRgb": _rgbHex6(AppColors.floorObject3dTint),
    };
    final ok = await _channel.invokeMethod<bool>("presentLocalFile", <String, dynamic>{
      "path": file.path,
      "strings": strings,
      "listingId": listingId,
      "publishMetricsIfMissing": publishMetricsIfMissing,
    });
    return ok ?? false;
  }
}
