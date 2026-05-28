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
  /// Canonical long/short footprint edges — same source as the 3D dimensions banner.
  var footprintLongM: Double
  var footprintShortM: Double
  var metadata: EditableFloorPlanMetadata
  var dimensionAnnotations: [EditableDimensionAnnotation]

  func vertex(_ id: VertexId) -> EditableVertex? {
    vertices.first { $0.id == id }
  }

  func wall(_ id: WallId) -> EditableWall? {
    walls.first { $0.id == id }
  }
}
