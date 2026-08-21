import Foundation

/// Parses App Clip invocation URLs of the form
/// `https://<any-host>/s/{scanSessionId}`, or default App Clip links
/// `https://appclip.apple.com/id?p=<bundle>&s={scanSessionId}`.
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

        if pathParts.count == 2, pathParts[0] == "s",
           let fromPath = validatedSessionId(pathParts[1]) {
            return fromPath
        }

        return querySessionId(components.queryItems)
    }

    /// True when the URL is clearly a `/s/{id}` invocation (valid or not).
    public static func isAssociatedScanPath(_ url: URL) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return false
        }
        let pathParts = components.path
            .split(separator: "/", omittingEmptySubsequences: true)
            .map(String.init)
        return pathParts.count == 2 && pathParts[0] == "s"
    }

    private static func querySessionId(_ items: [URLQueryItem]?) -> String? {
        guard let items else { return nil }
        for key in ["s", "scanSessionId"] {
            if let value = items.first(where: { $0.name == key })?.value,
               let sessionId = validatedSessionId(value) {
                return sessionId
            }
        }
        if let nested = items.first(where: { $0.name == "url" })?.value,
           let nestedURL = URL(string: nested) {
            return sessionId(from: nestedURL)
        }
        return nil
    }

    private static func validatedSessionId(_ candidate: String) -> String? {
        guard candidate.range(of: sessionIdPattern, options: .regularExpression) != nil else {
            return nil
        }
        return candidate
    }
}
