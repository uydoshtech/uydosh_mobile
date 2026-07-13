import Foundation

/// File kinds produced by a room scan and uploaded to the backend.
public enum ScanFileType: String, Codable, CaseIterable {
    case roomJson = "room_json"
    case roomUsdz = "room_usdz"
    case preview

    public var contentType: String {
        switch self {
        case .roomJson: return "application/json"
        case .roomUsdz: return "model/vnd.usdz+zip"
        case .preview: return "image/jpeg"
        }
    }
}

/// One pre-signed (or backend-tokenized) upload destination returned by
/// `POST /scan-sessions/{id}/uploads`.
public struct ScanUploadTarget: Codable, Equatable {
    public let type: ScanFileType
    public let uploadUrl: URL
    /// Storage key to report back in the completion request.
    public let storageKey: String?

    public init(type: ScanFileType, uploadUrl: URL, storageKey: String?) {
        self.type = type
        self.uploadUrl = uploadUrl
        self.storageKey = storageKey
    }
}

/// Aggregated outcome of all uploads, used to complete the scan session via
/// `POST /scan-sessions/{id}/complete`.
public struct ScanUploadResult: Codable, Equatable {
    public struct Metadata: Codable, Equatable {
        public let roomsCount: Int
        /// `nil` when the floor area could not be computed reliably —
        /// never fabricated.
        public let areaSquareMeters: Double?
        /// Ceiling height estimate from wall geometry; optional.
        public let heightMeters: Double?

        public init(roomsCount: Int, areaSquareMeters: Double?, heightMeters: Double? = nil) {
            self.roomsCount = roomsCount
            self.areaSquareMeters = areaSquareMeters
            self.heightMeters = heightMeters
        }
    }

    public let roomJsonKey: String
    public let roomUsdzKey: String
    public let previewKey: String?
    public let metadata: Metadata

    public init(roomJsonKey: String, roomUsdzKey: String, previewKey: String?, metadata: Metadata) {
        self.roomJsonKey = roomJsonKey
        self.roomUsdzKey = roomUsdzKey
        self.previewKey = previewKey
        self.metadata = metadata
    }
}
