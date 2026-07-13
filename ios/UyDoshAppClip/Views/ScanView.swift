import SwiftUI

/// Scanning screen. Phase 1 shows a placeholder with the Cancel/Finish
/// controls the real RoomPlan capture will use; Phase 2 replaces the body
/// with a `RoomCaptureView` wrapper behind the shared RoomScanner abstraction.
struct ScanView: View {
    @EnvironmentObject private var router: AppClipRouter

    var body: some View {
        VStack(spacing: 24) {
            HStack {
                Button {
                    router.cancelScan()
                } label: {
                    Text("scan.cancel")
                }
                Spacer()
                Button {
                    router.finishScan()
                } label: {
                    Text("scan.finish")
                        .bold()
                }
            }

            Spacer()

            Image(systemName: "arkit")
                .font(.system(size: 64))
                .foregroundStyle(.tint)

            Text("scan.placeholder_title")
                .font(.title3.bold())
                .multilineTextAlignment(.center)

            Text("scan.placeholder_subtitle")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()
        }
        .padding(24)
    }
}
