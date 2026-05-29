import XCTest
@testable import Runner

final class FloorPlanResizeServiceTests: XCTestCase {
  func testResizeWidthExpandsMaxXSide() {
    var model = makeRectangularRoom(width: 4.0, length: 6.0)
    model = FloorPlanResizeService.applyWidthChange(to: model, newWidth: 5.0)

    XCTAssertEqual(model.bounds.width, 5.0, accuracy: 1e-4)
    XCTAssertEqual(model.bounds.length, 6.0, accuracy: 1e-4)
    XCTAssertEqual(model.bounds.minX, 0.0, accuracy: 1e-4)
    XCTAssertEqual(model.bounds.maxX, 5.0, accuracy: 1e-4)
  }

  func testResizeLengthExpandsMaxZSide() {
    var model = makeRectangularRoom(width: 4.0, length: 6.0)
    model = FloorPlanResizeService.applyLengthChange(to: model, newLength: 7.0)

    XCTAssertEqual(model.bounds.width, 4.0, accuracy: 1e-4)
    XCTAssertEqual(model.bounds.length, 7.0, accuracy: 1e-4)
    XCTAssertEqual(model.bounds.minZ, 0.0, accuracy: 1e-4)
    XCTAssertEqual(model.bounds.maxZ, 7.0, accuracy: 1e-4)
  }

  func testRejectInvalidNegativeInput() {
    let result = FloorPlanResizeService.validateInput("-1.0", currentValue: 4.0)
    guard case .failure = result else {
      return XCTFail("Expected validation failure")
    }
  }

  func testOpeningOffsetScalesWithWallResize() {
    var model = makeRectangularRoom(width: 4.0, length: 6.0)
    guard let topWall = model.walls.first(where: { wall in
      guard let start = model.vertex(wall.startVertexId),
        let end = model.vertex(wall.endVertexId)
      else { return false }
      return abs(start.z - model.bounds.maxZ) < 0.01 && abs(end.z - model.bounds.maxZ) < 0.01
    }) else {
      return XCTFail("Missing top wall")
    }

    let opening = EditableOpening(
      id: UUID(),
      wallId: topWall.id,
      type: .window,
      offsetFromWallStart: 1.0,
      width: 1.0,
      height: 1.0,
      bottomOffset: 0.5,
      keepRelativePosition: true
    )
    model.openings = [opening]
    var walls = model.walls
    if let idx = walls.firstIndex(where: { $0.id == topWall.id }) {
      walls[idx].openingIds = [opening.id]
      model.walls = walls
    }

    model = FloorPlanResizeService.applyWidthChange(to: model, newWidth: 8.0)
    let updatedOpening = model.openings.first
    XCTAssertEqual(updatedOpening?.offsetFromWallStart ?? 0, 2.0, accuracy: 1e-4)
  }

  func testObjectDimensionsDoNotScaleOnResize() {
    var model = makeRectangularRoom(width: 4.0, length: 6.0)
    model.objects = [
      EditableObject(
        id: UUID(),
        type: .bed,
        centerX: 2.0,
        centerZ: 3.0,
        cornersXZ: [],
        width: 1.6,
        length: 2.0,
        rotationRadians: 0,
        height: 0.5,
        anchor: EditableObjectAnchor(type: .free, wallId: nil, offsetFromWall: nil, distanceFromWall: nil),
        isOutsideBounds: false
      ),
    ]

    model = FloorPlanResizeService.applyWidthChange(to: model, newWidth: 5.0)
    let object = model.objects.first
    XCTAssertEqual(object?.width ?? 0, 1.6, accuracy: 1e-4)
    XCTAssertEqual(object?.length ?? 0, 2.0, accuracy: 1e-4)
    XCTAssertEqual(object?.centerX ?? 0, 2.0, accuracy: 1e-4)
  }

  private func makeRectangularRoom(width: Double, length: Double) -> EditableFloorPlanModel {
    let v0 = EditableVertex(id: UUID(), x: 0, z: 0, locked: false)
    let v1 = EditableVertex(id: UUID(), x: width, z: 0, locked: false)
    let v2 = EditableVertex(id: UUID(), x: width, z: length, locked: false)
    let v3 = EditableVertex(id: UUID(), x: 0, z: length, locked: false)
    let vertices = [v0, v1, v2, v3]

    func wall(_ start: EditableVertex, _ end: EditableVertex) -> EditableWall {
      EditableWall(
        id: UUID(),
        startVertexId: start.id,
        endVertexId: end.id,
        height: 2.5,
        thickness: 0.12,
        type: .exterior,
        openingIds: [],
        computedLength: hypot(end.x - start.x, end.z - start.z)
      )
    }

    let walls = [wall(v0, v1), wall(v1, v2), wall(v2, v3), wall(v3, v0)]
    let bounds = EditableFloorPlanBounds(minX: 0, maxX: width, minZ: 0, maxZ: length)
    let now = Date()
    var model = EditableFloorPlanModel(
      id: UUID(),
      sourceScanId: "test",
      unit: .meters,
      vertices: vertices,
      walls: walls,
      openings: [],
      objects: [],
      floorPolygon: [v0.id, v1.id, v2.id, v3.id],
      ceilingEnabled: true,
      wallHeight: 2.5,
      wallThickness: 0.12,
      floorY: 0,
      bounds: bounds,
      scanFootprintBounds: bounds,
      footprintLongM: width,
      footprintShortM: length,
      worldEastPlanAngleRad: 0,
      trueNorthPlanAngleRad: nil,
      scanWorldPlusXBearingDeg: nil,
      northCorrectionDeg: 0,
      metadata: EditableFloorPlanMetadata(
        createdAt: now,
        updatedAt: now,
        isEdited: false,
        source: .manual
      ),
      dimensionAnnotations: []
    )
    model.dimensionAnnotations = DimensionLineService.annotations(for: model)
    return model
  }
}
