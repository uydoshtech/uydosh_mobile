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
  var start: FloorPlanPoint2D
  var end: FloorPlanPoint2D
  var label: String
  var offset: CGFloat
  var type: DimensionLineType
  /// Extension-line anchors on the measured geometry (architectural witness lines).
  var witnessStart: FloorPlanPoint2D?
  var witnessEnd: FloorPlanPoint2D?
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
}

enum FloorPlanDimensionMode: Int, CaseIterable {
  case overall = 0
  case wallSegments = 1
  case hidden = 2
}
