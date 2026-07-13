import Foundation

/// Uploads exported scan files to pre-signed (or backend-tokenized) URLs.
public protocol UploadServicing: Sendable {
    /// Uploads a local file to `target` with a `PUT`, reporting fractional
    /// progress in `0...1`. Throws on failure; callers decide about retries.
    func upload(
        fileURL: URL,
        to target: ScanUploadTarget,
        uploadToken: String,
        progress: @escaping @Sendable (Double) -> Void
    ) async throws
}

// MARK: - URLSession implementation

public final class URLSessionUploadService: NSObject, UploadServicing, @unchecked Sendable {
    private var progressHandlers: [Int: @Sendable (Double) -> Void] = [:]
    private let lock = NSLock()
    private lazy var session: URLSession = {
        // Uploads must finish before iOS may purge App Clip data, so they run
        // in the foreground; `waitsForConnectivity` rides out brief drops.
        let configuration = URLSessionConfiguration.default
        configuration.waitsForConnectivity = true
        configuration.timeoutIntervalForResource = 10 * 60
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()

    public func upload(
        fileURL: URL,
        to target: ScanUploadTarget,
        uploadToken: String,
        progress: @escaping @Sendable (Double) -> Void
    ) async throws {
        var request = URLRequest(url: target.uploadUrl)
        request.httpMethod = "PUT"
        request.setValue(target.type.contentType, forHTTPHeaderField: "Content-Type")
        request.setValue(uploadToken, forHTTPHeaderField: "X-Scan-Upload-Token")

        var taskIdentifier = -1
        let response: URLResponse = try await withCheckedThrowingContinuation { continuation in
            let task = session.uploadTask(with: request, fromFile: fileURL) { _, response, error in
                if let error {
                    continuation.resume(throwing: APIError.network(error.localizedDescription))
                } else if let response {
                    continuation.resume(returning: response)
                } else {
                    continuation.resume(throwing: APIError.invalidResponse)
                }
            }
            taskIdentifier = task.taskIdentifier
            setProgressHandler(progress, for: task.taskIdentifier)
            task.resume()
        }
        removeProgressHandler(for: taskIdentifier)

        guard let http = response as? HTTPURLResponse else { throw APIError.invalidResponse }
        guard (200...299).contains(http.statusCode) else {
            throw APIError.httpStatus(http.statusCode)
        }
        progress(1.0)
    }

    // Synchronous helpers so async code never holds the lock directly.
    private func setProgressHandler(_ handler: @escaping @Sendable (Double) -> Void, for taskIdentifier: Int) {
        lock.lock()
        progressHandlers[taskIdentifier] = handler
        lock.unlock()
    }

    private func removeProgressHandler(for taskIdentifier: Int) {
        lock.lock()
        progressHandlers.removeValue(forKey: taskIdentifier)
        lock.unlock()
    }
}

extension URLSessionUploadService: URLSessionTaskDelegate {
    public func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didSendBodyData bytesSent: Int64,
        totalBytesSent: Int64,
        totalBytesExpectedToSend: Int64
    ) {
        guard totalBytesExpectedToSend > 0 else { return }
        lock.lock()
        let handler = progressHandlers[task.taskIdentifier]
        lock.unlock()
        handler?(Double(totalBytesSent) / Double(totalBytesExpectedToSend))
    }
}

// MARK: - Mock implementation (simulator / tests)

/// Simulates a short upload, optionally failing a configurable number of
/// times to exercise retry handling.
public final class MockUploadService: UploadServicing, @unchecked Sendable {
    private let stepDelay: Duration
    private var remainingFailures: Int
    private let lock = NSLock()

    public init(failuresBeforeSuccess: Int = 0, stepDelay: Duration = .milliseconds(150)) {
        self.remainingFailures = failuresBeforeSuccess
        self.stepDelay = stepDelay
    }

    /// Reads `SCAN_CLIP_MOCK_UPLOAD_FAILURES` so upload retries are testable
    /// from the Xcode scheme.
    public static func fromEnvironment(_ environment: [String: String] = ProcessInfo.processInfo.environment) -> MockUploadService {
        let failures = environment["SCAN_CLIP_MOCK_UPLOAD_FAILURES"].flatMap(Int.init) ?? 0
        return MockUploadService(failuresBeforeSuccess: failures)
    }

    public func upload(
        fileURL: URL,
        to target: ScanUploadTarget,
        uploadToken: String,
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
