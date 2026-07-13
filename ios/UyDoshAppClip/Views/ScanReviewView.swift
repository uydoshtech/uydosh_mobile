import SwiftUI

/// Review screen after a finished scan: confirm the result or retry.
/// Phase 2 adds a 3D preview of the captured room.
struct ScanReviewView: View {
    @EnvironmentObject private var router: AppClipRouter

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.seal")
                .font(.system(size: 64))
                .foregroundStyle(.tint)

            Text("review.title")
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text("review.subtitle")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            VStack(spacing: 12) {
                Button {
                    router.confirmScan()
                } label: {
                    Text("review.confirm_button")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                Button {
                    router.retryScan()
                } label: {
                    Text("review.retry_button")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
        }
        .padding(24)
    }
}
