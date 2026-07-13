import Foundation

/// Files and metadata produced by a finished room scan, ready for upload.
/// Artifacts live in a per-session temporary directory that is kept until all
/// required uploads succeed (iOS may purge App Clip data, so uploads happen
/// immediately after the scan).
public struct RoomScanArtifacts {
    public let usdzURL: URL
    public let jsonURL: URL
    /// Set after the review screen captures a snapshot; optional.
    public var previewJPEGURL: URL?
    public let normalizedRoom: NormalizedRoom
    public let metadata: ScanUploadResult.Metadata

    public init(
        usdzURL: URL,
        jsonURL: URL,
        previewJPEGURL: URL?,
        normalizedRoom: NormalizedRoom,
        metadata: ScanUploadResult.Metadata
    ) {
        self.usdzURL = usdzURL
        self.jsonURL = jsonURL
        self.previewJPEGURL = previewJPEGURL
        self.normalizedRoom = normalizedRoom
        self.metadata = metadata
    }

    public func fileURL(for type: ScanFileType) -> URL? {
        switch type {
        case .roomJson: return jsonURL
        case .roomUsdz: return usdzURL
        case .preview: return previewJPEGURL
        }
    }

    /// Removes the session's temporary directory. Call only after the backend
    /// confirmed completion.
    public func cleanUp() {
        try? FileManager.default.removeItem(at: usdzURL.deletingLastPathComponent())
    }
}
