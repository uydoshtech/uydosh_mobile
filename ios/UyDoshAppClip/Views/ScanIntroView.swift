import SwiftUI

/// "Ready" state: session validated, user can start scanning.
struct ScanIntroView: View {
    @EnvironmentObject private var router: AppClipRouter

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "camera.metering.matrix")
                .font(.system(size: 64))
                .foregroundStyle(.tint)

            Text("intro.title")
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text("intro.subtitle")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            Button {
                router.startScan()
            } label: {
                Text("intro.start_button")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
        }
        .padding(24)
    }
}
