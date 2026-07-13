import Foundation
import UIKit
#if canImport(RoomPlan)
import RoomPlan
#endif

/// Outcome of a capture session.
public enum RoomScanOutcome {
    case finished(RoomScanArtifacts)
    case cancelled
    case failed(String)
}

/// Abstraction over RoomPlan capture so the App Clip flow can run with a
/// mocked scan result (simulator, unit tests). Real RoomPlan internals are
/// never unit-tested directly.
@MainActor
public protocol RoomScanning: AnyObject {
    /// The live capture UI to embed, if this scanner has one.
    var captureUIView: UIView? { get }
    func start()
    /// Stops scanning; RoomPlan then post-processes and `onOutcome` fires.
    func finish()
    func cancel()
    var onOutcome: ((RoomScanOutcome) -> Void)? { get set }
}

#if canImport(RoomPlan)
/// Real RoomPlan capture. Owns the `RoomCaptureView`, drives the session, and
/// exports artifacts as soon as the processed result arrives so the captured
/// room can't be lost while navigating between views.
@available(iOS 17.0, *)
@MainActor
public final class RoomScanCoordinator: NSObject, RoomScanning {
    public var onOutcome: ((RoomScanOutcome) -> Void)?
    public var captureUIView: UIView? { captureView }

    private let scanSessionId: String
    private lazy var captureView: RoomCaptureView = {
        let view = RoomCaptureView(frame: .zero)
        view.delegate = self
        return view
    }()
    private var isCancelling = false

    public init(scanSessionId: String) {
        self.scanSessionId = scanSessionId
        super.init()
    }

    public func start() {
        isCancelling = false
        // Scanning takes minutes with no touches; don't let the screen sleep.
        UIApplication.shared.isIdleTimerDisabled = true
        captureView.captureSession.run(configuration: RoomCaptureSession.Configuration())
    }

    public func finish() {
        captureView.captureSession.stop()
    }

    public func cancel() {
        isCancelling = true
        captureView.captureSession.stop(pauseARSession: true)
        UIApplication.shared.isIdleTimerDisabled = false
        onOutcome?(.cancelled)
    }

    // MARK: - NSCoding (required by RoomCaptureViewDelegate; never persisted)

    public required nonisolated init?(coder: NSCoder) { return nil }
    public nonisolated func encode(with coder: NSCoder) {}
}

@available(iOS 17.0, *)
extension RoomScanCoordinator: RoomCaptureViewDelegate {
    // RoomPlan calls its delegate on the main thread, but the protocol
    // requirements are nonisolated — assumeIsolated bridges the gap.
    public nonisolated func captureView(shouldPresent roomDataForProcessing: CapturedRoomData, error: Error?) -> Bool {
        MainActor.assumeIsolated {
            // Let RoomPlan post-process and present the final model in the view.
            !isCancelling && error == nil
        }
    }

    public nonisolated func captureView(didPresent processedResult: CapturedRoom, error: Error?) {
        MainActor.assumeIsolated {
            handleDidPresent(processedResult, error: error)
        }
    }

    private func handleDidPresent(_ processedResult: CapturedRoom, error: Error?) {
        UIApplication.shared.isIdleTimerDisabled = false
        guard !isCancelling else { return }
        if let error {
            onOutcome?(.failed(String(describing: error)))
            return
        }
        do {
            let artifacts = try RoomExporter.export(processedResult, scanSessionId: scanSessionId)
            onOutcome?(.finished(artifacts))
        } catch {
            onOutcome?(.failed(String(describing: error)))
        }
    }
}
#endif

/// Mock scanner used on the simulator and in tests: fabricates a small but
/// schema-valid scan result after a short "scanning" delay.
@MainActor
public final class MockRoomScanner: RoomScanning {
    public var onOutcome: ((RoomScanOutcome) -> Void)?
    public var captureUIView: UIView? { nil }

    private let scanSessionId: String

    public init(scanSessionId: String) {
        self.scanSessionId = scanSessionId
    }

    public func start() {}

    public func finish() {
        let sessionId = scanSessionId
        Task { @MainActor [weak self] in
            try? await Task.sleep(for: .milliseconds(400))
            guard let self else { return }
            do {
                self.onOutcome?(.finished(try Self.makeArtifacts(scanSessionId: sessionId)))
            } catch {
                self.onOutcome?(.failed(String(describing: error)))
            }
        }
    }

    public func cancel() {
        onOutcome?(.cancelled)
    }

    static func makeArtifacts(scanSessionId: String) throws -> RoomScanArtifacts {
        let dir = RoomExporter.sessionDirectory(scanSessionId: scanSessionId)
        try? FileManager.default.removeItem(at: dir)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)

        func wall(_ id: String, x: Double, z: Double, yaw: Double) -> NormalizedSurface {
            NormalizedSurface(
                id: id,
                category: "wall",
                dimensions: NormalizedDimensions(x: 4.2, y: 2.7, z: 0.1),
                transform: [
                    cos(yaw), 0, -sin(yaw), 0,
                    0, 1, 0, 0,
                    sin(yaw), 0, cos(yaw), 0,
                    x, 1.35, z, 1,
                ],
                confidence: "high"
            )
        }

        let room = NormalizedRoom(
            walls: [
                wall("11111111-0000-0000-0000-000000000001", x: 0, z: -2.2, yaw: 0),
                wall("11111111-0000-0000-0000-000000000002", x: 2.1, z: 0, yaw: .pi / 2),
                wall("11111111-0000-0000-0000-000000000003", x: 0, z: 2.2, yaw: 0),
                wall("11111111-0000-0000-0000-000000000004", x: -2.1, z: 0, yaw: .pi / 2),
            ],
            doors: [],
            windows: [],
            openings: [],
            objects: [],
            estimatedFloorAreaSquareMeters: 18.5
        )

        let jsonURL = try RoomExporter.writeNormalizedJSON(room, to: dir)
        let usdzURL = dir.appendingPathComponent("room.usdz")
        try Data("mock-usdz-not-a-real-model".utf8).write(to: usdzURL, options: .atomic)

        return RoomScanArtifacts(
            usdzURL: usdzURL,
            jsonURL: jsonURL,
            previewJPEGURL: nil,
            normalizedRoom: room,
            metadata: ScanUploadResult.Metadata(roomsCount: 1, areaSquareMeters: 18.5, heightMeters: 2.7)
        )
    }
}
