import SwiftUI

/// Terminal error screens: unsupported device, invalid/expired session, or a
/// recoverable failure with retry. Every variant lets the user go back to
/// Telegram so the listing flow is never blocked.
struct ScanErrorView: View {
    enum Kind: Equatable {
        case unsupportedDevice
        case invalidSession
        case failure(message: String)
    }

    let kind: Kind

    @EnvironmentObject private var router: AppClipRouter
    @Environment(\.openURL) private var openURL

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: iconName)
                .font(.system(size: 64))
                .foregroundStyle(.orange)

            Text(title)
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Spacer()

            VStack(spacing: 12) {
                if case .failure = kind {
                    Button {
                        router.retryValidation()
                    } label: {
                        Text("error.retry_button")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                }

                if let url = router.returnToTelegramURL {
                    Button {
                        openURL(url)
                    } label: {
                        Text("error.return_button")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }

                Text("error.publish_note")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(24)
    }

    private var iconName: String {
        switch kind {
        case .unsupportedDevice: return "iphone.slash"
        case .invalidSession: return "link.badge.plus"
        case .failure: return "exclamationmark.triangle"
        }
    }

    private var title: String {
        switch kind {
        case .unsupportedDevice: return String(localized: "error.unsupported_title")
        case .invalidSession: return String(localized: "error.invalid_title")
        case .failure: return String(localized: "error.failed_title")
        }
    }

    private var message: String {
        switch kind {
        case .unsupportedDevice: return String(localized: "error.unsupported_message")
        case .invalidSession: return String(localized: "error.invalid_message")
        case .failure(let message): return message
        }
    }
}
