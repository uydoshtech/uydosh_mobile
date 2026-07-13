import Foundation

/// Versioned, framework-independent representation of a captured room.
///
/// This is the canonical backend/web format for RoomPlan scans. Apple
/// framework objects (`CapturedRoom` etc.) are never serialized directly as
/// the only backend format; `version` allows future app versions to migrate
/// the schema.
public struct NormalizedRoom: Codable, Equatable {
    public static let currentVersion = 1

    public let version: Int
    public let walls: [NormalizedSurface]
    public let doors: [NormalizedSurface]
    public let windows: [NormalizedSurface]
    public let openings: [NormalizedSurface]
    public let objects: [NormalizedObject]
    /// `nil` when the area cannot be computed reliably from wall geometry.
    public let estimatedFloorAreaSquareMeters: Double?

    public init(
        version: Int = NormalizedRoom.currentVersion,
        walls: [NormalizedSurface],
        doors: [NormalizedSurface],
        windows: [NormalizedSurface],
        openings: [NormalizedSurface],
        objects: [NormalizedObject],
        estimatedFloorAreaSquareMeters: Double?
    ) {
        self.version = version
        self.walls = walls
        self.doors = doors
        self.windows = windows
        self.openings = openings
        self.objects = objects
        self.estimatedFloorAreaSquareMeters = estimatedFloorAreaSquareMeters
    }
}

/// Width/height/depth in meters.
public struct NormalizedDimensions: Codable, Equatable {
    public let x: Double
    public let y: Double
    public let z: Double

    public init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
}

/// A wall, door, window, or opening.
public struct NormalizedSurface: Codable, Equatable {
    /// Stable identifier (RoomPlan surface UUID).
    public let id: String
    public let category: String
    public let dimensions: NormalizedDimensions
    /// 4x4 world transform, column-major, 16 elements.
    public let transform: [Double]
    /// "high" | "medium" | "low" when RoomPlan provides it.
    public let confidence: String?

    public init(
        id: String,
        category: String,
        dimensions: NormalizedDimensions,
        transform: [Double],
        confidence: String?
    ) {
        self.id = id
        self.category = category
        self.dimensions = dimensions
        self.transform = transform
        self.confidence = confidence
    }
}

/// A detected object (bed, table, sofa, ...).
public struct NormalizedObject: Codable, Equatable {
    public let id: String
    public let category: String
    public let dimensions: NormalizedDimensions
    /// 4x4 world transform, column-major, 16 elements.
    public let transform: [Double]
    public let confidence: String?

    public init(
        id: String,
        category: String,
        dimensions: NormalizedDimensions,
        transform: [Double],
        confidence: String?
    ) {
        self.id = id
        self.category = category
        self.dimensions = dimensions
        self.transform = transform
        self.confidence = confidence
    }
}
