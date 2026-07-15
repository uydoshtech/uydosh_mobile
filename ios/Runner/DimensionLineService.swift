import CoreGraphics
import Foundation

/// Builds dimension annotations and renderable dimension lines from the editable model.
enum DimensionLineService {
  private static let metersFormat = "%.2f m"

  static func annotations(for model: EditableFloorPlanModel) -> [EditableDimensionAnnotation] {
    // Place overall dims on the drawn wall AABB only — never `scanFootprintBounds` and never
    // `model.bounds` when that still includes OBB footprint corners. Those inflate past (or cut
    // through) the blue perimeter on L / multi-room plans.
    let box = EditableFloorPlanBoundsCalculator.wallBounds(for: model)
    let widthM = max(box.maxX - box.minX, 0)
    let lengthM = max(box.maxZ - box.minZ, 0)
    let offset = max(widthM, lengthM, 1) * 0.10 + 0.45

    let maxXVertices = verticesNear(x: box.maxX, in: model)
    let maxZVertices = verticesNear(z: box.maxZ, in: model)

    // Horizontal overall — below the plan (plan Y = -Z).
    let longY = -box.maxZ - offset
    let longAnnotation = EditableDimensionAnnotation(
      id: UUID(),
      type: .overallWidth,
      startPoint2D: EditablePlanPoint2D(x: box.minX, y: longY),
      endPoint2D: EditablePlanPoint2D(x: box.maxX, y: longY),
      measuredValueMeters: widthM,
      label: String(format: metersFormat, widthM),
      editable: true,
      target: DimensionEditTarget(
        editType: .resizeWidth,
        affectedWallIds: wallsTouching(vertexIds: Set(maxXVertices.map(\.id)), in: model),
        affectedVertexIds: maxXVertices.map(\.id),
        fixedSide: .minX
      ),
      witnessStart2D: EditablePlanPoint2D(x: box.minX, y: -box.maxZ),
      witnessEnd2D: EditablePlanPoint2D(x: box.maxX, y: -box.maxZ)
    )

    // Vertical overall — to the right of the plan.
    let shortX = box.maxX + offset
    let shortAnnotation = EditableDimensionAnnotation(
      id: UUID(),
      type: .overallLength,
      startPoint2D: EditablePlanPoint2D(x: shortX, y: -box.maxZ),
      endPoint2D: EditablePlanPoint2D(x: shortX, y: -box.minZ),
      measuredValueMeters: lengthM,
      label: String(format: metersFormat, lengthM),
      editable: true,
      target: DimensionEditTarget(
        editType: .resizeLength,
        affectedWallIds: wallsTouching(vertexIds: Set(maxZVertices.map(\.id)), in: model),
        affectedVertexIds: maxZVertices.map(\.id),
        fixedSide: .minZ
      ),
      witnessStart2D: EditablePlanPoint2D(x: box.maxX, y: -box.maxZ),
      witnessEnd2D: EditablePlanPoint2D(x: box.maxX, y: -box.minZ)
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

  private static func wallVertices(in model: EditableFloorPlanModel) -> [EditableVertex] {
    let ids = Set(model.walls.flatMap { [$0.startVertexId, $0.endVertexId] })
    return model.vertices.filter { ids.contains($0.id) }
  }

  private static func verticesNear(x: Double, in model: EditableFloorPlanModel) -> [EditableVertex] {
    wallVertices(in: model).filter { abs($0.x - x) < tolerance }
  }

  private static func verticesNear(z: Double, in model: EditableFloorPlanModel) -> [EditableVertex] {
    wallVertices(in: model).filter { abs($0.z - z) < tolerance }
  }

  private static func wallsTouching(vertexIds ids: Set<VertexId>, in model: EditableFloorPlanModel) -> [WallId] {
    model.walls.filter { ids.contains($0.startVertexId) || ids.contains($0.endVertexId) }.map(\.id)
  }
}
