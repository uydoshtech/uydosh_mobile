import SwiftUI

/// Upload progress screen. The user is asked to keep the app open; the real
/// upload pipeline with retry arrives in Phase 3.
struct UploadProgressView: View {
    let progress: Double

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ProgressView(value: progress)
                .progressViewStyle(.linear)

            Text("upload.title")
                .font(.headline)

            Text("upload.subtitle")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Text(progress.formatted(.percent.precision(.fractionLength(0))))
                .font(.title3.monospacedDigit())
                .foregroundStyle(.secondary)

            Spacer()
        }
        .padding(24)
    }
}
