import Foundation

/// Rotates editable floor plan geometry so the longest wall is horizontal (+X).
enum EditableFloorPlanAlignService {
  /// Aligns scan geometry using RoomScan footprint yaw (OBB long edge → +X).
  static func alignToScanOrientation(
    _ model: EditableFloorPlanModel,
    footprintYaw: Double
  ) -> EditableFloorPlanModel {
    let angle = -footprintYaw
    guard abs(angle) > 1e-5 else { return recalculate(model) }
    let pivotX = model.bounds.minX + model.bounds.width * 0.5
    let pivotZ = model.bounds.minZ + model.bounds.length * 0.5
    return rotate(model, by: angle, pivotX: pivotX, pivotZ: pivotZ)
  }

  static func alignToLongestWall(_ model: EditableFloorPlanModel) -> EditableFloorPlanModel {
    guard let wall = model.walls.max(by: { $0.computedLength < $1.computedLength }),
      wall.computedLength >= 0.2,
      let start = model.vertex(wall.startVertexId),
      let end = model.vertex(wall.endVertexId)
    else {
      return model
    }

    let dx = end.x - start.x
    let dz = end.z - start.z
    guard hypot(dx, dz) > 1e-4 else { return model }

    let angle = -atan2(dz, dx)
    guard abs(angle) > 1e-5 else {
      return recalculate(model)
    }

    let pivotX = model.bounds.minX + model.bounds.width * 0.5
    let pivotZ = model.bounds.minZ + model.bounds.length * 0.5
    return rotate(model, by: angle, pivotX: pivotX, pivotZ: pivotZ)
  }

  private static func rotate(
    _ model: EditableFloorPlanModel,
    by angle: Double,
    pivotX: Double,
    pivotZ: Double
  ) -> EditableFloorPlanModel {
    func rotatePoint(x: Double, z: Double) -> (x: Double, z: Double) {
      let dx = x - pivotX
      let dz = z - pivotZ
      let cosA = cos(angle)
      let sinA = sin(angle)
      return (
        x: pivotX + dx * cosA - dz * sinA,
        z: pivotZ + dx * sinA + dz * cosA
      )
    }

    func rotateBounds(_ bounds: EditableFloorPlanBounds) -> EditableFloorPlanBounds {
      let corners = [
        (bounds.minX, bounds.minZ),
        (bounds.maxX, bounds.minZ),
        (bounds.maxX, bounds.maxZ),
        (bounds.minX, bounds.maxZ),
      ]
      let rotated = corners.map { rotatePoint(x: $0.0, z: $0.1) }
      return EditableFloorPlanBoundsCalculator.bounds(
        for: rotated.map { EditableVertex(id: UUID(), x: $0.0, z: $0.1, locked: true) }
      )
    }

    var updated = model
    updated.worldEastPlanAngleRad = model.worldEastPlanAngleRad - angle
    if var trueNorth = updated.trueNorthPlanAngleRad {
      trueNorth -= angle
      updated.trueNorthPlanAngleRad = trueNorth
    }
    updated.vertices = model.vertices.map { vertex in
      var v = vertex
      let rotated = rotatePoint(x: vertex.x, z: vertex.z)
      v.x = rotated.x
      v.z = rotated.z
      return v
    }
    updated.objects = model.objects.map { object in
      var o = object
      o.cornersXZ = object.cornersXZ.map { corner in
        let rotated = rotatePoint(x: corner.x, z: corner.z)
        return EditablePointXZ(x: rotated.x, z: rotated.z)
      }
      if !o.cornersXZ.isEmpty {
        o.centerX = o.cornersXZ.map(\.x).reduce(0, +) / Double(o.cornersXZ.count)
        o.centerZ = o.cornersXZ.map(\.z).reduce(0, +) / Double(o.cornersXZ.count)
        if o.cornersXZ.count >= 2 {
          let c0 = o.cornersXZ[0]
          let c1 = o.cornersXZ[1]
          o.rotationRadians = atan2(c1.z - c0.z, c1.x - c0.x)
        } else {
          o.rotationRadians += angle
        }
      } else {
        let rotated = rotatePoint(x: object.centerX, z: object.centerZ)
        o.centerX = rotated.x
        o.centerZ = rotated.z
        o.rotationRadians += angle
      }
      return o
    }
    updated.scanFootprintBounds = rotateBounds(model.scanFootprintBounds)
    return recalculate(updated)
  }

  private static func recalculate(_ model: EditableFloorPlanModel) -> EditableFloorPlanModel {
    var updated = model
    updated.bounds = EditableFloorPlanBoundsCalculator.bounds(for: updated.vertices)
    updated.walls = updated.walls.map { wall in
      var w = wall
      if let start = updated.vertex(w.startVertexId),
        let end = updated.vertex(w.endVertexId)
      {
        w.computedLength = hypot(end.x - start.x, end.z - start.z)
      }
      return w
    }
    return updated
  }
}

enum EditableFloorPlanBoundsCalculator {
  static func bounds(for vertices: [EditableVertex]) -> EditableFloorPlanBounds {
    guard let first = vertices.first else {
      return EditableFloorPlanBounds(minX: 0, maxX: 1, minZ: 0, maxZ: 1)
    }
    var minX = first.x
    var maxX = first.x
    var minZ = first.z
    var maxZ = first.z
    for v in vertices.dropFirst() {
      minX = min(minX, v.x)
      maxX = max(maxX, v.x)
      minZ = min(minZ, v.z)
      maxZ = max(maxZ, v.z)
    }
    return EditableFloorPlanBounds(minX: minX, maxX: maxX, minZ: minZ, maxZ: maxZ)
  }
}
