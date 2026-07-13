import Foundation

/// Parses App Clip invocation URLs of the form
/// `https://<any-host>/s/{scanSessionId}`.
///
/// Parsing is intentionally host-agnostic: the associated-domains entitlement
/// already restricts which hosts can launch the App Clip, and keeping the
/// parser host-agnostic means the invocation domain can change without a
/// client update.
public enum ScanInvocation {
    /// Allowed session id shape: URL-safe token, 4–64 chars.
    private static let sessionIdPattern = "^[A-Za-z0-9_-]{4,64}$"

    /// Extracts the scan session id from an invocation URL, or returns `nil`
    /// when the URL does not look like a valid scan invocation.
    public static func sessionId(from url: URL) -> String? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              components.scheme == "https" || components.scheme == "http" else {
            return nil
        }

        let pathParts = components.path
            .split(separator: "/", omittingEmptySubsequences: true)
            .map(String.init)

        guard pathParts.count == 2, pathParts[0] == "s" else { return nil }

        let candidate = pathParts[1]
        guard candidate.range(of: sessionIdPattern, options: .regularExpression) != nil else {
            return nil
        }
        return candidate
    }
}
