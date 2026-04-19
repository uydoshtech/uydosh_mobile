import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_roomplan/flutter_roomplan.dart";
import "package:uy_dosh/base/config/client_lidar_room_scan_config.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/ios_device.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
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
  bool _uploading = false;
  bool _starting = false;

  late final AnimationController _iconRotationController;
  late final Animation<double> _iconRotationAnimation;

  @override
  void dispose() {
    _iconRotationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _iconRotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    _iconRotationAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _iconRotationController, curve: Curves.linear),
    );

    if (!isIOSDevice) return;
    if (ClientLidarRoomScanConfig.lidarRoomScanDisabled.value) return;
    _roomPlan.onRoomCaptureFinished(() {
      Future<void> run() async {
        final path = await _roomPlan.getUsdzFilePath();
        if (!mounted || path == null || path.isEmpty) {
          if (mounted) {
            ToastTheme.showError(
              context,
              message: L10n.get("room_scan_error"),
            );
          }
          return;
        }
        setState(() => _uploading = true);
        try {
          await getIt<IListingService>().uploadRoomScan(
            listingId: widget.listingId,
            usdzFilePath: path,
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
                ? "3D scan is too large to upload. Please try scanning a smaller area."
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
      final supported = await _roomPlan.isSupported();
      if (!supported) {
        if (!mounted) return;
        ToastTheme.showError(
          context,
          message: L10n.get("room_scan_not_supported"),
        );
        return;
      }
      await _roomPlan.startScan();
    } on MissingPluginException catch (e, st) {
      logger.e("Room scan plugin missing", error: e, stackTrace: st);
      if (!mounted) return;
      ToastTheme.showError(
        context,
        message: "Room scan is unavailable (iOS plugin not initialized).",
      );
    } on PlatformException catch (e, st) {
      logger.e("Room scan platform error", error: e, stackTrace: st);
      if (!mounted) return;
      ToastTheme.showError(
        context,
        message: "Room scan failed: ${e.code}",
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
