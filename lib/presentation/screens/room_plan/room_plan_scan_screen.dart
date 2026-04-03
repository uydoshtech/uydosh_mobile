import "package:flutter/material.dart";
import "package:flutter_roomplan/flutter_roomplan.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/utils/ios_device.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";

/// RoomPlan (LiDAR) capture → upload USDZ to [point_cloud_url] on the listing.
class RoomPlanScanScreen extends StatefulWidget {
  const RoomPlanScanScreen({required this.listingId, super.key});

  final int listingId;

  @override
  State<RoomPlanScanScreen> createState() => _RoomPlanScanScreenState();
}

class _RoomPlanScanScreenState extends State<RoomPlanScanScreen> {
  final _roomPlan = FlutterRoomplan();
  bool _uploading = false;
  bool _starting = false;

  @override
  void initState() {
    super.initState();
    if (!isIOSDevice) return;
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
    if (!isIOSDevice) {
      return Scaffold(
        appBar: AppBar(title: Text(L10n.get("room_scan_title"))),
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

    final loading = _uploading || _starting;

    return Scaffold(
      appBar: AppBar(
        title: Text(L10n.get("room_scan_title")),
        actions: [
          TextButton(
            onPressed: loading ? null : () => Navigator.of(context).pop(false),
            child: Text(L10n.get("skip")),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              L10n.get("room_scan_instructions"),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            if (_uploading)
              Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(L10n.get("room_scan_uploading")),
                ],
              )
            else
              PrimaryButton(
                onPressed: loading ? null : _startScan,
                isLoading: _starting,
                isDisabled: loading,
                child: Text(L10n.get("room_scan_start")),
              ),
          ],
        ),
      ),
    );
  }
}
