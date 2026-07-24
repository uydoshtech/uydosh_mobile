import Combine
import Foundation
import SwiftUI
import UIKit
#if canImport(RoomPlan)
import RoomPlan
#endif

/// All states of the App Clip scanning flow.
enum AppClipScanState: Equatable {
    case loadingInvocation
    case validatingSession
    case unsupportedDevice
    case invalidSession
    case ready
    case scanning
    case reviewing
    case exporting
    case uploading(progress: Double)
    case completed
    case failed(message: String)
}

/// Drives the App Clip flow: invocation URL → session validation → scan →
/// review → export → upload → completed. Owns the single source of truth for
/// `AppClipScanState` so views stay dumb and the flow is testable.
@MainActor
final class AppClipRouter: ObservableObject {
    @Published private(set) var state: AppClipScanState = .loadingInvocation

    private(set) var scanSessionId: String?
    private(set) var session: ScanSession?
    private(set) var scanner: (any RoomScanning)?
    private(set) var artifacts: RoomScanArtifacts?

    private let sessionAPI: any ScanSessionAPIProtocol
    private let uploadService: any UploadServicing
    private let isDeviceSupported: () -> Bool
    private let makeScanner: (String) -> any RoomScanning
    private var validationTask: Task<Void, Never>?
    private var uploadTask: Task<Void, Never>?
    /// True when the upload step failed (vs. validation), so retry re-runs
    /// the upload with the kept artifacts instead of re-validating.
    private var failedDuringUpload = false
    private var autopilotCancellable: AnyCancellable?

    init(
        sessionAPI: (any ScanSessionAPIProtocol)? = nil,
        uploadService: (any UploadServicing)? = nil,
        isDeviceSupported: @escaping () -> Bool = { RoomPlanSupport.isSupported },
        makeScanner: ((String) -> any RoomScanning)? = nil
    ) {
        // Mock backend is opt-in through the SCAN_CLIP_MOCK scheme variable
        // (see docs/APP_CLIP.md); otherwise the live API is used.
        let mockAPI = MockScanSessionAPI.fromEnvironment()
        self.sessionAPI = sessionAPI ?? mockAPI ?? LiveScanSessionAPI()
        self.uploadService = uploadService
            ?? (mockAPI != nil ? MockUploadService.fromEnvironment() : URLSessionUploadService())
        self.isDeviceSupported = isDeviceSupported
        self.makeScanner = makeScanner ?? Self.defaultScanner(scanSessionId:)

        #if DEBUG
        // SCAN_CLIP_AUTOPILOT=1 drives the whole flow hands-free (mock
        // scanner + mock backend) so the pipeline can be smoke-tested from
        // the command line: ready → scan → finish → confirm → completed.
        if ProcessInfo.processInfo.environment["SCAN_CLIP_AUTOPILOT"] == "1" {
            autopilotCancellable = $state
                .removeDuplicates()
                .receive(on: DispatchQueue.main)
                .sink { [weak self] state in
                    Task { @MainActor [weak self] in
                        try? await Task.sleep(for: .milliseconds(800))
                        guard let self else { return }
                        switch state {
                        case .ready: self.startScan()
                        case .scanning: self.finishScan()
                        case .reviewing: self.confirmScan(previewJPEG: nil)
                        default: break
                        }
                    }
                }
        }
        #endif
    }

    /// Real RoomPlan on LiDAR hardware; mock scanner elsewhere (simulator).
    private static func defaultScanner(scanSessionId: String) -> any RoomScanning {
        #if canImport(RoomPlan) && !targetEnvironment(simulator)
        if RoomPlanSupport.isHardwareSupported {
            return RoomScanCoordinator(scanSessionId: scanSessionId)
        }
        #endif
        return MockRoomScanner(scanSessionId: scanSessionId)
    }

    // MARK: - Invocation

    /// Handles the App Clip invocation URL. Safe to call more than once
    /// (cold launch and warm relaunch both deliver NSUserActivity): a second
    /// invocation for the same session while a flow is in progress is ignored.
    func handleInvocationURL(_ url: URL) {
        guard let sessionId = ScanInvocation.sessionId(from: url) else {
            // Only fail if we don't already have a valid flow going.
            if scanSessionId == nil {
                state = .invalidSession
            }
            return
        }

        if sessionId == scanSessionId, state != .invalidSession, !isFailureState {
            return
        }

        scanSessionId = sessionId
        validate(sessionId: sessionId)
    }

    /// Called when the scene became active but no user activity arrived —
    /// e.g. the App Clip was launched without an invocation URL.
    func invocationTimedOut() {
        if case .loadingInvocation = state {
            state = .invalidSession
        }
    }

    func retryValidation() {
        if failedDuringUpload {
            retryUpload()
            return
        }
        guard let sessionId = scanSessionId else {
            state = .invalidSession
            return
        }
        validate(sessionId: sessionId)
    }

    private func validate(sessionId: String) {
        guard isDeviceSupported() else {
            state = .unsupportedDevice
            return
        }

        failedDuringUpload = false
        state = .validatingSession
        validationTask?.cancel()
        validationTask = Task { [weak self] in
            guard let self else { return }
            do {
                let session = try await self.sessionAPI.fetchSession(id: sessionId)
                guard !Task.isCancelled else { return }
                self.session = session
                if session.isUsableForScanning() {
                    self.state = .ready
                } else if session.status == .completed || session.status == .processing {
                    // Session already finished (e.g. relaunch after success).
                    self.state = .completed
                } else {
                    self.state = .invalidSession
                }
            } catch APIError.notFound {
                guard !Task.isCancelled else { return }
                self.state = .invalidSession
            } catch {
                guard !Task.isCancelled else { return }
                self.state = .failed(message: String(localized: "error.validation_failed"))
            }
        }
    }

