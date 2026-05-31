import CoreGraphics
import Foundation

/// Builds dimension annotations and renderable dimension lines from the editable model.
enum DimensionLineService {
  private static let metersFormat = "%.2f m"

  static func annotations(for model: EditableFloorPlanModel) -> [EditableDimensionAnnotation] {
    let scan = model.scanFootprintBounds
    let offset = max(model.footprintLongM, model.footprintShortM) * 0.10 + 0.45
    // After alignment the long edge is horizontal (+X), short edge is vertical (+Z).
    let longM = model.footprintLongM
    let shortM = model.footprintShortM

    let maxXVertices = verticesNearMaxX(in: model)
    let maxZVertices = verticesNearMaxZ(in: model)

    // Long edge (matches 3D banner) — horizontal below the scan footprint.
    let longY = -scan.maxZ - offset
    let longAnnotation = EditableDimensionAnnotation(
      id: UUID(),
      type: .overallWidth,
      startPoint2D: EditablePlanPoint2D(x: scan.minX, y: longY),
      endPoint2D: EditablePlanPoint2D(x: scan.maxX, y: longY),
      measuredValueMeters: longM,
      label: String(format: metersFormat, longM),
      editable: true,
      target: DimensionEditTarget(
        editType: .resizeWidth,
        affectedWallIds: wallsTouchingMaxX(in: model),
        affectedVertexIds: maxXVertices.map(\.id),
        fixedSide: .minX
      ),
      witnessStart2D: EditablePlanPoint2D(x: scan.minX, y: -scan.maxZ),
      witnessEnd2D: EditablePlanPoint2D(x: scan.maxX, y: -scan.maxZ)
    )

    // Short edge — vertical to the right of the scan footprint.
    let shortX = scan.maxX + offset
    let shortAnnotation = EditableDimensionAnnotation(
      id: UUID(),
      type: .overallLength,
      startPoint2D: EditablePlanPoint2D(x: shortX, y: -scan.maxZ),
      endPoint2D: EditablePlanPoint2D(x: shortX, y: -scan.minZ),
      measuredValueMeters: shortM,
      label: String(format: metersFormat, shortM),
      editable: true,
      target: DimensionEditTarget(
        editType: .resizeLength,
        affectedWallIds: wallsTouchingMaxZ(in: model),
        affectedVertexIds: maxZVertices.map(\.id),
        fixedSide: .minZ
      ),
      witnessStart2D: EditablePlanPoint2D(x: scan.maxX, y: -scan.maxZ),
      witnessEnd2D: EditablePlanPoint2D(x: scan.maxX, y: -scan.minZ)
    )

    return [longAnnotation, shortAnnotation] + wallSegmentAnnotations(for: model)
  }

  /// Editable annotations for each wall segment. Editing a segment resizes it together with the
  /// wall parallel to it (a horizontal wall drives overall width, a vertical wall drives length),
  /// keeping the room rectangular.
  static func wallSegmentAnnotations(for model: EditableFloorPlanModel) -> [EditableDimensionAnnotation] {
    var result: [EditableDimensionAnnotation] = []
    for wall in model.walls where wall.computedLength >= 0.25 {
      guard let start = model.vertex(wall.startVertexId),
        let end = model.vertex(wall.endVertexId)
      else { continue }
      let dx = end.x - start.x
      let dz = end.z - start.z
      let len = hypot(dx, dz)
      guard len > 1e-4 else { continue }
      let nx = -dz / len
      let nz = dx / len
      let offset = 0.22
      // After alignment the long edge is horizontal (+X) and drives width; the short edge is
      // vertical (+Z) and drives length.
      let editType: DimensionEditType = abs(dx) >= abs(dz) ? .resizeWidth : .resizeLength
      result.append(
        EditableDimensionAnnotation(
          id: UUID(),
          type: .wallSegmentLength,
          startPoint2D: EditablePlanPoint2D(x: start.x + nx * offset, y: -(start.z + nz * offset)),
          endPoint2D: EditablePlanPoint2D(x: end.x + nx * offset, y: -(end.z + nz * offset)),
          measuredValueMeters: wall.computedLength,
          label: String(format: metersFormat, wall.computedLength),
          editable: true,
          target: DimensionEditTarget(
            editType: editType,
            affectedWallIds: [wall.id],
            affectedVertexIds: [wall.startVertexId, wall.endVertexId],
            fixedSide: .auto
          ),
          witnessStart2D: EditablePlanPoint2D(x: start.x, y: -start.z),
          witnessEnd2D: EditablePlanPoint2D(x: end.x, y: -end.z)
        )
      )
    }
    return result
  }

  static func renderLines(from annotations: [EditableDimensionAnnotation]) -> [DimensionLine] {
    annotations.map { annotation in
      DimensionLine(
        id: annotation.id,
        start: planPoint(x: annotation.startPoint2D.x, y: annotation.startPoint2D.y),
        end: planPoint(x: annotation.endPoint2D.x, y: annotation.endPoint2D.y),
        label: annotation.label,
        offset: 0,
        type: annotation.type == .wallSegmentLength ? .wallSegment : .overall,
        witnessStart: annotation.witnessStart2D.map { planPoint(x: $0.x, y: $0.y) },
        witnessEnd: annotation.witnessEnd2D.map { planPoint(x: $0.x, y: $0.y) },
        isEditable: annotation.editable,
        editKind: annotation.type
      )
    }
  }

  private static func planPoint(x: Double, y: Double) -> FloorPlanPoint2D {
    FloorPlanPoint2D(x: CGFloat(x), y: CGFloat(y))
  }

  private static let tolerance = 0.05

  private static func verticesNearMaxX(in model: EditableFloorPlanModel) -> [EditableVertex] {
    model.vertices.filter { abs($0.x - model.bounds.maxX) < tolerance }
  }

  private static func verticesNearMinX(in model: EditableFloorPlanModel) -> [EditableVertex] {
    model.vertices.filter { abs($0.x - model.bounds.minX) < tolerance }
  }

  private static func verticesNearMaxZ(in model: EditableFloorPlanModel) -> [EditableVertex] {
    model.vertices.filter { abs($0.z - model.bounds.maxZ) < tolerance }
  }

  private static func verticesNearMinZ(in model: EditableFloorPlanModel) -> [EditableVertex] {
    model.vertices.filter { abs($0.z - model.bounds.minZ) < tolerance }
  }

  private static func wallsTouchingMaxX(in model: EditableFloorPlanModel) -> [WallId] {
    let ids = Set(verticesNearMaxX(in: model).map(\.id))
    return model.walls.filter { ids.contains($0.startVertexId) || ids.contains($0.endVertexId) }.map(\.id)
  }

  private static func wallsTouchingMaxZ(in model: EditableFloorPlanModel) -> [WallId] {
    let ids = Set(verticesNearMaxZ(in: model).map(\.id))
    return model.walls.filter { ids.contains($0.startVertexId) || ids.contains($0.endVertexId) }.map(\.id)
  }
}
