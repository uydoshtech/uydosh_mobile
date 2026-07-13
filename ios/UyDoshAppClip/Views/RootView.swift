import SwiftUI

/// Switches between screens based on the router's state machine.
struct RootView: View {
    @EnvironmentObject private var router: AppClipRouter

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
        .animation(.default, value: router.state)
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
