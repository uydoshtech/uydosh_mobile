import Foundation

// MARK: - Identifiers

typealias VertexId = UUID
typealias WallId = UUID
typealias OpeningId = UUID
typealias ObjectId = UUID
typealias DimensionAnnotationId = UUID

// MARK: - Enums

enum EditableFloorPlanUnit: String, Equatable {
  case meters
}

enum EditableFloorPlanSource: String, Equatable {
  case roomPlan
  case lidar
  case manual
}

enum EditableWallType: String, Equatable {
  case exterior
  case interior
}

enum EditableOpeningKind: String, Equatable {
  case door
  case window
  case opening
}

enum EditableObjectType: String, Equatable {
  case bed
  case table
  case chair
  case sofa
  case storage
  case appliance
  case cabinet
  case television
  case fixture
  case unknown

  /// Derives a furniture category from a scan/USDZ node name (RoomPlan names object nodes by
  /// category, e.g. "Table0", "Sofa1"). Shared by the model mapper and the 3D material styling.
  static func from(nodeName name: String) -> EditableObjectType {
    let n = name.lowercased()
    if n.contains("bed") { return .bed }
    if n.contains("sofa") || n.contains("couch") { return .sofa }
    if n.contains("table") || n.contains("desk") { return .table }
    if n.contains("chair") || n.contains("stool") { return .chair }
    if n.contains("storage") || n.contains("shelf") { return .storage }
    if n.contains("cabinet") || n.contains("cupboard") { return .cabinet }
    if n.contains("refrigerator") || n.contains("fridge") || n.contains("oven")
      || n.contains("washer") || n.contains("appliance")
    {
      return .appliance
    }
    if n.contains("television") || n.contains("tv") { return .television }
    if n.contains("bathtub") || n.contains("toilet") || n.contains("sink") { return .fixture }
    return .unknown
  }
}

enum EditableObjectAnchorType: String, Equatable {
  case free
  case nearestWall
  case wallId
}

enum DimensionEditKind: Equatable {
  case overallWidth
  case overallLength
  case wallSegmentLength
}

enum DimensionFixedSide: Equatable {
  case minX
  case maxX
  case minZ
  case maxZ
  case auto
}

enum DimensionEditType: Equatable {
  case resizeWidth
  case resizeLength
  case wallSegmentLength
}

// MARK: - Components

struct EditableVertex: Equatable {
  var id: VertexId
  var x: Double
  var z: Double
  var locked: Bool
}

struct EditableWall: Equatable {
  var id: WallId
  var startVertexId: VertexId
  var endVertexId: VertexId
  var height: Double
  var thickness: Double
  var type: EditableWallType
  var openingIds: [OpeningId]
  var computedLength: Double
}

struct EditableOpening: Equatable {
  var id: OpeningId
  var wallId: WallId
  var type: EditableOpeningKind
  var offsetFromWallStart: Double
  var width: Double
  var height: Double
  var bottomOffset: Double
  var keepRelativePosition: Bool
}

struct EditableObjectAnchor: Equatable {
  var type: EditableObjectAnchorType
  var wallId: WallId?
  var offsetFromWall: Double?
  var distanceFromWall: Double?
}

struct EditablePointXZ: Equatable {
  var x: Double
  var z: Double
}

struct EditableObject: Equatable {
  var id: ObjectId
  var type: EditableObjectType
  var centerX: Double
  var centerZ: Double
  /// Bottom-face corners in world X/Z — matches mesh orientation in the scan.
  var cornersXZ: [EditablePointXZ]
  var width: Double
  var length: Double
  var rotationRadians: Double
  var height: Double?
  var anchor: EditableObjectAnchor
  var isOutsideBounds: Bool
}

struct EditableFloorPlanBounds: Equatable {
  var minX: Double
  var maxX: Double
  var minZ: Double
  var maxZ: Double

  var width: Double { maxX - minX }
  var length: Double { maxZ - minZ }
}

struct EditableFloorPlanMetadata: Equatable {
  var createdAt: Date
  var updatedAt: Date
  var isEdited: Bool
  var source: EditableFloorPlanSource
}

struct DimensionEditTarget: Equatable {
  var editType: DimensionEditType
  var affectedWallIds: [WallId]
  var affectedVertexIds: [VertexId]
  var fixedSide: DimensionFixedSide
}

struct EditablePlanPoint2D: Equatable {
  var x: Double
  var y: Double
}

struct EditableDimensionAnnotation: Equatable {
  var id: DimensionAnnotationId
  var type: DimensionEditKind
  var startPoint2D: EditablePlanPoint2D
  var endPoint2D: EditablePlanPoint2D
  var measuredValueMeters: Double
  var label: String
  var editable: Bool
  var target: DimensionEditTarget
  var witnessStart2D: EditablePlanPoint2D?
  var witnessEnd2D: EditablePlanPoint2D?
}

// MARK: - Root model

struct EditableFloorPlanModel: Equatable {
  var id: UUID
  var sourceScanId: String
  var unit: EditableFloorPlanUnit
  var vertices: [EditableVertex]
  var walls: [EditableWall]
  var openings: [EditableOpening]
  var objects: [EditableObject]
  var floorPolygon: [VertexId]
  var ceilingEnabled: Bool
  var wallHeight: Double
  var wallThickness: Double
  var floorY: Double
  var bounds: EditableFloorPlanBounds
  /// Scan OBB footprint (matches 3D banner); walls may extend beyond this after content padding.
  var scanFootprintBounds: EditableFloorPlanBounds
  /// Canonical long/short footprint edges — same source as the 3D dimensions banner.
  var footprintLongM: Double
  var footprintShortM: Double
  /// Plan angle (radians) of world +X after alignment rotations.
  var worldEastPlanAngleRad: Double
  /// True geographic north in plan coordinates; nil = scan axes only (world −Z).
  var trueNorthPlanAngleRad: Double?
  /// Captured scan bearing of world +X (degrees clockwise from true north).
  var scanWorldPlusXBearingDeg: Double?
  /// Manual correction (degrees) added to [scanWorldPlusXBearingDeg] for compass north.
  var northCorrectionDeg: Double
  var metadata: EditableFloorPlanMetadata
  var dimensionAnnotations: [EditableDimensionAnnotation]

  func vertex(_ id: VertexId) -> EditableVertex? {
    vertices.first { $0.id == id }
  }

  func wall(_ id: WallId) -> EditableWall? {
    walls.first { $0.id == id }
  }

  /// Angle (radians, in world X/Z) of the longest wall. Used to align the floor tile grid so its
  /// lines run parallel/perpendicular to the walls instead of the world axes.
  var dominantWallAngle: Float {
    var bestLength: Double = -1
    var bestAngle: Float = 0
    for wall in walls {
      guard let start = vertex(wall.startVertexId), let end = vertex(wall.endVertexId) else {
        continue
      }
      let dx = end.x - start.x
      let dz = end.z - start.z
      let length = (dx * dx + dz * dz).squareRoot()
      if length > bestLength {
        bestLength = length
        bestAngle = Float(atan2(dz, dx))
      }
    }
    return bestAngle
  }
}
