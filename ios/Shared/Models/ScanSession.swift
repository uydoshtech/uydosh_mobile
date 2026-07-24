import Foundation

/// A temporary scan session created by a Telegram Mini App (UyDosh or
/// Makon3D) and consumed by the App Clip. Mirrors
/// `GET /scan-sessions/{scanSessionId}`.
public struct ScanSession: Codable, Equatable {
    public enum Status: String, Codable, Equatable {
        case created
        case uploading
        /// Files received; backend is converting/attaching the scan.
        case processing
        case completed
        case failed
        case expired
    }

    public let scanSessionId: String
    /// Listing the scan belongs to — `listing` sessions only (absent for
    /// Makon3D gallery sessions). The backend uses integer listing ids, but
    /// the wire format is a string; decoding accepts both.
    public let listingId: String?
    public let status: Status
    /// Short-lived token authorizing uploads for this session. Present while
    /// the session is active; never a Telegram user identifier.
    public let uploadToken: String?
    public let expiresAt: Date
    /// Telegram deep link to open after the scan — points back at whichever
    /// Mini App created the session. Falls back to the UyDosh Mini App when
    /// absent (older backends).
    public let returnUrl: URL?

    public init(
        scanSessionId: String,
        listingId: String?,
        status: Status,
        uploadToken: String?,
        expiresAt: Date,
        returnUrl: URL? = nil
    ) {
        self.scanSessionId = scanSessionId
        self.listingId = listingId
        self.status = status
        self.uploadToken = uploadToken
        self.expiresAt = expiresAt
        self.returnUrl = returnUrl
    }

    public func isExpired(now: Date = Date()) -> Bool {
        status == .expired || now >= expiresAt
    }

    /// Whether the App Clip may start (or continue) the scanning flow.
    public func isUsableForScanning(now: Date = Date()) -> Bool {
        !isExpired(now: now) && (status == .created || status == .uploading)
    }

    private enum CodingKeys: String, CodingKey {
        case scanSessionId, listingId, status, uploadToken, expiresAt, returnUrl
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        scanSessionId = try container.decode(String.self, forKey: .scanSessionId)
        if let stringId = try? container.decode(String.self, forKey: .listingId) {
            listingId = stringId
        } else if let intId = try? container.decode(Int.self, forKey: .listingId) {
            listingId = String(intId)
        } else {
            listingId = nil
        }
        status = try container.decode(Status.self, forKey: .status)
        uploadToken = try container.decodeIfPresent(String.self, forKey: .uploadToken)
        expiresAt = try container.decode(Date.self, forKey: .expiresAt)
        if let returnUrlString = try container.decodeIfPresent(String.self, forKey: .returnUrl) {
            returnUrl = URL(string: returnUrlString)
        } else {
            returnUrl = nil
        }
    }
}
