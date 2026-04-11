import "package:flutter/material.dart";
import "package:flutter_roomplan/flutter_roomplan.dart";
import "package:smooth_page_indicator/smooth_page_indicator.dart";
import "package:uy_dosh/base/config/client_lidar_room_scan_config.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/utils/ios_device.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";

const _kRoomScanExampleAssets = <String>[
  "assets/images/room_scan_examples/example_1.png",
  "assets/images/room_scan_examples/example_2.png",
  "assets/images/room_scan_examples/example_3.png",
];

/// RoomPlan (LiDAR) capture → upload USDZ to [point_cloud_url] on the listing.
class RoomPlanScanScreen extends StatefulWidget {
  const RoomPlanScanScreen({required this.listingId, super.key});

  final int listingId;

  @override
  State<RoomPlanScanScreen> createState() => _RoomPlanScanScreenState();
}

class _RoomPlanScanScreenState extends State<RoomPlanScanScreen> {
  final _roomPlan = FlutterRoomplan();
  final PageController _examplePageController = PageController();
  bool _uploading = false;
  bool _starting = false;

  @override
  void dispose() {
    _examplePageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: ClientLidarRoomScanConfig.lidarRoomScanDisabled,
      builder: (context, lidarDisabled, _) {
        if (!isIOSDevice) {
          return Scaffold(
            appBar: AppBar(
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
            appBar: AppBar(
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

        final colorScheme = Theme.of(context).colorScheme;

        return Scaffold(
          appBar: AppBar(
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
                  const SizedBox(height: 20),
                  Text(
                    L10n.get("room_scan_examples_label"),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Semantics(
                    label: L10n.get("room_scan_examples_label"),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: PageView.builder(
                          controller: _examplePageController,
                          itemCount: _kRoomScanExampleAssets.length,
                          itemBuilder: (context, index) {
                            return Image.asset(
                              _kRoomScanExampleAssets[index],
                              fit: BoxFit.cover,
                              gaplessPlayback: true,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: SmoothPageIndicator(
                      controller: _examplePageController,
                      count: _kRoomScanExampleAssets.length,
                      effect: WormEffect(
                        dotHeight: 8,
                        dotWidth: 8,
                        spacing: 8,
                        dotColor: colorScheme.outline.withValues(alpha: 0.35),
                        activeDotColor: colorScheme.primary,
                      ),
                    ),
                  ),
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
                  PrimaryButton(
                    onPressed: loading ? null : _startScan,
                    isLoading: _starting,
                    isDisabled: loading,
                    child: Text(L10n.get("room_scan_start")),
                  ),
                  const SizedBox(height: 16),
                  GhostButtonFactory.text(
                    onPressed: () => Navigator.of(context).pop(false),
                    text: L10n.get("skip"),
                    width: double.infinity,
                    isDisabled: loading,
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
