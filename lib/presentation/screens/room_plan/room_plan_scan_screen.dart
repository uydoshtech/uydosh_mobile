import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_roomplan/flutter_roomplan.dart";
import "package:permission_handler/permission_handler.dart";
import "package:uy_dosh/base/config/client_lidar_room_scan_config.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/services/room_scan_bounds_service.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/ios_device.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/screens/permissions/camera_permission_gate.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/uydosh_link_button.dart";

// TEMP (for testing): render the 3D scan welcome UI even on web/Chrome.
// Scanning will still be disabled (Start button no-ops on non‑iOS).
const bool kForceShowRoomScanWelcomeUiOnWeb = true;

/// RoomPlan (LiDAR) capture → upload USDZ to [point_cloud_url] on the listing.
class RoomPlanScanScreen extends StatefulWidget {
  const RoomPlanScanScreen({required this.listingId, super.key});

  final int listingId;

  @override
  State<RoomPlanScanScreen> createState() => _RoomPlanScanScreenState();
}

class _RoomPlanScanScreenState extends State<RoomPlanScanScreen>
    with SingleTickerProviderStateMixin {
  final _roomPlan = FlutterRoomplan();
  static const MethodChannel _roomplanChannel = MethodChannel("rkg/flutter_roomplan");
  /// The RoomPlan plugin keeps the last capture-finished handler in a singleton; clear it on
  /// dispose so this [State] is not retained after leaving the screen.
  bool _registeredRoomCaptureCallback = false;
  bool _uploading = false;
  bool _starting = false;

  late final AnimationController _iconRotationController;
  late final Animation<double> _iconRotationAnimation;

  @override
  void dispose() {
    if (_registeredRoomCaptureCallback) {
      _roomPlan.onRoomCaptureFinished(() {});
    }
    _iconRotationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
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
          final metrics = await RoomScanBoundsService.computeFromUsdPath(path);
          await getIt<IListingService>().uploadRoomScan(
            listingId: widget.listingId,
            usdzFilePath: path,
            roomScanMetrics: metrics,
          );
          if (!mounted) return;
          ToastTheme.showSuccess(
            context,
            message: L10n.get("room_scan_success"),
          );
          Navigator.of(context).pop(true);
        } catch (e, st) {
          logger.e("Room scan upload failed", error: e, stackTrace: st);
          if (!mounted) return;
          final msg = e.toString();
          final isTooLarge =
              msg.contains("File too large") || msg.contains("413") || msg.contains("Payload Too Large");
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
    setState(() => _starting = true);
    try {
      // NOTE: We intentionally do NOT call NativeLanguageService here. iOS
      // frameworks (RoomPlan, ARKit) cache localized strings at process start,
      // so writing `AppleLanguages` mid-session has no effect on the coaching
      // overlay shown during this scan. The language is applied at app launch
      // in AppDelegate (reading the in-app language from shared_preferences),
      // and persisted on every in-app language change via
      // `LanguageState.setLanguage` for the *next* launch.
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
        "enableMultiRoom": false,
        "strings": <String, String>{
          "cancel": L10n.get("cancel"),
          "done": L10n.get("done"),
          "finish": L10n.get("room_scan_finish"),
          "scanOtherRooms": L10n.get("room_scan_scan_other_rooms"),
        },
      });
    } on MissingPluginException catch (e, st) {
      logger.e("Room scan plugin missing", error: e, stackTrace: st);
      if (!mounted) return;
      ToastTheme.showError(
        context,
        message: L10n.get("room_scan_error"),
      );
    } on PlatformException catch (e, st) {
      logger.e("Room scan platform error", error: e, stackTrace: st);
      if (!mounted) return;
      ToastTheme.showError(
        context,
        message: L10n.get("room_scan_error"),
      );
    } catch (e, st) {
      logger.e("Room scan start failed", error: e, stackTrace: st);
      if (!mounted) return;
      ToastTheme.showError(
        context,
        message: L10n.get("room_scan_error"),
      );
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
                if (_uploading)
                  Column(
                    children: [
                      const CircularProgressIndicator(),
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
