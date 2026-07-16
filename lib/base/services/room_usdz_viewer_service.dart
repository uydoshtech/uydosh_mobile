import "dart:io";
import "dart:ui";

import "package:dio/dio.dart";
import "package:path_provider/path_provider.dart";
import "package:room_scan_kit/room_scan_kit.dart" as kit;
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/utils/ios_device.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/domain/services/listing_service_common.dart";

/// iOS: download USDZ then present custom SceneKit viewer via `room_scan_kit`.
class RoomUsdzViewerService {
  RoomUsdzViewerService._();

  static bool _presentInFlight = false;
  static bool _listingSinksWired = false;

  static void _ensureListingSinks() {
    if (_listingSinksWired) return;
    _listingSinksWired = true;
    kit.RoomUsdzViewer.onComputedMetrics = (listingId, metrics) async {
      try {
        await getIt<IListingService>().patchRoomScanMetricsIfMissing(
          listingId: listingId,
          metrics: RoomScanMetrics(
            floorLongM: metrics.floorLongM,
            floorShortM: metrics.floorShortM,
            heightM: metrics.heightM,
            floorAreaM2: metrics.floorAreaM2,
            worldPlusXBearingDeg: metrics.worldPlusXBearingDeg,
          ),
        );
      } catch (e, st) {
        logger.d("Room scan metrics backfill failed: $e\n$st");
      }
    };
    kit.RoomUsdzViewer.onNorthCorrectionChanged =
        (listingId, northCorrectionDeg) async {
      try {
        await getIt<IListingService>().patchRoomScanNorthCorrection(
          listingId: listingId,
          northCorrectionDeg: northCorrectionDeg,
        );
      } catch (e, st) {
        logger.d("Room scan north correction save failed: $e\n$st");
      }
    };
    kit.RoomUsdzViewer.onFurnitureEditsChanged =
        (listingId, furnitureEdits) async {
      try {
        await getIt<IListingService>().patchRoomScanFurnitureEdits(
          listingId: listingId,
          furnitureEdits: furnitureEdits,
        );
      } catch (e, st) {
        logger.d("Room scan furniture edits save failed: $e\n$st");
      }
    };
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
    Map<String, dynamic>? furnitureEdits,
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
        furnitureEdits: furnitureEdits,
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
    Map<String, dynamic>? furnitureEdits,
  }) async {
    if (publishMetricsIfMissing || isListingOwner) {
      _ensureListingSinks();
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
      "floorPlanRotateFurnitureTitle":
          L10n.getForLanguage("room_3d_floor_plan_rotate_furniture_title", languageCode),
      "floorPlanRotateFurnitureMessage":
          L10n.getForLanguage("room_3d_floor_plan_rotate_furniture_message", languageCode),
      "floorPlanRotateFurnitureUpdated":
          L10n.getForLanguage("room_3d_floor_plan_rotate_furniture_updated", languageCode),
      "floorPlanRotateFurnitureDegreesFormat":
          L10n.getForLanguage("room_3d_floor_plan_rotate_furniture_degrees_format", languageCode),
      "floorPlanMoveFurnitureUp":
          L10n.getForLanguage("room_3d_floor_plan_move_furniture_up", languageCode),
      "floorPlanMoveFurnitureDown":
          L10n.getForLanguage("room_3d_floor_plan_move_furniture_down", languageCode),
      "floorPlanMoveFurnitureLeft":
          L10n.getForLanguage("room_3d_floor_plan_move_furniture_left", languageCode),
      "floorPlanMoveFurnitureRight":
          L10n.getForLanguage("room_3d_floor_plan_move_furniture_right", languageCode),
      "floorPlanFurnitureVariantTitle":
          L10n.getForLanguage("room_3d_floor_plan_furniture_variant_title", languageCode),
      "floorPlanFurnitureVariantAccessibility": L10n.getForLanguage(
          "room_3d_floor_plan_furniture_variant_accessibility", languageCode),
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
      "floorPlanObjectBed":
          L10n.getForLanguage("room_3d_floor_plan_object_bed", languageCode),
      "floorPlanObjectSofa":
          L10n.getForLanguage("room_3d_floor_plan_object_sofa", languageCode),
      "floorPlanObjectTable":
          L10n.getForLanguage("room_3d_floor_plan_object_table", languageCode),
      "floorPlanObjectChair":
          L10n.getForLanguage("room_3d_floor_plan_object_chair", languageCode),
      "floorPlanObjectStorage":
          L10n.getForLanguage("room_3d_floor_plan_object_storage", languageCode),
      "floorPlanObjectAppliance":
          L10n.getForLanguage("room_3d_floor_plan_object_appliance", languageCode),
      "floorPlanObjectCabinet":
          L10n.getForLanguage("room_3d_floor_plan_object_cabinet", languageCode),
      "floorPlanObjectTelevision":
          L10n.getForLanguage("room_3d_floor_plan_object_television", languageCode),
      "floorPlanObjectFixture":
          L10n.getForLanguage("room_3d_floor_plan_object_fixture", languageCode),
      "floorPlanObjectUnknown":
          L10n.getForLanguage("room_3d_floor_plan_object_unknown", languageCode),
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
    return kit.RoomUsdzViewer.presentLocalFile(
      path: file.path,
      strings: strings,
      listingId: listingId,
      publishMetricsIfMissing: publishMetricsIfMissing,
      isListingOwner: isListingOwner,
      worldPlusXBearingDeg: worldPlusXBearingDeg,
      northCorrectionDeg: northCorrectionDeg,
      furnitureEdits: furnitureEdits,
    );
  }
}
