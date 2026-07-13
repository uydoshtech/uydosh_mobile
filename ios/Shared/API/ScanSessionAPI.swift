import Foundation

/// Backend contract for scan sessions. Routes are placeholders behind this
/// protocol until the backend endpoints land (Phase 3), so exact paths can
/// change without touching the App Clip flow.
public protocol ScanSessionAPIProtocol: Sendable {
    /// `GET /scan-sessions/{scanSessionId}` — validate a session.
    func fetchSession(id: String) async throws -> ScanSession

    /// `POST /scan-sessions/{scanSessionId}/uploads` — request upload URLs.
    func requestUploadTargets(sessionId: String, uploadToken: String, files: [ScanFileType]) async throws -> [ScanUploadTarget]

    /// `POST /scan-sessions/{scanSessionId}/complete` — mark the session done.
    func completeSession(sessionId: String, uploadToken: String, result: ScanUploadResult) async throws
}

// MARK: - Live implementation (placeholder routes)

public final class LiveScanSessionAPI: ScanSessionAPIProtocol {
    private let client: APIClient

    public init(client: APIClient = APIClient()) {
        self.client = client
    }

    public func fetchSession(id: String) async throws -> ScanSession {
        try await client.get("scan-sessions/\(id)")
    }

    public func requestUploadTargets(
        sessionId: String,
        uploadToken: String,
        files: [ScanFileType]
    ) async throws -> [ScanUploadTarget] {
        struct FileRequest: Encodable {
            let type: String
            let contentType: String
        }
        struct Request: Encodable { let files: [FileRequest] }
        struct Response: Decodable { let uploads: [ScanUploadTarget] }

        let request = Request(files: files.map { FileRequest(type: $0.rawValue, contentType: $0.contentType) })
        let response: Response = try await client.post(
            "scan-sessions/\(sessionId)/uploads",
            body: request,
            headers: ["X-Scan-Upload-Token": uploadToken]
        )
        return response.uploads
    }

    public func completeSession(sessionId: String, uploadToken: String, result: ScanUploadResult) async throws {
        struct Files: Encodable {
            let roomJson: String
            let roomUsdz: String
            let preview: String?
        }
        struct Request: Encodable {
            let files: Files
            let metadata: ScanUploadResult.Metadata
        }
        struct Response: Decodable {}

        let request = Request(
            files: Files(
                roomJson: result.roomJsonKey,
                roomUsdz: result.roomUsdzKey,
                preview: result.previewKey
            ),
            metadata: result.metadata
        )
        let _: Response = try await client.post(
            "scan-sessions/\(sessionId)/complete",
            body: request,
            headers: ["X-Scan-Upload-Token": uploadToken]
        )
    }
}

// MARK: - Mock implementation (Phase 1 / testing)

/// Deterministic mock driven by a scenario. The App Clip scheme selects the
/// scenario through the `SCAN_CLIP_MOCK` environment variable so invalid and
/// expired sessions are testable from Xcode without a backend.
public final class MockScanSessionAPI: ScanSessionAPIProtocol {
    public enum Scenario: String, Sendable {
        case valid
        case expired
        case invalid
        case error
    }

    private let scenario: Scenario
    private let artificialDelay: Duration

    public init(scenario: Scenario, artificialDelay: Duration = .milliseconds(600)) {
        self.scenario = scenario
        self.artificialDelay = artificialDelay
    }

    /// Reads `SCAN_CLIP_MOCK` from the process environment; returns `nil`
    /// when mocking is not requested.
    public static func fromEnvironment(_ environment: [String: String] = ProcessInfo.processInfo.environment) -> MockScanSessionAPI? {
        guard let raw = environment["SCAN_CLIP_MOCK"], let scenario = Scenario(rawValue: raw) else {
            return nil
        }
        return MockScanSessionAPI(scenario: scenario)
    }

    public func fetchSession(id: String) async throws -> ScanSession {
        try await Task.sleep(for: artificialDelay)
        switch scenario {
        case .valid:
            return ScanSession(
                scanSessionId: id,
                listingId: "18472",
                status: .created,
                uploadToken: "mock-upload-token",
                expiresAt: Date().addingTimeInterval(30 * 60)
            )
        case .expired:
            return ScanSession(
                scanSessionId: id,
                listingId: "18472",
                status: .expired,
                uploadToken: nil,
                expiresAt: Date().addingTimeInterval(-60)
            )
        case .invalid:
            throw APIError.notFound
        case .error:
            throw APIError.network("Mocked network failure")
        }
    }

    public func requestUploadTargets(
        sessionId: String,
        uploadToken: String,
        files: [ScanFileType]
    ) async throws -> [ScanUploadTarget] {
        try await Task.sleep(for: artificialDelay)
        return files.map {
            ScanUploadTarget(
                type: $0,
                uploadUrl: URL(string: "https://mock.invalid/upload/\(sessionId)/\($0.rawValue)")!,
                storageKey: "mock/\(sessionId)/\($0.rawValue)"
            )
        }
    }

    public func completeSession(sessionId: String, uploadToken: String, result: ScanUploadResult) async throws {
        try await Task.sleep(for: artificialDelay)
    }
}
