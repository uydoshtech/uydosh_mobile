import Foundation

/// Central configuration for the App Clip scanning flow.
///
/// NOTE: if the invocation domain ever changes, this file is the only place
/// that needs updating — invocation URL parsing itself is host-agnostic (see
/// `ScanInvocation`) — plus the entitlements and the backend AASA config.
public enum AppClipConfig {
    /// Host that serves the App Clip invocation URLs and the
    /// apple-app-site-association file (see docs/APP_CLIP.md).
    public static let invocationHost = "scan.uydosh.com"

    /// Base URL of the UyDosh backend API used by the App Clip.
    public static let apiBaseURL = URL(string: "https://api.uydosh.com")!

    /// Telegram bot that hosts the UyDosh Mini App.
    public static let telegramBotUsername = "uydosh_bot"

    /// Builds the invocation URL for a scan session:
    /// `https://scan.uydosh.com/s/{scanSessionId}`.
    public static func invocationURL(scanSessionId: String) -> URL {
        URL(string: "https://\(invocationHost)/s/\(scanSessionId)")!
    }

    /// Deep link to the Telegram Mini App without any scan context. Used as
    /// the close-button fallback when the clip was launched without a valid
    /// invocation and there is no session to return to.
    public static var miniAppURL: URL {
        URL(string: "https://t.me/\(telegramBotUsername)/app")!
    }

    /// Deep link that returns the user to the Telegram Mini App after a scan:
    /// `https://t.me/uydosh_bot/app?startapp=scan_{scanSessionId}`.
    public static func returnToTelegramURL(scanSessionId: String) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "t.me"
        components.path = "/\(telegramBotUsername)/app"
        components.queryItems = [URLQueryItem(name: "startapp", value: "scan_\(scanSessionId)")]
        return components.url!
    }
}
