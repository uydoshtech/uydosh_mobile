import SwiftUI
import SceneKit

/// Review screen after a finished scan: shows a 3D preview of the exported
/// USDZ, the estimated area, and lets the user save or rescan. The snapshot
/// of the preview becomes the uploaded preview image.
struct ScanReviewView: View {
    @EnvironmentObject private var router: AppClipRouter
    @State private var scnView: SCNView?

    var body: some View {
        VStack(spacing: 16) {
            Text("review.title")
                .font(.title2.bold())
                .multilineTextAlignment(.center)
                .padding(.top, 8)

            if let usdzURL = router.artifacts?.usdzURL,
               let scene = try? SCNScene(url: usdzURL, options: nil) {
                ModelPreview(scene: scene, scnView: $scnView)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "cube.transparent")
                        .font(.system(size: 56))
                        .foregroundStyle(.tint)
                    Text("review.subtitle")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            if let area = router.artifacts?.metadata.areaSquareMeters {
                Text(String(format: String(localized: "review.area_format"), area))
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 12) {
                Button {
                    let preview = scnView?.snapshot().jpegData(compressionQuality: 0.8)
                    router.confirmScan(previewJPEG: preview)
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
        .padding(20)
    }
}

/// SceneKit preview with orbit controls; exposes the underlying `SCNView`
/// so the confirm action can snapshot it for the preview upload.
private struct ModelPreview: UIViewRepresentable {
    let scene: SCNScene
    @Binding var scnView: SCNView?

    func makeUIView(context: Context) -> SCNView {
        let view = SCNView()
        view.scene = scene
        view.allowsCameraControl = true
        view.autoenablesDefaultLighting = true
        view.backgroundColor = .secondarySystemBackground
        DispatchQueue.main.async { scnView = view }
        return view
    }

    func updateUIView(_ uiView: SCNView, context: Context) {}
}
