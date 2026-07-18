import "package:flutter/material.dart";
import "package:room_scan_kit/scan_flow/scan_flow.dart";

import "package:uy_dosh/base/scan_flow/uydosh_scan_entry.dart";
import "package:uy_dosh/presentation/screens/room_plan/room_plan_scan_screen.dart";

/// UyDosh whole-housing scan orchestration (listing-attached RoomPlan).
///
/// Skips mode selection — [ScanModePolicy] exposes only [ScanMode.entireHousing].
class UyDoshWholeHousingCoordinator implements ScanFlowCoordinator {
  UyDoshWholeHousingCoordinator({
    required this.context,
    required this.listingId,
  }) : assert(
          !uydoshShowsScanModeSelection,
          "UyDosh must not show scan-mode selection",
        );

  final BuildContext context;
  final int listingId;

  bool _cancelled = false;

  ScanEntryConfiguration get entry => kUydoshScanEntry;

  @override
  Future<void> start() async {
    _cancelled = false;
    assert(entry.product == ProductContext.uydosh);
    assert(
      ScanRouting.initialDestination(product: entry.product) ==
          ScanDestination.wholeHousingScan,
    );
    if (!context.mounted || _cancelled) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => RoomPlanScanScreen(listingId: listingId),
      ),
    );
  }

  @override
  void cancel() {
    _cancelled = true;
    if (context.mounted) {
      Navigator.of(context).maybePop();
    }
  }
}
