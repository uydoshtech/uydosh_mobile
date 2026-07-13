import Foundation

/// Uploads exported scan files to pre-signed (or backend-tokenized) URLs.
/// The real `URLSession`-based implementation with progress and retry lands in
/// Phase 3; the protocol exists now so the App Clip state machine and views
/// can be built and tested against it.
public protocol UploadServicing: Sendable {
    /// Uploads a local file to `target`, reporting fractional progress in
    /// `0...1`. Throws on failure; callers decide about retries.
    func upload(
        fileURL: URL,
        to target: ScanUploadTarget,
        progress: @escaping @Sendable (Double) -> Void
    ) async throws
}

/// Mock used in Phase 1 and in tests: simulates a short upload, optionally
/// failing a configurable number of times to exercise retry handling.
public final class MockUploadService: UploadServicing, @unchecked Sendable {
    private let stepDelay: Duration
    private var remainingFailures: Int
    private let lock = NSLock()

    public init(failuresBeforeSuccess: Int = 0, stepDelay: Duration = .milliseconds(150)) {
        self.remainingFailures = failuresBeforeSuccess
        self.stepDelay = stepDelay
    }

    public func upload(
        fileURL: URL,
        to target: ScanUploadTarget,
        progress: @escaping @Sendable (Double) -> Void
    ) async throws {
        let shouldFail: Bool = {
            lock.lock()
            defer { lock.unlock() }
            if remainingFailures > 0 {
                remainingFailures -= 1
                return true
            }
            return false
        }()

        for step in 1...5 {
            try await Task.sleep(for: stepDelay)
            if shouldFail && step == 3 {
                throw APIError.network("Mocked upload failure")
            }
            progress(Double(step) / 5.0)
        }
    }
}
