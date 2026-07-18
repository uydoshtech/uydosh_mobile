import "package:room_scan_kit/scan_flow/scan_flow.dart";

/// Explicit UyDosh product context for the listing scan flow.
///
/// Do not infer product from UI text, bundle display name, or navigation.
const ScanEntryConfiguration kUydoshScanEntry = ScanEntryConfiguration(
  product: ProductContext.uydosh,
  scanMode: ScanMode.entireHousing,
);

/// UyDosh only supports whole-housing scanning — never show mode selection.
bool get uydoshShowsScanModeSelection =>
    ScanModePolicy.shouldShowModeSelection(product: kUydoshScanEntry.product);

ScanDestination get uydoshInitialScanDestination =>
    ScanRouting.initialDestination(product: kUydoshScanEntry.product);
