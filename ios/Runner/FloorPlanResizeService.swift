import Foundation

enum FloorPlanResizeValidationError: Error, Equatable {
  case notNumeric
  case notFinite
  case belowMinimum(Double)
  case aboveMaximum(Double)
  case notPositive
}

struct FloorPlanResizeValidationResult {
  var valueMeters: Double
  var requiresLargeChangeConfirmation: Bool
}

/// Applies overall width/length corrections to the editable floor plan model.
enum FloorPlanResizeService {
  static let minMeters = 0.5
  static let maxMeters = 100.0
  static let boundaryTolerance = 0.05
  static let largeChangeRatio = 0.30

  static func validateInput(_ text: String, currentValue: Double) -> Result<FloorPlanResizeValidationResult, FloorPlanResizeValidationError> {
    let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
      .replacingOccurrences(of: ",", with: ".")
      .replacingOccurrences(of: "m", with: "")
      .trimmingCharacters(in: .whitespacesAndNewlines)
    guard let value = Double(trimmed), !trimmed.isEmpty else {
      return .failure(.notNumeric)
    }
    guard value.isFinite else { return .failure(.notFinite) }
    guard value > 0 else { return .failure(.notPositive) }
    guard value >= minMeters else { return .failure(.belowMinimum(minMeters)) }
    guard value <= maxMeters else { return .failure(.aboveMaximum(maxMeters)) }

    let deltaRatio = currentValue > 1e-6 ? abs(value - currentValue) / currentValue : 0
    return .success(
      FloorPlanResizeValidationResult(
        valueMeters: value,
        requiresLargeChangeConfirmation: deltaRatio > largeChangeRatio
      )
    )
  }

  static func applyWidthChange(to model: EditableFloorPlanModel, newWidth: Double) -> EditableFloorPlanModel {
    let currentWidth = model.footprintLongM
    let delta = newWidth - currentWidth
    guard abs(delta) > 1e-6 else { return model }

    let fixedSide = model.dimensionAnnotations
      .first(where: { $0.type == .overallWidth })?.target.fixedSide ?? .minX
    return applyHorizontalResize(to: model, delta: delta, fixedSide: fixedSide, newLongM: newWidth)
  }

  static func applyLengthChange(to model: EditableFloorPlanModel, newLength: Double) -> EditableFloorPlanModel {
    let currentLength = model.footprintShortM
    let delta = newLength - currentLength
    guard abs(delta) > 1e-6 else { return model }

    let fixedSide = model.dimensionAnnotations
      .first(where: { $0.type == .overallLength })?.target.fixedSide ?? .minZ
    return applyVerticalResize(to: model, delta: delta, fixedSide: fixedSide, newShortM: newLength)
  }

  // MARK: - Resize internals

  private static func applyHorizontalResize(
    to model: EditableFloorPlanModel,
    delta: Double,
    fixedSide: DimensionFixedSide,
    newLongM: Double
  ) -> EditableFloorPlanModel {
    var updated = model
    let moveMin = fixedSide == .maxX
    let targetX = moveMin ? model.bounds.minX : model.bounds.maxX

    updated.vertices = model.vertices.map { vertex in
      guard !vertex.locked, abs(vertex.x - targetX) < boundaryTolerance else { return vertex }
      var v = vertex
      v.x += moveMin ? -delta : delta
      return v
    }

    updated = recalculateDerivedFields(updated)
    updated = adjustAnchoredObjects(in: updated, movedWallIds: wallsOnVerticalSide(updated, maxSide: !moveMin))
    updated = clampFreeObjects(in: updated)
    updated.metadata.isEdited = true
    updated.metadata.updatedAt = Date()
    updated.scanFootprintBounds = resizeScanBoundsHorizontally(
      model.scanFootprintBounds,
      delta: delta,
      fixedSide: fixedSide
    )
    updated.footprintLongM = newLongM
    updated.dimensionAnnotations = DimensionLineService.annotations(for: updated)
    return updated
  }

  private static func applyVerticalResize(
    to model: EditableFloorPlanModel,
    delta: Double,
    fixedSide: DimensionFixedSide,
    newShortM: Double
  ) -> EditableFloorPlanModel {
    var updated = model
    let moveMin = fixedSide == .maxZ
    let targetZ = moveMin ? model.bounds.minZ : model.bounds.maxZ

    updated.vertices = model.vertices.map { vertex in
      guard !vertex.locked, abs(vertex.z - targetZ) < boundaryTolerance else { return vertex }
      var v = vertex
      v.z += moveMin ? -delta : delta
      return v
    }

    updated = recalculateDerivedFields(updated)
    updated = adjustAnchoredObjects(in: updated, movedWallIds: wallsOnHorizontalSide(updated, maxSide: !moveMin))
    updated = clampFreeObjects(in: updated)
    updated.metadata.isEdited = true
    updated.metadata.updatedAt = Date()
    updated.scanFootprintBounds = resizeScanBoundsVertically(
      model.scanFootprintBounds,
      delta: delta,
      fixedSide: fixedSide
    )
    updated.footprintShortM = newShortM
    updated.dimensionAnnotations = DimensionLineService.annotations(for: updated)
    return updated
  }

