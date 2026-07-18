import Foundation

public enum ScanMode: String, Codable, CaseIterable, Sendable {
    case entireHousing
    case roomByRoom
}

public enum ScanModePolicy {
    public static func availableModes(for product: ProductContext) -> [ScanMode] {
        switch product {
        case .uydosh:
            return [.entireHousing]
        case .makon3D:
            return [.entireHousing, .roomByRoom]
        }
    }

    public static func shouldShowModeSelection(for product: ProductContext) -> Bool {
        availableModes(for: product).count > 1
    }
}

public struct ScanEntryConfiguration: Sendable {
    public let product: ProductContext
    public let scanMode: ScanMode?

    public init(product: ProductContext, scanMode: ScanMode? = nil) {
        self.product = product
        self.scanMode = scanMode
    }
}
