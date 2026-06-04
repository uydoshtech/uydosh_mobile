import CoreGraphics
import Foundation

/// A point on the 2D floor plan. `x` maps from 3D X; `y` maps from 3D −Z.
struct FloorPlanPoint2D: Equatable {
  var x: CGFloat
  var y: CGFloat
}

struct FloorPlanBounds: Equatable {
  var minX: CGFloat
  var maxX: CGFloat
  var minY: CGFloat
  var maxY: CGFloat

  var width: CGFloat { maxX - minX }
  var height: CGFloat { maxY - minY }
  var center: FloorPlanPoint2D {
    FloorPlanPoint2D(x: (minX + maxX) * 0.5, y: (minY + maxY) * 0.5)
  }
}

enum FloorPlanOpeningType: Equatable {
  case door
  case window
  case opening
}

struct FloorPlanWall: Equatable {
  var start: FloorPlanPoint2D
  var end: FloorPlanPoint2D
  var thickness: CGFloat
  var length: CGFloat
}

struct FloorPlanObject: Equatable {
  var center: FloorPlanPoint2D
  /// Bottom-face corners in plan space (matches 3D mesh orientation).
  var corners: [FloorPlanPoint2D]
  var width: CGFloat
  var length: CGFloat
  var rotation: CGFloat
  var category: String
  var label: String
  var isOutsideBounds: Bool

  init(
    center: FloorPlanPoint2D,
    corners: [FloorPlanPoint2D],
    width: CGFloat,
    length: CGFloat,
    rotation: CGFloat,
    category: String,
    label: String,
    isOutsideBounds: Bool = false
  ) {
    self.center = center
    self.corners = corners
    self.width = width
    self.length = length
    self.rotation = rotation
    self.category = category
    self.label = label
    self.isOutsideBounds = isOutsideBounds
  }
}

struct FloorPlanOpening: Equatable {
  var type: FloorPlanOpeningType
  var start: FloorPlanPoint2D
  var end: FloorPlanPoint2D
  var width: CGFloat
}

enum DimensionLineType: Equatable {
  case overall
  case wallSegment
  case object
}

struct DimensionLine: Equatable {
  var id: UUID
  var start: FloorPlanPoint2D
  var end: FloorPlanPoint2D
  var label: String
  var offset: CGFloat
  var type: DimensionLineType
  /// Extension-line anchors on the measured geometry (architectural witness lines).
  var witnessStart: FloorPlanPoint2D?
  var witnessEnd: FloorPlanPoint2D?
  var isEditable: Bool
  var editKind: DimensionEditKind?

  init(
    id: UUID = UUID(),
    start: FloorPlanPoint2D,
    end: FloorPlanPoint2D,
    label: String,
    offset: CGFloat,
    type: DimensionLineType,
    witnessStart: FloorPlanPoint2D? = nil,
    witnessEnd: FloorPlanPoint2D? = nil,
    isEditable: Bool = false,
    editKind: DimensionEditKind? = nil
  ) {
    self.id = id
    self.start = start
    self.end = end
    self.label = label
    self.offset = offset
    self.type = type
    self.witnessStart = witnessStart
    self.witnessEnd = witnessEnd
    self.isEditable = isEditable
    self.editKind = editKind
  }
}

struct FloorPlanModel: Equatable {
  var walls: [FloorPlanWall]
  var objects: [FloorPlanObject]
  var doors: [FloorPlanOpening]
  var windows: [FloorPlanOpening]
  var openings: [FloorPlanOpening]
  var boundary: [FloorPlanPoint2D]
  var bounds: FloorPlanBounds
  var overallWidth: CGFloat
  var overallLength: CGFloat
  var overallDimensions: [DimensionLine]
  var wallSegmentDimensions: [DimensionLine]
  /// Yaw (radians) of the long room edge in world X/Z; matches SceneKit top-down camera.
  var footprintYaw: CGFloat
  /// Footprint center in plan coordinates — same pivot as the 3D top-down camera.
  var planCenter: FloorPlanPoint2D
  /// Plan angle (radians) of world +X (east) relative to plan +X.
  var orientationEastPlanAngleRad: CGFloat
  /// When set, compass north arrow follows this plan angle.
  var orientationTrueNorthPlanAngleRad: CGFloat?
  /// Scan captured geographic bearing of world +X; nil = scan-north fallback only.
  var orientationScanWorldPlusXBearingDeg: CGFloat?
  /// Manual correction applied on top of scan bearing.
  var orientationNorthCorrectionDeg: CGFloat
  /// True when scan-time compass heading was stored (vs scan-axis fallback).
  var orientationHasGeographicNorth: Bool

  var orientationUsesTrueNorth: Bool {
    orientationTrueNorthPlanAngleRad != nil
  }

  var orientationNorthIsAdjusted: Bool {
    abs(orientationNorthCorrectionDeg) > 0.01
  }
}

enum FloorPlanDimensionMode: Int, CaseIterable {
  case overall = 0
  case wallSegments = 1
  case hidden = 2
}

/// Temporary diagnostics for the 2D floor-plan projection. Flip `isEnabled` to true to log the
/// projected bounding box / scale / per-wall geometry and draw debug markers on the canvas.
enum FloorPlanDebug {
  static var isEnabled = false

  static func log(_ message: @autoclosure () -> String) {
    guard isEnabled else { return }
    NSLog("[FloorPlanDebug] %@", message())
  }
}