    // MARK: - Scan flow

    func startScan() {
        guard state == .ready || state == .reviewing, let sessionId = scanSessionId else { return }
        artifacts = nil

        let scanner = makeScanner(sessionId)
        scanner.onOutcome = { [weak self] outcome in
            Task { @MainActor [weak self] in
                self?.handleScanOutcome(outcome)
            }
        }
        self.scanner = scanner
        state = .scanning
        scanner.start()
    }

    func cancelScan() {
        guard state == .scanning else { return }
        scanner?.cancel()
    }

    /// Stops capture; RoomPlan post-processes and the outcome callback moves
    /// the flow to reviewing.
    func finishScan() {
        guard state == .scanning else { return }
        state = .exporting
        scanner?.finish()
    }

    private func handleScanOutcome(_ outcome: RoomScanOutcome) {
        switch outcome {
        case .finished(let artifacts):
            self.artifacts = artifacts
            scanner = nil
            state = .reviewing
        case .cancelled:
            scanner = nil
            state = .ready
        case .failed:
            scanner = nil
            state = .failed(message: String(localized: "error.scan_failed"))
        }
    }

    func retryScan() {
        guard state == .reviewing else { return }
        artifacts?.cleanUp()
        artifacts = nil
        state = .ready
        startScan()
    }

    // MARK: - Upload

    /// Confirms the reviewed scan and uploads all artifacts. `previewJPEG` is
    /// an optional snapshot from the review screen.
    func confirmScan(previewJPEG: Data?) {
        guard state == .reviewing, let artifacts else { return }
        if let previewJPEG {
            self.artifacts = RoomExporter.writePreview(jpegData: previewJPEG, for: artifacts)
        }
        beginUpload()
    }

    func retryUpload() {
        guard case .failed = state, artifacts != nil else { return }
        beginUpload()
    }

    private func beginUpload() {
        guard let sessionId = scanSessionId,
              let uploadToken = session?.uploadToken,
              let artifacts else {
            state = .failed(message: String(localized: "error.validation_failed"))
            failedDuringUpload = false
            return
        }

        state = .uploading(progress: 0)
        uploadTask?.cancel()
        uploadTask = Task { [weak self] in
            // Keep running briefly if the user backgrounds the app mid-upload.
            let backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "scan-upload")
            defer { UIApplication.shared.endBackgroundTask(backgroundTask) }

            guard let self else { return }
            do {
                try await self.runUploadPipeline(
                    sessionId: sessionId,
                    uploadToken: uploadToken,
                    artifacts: artifacts
                )
                guard !Task.isCancelled else { return }
                artifacts.cleanUp()
                self.failedDuringUpload = false
                self.state = .completed
            } catch {
                guard !Task.isCancelled else { return }
                // Artifacts are intentionally kept for retry.
                self.failedDuringUpload = true
                self.state = .failed(message: String(localized: "error.upload_failed"))
            }
        }
    }

    private func runUploadPipeline(
        sessionId: String,
        uploadToken: String,
        artifacts: RoomScanArtifacts
    ) async throws {
        var files: [ScanFileType] = [.roomJson, .roomUsdz]
        if artifacts.previewJPEGURL != nil {
            files.append(.preview)
        }

        let targets = try await sessionAPI.requestUploadTargets(
            sessionId: sessionId,
            uploadToken: uploadToken,
            files: files
        )

        var storageKeys: [ScanFileType: String] = [:]
        let share = 1.0 / Double(max(targets.count, 1))
        for (index, target) in targets.enumerated() {
            guard let fileURL = artifacts.fileURL(for: target.type) else { continue }
            let base = Double(index) * share
            try await uploadService.upload(
                fileURL: fileURL,
                to: target,
                uploadToken: uploadToken
            ) { [weak self] fileProgress in
                Task { @MainActor [weak self] in
                    guard let self, case .uploading = self.state else { return }
                    self.state = .uploading(progress: min(base + fileProgress * share, 1.0))
                }
            }
            storageKeys[target.type] = target.storageKey ?? target.type.rawValue
        }

        guard let jsonKey = storageKeys[.roomJson], let usdzKey = storageKeys[.roomUsdz] else {
            throw APIError.invalidResponse
        }

        try await sessionAPI.completeSession(
            sessionId: sessionId,
            uploadToken: uploadToken,
            result: ScanUploadResult(
                roomJsonKey: jsonKey,
                roomUsdzKey: usdzKey,
                previewKey: storageKeys[.preview],
                metadata: artifacts.metadata
            )
        )
    }

    // MARK: - Return to Telegram

    var returnToTelegramURL: URL? {
        // The backend tells us which Mini App created the session (UyDosh or
        // Makon3D); the hardcoded UyDosh link is only a fallback for older
        // backends that don't send `returnUrl`.
        if let returnUrl = session?.returnUrl { return returnUrl }
        guard let sessionId = scanSessionId else { return nil }
        return AppClipConfig.returnToTelegramURL(scanSessionId: sessionId)
    }

    private var isFailureState: Bool {
        if case .failed = state { return true }
        return false
    }
}