  private static func resizeScanBoundsHorizontally(
    _ bounds: EditableFloorPlanBounds,
    delta: Double,
    fixedSide: DimensionFixedSide
  ) -> EditableFloorPlanBounds {
    var updated = bounds
    switch fixedSide {
    case .minX, .auto:
      updated.maxX += delta
    case .maxX:
      updated.minX -= delta
    case .minZ, .maxZ:
      break
    }
    return updated
  }

  private static func resizeScanBoundsVertically(
    _ bounds: EditableFloorPlanBounds,
    delta: Double,
    fixedSide: DimensionFixedSide
  ) -> EditableFloorPlanBounds {
    var updated = bounds
    switch fixedSide {
    case .minZ, .auto:
      updated.maxZ += delta
    case .maxZ:
      updated.minZ -= delta
    case .minX, .maxX:
      break
    }
    return updated
  }

  private static func recalculateDerivedFields(_ model: EditableFloorPlanModel) -> EditableFloorPlanModel {
    var updated = model
    updated.bounds = EditableFloorPlanBoundsCalculator.bounds(for: updated.vertices)
    let oldLengths = Dictionary(uniqueKeysWithValues: model.walls.map { ($0.id, $0.computedLength) })

    updated.walls = updated.walls.map { wall in
      var w = wall
      if let start = updated.vertex(w.startVertexId),
        let end = updated.vertex(w.endVertexId)
      {
        w.computedLength = hypot(end.x - start.x, end.z - start.z)
      }
      return w
    }

    updated.openings = updated.openings.map { opening in
      guard opening.keepRelativePosition,
        let oldLength = oldLengths[opening.wallId],
        oldLength > 1e-6,
        let wall = updated.wall(opening.wallId)
      else { return opening }
      var o = opening
      let ratio = wall.computedLength / oldLength
      o.offsetFromWallStart = min(
        max(o.offsetFromWallStart * ratio, 0),
        max(wall.computedLength - o.width, 0)
      )
      return o
    }
    return updated
  }

  private static func wallsOnVerticalSide(_ model: EditableFloorPlanModel, maxSide: Bool) -> Set<WallId> {
    let targetX = maxSide ? model.bounds.maxX : model.bounds.minX
    let vertexIds = Set(
      model.vertices.filter { abs($0.x - targetX) < boundaryTolerance }.map(\.id)
    )
    return Set(
      model.walls.filter { vertexIds.contains($0.startVertexId) || vertexIds.contains($0.endVertexId) }.map(\.id)
    )
  }

  private static func wallsOnHorizontalSide(_ model: EditableFloorPlanModel, maxSide: Bool) -> Set<WallId> {
    let targetZ = maxSide ? model.bounds.maxZ : model.bounds.minZ
    let vertexIds = Set(
      model.vertices.filter { abs($0.z - targetZ) < boundaryTolerance }.map(\.id)
    )
    return Set(
      model.walls.filter { vertexIds.contains($0.startVertexId) || vertexIds.contains($0.endVertexId) }.map(\.id)
    )
  }

  private static func adjustAnchoredObjects(
    in model: EditableFloorPlanModel,
    movedWallIds: Set<WallId>
  ) -> EditableFloorPlanModel {
    var updated = model
    updated.objects = model.objects.map { object in
      guard object.anchor.type != .free,
        let wallId = object.anchor.wallId,
        movedWallIds.contains(wallId),
        let wall = model.wall(wallId),
        let start = model.vertex(wall.startVertexId),
        let end = model.vertex(wall.endVertexId)
      else { return object }

      var o = object
      let dx = end.x - start.x
      let dz = end.z - start.z
      let len = hypot(dx, dz)
      guard len > 1e-4 else { return o }
      let offset = object.anchor.offsetFromWall ?? 0
      let t = min(max(offset / len, 0), 1)
      let px = start.x + dx * t
      let pz = start.z + dz * t
      let dist = object.anchor.distanceFromWall ?? 0.5
      let nx = -dz / len
      let nz = dx / len
      let newCenterX = px + nx * dist
      let newCenterZ = pz + nz * dist
      let moveX = newCenterX - object.centerX
      let moveZ = newCenterZ - object.centerZ
      o.centerX = newCenterX
      o.centerZ = newCenterZ
      if !o.cornersXZ.isEmpty {
        o.cornersXZ = o.cornersXZ.map { EditablePointXZ(x: $0.x + moveX, z: $0.z + moveZ) }
      }
      return o
    }
    return updated
  }

  private static func clampFreeObjects(in model: EditableFloorPlanModel) -> EditableFloorPlanModel {
    var updated = model
    let inset = 0.08
    let minX = model.bounds.minX + inset
    let maxX = model.bounds.maxX - inset
    let minZ = model.bounds.minZ + inset
    let maxZ = model.bounds.maxZ - inset

    updated.objects = model.objects.map { object in
      var o = object
      let halfW = object.width * 0.5
      let halfL = object.length * 0.5
      let clampedX = min(max(object.centerX, minX + halfW), maxX - halfW)
      let clampedZ = min(max(object.centerZ, minZ + halfL), maxZ - halfL)
      o.isOutsideBounds = clampedX != object.centerX || clampedZ != object.centerZ
      let dx = clampedX - object.centerX
      let dz = clampedZ - object.centerZ
      o.centerX = clampedX
      o.centerZ = clampedZ
      if !o.cornersXZ.isEmpty {
        o.cornersXZ = o.cornersXZ.map { EditablePointXZ(x: $0.x + dx, z: $0.z + dz) }
      }
      return o
    }
    return updated
  }
}
