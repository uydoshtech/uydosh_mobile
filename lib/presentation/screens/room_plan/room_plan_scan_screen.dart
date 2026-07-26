import "dart:async";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_roomplan/flutter_roomplan.dart";
import "package:permission_handler/permission_handler.dart";
import "package:room_scan_kit/scan_flow/scan_flow.dart";
import "package:room_scan_kit/photogrammetry_upload.dart";
import "package:uy_dosh/base/config/client_lidar_room_scan_config.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/scan_flow/uydosh_scan_entry.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/services/native_language_service.dart";
import "package:uy_dosh/base/services/room_plan_capability.dart";
import "package:uy_dosh/base/services/room_scan_bounds_service.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/ios_device.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/screens/permissions/camera_permission_gate.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_logo_spinner.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/uydosh_link_button.dart";

// TEMP (for testing): render the 3D scan welcome UI even on web/Chrome.
// Scanning will still be disabled (Start button no-ops on non‑iOS).
const bool kForceShowRoomScanWelcomeUiOnWeb = true;

/// RoomPlan (LiDAR) capture → upload USDZ to [point_cloud_url] on the listing.
///
/// Product: [ProductContext.uydosh] — entire housing only; no mode selection.
class RoomPlanScanScreen extends StatefulWidget {
  const RoomPlanScanScreen({
    required this.listingId,
    this.scanEntry = kUydoshScanEntry,
    super.key,
  });

  final int listingId;

  /// Explicit product dependency — never inferred from UI or bundle name.
  final ScanEntryConfiguration scanEntry;

  @override
  State<RoomPlanScanScreen> createState() => _RoomPlanScanScreenState();
}

