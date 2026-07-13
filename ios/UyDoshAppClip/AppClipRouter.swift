import Foundation
import SwiftUI

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

    private let sessionAPI: any ScanSessionAPIProtocol
    private let isDeviceSupported: () -> Bool
    private var validationTask: Task<Void, Never>?

    init(
        sessionAPI: (any ScanSessionAPIProtocol)? = nil,
        isDeviceSupported: @escaping () -> Bool = { RoomPlanSupport.isSupported }
    ) {
        // Mock backend is opt-in through the SCAN_CLIP_MOCK scheme variable
        // (see docs/APP_CLIP.md); otherwise the live API is used.
        self.sessionAPI = sessionAPI ?? MockScanSessionAPI.fromEnvironment() ?? LiveScanSessionAPI()
        self.isDeviceSupported = isDeviceSupported
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
                } else if session.status == .completed {
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

    // MARK: - Scan flow (Phase 1: placeholder transitions; RoomPlan lands in Phase 2)

    func startScan() {
        guard state == .ready || state == .reviewing else { return }
        state = .scanning
    }

    func cancelScan() {
        guard state == .scanning else { return }
        state = .ready
    }

    func finishScan() {
        guard state == .scanning else { return }
        state = .reviewing
    }

    func retryScan() {
        guard state == .reviewing else { return }
        state = .scanning
    }

    func confirmScan() {
        guard state == .reviewing else { return }
        // Phase 2 adds real export; Phase 3 adds real uploads. For now, walk
        // through the states so the full UI flow can be exercised.
        state = .exporting
        Task { [weak self] in
            guard let self else { return }
            try? await Task.sleep(for: .milliseconds(800))
            for step in 0...10 {
                self.state = .uploading(progress: Double(step) / 10.0)
                try? await Task.sleep(for: .milliseconds(200))
            }
            self.state = .completed
        }
    }

    // MARK: - Return to Telegram

    var returnToTelegramURL: URL? {
        guard let sessionId = scanSessionId else { return nil }
        return AppClipConfig.returnToTelegramURL(scanSessionId: sessionId)
    }

    private var isFailureState: Bool {
        if case .failed = state { return true }
        return false
    }
}
