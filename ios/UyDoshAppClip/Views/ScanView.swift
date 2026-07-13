import SwiftUI
import UIKit

/// Scanning screen. On LiDAR hardware this embeds the live RoomPlan capture
/// view; on the simulator (mock scanner) it shows a stand-in so the flow can
/// still be exercised end to end.
struct ScanView: View {
    @EnvironmentObject private var router: AppClipRouter

    var body: some View {
        ZStack {
            if let captureUIView = router.scanner?.captureUIView {
                CaptureViewContainer(uiView: captureUIView)
                    .ignoresSafeArea()
            } else {
                mockScanPlaceholder
            }

            VStack {
                HStack {
                    Button {
                        router.cancelScan()
                    } label: {
                        Text("scan.cancel")
                            .padding(.horizontal, 4)
                    }
                    .buttonStyle(.bordered)
                    .tint(.white)

                    Spacer()

                    Button {
                        router.finishScan()
                    } label: {
                        Text("scan.finish")
                            .bold()
                            .padding(.horizontal, 4)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()

                Spacer()

                Text("scan.instructions")
                    .font(.callout)
                    .multilineTextAlignment(.center)
                    .padding(12)
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    .padding(.horizontal, 24)
                    .padding(.bottom, 24)
            }
        }
    }

    private var mockScanPlaceholder: some View {
        VStack(spacing: 24) {
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
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Hosts the RoomPlan `RoomCaptureView` (owned by the coordinator so the
/// session survives SwiftUI view updates).
private struct CaptureViewContainer: UIViewRepresentable {
    let uiView: UIView

    func makeUIView(context: Context) -> UIView { uiView }
    func updateUIView(_ uiView: UIView, context: Context) {}
}
