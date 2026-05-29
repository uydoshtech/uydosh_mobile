import CoreGraphics

/// Rotates the floor plan so the longest wall segment is horizontal.
enum FloorPlanAlignmentService {
  static func alignToLongestWall(_ model: FloorPlanModel) -> FloorPlanModel {
    guard let wall = model.walls.max(by: { $0.length < $1.length }),
      wall.length >= 0.2
    else {
      return model
    }

    let dx = wall.end.x - wall.start.x
    let dy = wall.end.y - wall.start.y
    guard hypot(dx, dy) > 1e-4 else { return model }

    let angle = -atan2(dy, dx)
    guard abs(angle) > 1e-5 else {
      return finalizeAligned(model)
    }

    let pivot = model.bounds.center
    return finalizeAligned(rotateModel(model, by: angle, pivot: pivot))
  }

  private static func finalizeAligned(_ model: FloorPlanModel) -> FloorPlanModel {
    var aligned = model
    aligned.footprintYaw = 0
    aligned.planCenter = aligned.bounds.center
    aligned.overallDimensions = FloorPlanProjectionService.axisAlignedOverallDimensions(
      bounds: aligned.bounds,
      width: aligned.overallWidth,
      length: aligned.overallLength
    )
    aligned.wallSegmentDimensions = FloorPlanProjectionService.wallSegmentDimensions(for: aligned.walls)
    return aligned
  }

  private static func rotateModel(
    _ model: FloorPlanModel,
    by angle: CGFloat,
    pivot: FloorPlanPoint2D
  ) -> FloorPlanModel {
    func rotate(_ point: FloorPlanPoint2D) -> FloorPlanPoint2D {
      rotatePoint(point, around: pivot, by: angle)
    }

    let walls = model.walls.map { wall in
      FloorPlanWall(
        start: rotate(wall.start),
        end: rotate(wall.end),
        thickness: wall.thickness,
        length: wall.length
      )
    }
    let objects = model.objects.map { object in
      FloorPlanObject(
        center: rotate(object.center),
        corners: object.corners.map(rotate),
        width: object.width,
        length: object.length,
        rotation: object.rotation + angle,
        category: object.category,
        label: object.label
      )
    }
    let doors = model.doors.map { door in
      FloorPlanOpening(
        type: door.type,
        start: rotate(door.start),
        end: rotate(door.end),
        width: door.width
      )
    }
    let windows = model.windows.map { window in
      FloorPlanOpening(
        type: window.type,
        start: rotate(window.start),
        end: rotate(window.end),
        width: window.width
      )
    }
    let openings = model.openings.map { opening in
      FloorPlanOpening(
        type: opening.type,
        start: rotate(opening.start),
        end: rotate(opening.end),
        width: opening.width
      )
    }
    let boundary = model.boundary.map(rotate)
    let bounds = boundsFor(points: boundary.isEmpty ? wallPoints(walls) : boundary)

    return FloorPlanModel(
      walls: walls,
      objects: objects,
      doors: doors,
      windows: windows,
      openings: openings,
      boundary: boundary,
      bounds: bounds,
      overallWidth: model.overallWidth,
      overallLength: model.overallLength,
      overallDimensions: [],
      wallSegmentDimensions: [],
      footprintYaw: 0,
      planCenter: bounds.center,
      orientationEastPlanAngleRad: model.orientationEastPlanAngleRad - angle,
      orientationTrueNorthPlanAngleRad: model.orientationTrueNorthPlanAngleRad.map { $0 - angle },
      orientationScanWorldPlusXBearingDeg: model.orientationScanWorldPlusXBearingDeg,
      orientationNorthCorrectionDeg: model.orientationNorthCorrectionDeg,
      orientationHasGeographicNorth: model.orientationHasGeographicNorth
    )
  }

  private static func rotatePoint(
    _ point: FloorPlanPoint2D,
    around center: FloorPlanPoint2D,
    by angle: CGFloat
  ) -> FloorPlanPoint2D {
    let dx = point.x - center.x
    let dy = point.y - center.y
    let cosA = cos(angle)
    let sinA = sin(angle)
    return FloorPlanPoint2D(
      x: center.x + dx * cosA - dy * sinA,
      y: center.y + dx * sinA + dy * cosA
    )
  }

  private static func wallPoints(_ walls: [FloorPlanWall]) -> [FloorPlanPoint2D] {
    walls.flatMap { [$0.start, $0.end] }
  }

  private static func boundsFor(points: [FloorPlanPoint2D]) -> FloorPlanBounds {
    guard !points.isEmpty else {
      return FloorPlanBounds(minX: 0, maxX: 1, minY: 0, maxY: 1)
    }
    var minX = points[0].x
    var maxX = points[0].x
    var minY = points[0].y
    var maxY = points[0].y
    for p in points.dropFirst() {
      minX = min(minX, p.x)
      maxX = max(maxX, p.x)
      minY = min(minY, p.y)
      maxY = max(maxY, p.y)
    }
    return FloorPlanBounds(minX: minX, maxX: maxX, minY: minY, maxY: maxY)
  }
}
