import CoreGraphics
import Foundation

/// Projects EditableFloorPlanModel into the read-only FloorPlanModel used by the 2D canvas.
enum EditableFloorPlanProjector {
  static func project(_ model: EditableFloorPlanModel) -> FloorPlanModel {
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

    let bounds = planBounds(model.bounds)
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
        label: label(for: object.type),
        isOutsideBounds: object.isOutsideBounds
      )
    }

    let overallDimensions = DimensionLineService.renderLines(from: model.dimensionAnnotations)
    let wallSegmentDimensions = DimensionLineService.wallSegmentLines(for: model)

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
      planCenter: bounds.center
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

  private static func label(for type: EditableObjectType) -> String {
    switch type {
    case .bed: return "Bed"
    case .sofa: return "Sofa"
    case .table: return "Table"
    case .chair: return "Chair"
    case .storage: return "Storage"
    case .appliance: return "Appliance"
    case .cabinet: return "Cabinet"
    case .television: return "TV"
    case .fixture: return "Fixture"
    case .unknown: return "Object"
    }
  }
}
