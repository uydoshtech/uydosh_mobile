import Foundation

/// Explicit product identity for scan-flow routing (App Clip / shared native).
/// Do not infer from UI text, bundle display name, or navigation history.
public enum ProductContext: String, Codable, Sendable {
    case uydosh
    case makon3D
}
