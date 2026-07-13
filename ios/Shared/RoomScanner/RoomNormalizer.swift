import Foundation
import simd
#if canImport(RoomPlan)
import RoomPlan
#endif

/// Converts Apple RoomPlan results into the versioned `NormalizedRoom` schema.
/// Apple framework objects are never the backend format — this keeps the wire
/// schema stable across RoomPlan/OS changes.
public enum RoomNormalizer {
    #if canImport(RoomPlan)
    @available(iOS 17.0, *)
    public static func normalize(_ room: CapturedRoom) -> NormalizedRoom {
        NormalizedRoom(
            walls: room.walls.map(normalizeSurface),
            doors: room.doors.map(normalizeSurface),
            windows: room.windows.map(normalizeSurface),
            openings: room.openings.map(normalizeSurface),
            objects: room.objects.map(normalizeObject),
            estimatedFloorAreaSquareMeters: estimatedFloorArea(of: room)
        )
    }

    /// Floor area from RoomPlan floor polygons only — never fabricated.
    /// Returns `nil` when no reliable floor geometry is available; the backend
    /// computes footprint metrics from the converted GLB as a fallback.
    @available(iOS 17.0, *)
    public static func estimatedFloorArea(of room: CapturedRoom) -> Double? {
        var total: Double = 0
        for floor in room.floors {
            let corners = floor.polygonCorners
            guard corners.count >= 3 else { continue }
            // Corners are on the surface plane; project through the surface
            // transform into world space, then measure on the horizontal plane.
            let worldPoints = corners.map { corner -> SIMD2<Double> in
                let world = floor.transform * SIMD4<Float>(corner.x, corner.y, corner.z, 1)
                return SIMD2<Double>(Double(world.x), Double(world.z))
            }
            total += abs(shoelaceArea(worldPoints))
        }
        // Reject degenerate results (a real room can't be under ~1 m²).
        return total >= 1.0 ? total : nil
    }

    /// Ceiling height estimate from wall heights; `nil` when there are no walls.
    @available(iOS 17.0, *)
    public static func estimatedHeightMeters(of room: CapturedRoom) -> Double? {
        let heights = room.walls.map { Double($0.dimensions.y) }.filter { $0 > 0.5 }
        return heights.max()
    }

    @available(iOS 17.0, *)
    private static func normalizeSurface(_ surface: CapturedRoom.Surface) -> NormalizedSurface {
        NormalizedSurface(
            id: surface.identifier.uuidString,
            category: categoryName(surface.category),
            dimensions: dimensions(surface.dimensions),
            transform: flatten(surface.transform),
            confidence: confidenceName(surface.confidence)
        )
    }

    @available(iOS 17.0, *)
    private static func normalizeObject(_ object: CapturedRoom.Object) -> NormalizedObject {
        NormalizedObject(
            id: object.identifier.uuidString,
            category: String(describing: object.category),
            dimensions: dimensions(object.dimensions),
            transform: flatten(object.transform),
            confidence: confidenceName(object.confidence)
        )
    }

    @available(iOS 17.0, *)
    private static func categoryName(_ category: CapturedRoom.Surface.Category) -> String {
        switch category {
        case .wall: return "wall"
        case .opening: return "opening"
        case .window: return "window"
        case .door(let isOpen): return isOpen ? "door_open" : "door"
        case .floor: return "floor"
        @unknown default: return String(describing: category)
        }
    }

    @available(iOS 17.0, *)
    private static func confidenceName(_ confidence: CapturedRoom.Confidence) -> String {
        switch confidence {
        case .high: return "high"
        case .medium: return "medium"
        case .low: return "low"
        @unknown default: return String(describing: confidence)
        }
    }
    #endif

    // MARK: - Geometry helpers (framework-independent, unit-testable)

    /// Signed polygon area via the shoelace formula.
    public static func shoelaceArea(_ points: [SIMD2<Double>]) -> Double {
        guard points.count >= 3 else { return 0 }
        var sum: Double = 0
        for i in 0..<points.count {
            let a = points[i]
            let b = points[(i + 1) % points.count]
            sum += a.x * b.y - b.x * a.y
        }
        return sum / 2
    }

    public static func dimensions(_ v: SIMD3<Float>) -> NormalizedDimensions {
        NormalizedDimensions(x: Double(v.x), y: Double(v.y), z: Double(v.z))
    }

    /// Column-major 4x4 matrix as 16 doubles.
    public static func flatten(_ m: simd_float4x4) -> [Double] {
        [m.columns.0, m.columns.1, m.columns.2, m.columns.3].flatMap {
            [Double($0.x), Double($0.y), Double($0.z), Double($0.w)]
        }
    }
}
