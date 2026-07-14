import SwiftUI

/// Switches between screens based on the router's state machine.
struct RootView: View {
    @EnvironmentObject private var router: AppClipRouter
    @Environment(\.openURL) private var openURL

    var body: some View {
        ZStack {
            switch router.state {
            case .loadingInvocation:
                ProgressScreen(text: String(localized: "state.loading_invocation"))
            case .validatingSession:
                ProgressScreen(text: String(localized: "state.validating_session"))
            case .unsupportedDevice:
                ScanErrorView(kind: .unsupportedDevice)
            case .invalidSession:
                ScanErrorView(kind: .invalidSession)
            case .ready:
                ScanIntroView()
            case .scanning:
                ScanView()
            case .reviewing:
                ScanReviewView()
            case .exporting:
                ProgressScreen(text: String(localized: "state.exporting"))
            case .uploading(let progress):
                UploadProgressView(progress: progress)
            case .completed:
                ScanSuccessView()
            case .failed(let message):
                ScanErrorView(kind: .failure(message: message))
            }
        }
        .overlay(alignment: .topTrailing) {
            if showsCloseButton {
                closeButton
            }
        }
        .animation(.default, value: router.state)
    }

    /// The scanning screen has its own cancel/finish controls, and during
    /// export/upload leaving would lose the scan — hide the close button there.
    private var showsCloseButton: Bool {
        switch router.state {
        case .scanning, .exporting, .uploading:
            return false
        default:
            return true
        }
    }

    /// "Closes" the clip by returning the user to the Telegram Mini App —
    /// iOS apps cannot terminate themselves, so deep-linking back to the
    /// invoking context is the supported way out.
    private var closeButton: some View {
        Button {
            openURL(router.returnToTelegramURL ?? AppClipConfig.miniAppURL)
        } label: {
            Image(systemName: "xmark")
                .font(.body.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(10)
                .background(.thinMaterial, in: Circle())
        }
        .accessibilityLabel(Text("close.button"))
        .padding(.top, 8)
        .padding(.trailing, 16)
    }
}

/// Simple full-screen spinner with a caption.
struct ProgressScreen: View {
    let text: String

    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
            Text(text)
                .font(.headline)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
