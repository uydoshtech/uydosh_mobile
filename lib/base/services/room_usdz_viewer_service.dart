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
  static const MethodChannel _northCorrectionSink =
      MethodChannel("uydosh/room_scan_north_correction_sink");

  static bool _metricsSinkRegistered = false;
  static bool _northCorrectionSinkRegistered = false;
  static bool _presentInFlight = false;

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

  static void _ensureRoomScanNorthCorrectionSink() {
    if (_northCorrectionSinkRegistered) {
      return;
    }
    _northCorrectionSinkRegistered = true;
    _northCorrectionSink.setMethodCallHandler((call) async {
      if (call.method != "onNorthCorrectionChanged") {
        return;
      }
      final raw = call.arguments;
      if (raw is! Map) {
        return;
      }
      final listingId = (raw["listingId"] as num?)?.toInt();
      if (listingId == null) {
        return;
      }
      final rawCorrection = raw["north_correction_deg"];
      final double? northCorrectionDeg;
      if (rawCorrection == null) {
        northCorrectionDeg = null;
      } else if (rawCorrection is num) {
        northCorrectionDeg = rawCorrection.toDouble();
      } else {
        return;
      }
      try {
        await getIt<IListingService>().patchRoomScanNorthCorrection(
          listingId: listingId,
          northCorrectionDeg: northCorrectionDeg,
        );
      } catch (e, st) {
        logger.d("Room scan north correction save failed: $e\n$st");
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
    double? worldPlusXBearingDeg,
    double? northCorrectionDeg,
    bool isListingOwner = false,
  }) async {
    if (!isIOSDevice) return false;
    if (_presentInFlight) return false;
    _presentInFlight = true;
    try {
      return await _downloadAndPresentImpl(
        absoluteUrl,
        listingId: listingId,
        languageCode: languageCode,
        publishMetricsIfMissing: publishMetricsIfMissing,
        worldPlusXBearingDeg: worldPlusXBearingDeg,
        northCorrectionDeg: northCorrectionDeg,
        isListingOwner: isListingOwner,
      );
    } finally {
      _presentInFlight = false;
    }
  }

  /// Downloads USDZ to the per-listing temp cache. Returns null on non-iOS.
  static Future<File?> downloadUsdToCache(
    String absoluteUrl, {
    required int listingId,
  }) async {
    if (!isIOSDevice) return null;
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
    return file;
  }

  static Future<bool> _downloadAndPresentImpl(
    String absoluteUrl, {
    required int listingId,
    required String languageCode,
    required bool publishMetricsIfMissing,
    double? worldPlusXBearingDeg,
    double? northCorrectionDeg,
    bool isListingOwner = false,
  }) async {
    if (publishMetricsIfMissing) {
      _ensureRoomScanMetricsSink();
    }
    if (isListingOwner) {
      _ensureRoomScanNorthCorrectionSink();
    }
    final file = await downloadUsdToCache(
      absoluteUrl,
      listingId: listingId,
    );
    if (file == null) return false;
    final strings = <String, String>{
      "title": L10n.getForLanguage("room_3d_viewer_title", languageCode),
      "dimensionsCaption":
          L10n.getForLanguage("room_3d_dimensions_caption", languageCode),
      "dimensionsLine1Template":
          L10n.getForLanguage("room_3d_dimensions_line1_template", languageCode),
      "dimensionsHeightTemplate":
          L10n.getForLanguage("room_3d_dimensions_height_template", languageCode),
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
      "tab3DView": L10n.getForLanguage("room_3d_tab_view_3d", languageCode),
      "tabFloorPlan": L10n.getForLanguage("room_3d_tab_floor_plan", languageCode),
      "floorPlanReset": L10n.getForLanguage("room_3d_floor_plan_reset", languageCode),
      "floorPlanDimensionsOverall":
          L10n.getForLanguage("room_3d_floor_plan_dimensions_overall", languageCode),
      "floorPlanDimensionsWalls":
          L10n.getForLanguage("room_3d_floor_plan_dimensions_walls", languageCode),
      "floorPlanDimensionsHide":
          L10n.getForLanguage("room_3d_floor_plan_dimensions_hide", languageCode),
      "floorPlanShowObjects":
          L10n.getForLanguage("room_3d_floor_plan_show_objects", languageCode),
      "floorPlanHideObjects":
          L10n.getForLanguage("room_3d_floor_plan_hide_objects", languageCode),
      "floorPlanShowGrid": L10n.getForLanguage("room_3d_floor_plan_show_grid", languageCode),
      "floorPlanHideGrid": L10n.getForLanguage("room_3d_floor_plan_hide_grid", languageCode),
      "floorPlanAutoAlignOn":
          L10n.getForLanguage("room_3d_floor_plan_auto_align_on", languageCode),
      "floorPlanAutoAlignOff":
          L10n.getForLanguage("room_3d_floor_plan_auto_align_off", languageCode),
      "floorPlanAdjustNorth":
          L10n.getForLanguage("room_3d_floor_plan_adjust_north", languageCode),
      "floorPlanAdjustNorthTitle":
          L10n.getForLanguage("room_3d_floor_plan_adjust_north_title", languageCode),
      "floorPlanAdjustNorthMessage":
          L10n.getForLanguage("room_3d_floor_plan_adjust_north_message", languageCode),
      "floorPlanAdjustNorthReset":
          L10n.getForLanguage("room_3d_floor_plan_adjust_north_reset", languageCode),
      "floorPlanAdjustNorthUpdated":
          L10n.getForLanguage("room_3d_floor_plan_adjust_north_updated", languageCode),
      "floorPlanAdjustNorthDegreesFormat":
          L10n.getForLanguage("room_3d_floor_plan_adjust_north_degrees_format", languageCode),
      "floorPlanEditDimensionTitle":
          L10n.getForLanguage("room_3d_floor_plan_edit_dimension_title", languageCode),
      "floorPlanEditDimensionCurrent":
          L10n.getForLanguage("room_3d_floor_plan_edit_dimension_current", languageCode),
      "floorPlanEditDimensionNewValue":
          L10n.getForLanguage("room_3d_floor_plan_edit_dimension_new_value", languageCode),
      "floorPlanEditDimensionCancel":
          L10n.getForLanguage("room_3d_floor_plan_edit_dimension_cancel", languageCode),
      "floorPlanEditDimensionApply":
          L10n.getForLanguage("room_3d_floor_plan_edit_dimension_apply", languageCode),
      "floorPlanEditDimensionUpdated":
          L10n.getForLanguage("room_3d_floor_plan_edit_dimension_updated", languageCode),
      "floorPlanEditDimensionLargeChangeTitle":
          L10n.getForLanguage("room_3d_floor_plan_edit_dimension_large_change_title", languageCode),
      "floorPlanEditDimensionLargeChangeMessage":
          L10n.getForLanguage("room_3d_floor_plan_edit_dimension_large_change_message", languageCode),
      "floorPlanEditDimensionInvalidTitle":
          L10n.getForLanguage("room_3d_floor_plan_edit_dimension_invalid_title", languageCode),
      "floorPlanEditDimensionInvalidMessage":
          L10n.getForLanguage("room_3d_floor_plan_edit_dimension_invalid_message", languageCode),
      "floorPlanEditDimensionConfirmLargeChange":
          L10n.getForLanguage("room_3d_floor_plan_edit_dimension_confirm_large_change", languageCode),
      "floorPlanUnitMeters":
          L10n.getForLanguage("room_3d_floor_plan_unit_meters", languageCode),
      "sunToggleLabel":
          L10n.getForLanguage("room_3d_sun_toggle_label", languageCode),
      "sunToggleHint":
          L10n.getForLanguage("room_3d_sun_toggle_hint", languageCode),
      "sunAzimuthLabel":
          L10n.getForLanguage("room_3d_sun_azimuth_label", languageCode),
      "sunElevationLabel":
          L10n.getForLanguage("room_3d_sun_elevation_label", languageCode),
      "sunIntensityLabel":
          L10n.getForLanguage("room_3d_sun_intensity_label", languageCode),
      "sunPresetMorning":
          L10n.getForLanguage("room_3d_sun_preset_morning", languageCode),
      "sunPresetNoon":
          L10n.getForLanguage("room_3d_sun_preset_noon", languageCode),
      "sunPresetEvening":
          L10n.getForLanguage("room_3d_sun_preset_evening", languageCode),
      "sunAzimuthFormat":
          L10n.getForLanguage("room_3d_sun_azimuth_format", languageCode),
      "sunElevationFormat":
          L10n.getForLanguage("room_3d_sun_elevation_format", languageCode),
    };
    final ok = await _channel.invokeMethod<bool>("presentLocalFile", <String, dynamic>{
      "path": file.path,
      "strings": strings,
      "listingId": listingId,
      "publishMetricsIfMissing": publishMetricsIfMissing,
      "isListingOwner": isListingOwner,
      if (worldPlusXBearingDeg != null) "worldPlusXBearingDeg": worldPlusXBearingDeg,
      if (northCorrectionDeg != null) "northCorrectionDeg": northCorrectionDeg,
    });
    return ok ?? false;
  }
}