class _RoomPlanScanScreenState extends State<RoomPlanScanScreen>
    with SingleTickerProviderStateMixin {
  final _roomPlan = FlutterRoomplan();
  static const MethodChannel _roomplanChannel = MethodChannel(
    "rkg/flutter_roomplan",
  );

  /// The RoomPlan plugin keeps the last capture-finished handler in a singleton; clear it on
  /// dispose so this [State] is not retained after leaving the screen.
  bool _registeredRoomCaptureCallback = false;
  bool _uploading = false;
  bool _starting = false;
  PhotogrammetryUploadProgress? _photogrammetryProgress;
  bool _standardUploadComplete = false;
  bool _photogrammetryFinished = false;
  bool _photogrammetryEnabled = false;

  /// Null until [RoomPlanCapability.isSupportedOnDevice] resolves on iOS; unused on web.
  bool? _roomPlanSupported;

  late final AnimationController _iconRotationController;
  late final Animation<double> _iconRotationAnimation;

  @override
  void dispose() {
    if (_registeredRoomCaptureCallback) {
      _roomPlan.onRoomCaptureFinished(() {});
    }
    _iconRotationController.dispose();
    PhotogrammetryUpload.instance.stopListening();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    assert(
      !ScanModePolicy.shouldShowModeSelection(
        product: widget.scanEntry.product,
      ),
      "UyDosh must not show scan-mode selection",
    );
    getIt<AppAnalyticsService>().logScreenView(screenName: "room_plan_scan");

    // 6-second attention burst (2 full rotations), then static. Previously
    // this rotated forever for the entire lifetime of the welcome screen,
    // burning CPU/GPU continuously even though the rotation is purely
    // decorative — the user understands the affordance after one or two
    // turns.
    _iconRotationController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..forward();
    _iconRotationAnimation = Tween<double>(begin: 0.0, end: 2.0).animate(
      CurvedAnimation(parent: _iconRotationController, curve: Curves.linear),
    );

    if (!isIOSDevice) return;
    if (ClientLidarRoomScanConfig.lidarRoomScanDisabled.value) return;
    PhotogrammetryUpload.instance.listen(_uploadPhotogrammetryPackage);
    unawaited(
      PhotogrammetryPreference.load().then((value) {
        if (mounted) setState(() => _photogrammetryEnabled = value);
      }),
    );
    unawaited(
      PhotogrammetryUpload.instance.resumePendingMonitors(
        apiBaseUrl: EnvironmentUtil.basePath,
      ),
    );
    unawaited(_resolveSupportAndRegisterCapture());
  }

  Future<void> _uploadPhotogrammetryPackage(String path) async {
    try {
      await PhotogrammetryUpload.instance.submit(
        packagePath: path,
        apiBaseUrl: EnvironmentUtil.basePath,
        onProgress: (progress) {
          if (mounted) setState(() => _photogrammetryProgress = progress);
        },
      );
    } catch (error, stack) {
      logger.d("Photogrammetry upload failed: $error\n$stack");
    } finally {
      _photogrammetryFinished = true;
      if (mounted && _standardUploadComplete) Navigator.of(context).pop(true);
    }
  }

  Future<void> _resolveSupportAndRegisterCapture() async {
    final supported = await RoomPlanCapability.isSupportedOnDevice();
    if (!mounted) return;
    setState(() => _roomPlanSupported = supported);
    if (!supported) return;
    _registerRoomCaptureCallback();
  }

  void _registerRoomCaptureCallback() {
    if (_registeredRoomCaptureCallback) return;
    _registeredRoomCaptureCallback = true;
    _roomPlan.onRoomCaptureFinished(() {
      Future<void> run() async {
        final path = await _roomPlan.getUsdzFilePath();
        if (!mounted) return;
        if (path == null || path.isEmpty) {
          // RoomPlan invokes onRoomCaptureFinished on Cancel too, with no
          // USDZ. Treat that as "user backed out" — surface a friendly info
          // toast instead of a scary error.
          ToastTheme.showInfo(
            context,
            message: L10n.get("room_scan_cancelled"),
          );
          return;
        }
        setState(() => _uploading = true);
        try {
          var metrics = await RoomScanBoundsService.computeFromUsdPath(path);
          await getIt<IListingService>().uploadRoomScan(
            listingId: widget.listingId,
            usdzFilePath: path,
            roomScanMetrics: metrics,
          );
          // RoomPlan may finish writing the USDZ slightly after the callback; backfill if
          // the first compute failed but upload succeeded.
          if (metrics == null) {
            metrics = await RoomScanBoundsService.computeFromUsdPath(path);
          }
          if (metrics != null) {
            try {
              await getIt<IListingService>().patchRoomScanMetricsIfMissing(
                listingId: widget.listingId,
                metrics: metrics,
              );
            } catch (e, st) {
              logger.d(
                "Room scan metrics backfill after upload failed: $e\n$st",
              );
            }
          }
          if (!mounted) return;
          ToastTheme.showSuccess(
            context,
            message: L10n.get("room_scan_success"),
          );
          _standardUploadComplete = true;
          if (_photogrammetryFinished) Navigator.of(context).pop(true);
        } catch (e, st) {
          logger.e("Room scan upload failed", error: e, stackTrace: st);
          if (!mounted) return;
          final msg = e.toString();
          final isTooLarge =
              msg.contains("File too large") ||
              msg.contains("413") ||
              msg.contains("Payload Too Large");
          ToastTheme.showError(
            context,
            message: isTooLarge
                ? L10n.get("room_scan_too_large")
                : L10n.get("room_scan_error"),
          );
        } finally {
          if (mounted) setState(() => _uploading = false);
        }
      }

      run();
    });
  }

  Future<void> _startScan() async {
    if (!isIOSDevice) return;
    setState(() {
      _starting = true;
      _standardUploadComplete = false;
      _photogrammetryFinished = !_photogrammetryEnabled;
      _photogrammetryProgress = null;
    });
    try {
      // Best-effort: re-apply `AppleLanguages` right before touching RoomPlan.
      // This mid-session write is NOT guaranteed to affect the coaching
      // overlay — iOS frameworks may have already cached their own bundle's
      // localized strings earlier this process — but if this is the first
      // RoomPlan/ARKit access in the session, it can still take effect. Either
      // way, `LanguageState.setLanguage` / the app-launch read in AppDelegate
      // guarantee it's correct from the *next* cold launch onward.
      await NativeLanguageService.setPreferredLanguage(
        LanguageState().currentLanguage,
      );

      final supported = await _roomPlan.isSupported();
      if (!supported) {
        if (!mounted) return;
        ToastTheme.showError(
          context,
          message: L10n.get("room_scan_not_supported"),
        );
        return;
      }
      // Rationale first (see [CameraPermissionGate]). That gate does not
      // call `Permission.camera.request()` — listing photos rely on the camera
      // plugin instead. RoomPlan only touches the camera inside native
      // `startScan`, which used to surface the iOS sheet on top of the black
      // capture UI. Request here so the system dialog appears over this
      // Flutter screen instead.
      final rationaleOk = await CameraPermissionGate.ensure(
        context,
        purpose: CameraPermissionPurpose.roomPlan3dScan,
      );
      if (!rationaleOk || !mounted) return;

      final camStatus = await Permission.camera.request();
      if (!camStatus.isGranted) {
        if (!mounted) return;
        ToastTheme.showInfo(
          context,
          message: L10n.get("room_scan_camera_required"),
        );
        return;
      }
      if (!mounted) return;

      await _roomplanChannel.invokeMethod<void>("startScan", <String, dynamic>{
        // Single-room only — hides the secondary "Scan Other Rooms" button.
        "enableMultiRoom": false,
        "enablePhotogrammetry": _photogrammetryEnabled,
        "strings": <String, String>{
          "cancel": L10n.get("cancel"),
          "done": L10n.get("done"),
          "finish": L10n.get("room_scan_finish"),
          // Live detection HUD (native RoomCapture overlay).
          "roomplan_stats_walls": L10n.get("room_scan_stats_walls"),
          "roomplan_stats_doors": L10n.get("room_scan_stats_doors"),
          "roomplan_stats_windows": L10n.get("room_scan_stats_windows"),
          "roomplan_stats_objects": L10n.get("room_scan_stats_objects"),
          "roomplan_compass": L10n.get("room_scan_compass"),
          "roomplan_stats_television": L10n.get("room_scan_stats_television"),
          "roomplan_stats_storage": L10n.get("room_scan_stats_storage"),
          "roomplan_stats_cabinet": L10n.get("room_scan_stats_cabinet"),
          "roomplan_stats_sofa": L10n.get("room_scan_stats_sofa"),
          "roomplan_stats_bed": L10n.get("room_scan_stats_bed"),
          "roomplan_stats_table": L10n.get("room_scan_stats_table"),
          "roomplan_stats_chair": L10n.get("room_scan_stats_chair"),
          "roomplan_stats_refrigerator": L10n.get(
            "room_scan_stats_refrigerator",
          ),
          "roomplan_stats_sink": L10n.get("room_scan_stats_sink"),
          "roomplan_stats_toilet": L10n.get("room_scan_stats_toilet"),
          "roomplan_stats_bathtub": L10n.get("room_scan_stats_bathtub"),
          "roomplan_stats_oven": L10n.get("room_scan_stats_oven"),
          "roomplan_stats_stove": L10n.get("room_scan_stats_stove"),
          "roomplan_stats_dishwasher": L10n.get("room_scan_stats_dishwasher"),
          "roomplan_stats_washer_dryer": L10n.get(
            "room_scan_stats_washer_dryer",
          ),
          "roomplan_stats_fireplace": L10n.get("room_scan_stats_fireplace"),
          "roomplan_stats_stairs": L10n.get("room_scan_stats_stairs"),
          "roomplan_stats_object": L10n.get("room_scan_stats_object"),
          "roomplan_detected_wall": L10n.get("room_scan_detected_wall"),
          "roomplan_detected_door": L10n.get("room_scan_detected_door"),
          "roomplan_detected_window": L10n.get("room_scan_detected_window"),
          "roomplan_detected_storage": L10n.get("room_scan_detected_storage"),
          "roomplan_detected_cabinet": L10n.get("room_scan_detected_cabinet"),
          "roomplan_detected_bed": L10n.get("room_scan_detected_bed"),
          "roomplan_detected_sofa": L10n.get("room_scan_detected_sofa"),
          "roomplan_detected_table": L10n.get("room_scan_detected_table"),
          "roomplan_detected_chair": L10n.get("room_scan_detected_chair"),
          "roomplan_detected_television": L10n.get(
            "room_scan_detected_television",
          ),
          "roomplan_detected_refrigerator": L10n.get(
            "room_scan_detected_refrigerator",
          ),
          "roomplan_detected_sink": L10n.get("room_scan_detected_sink"),
          "roomplan_detected_toilet": L10n.get("room_scan_detected_toilet"),
          "roomplan_detected_bathtub": L10n.get("room_scan_detected_bathtub"),
          "roomplan_detected_oven": L10n.get("room_scan_detected_oven"),
          "roomplan_detected_stove": L10n.get("room_scan_detected_stove"),
          "roomplan_detected_dishwasher": L10n.get(
            "room_scan_detected_dishwasher",
          ),
          "roomplan_detected_washer_dryer": L10n.get(
            "room_scan_detected_washer_dryer",
          ),
          "roomplan_detected_fireplace": L10n.get(
            "room_scan_detected_fireplace",
          ),
          "roomplan_detected_stairs": L10n.get("room_scan_detected_stairs"),
          "roomplan_detected_object": L10n.get("room_scan_detected_object"),
          // Post-scan results card (grey model screen).
          "roomplan_results_perimeter": L10n.get("room_scan_results_perimeter"),
          "roomplan_results_floor_area": L10n.get(
            "room_scan_results_floor_area",
          ),
          "roomplan_results_wall_area": L10n.get("room_scan_results_wall_area"),
          "roomplan_results_windows": L10n.get("room_scan_results_windows"),
          "roomplan_results_doors": L10n.get("room_scan_results_doors"),
          "roomplan_results_height": L10n.get("room_scan_results_height"),
        },
      });
    } on MissingPluginException catch (e, st) {
      logger.e("Room scan plugin missing", error: e, stackTrace: st);
      if (!mounted) return;
      ToastTheme.showError(context, message: L10n.get("room_scan_error"));
    } on PlatformException catch (e, st) {
      logger.e("Room scan platform error", error: e, stackTrace: st);
      if (!mounted) return;
      ToastTheme.showError(context, message: L10n.get("room_scan_error"));
    } catch (e, st) {
      logger.e("Room scan start failed", error: e, stackTrace: st);
      if (!mounted) return;
      ToastTheme.showError(context, message: L10n.get("room_scan_error"));
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  Color _get3dIconColor(BuildContext context) {
    final themeState = ThemeState();
    return themeState.isBlueTheme
        ? BlueThemeColors.textPrimary
        : Theme.of(context).colorScheme.primary;
  }

  Widget _buildRotating3dIcon(BuildContext context) {
    final iconColor = _get3dIconColor(context);

    return Semantics(
      label: L10n.get("room_scan_title"),
      child: AnimatedBuilder(
        animation: _iconRotationAnimation,
        builder: (context, child) {
          return Transform.rotate(
            angle: _iconRotationAnimation.value * 2 * 3.14159,
            child: child,
          );
        },
        child: Icon(
          Icons.view_in_ar,
          size: 190,
          color: iconColor.withValues(alpha: 0.92),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ClientLidarRoomScanConfig.lidarRoomScanDisabled,
      builder: (context, lidarDisabled, _) {
        if (!isIOSDevice && !kForceShowRoomScanWelcomeUiOnWeb) {
          return Scaffold(
            appBar: UydoshAppBar(
              leading: ThreeDAppBarIconButton.backLeading(context),
              title: Text(L10n.get("room_scan_title")),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  L10n.get("room_scan_not_supported"),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        if (lidarDisabled) {
          return Scaffold(
            appBar: UydoshAppBar(
              leading: ThreeDAppBarIconButton.backLeading(context),
              title: Text(L10n.get("room_scan_title")),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  L10n.get("room_scan_disabled_globally"),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        if (isIOSDevice) {
          if (_roomPlanSupported == null) {
            return Scaffold(
              appBar: UydoshAppBar(
                leading: ThreeDAppBarIconButton.backLeading(context),
                title: Text(L10n.get("room_scan_title")),
              ),
              body: const Center(child: UydoshLogoSpinner()),
            );
          }
          if (_roomPlanSupported == false) {
            return Scaffold(
              appBar: UydoshAppBar(
                leading: ThreeDAppBarIconButton.backLeading(context),
                title: Text(L10n.get("room_scan_title")),
              ),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    L10n.get("room_scan_not_supported"),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            );
          }
        }

        final loading = _uploading || _starting;

        return Scaffold(
          appBar: UydoshAppBar(
            leading: ThreeDAppBarIconButton.backLeading(context),
            title: Text(L10n.get("room_scan_title")),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  L10n.get("room_scan_instructions"),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (!_uploading) ...[
                  const SizedBox(height: 28),
                  Center(child: _buildRotating3dIcon(context)),
                  const SizedBox(height: 28),
                ],
                const SizedBox(height: 24),
                SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Photogrammetry"),
                  subtitle: const Text(
                    "Create a textured 3D model after scanning",
                  ),
                  value: _photogrammetryEnabled,
                  onChanged: loading
                      ? null
                      : (value) {
                          setState(() => _photogrammetryEnabled = value);
                          unawaited(PhotogrammetryPreference.save(value));
                        },
                ),
                if (_photogrammetryProgress case final progress?) ...[
                  LinearProgressIndicator(
                    value: progress.phase == PhotogrammetryUploadPhase.uploading
                        ? progress.fraction
                        : progress.phase == PhotogrammetryUploadPhase.complete
                        ? 1
                        : null,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    progress.phase == PhotogrammetryUploadPhase.complete
                        ? L10n.get("room_scan_success")
                        : progress.phase == PhotogrammetryUploadPhase.failed
                        ? L10n.get("room_scan_error")
                        : L10n.get("room_scan_uploading"),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                ],
                if (_uploading)
                  Column(
                    children: [
                      const UydoshLogoSpinner(),
                      const SizedBox(height: 16),
                      Text(L10n.get("room_scan_uploading")),
                    ],
                  )
                else ...[
                  Center(
                    child: UydoshLinkButton(
                      text: L10n.get("skip"),
                      onPressed: () => Navigator.of(context).pop(false),
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButtonFactory.iconText(
                    onPressed: loading ? null : _startScan,
                    isLoading: _starting,
                    isDisabled: loading,
                    icon: Icons.view_in_ar,
                    iconSize: 18,
                    text: L10n.get("room_scan_start"),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
