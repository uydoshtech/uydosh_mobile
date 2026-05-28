import CoreGraphics
import Foundation

/// Builds dimension annotations and renderable dimension lines from the editable model.
enum DimensionLineService {
  private static let metersFormat = "%.2f m"

  static func annotations(for model: EditableFloorPlanModel) -> [EditableDimensionAnnotation] {
    let bounds = model.bounds
    let offset = max(model.footprintLongM, model.footprintShortM) * 0.10 + 0.45
    // After alignment the long edge is horizontal (+X), short edge is vertical (+Z).
    let longM = model.footprintLongM
    let shortM = model.footprintShortM

    let maxXVertices = verticesNearMaxX(in: model)
    let maxZVertices = verticesNearMaxZ(in: model)

    // Long edge (matches 3D banner) — horizontal below the room; resize moves maxX.
    let longY = -bounds.minZ - offset
    let longAnnotation = EditableDimensionAnnotation(
      id: UUID(),
      type: .overallWidth,
      startPoint2D: EditablePlanPoint2D(x: bounds.minX, y: longY),
      endPoint2D: EditablePlanPoint2D(x: bounds.maxX, y: longY),
      measuredValueMeters: longM,
      label: String(format: metersFormat, longM),
      editable: true,
      target: DimensionEditTarget(
        editType: .resizeWidth,
        affectedWallIds: wallsTouchingMaxX(in: model),
        affectedVertexIds: maxXVertices.map(\.id),
        fixedSide: .minX
      ),
      witnessStart2D: EditablePlanPoint2D(x: bounds.minX, y: -bounds.minZ),
      witnessEnd2D: EditablePlanPoint2D(x: bounds.maxX, y: -bounds.minZ)
    )

    // Short edge — vertical to the right; resize moves maxZ.
    let shortX = bounds.maxX + offset
    let shortAnnotation = EditableDimensionAnnotation(
      id: UUID(),
      type: .overallLength,
      startPoint2D: EditablePlanPoint2D(x: shortX, y: -bounds.maxZ),
      endPoint2D: EditablePlanPoint2D(x: shortX, y: -bounds.minZ),
      measuredValueMeters: shortM,
      label: String(format: metersFormat, shortM),
      editable: true,
      target: DimensionEditTarget(
        editType: .resizeLength,
        affectedWallIds: wallsTouchingMaxZ(in: model),
        affectedVertexIds: maxZVertices.map(\.id),
        fixedSide: .minZ
      ),
      witnessStart2D: EditablePlanPoint2D(x: bounds.maxX, y: -bounds.maxZ),
      witnessEnd2D: EditablePlanPoint2D(x: bounds.maxX, y: -bounds.minZ)
    )

    return [longAnnotation, shortAnnotation]
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

  static func wallSegmentLines(for model: EditableFloorPlanModel) -> [DimensionLine] {
    var lines: [DimensionLine] = []
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
      let sPlan = planPoint(x: start.x + nx * offset, z: start.z + nz * offset)
      let ePlan = planPoint(x: end.x + nx * offset, z: end.z + nz * offset)
      lines.append(
        DimensionLine(
          id: UUID(),
          start: sPlan,
          end: ePlan,
          label: String(format: metersFormat, wall.computedLength),
          offset: offset,
          type: .wallSegment,
          witnessStart: planPoint(x: start.x, z: start.z),
          witnessEnd: planPoint(x: end.x, z: end.z),
          isEditable: false,
          editKind: nil
        )
      )
    }
    return lines
  }

  private static func planPoint(x: Double, z: Double) -> FloorPlanPoint2D {
    FloorPlanPoint2D(x: CGFloat(x), y: CGFloat(-z))
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
