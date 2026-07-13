import SwiftUI

/// Success screen with the "Return to Telegram" call to action and a fallback
/// note in case Telegram cannot be opened.
struct ScanSuccessView: View {
    @EnvironmentObject private var router: AppClipRouter
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.green)

            Text("success.title")
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text("success.message")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            VStack(spacing: 12) {
                if let url = router.returnToTelegramURL {
                    Button {
                        openURL(url)
                    } label: {
                        Text("success.return_button")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }

                Text("success.fallback")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(24)
    }
}
