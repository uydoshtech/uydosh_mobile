import CoreGraphics
import Foundation

/// Projects EditableFloorPlanModel into the read-only FloorPlanModel used by the 2D canvas.
enum EditableFloorPlanProjector {
  static func project(
    _ model: EditableFloorPlanModel,
    objectLabels: FloorPlanObjectLabels = .englishFallback
  ) -> FloorPlanModel {
    let walls = model.walls.compactMap { wall -> FloorPlanWall? in
      guard let start = model.vertex(wall.startVertexId),
        let end = model.vertex(wall.endVertexId)
      else { return nil }
      return FloorPlanWall(
        start: planPoint(x: start.x, z: start.z),
        end: planPoint(x: end.x, z: end.z),
        thickness: CGFloat(wall.thickness),
        length: CGFloat(wall.computedLength)
      )
    }

    let boundary = model.floorPolygon.compactMap { id -> FloorPlanPoint2D? in
      guard let vertex = model.vertex(id) else { return nil }
      return planPoint(x: vertex.x, z: vertex.z)
    }

    var doors: [FloorPlanOpening] = []
    var windows: [FloorPlanOpening] = []
    var misc: [FloorPlanOpening] = []

    for opening in model.openings {
      guard let segment = openingSegment(opening, in: model) else { continue }
      let fpOpening = FloorPlanOpening(
        type: mapOpeningType(opening.type),
        start: segment.start,
        end: segment.end,
        width: CGFloat(opening.width)
      )
      switch opening.type {
      case .door: doors.append(fpOpening)
      case .window: windows.append(fpOpening)
      case .opening: misc.append(fpOpening)
      }
    }

    let objects = model.objects.map { object in
      let corners = objectFootprintCorners(for: object)
      return FloorPlanObject(
        center: planPoint(x: object.centerX, z: object.centerZ),
        corners: corners,
        width: CGFloat(object.width),
        length: CGFloat(object.length),
        rotation: CGFloat(object.rotationRadians),
        category: object.type.rawValue,
        label: objectLabels.label(for: object.type),
        isOutsideBounds: object.isOutsideBounds
      )
    }

    // Overall dims sit on the drawn wall rectangle (see DimensionLineService); wall
    // segments remain available alongside them.
    let overallDimensions = DimensionLineService.renderLines(
      from: model.dimensionAnnotations.filter {
        $0.type == .overallWidth || $0.type == .overallLength
      }
    )
    let wallSegmentDimensions = DimensionLineService.renderLines(
      from: model.dimensionAnnotations.filter { $0.type == .wallSegmentLength }
    )

    // Center / size on the actually-drawn geometry so the plan sits in the middle of the canvas.
    // The footprint OBB is intentionally excluded: extracted walls may not fill it, which would
    // otherwise offset the plan toward one side.
    let bounds = drawnBounds(
      walls: walls,
      objects: objects,
      openings: doors + windows + misc,
      boundary: boundary,
      fallback: planBounds(model.bounds)
    )

    return FloorPlanModel(
      walls: walls,
      objects: objects,
      doors: doors,
      windows: windows,
      openings: misc,
      boundary: boundary,
      bounds: bounds,
      overallWidth: CGFloat(model.footprintShortM),
      overallLength: CGFloat(model.footprintLongM),
      overallDimensions: overallDimensions,
      wallSegmentDimensions: wallSegmentDimensions,
      footprintYaw: 0,
      planCenter: bounds.center,
      orientationEastPlanAngleRad: CGFloat(model.worldEastPlanAngleRad),
      orientationTrueNorthPlanAngleRad: model.trueNorthPlanAngleRad.map { CGFloat($0) },
      orientationScanWorldPlusXBearingDeg: model.scanWorldPlusXBearingDeg.map { CGFloat($0) },
      orientationNorthCorrectionDeg: CGFloat(model.northCorrectionDeg),
      orientationHasGeographicNorth: model.scanWorldPlusXBearingDeg != nil
    )
  }

