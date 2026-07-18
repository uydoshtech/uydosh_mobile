import "package:flutter_test/flutter_test.dart";
import "package:room_scan_kit/scan_flow/scan_flow.dart";
import "package:uy_dosh/base/scan_flow/uydosh_scan_entry.dart";

void main() {
  test("UyDosh product context is explicit and entire-housing only", () {
    expect(kUydoshScanEntry.product, ProductContext.uydosh);
    expect(kUydoshScanEntry.scanMode, ScanMode.entireHousing);
    expect(
      ScanModePolicy.availableModes(forProduct: ProductContext.uydosh),
      [ScanMode.entireHousing],
    );
    expect(uydoshShowsScanModeSelection, isFalse);
    expect(uydoshInitialScanDestination, ScanDestination.wholeHousingScan);
  });
}