  private static func openingSegment(
    _ opening: EditableOpening,
    in model: EditableFloorPlanModel
  ) -> (start: FloorPlanPoint2D, end: FloorPlanPoint2D)? {
    guard let wall = model.wall(opening.wallId),
      let start = model.vertex(wall.startVertexId),
      let end = model.vertex(wall.endVertexId)
    else { return nil }
    let dx = end.x - start.x
    let dz = end.z - start.z
    let len = hypot(dx, dz)
    guard len > 1e-4 else { return nil }
    let ux = dx / len
    let uz = dz / len
    let sX = start.x + ux * opening.offsetFromWallStart
    let sZ = start.z + uz * opening.offsetFromWallStart
    let eX = sX + ux * opening.width
    let eZ = sZ + uz * opening.width
    return (planPoint(x: sX, z: sZ), planPoint(x: eX, z: eZ))
  }

  private static func objectFootprintCorners(for object: EditableObject) -> [FloorPlanPoint2D] {
    if object.cornersXZ.count >= 3 {
      return object.cornersXZ.map { planPoint(x: $0.x, z: $0.z) }
    }
    return orientedCorners(for: object)
  }

  private static func orientedCorners(for object: EditableObject) -> [FloorPlanPoint2D] {
    let halfLength = object.length * 0.5
    let halfWidth = object.width * 0.5
    let cosA = cos(object.rotationRadians)
    let sinA = sin(object.rotationRadians)
    let local: [(Double, Double)] = [
      (-halfLength, -halfWidth),
      (halfLength, -halfWidth),
      (halfLength, halfWidth),
      (-halfLength, halfWidth),
    ]
    return local.map { lx, lz in
      let rx = lx * cosA - lz * sinA
      let rz = lx * sinA + lz * cosA
      return planPoint(x: object.centerX + rx, z: object.centerZ + rz)
    }
  }

  private static func planPoint(x: Double, z: Double) -> FloorPlanPoint2D {
    FloorPlanPoint2D(x: CGFloat(x), y: CGFloat(-z))
  }

  /// Tight bounding box of everything actually rendered. Furniture flagged outside the footprint is
  /// excluded so a stray object can't drag the centering off; the footprint boundary is only counted
  /// when there are no walls (the only case it gets drawn).
  private static func drawnBounds(
    walls: [FloorPlanWall],
    objects: [FloorPlanObject],
    openings: [FloorPlanOpening],
    boundary: [FloorPlanPoint2D],
    fallback: FloorPlanBounds
  ) -> FloorPlanBounds {
    var points: [FloorPlanPoint2D] = []
    points.append(contentsOf: walls.flatMap { [$0.start, $0.end] })
    points.append(contentsOf: objects.filter { !$0.isOutsideBounds }.flatMap { $0.corners })
    points.append(contentsOf: openings.flatMap { [$0.start, $0.end] })
    if walls.isEmpty {
      points.append(contentsOf: boundary)
    }

    guard let first = points.first else { return fallback }
    var minX = first.x
    var maxX = first.x
    var minY = first.y
    var maxY = first.y
    for point in points.dropFirst() {
      minX = min(minX, point.x)
      maxX = max(maxX, point.x)
      minY = min(minY, point.y)
      maxY = max(maxY, point.y)
    }
    return FloorPlanBounds(minX: minX, maxX: maxX, minY: minY, maxY: maxY)
  }

  private static func planBounds(_ bounds: EditableFloorPlanBounds) -> FloorPlanBounds {
    FloorPlanBounds(
      minX: CGFloat(bounds.minX),
      maxX: CGFloat(bounds.maxX),
      minY: CGFloat(-bounds.maxZ),
      maxY: CGFloat(-bounds.minZ)
    )
  }

  private static func mapOpeningType(_ type: EditableOpeningKind) -> FloorPlanOpeningType {
    switch type {
    case .door: return .door
    case .window: return .window
    case .opening: return .opening
    }
  }
}
