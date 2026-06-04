import Foundation
import SceneKit

/// Converts RoomPlan / LiDAR scan data into the internal editable floor plan model.
enum RoomPlanToEditableModelMapper {
  private static let metersFormat = "%.2f m"
  private static let boundaryTolerance = 0.05

  static func map(
    scene: SCNScene,
    metrics: RoomScanMetricsResult,
    sourceScanId: String,
    worldPlusXTrueBearingDeg: Double? = nil,
    northCorrectionDeg: Double = 0
  ) -> EditableFloorPlanModel? {
    guard let sceneBounds = RoomScanMetricsComputer.unionWorldBounds(of: scene.rootNode) else {
      return nil
    }

    let floorY = Double(sceneBounds.min.y)
    let wallHeight = metrics.heightM
    let wallThickness = 0.12

    // OBB footprint corners drive the overall dimension banner (floorLongM × floorShortM) and the
    // "outside footprint" furniture flag. They are NOT used as the drawn walls anymore.
    let footprintVertices = obbFootprintVertices(from: metrics)
    guard footprintVertices.count == 4 else { return nil }
    let scanFootprintBounds = EditableFloorPlanBoundsCalculator.bounds(for: footprintVertices)

    // Walls are projected from the real scanned wall geometry (true top-down X/Z projection) so the
    // 2D plan preserves the actual multi-room / L-shape outline instead of a bounding rectangle.
    // When a scan exposes no usable wall meshes we fall back to the OBB rectangle.
    let extracted = extractWalls(
      from: scene,
      wallHeight: wallHeight
    )
    let usingRealWalls = extracted.walls.count >= 3

    var walls: [EditableWall]
    var wallVertices: [EditableVertex]
    if usingRealWalls {
      walls = extracted.walls
      wallVertices = extracted.vertices
    } else {
      wallVertices = footprintVertices.map { $0 }
      walls = exteriorWalls(
        from: wallVertices,
        wallHeight: wallHeight,
        wallThickness: wallThickness
      )
    }

    // Model vertices = wall endpoints (drawn geometry) + footprint corners (boundary / bounds).
    var vertices = wallVertices
    let floorPolygonIds: [VertexId]
    if usingRealWalls {
      vertices.append(contentsOf: footprintVertices)
      floorPolygonIds = footprintVertices.map(\.id)
    } else {
      floorPolygonIds = wallVertices.map(\.id)
    }

    var objects = extractObjects(
      from: scene,
      sceneBounds: sceneBounds,
      wallHeight: wallHeight,
      walls: walls,
      vertices: vertices
    )

    var openings = extractOpenings(from: scene, walls: walls, vertices: vertices, wallHeight: wallHeight)
    attachOpeningsToWalls(openings: &openings, walls: &walls)
    markObjectsOutsideBounds(&objects, vertices: footprintVertices)

    let bounds = EditableFloorPlanBoundsCalculator.bounds(for: vertices)
    let now = Date()
    var model = EditableFloorPlanModel(
      id: UUID(),
      sourceScanId: sourceScanId,
      unit: .meters,
      vertices: vertices,
      walls: walls,
      openings: openings,
      objects: objects,
      floorPolygon: floorPolygonIds,
      ceilingEnabled: true,
      wallHeight: wallHeight,
      wallThickness: wallThickness,
      floorY: floorY,
      bounds: bounds,
      scanFootprintBounds: scanFootprintBounds,
      footprintLongM: metrics.floorLongM,
      footprintShortM: metrics.floorShortM,
      worldEastPlanAngleRad: 0,
      trueNorthPlanAngleRad: nil,
      scanWorldPlusXBearingDeg: nil,
      northCorrectionDeg: 0,
      metadata: EditableFloorPlanMetadata(
        createdAt: now,
        updatedAt: now,
        isEdited: false,
        source: .roomPlan
      ),
      dimensionAnnotations: []
    )

    logWalls(walls, vertices: vertices, label: usingRealWalls ? "real-geometry" : "obb-fallback")

    // Orient with the same yaw the 3D top-down camera uses (`footprintYaw`) so switching between
    // 2D and 3D never rotates the model. The longest-wall snap is only applied to the rectangular
    // fallback (a no-op for the already axis-aligned OBB); real geometry keeps the scan orientation.
    model = EditableFloorPlanAlignService.alignToScanOrientation(
      model,
      footprintYaw: Double(metrics.footprintYaw)
    )
    if usingRealWalls {
      model = regularizeWalls(model)
    } else {
      model = EditableFloorPlanAlignService.alignToLongestWall(model)
    }
    model.scanWorldPlusXBearingDeg = worldPlusXTrueBearingDeg
    FloorPlanNorthOrientation.applyTrueNorth(to: &model, correctionDeg: northCorrectionDeg)
    model.dimensionAnnotations = DimensionLineService.annotations(for: model)
    return model
  }

  // MARK: - Walls

  /// OBB footprint rectangle — matches `RoomScanMetricsResult.floorLongM × floorShortM`.
  private static func obbFootprintVertices(from metrics: RoomScanMetricsResult) -> [EditableVertex] {
    let centerX = Double(metrics.footprintCenterX)
    let centerZ = Double(metrics.footprintCenterZ)
    let halfLong = metrics.floorLongM * 0.5
    let halfShort = metrics.floorShortM * 0.5
    let yaw = Double(metrics.footprintYaw)
    let cosA = cos(yaw)
    let sinA = sin(yaw)
    let local: [(Double, Double)] = [
      (-halfLong, -halfShort),
      (halfLong, -halfShort),
      (halfLong, halfShort),
      (-halfLong, halfShort),
    ]
    return local.map { lx, lz in
      EditableVertex(
        id: UUID(),
        x: centerX + lx * cosA - lz * sinA,
        z: centerZ + lx * sinA + lz * cosA,
        locked: false
      )
    }
  }

  private static func exteriorWalls(
    from vertices: [EditableVertex],
    wallHeight: Double,
    wallThickness: Double,
    wallIds: [WallId]? = nil
  ) -> [EditableWall] {
    guard vertices.count == 4 else { return [] }
    let ids = wallIds ?? (0..<4).map { _ in UUID() }
    guard ids.count == 4 else { return [] }
    return [
      makeWall(id: ids[0], start: vertices[0], end: vertices[1], height: wallHeight, thickness: wallThickness),
      makeWall(id: ids[1], start: vertices[1], end: vertices[2], height: wallHeight, thickness: wallThickness),
      makeWall(id: ids[2], start: vertices[2], end: vertices[3], height: wallHeight, thickness: wallThickness),
      makeWall(id: ids[3], start: vertices[3], end: vertices[0], height: wallHeight, thickness: wallThickness),
    ]
  }

  /// Minimum projected wall length (meters) worth drawing — filters tiny mesh fragments.
  private static let minWallLengthM = 0.12

  /// Snapping radius (meters) used to merge wall endpoints into shared corner vertices so the plan
  /// renders as a connected wall network rather than disjoint segments.
  private static let cornerSnapM = 0.20

  /// Projects every scanned wall mesh onto the X/Z plane and returns the real wall segments plus the
  /// shared corner vertices they connect to. Each wall keeps its true center, length, thickness and
  /// rotation taken from the mesh — no bounding-box approximation.
  private static func extractWalls(
    from scene: SCNScene,
    wallHeight: Double
  ) -> (vertices: [EditableVertex], walls: [EditableWall]) {
    var segments: [WallSegmentXZ] = []
    func visit(_ node: SCNNode) {
      let name = (node.name ?? "").lowercased()
      if node.geometry != nil, name != "uydoshframingcamera", name.contains("wall"),
        let segment = wallSegmentXZ(of: node)
      {
        segments.append(segment)
      }
      for child in node.childNodes { visit(child) }
    }
    visit(scene.rootNode)

    segments = dedupeWallSegments(segments)
    guard !segments.isEmpty else { return ([], []) }

    var pool = VertexPool(snap: cornerSnapM)
    var walls: [EditableWall] = []
    for segment in segments {
      let startId = pool.vertexId(x: segment.startX, z: segment.startZ)
      let endId = pool.vertexId(x: segment.endX, z: segment.endZ)
      guard startId != endId else { continue }
      walls.append(
        EditableWall(
          id: UUID(),
          startVertexId: startId,
          endVertexId: endId,
          height: wallHeight,
          thickness: segment.thickness,
          type: .exterior,
          openingIds: [],
          computedLength: segment.length
        )
      )
    }
    return (pool.vertices, walls)
  }

  /// Centerline of a single wall mesh in world X/Z, derived from its oriented bottom footprint.
  private static func wallSegmentXZ(of node: SCNNode) -> WallSegmentXZ? {
    guard let footprint = orientedBottomFootprintXZ(of: node), footprint.length >= minWallLengthM
    else { return nil }
    let half = footprint.length * 0.5
    let cosA = cos(footprint.rotation)
    let sinA = sin(footprint.rotation)
    return WallSegmentXZ(
      startX: footprint.centerX - cosA * half,
      startZ: footprint.centerZ - sinA * half,
      endX: footprint.centerX + cosA * half,
      endZ: footprint.centerZ + sinA * half,
      thickness: max(0.05, min(footprint.width, 0.4)),
      length: footprint.length
    )
  }

  /// Removes near-duplicate / collinear-overlapping wall meshes (e.g. inner+outer surfaces), keeping
  /// the longer segment so each physical wall is drawn once.
  private static func dedupeWallSegments(_ segments: [WallSegmentXZ]) -> [WallSegmentXZ] {
    let sorted = segments.sorted { $0.length > $1.length }
    var kept: [WallSegmentXZ] = []
    for segment in sorted {
      let midX = (segment.startX + segment.endX) * 0.5
      let midZ = (segment.startZ + segment.endZ) * 0.5
      let angle = atan2(segment.endZ - segment.startZ, segment.endX - segment.startX)
      let duplicate = kept.contains { other in
        let otherMidX = (other.startX + other.endX) * 0.5
        let otherMidZ = (other.startZ + other.endZ) * 0.5
        guard hypot(midX - otherMidX, midZ - otherMidZ) < 0.30 else { return false }
        let otherAngle = atan2(other.endZ - other.startZ, other.endX - other.startX)
        var diff = abs(angle - otherAngle).truncatingRemainder(dividingBy: .pi)
        diff = min(diff, .pi - diff)
        return diff < 0.22
      }
      if !duplicate { kept.append(segment) }
    }
    return kept
  }

  /// Rectilinear cleanup applied after the plan is aligned to the scan yaw. Scanned wall meshes are
  /// usually a few degrees off-axis with corners that don't quite meet; this snaps near-axis walls to
  /// exact horizontal/vertical (preserving genuinely diagonal walls) and clusters endpoint
  /// coordinates so collinear walls and corners line up. Wall and vertex ids are kept stable so the
  /// already-attached openings stay valid.
  private static let wallAxisSnapTol = 12.0 * Double.pi / 180
  private static let cornerClusterTol = 0.12

  private static func regularizeWalls(_ model: EditableFloorPlanModel) -> EditableFloorPlanModel {
    guard !model.walls.isEmpty else { return model }

    // 1. Snap each wall to the nearest axis when within tolerance. A corner shared by several walls
    //    collects one target per wall; we average them so the joint stays connected.
    var targetSumX: [VertexId: Double] = [:]
    var targetSumZ: [VertexId: Double] = [:]
    var targetCount: [VertexId: Int] = [:]
    for wall in model.walls {
      guard let start = model.vertex(wall.startVertexId),
        let end = model.vertex(wall.endVertexId)
      else { continue }
      var sx = start.x, sz = start.z, ex = end.x, ez = end.z
      let len = hypot(ex - sx, ez - sz)
      if len > 1e-4 {
        let angle = atan2(ez - sz, ex - sx)
        let snapped = (angle / (Double.pi / 2)).rounded() * (Double.pi / 2)
        let delta = atan2(sin(angle - snapped), cos(angle - snapped))
        if abs(delta) <= wallAxisSnapTol {
          let midX = (sx + ex) * 0.5
          let midZ = (sz + ez) * 0.5
          let half = len * 0.5
          sx = midX - cos(snapped) * half
          sz = midZ - sin(snapped) * half
          ex = midX + cos(snapped) * half
          ez = midZ + sin(snapped) * half
        }
      }
      targetSumX[wall.startVertexId, default: 0] += sx
      targetSumZ[wall.startVertexId, default: 0] += sz
      targetCount[wall.startVertexId, default: 0] += 1
      targetSumX[wall.endVertexId, default: 0] += ex
      targetSumZ[wall.endVertexId, default: 0] += ez
      targetCount[wall.endVertexId, default: 0] += 1
    }

    var newX: [VertexId: Double] = [:]
    var newZ: [VertexId: Double] = [:]
    for (id, count) in targetCount where count > 0 {
      newX[id] = targetSumX[id]! / Double(count)
      newZ[id] = targetSumZ[id]! / Double(count)
    }

    // 2. Cluster the snapped coordinates so collinear walls share an exact line and corners meet.
    let xMap = snapCoordinates(Array(newX.values), tolerance: cornerClusterTol)
    let zMap = snapCoordinates(Array(newZ.values), tolerance: cornerClusterTol)

    var updated = model
    updated.vertices = model.vertices.map { vertex in
      guard let nx = newX[vertex.id], let nz = newZ[vertex.id] else { return vertex }
      var moved = vertex
      moved.x = xMap[nx] ?? nx
      moved.z = zMap[nz] ?? nz
      return moved
    }
    updated.walls = updated.walls.map { wall in
      var w = wall
      if let start = updated.vertex(wall.startVertexId), let end = updated.vertex(wall.endVertexId) {
        w.computedLength = hypot(end.x - start.x, end.z - start.z)
      }
      return w
    }
    updated.walls.removeAll { $0.computedLength < 1e-3 }
    updated.bounds = EditableFloorPlanBoundsCalculator.bounds(for: updated.vertices)
    return updated
  }

  /// Groups 1D coordinates that lie within `tolerance` of each other and maps each input value to its
  /// group mean, so near-equal wall coordinates collapse onto a single shared line.
  private static func snapCoordinates(_ values: [Double], tolerance: Double) -> [Double: Double] {
    let sorted = values.sorted()
    var map: [Double: Double] = [:]
    guard let first = sorted.first else { return map }
    var cluster: [Double] = [first]
    func flush() {
      let mean = cluster.reduce(0, +) / Double(cluster.count)
      for value in cluster { map[value] = mean }
    }
    for value in sorted.dropFirst() {
      if value - (cluster.last ?? value) <= tolerance {
        cluster.append(value)
      } else {
        flush()
        cluster = [value]
      }
    }
    flush()
    return map
  }

  private static func markObjectsOutsideBounds(
    _ objects: inout [EditableObject],
    vertices: [EditableVertex]
  ) {
    guard vertices.count >= 3 else { return }
    let ring = vertices.map { (x: $0.x, z: $0.z) }
    for index in objects.indices {
      objects[index].isOutsideBounds = !pointInsidePolygon(
        x: objects[index].centerX,
        z: objects[index].centerZ,
        ring: ring
      )
    }
  }

  private static func pointInsidePolygon(
    x: Double,
    z: Double,
    ring: [(x: Double, z: Double)]
  ) -> Bool {
    guard ring.count >= 3 else { return false }
    var inside = false
    var j = ring.count - 1
    for i in 0..<ring.count {
      let xi = ring[i].x
      let zi = ring[i].z
      let xj = ring[j].x
      let zj = ring[j].z
      let intersects = (zi > z) != (zj > z)
        && x < (xj - xi) * (z - zi) / (zj - zi + 1e-12) + xi
      if intersects { inside.toggle() }
      j = i
    }
    return inside
  }

  private static func makeWall(
    id: WallId = UUID(),
    start: EditableVertex,
    end: EditableVertex,
    height: Double,
    thickness: Double
  ) -> EditableWall {
    let dx = end.x - start.x
    let dz = end.z - start.z
    let length = hypot(dx, dz)
    return EditableWall(
      id: id,
      startVertexId: start.id,
      endVertexId: end.id,
      height: height,
      thickness: thickness,
      type: .exterior,
      openingIds: [],
      computedLength: length
    )
  }

  // MARK: - Openings

  private static func extractOpenings(
    from scene: SCNScene,
    walls: [EditableWall],
    vertices: [EditableVertex],
    wallHeight: Double
  ) -> [EditableOpening] {
    var result: [EditableOpening] = []
    func visit(_ node: SCNNode) {
      guard node.geometry != nil, node.name != "UydoshFramingCamera" else {
        for child in node.childNodes { visit(child) }
        return
      }
      let name = (node.name ?? "").lowercased()
      let kind: EditableOpeningKind?
      if name.contains("door") { kind = .door }
      else if name.contains("window") { kind = .window }
      else if name.contains("opening") { kind = .opening }
      else { kind = nil }

      if let kind, let edge = longestFloorEdgeXZ(of: node, minLength: 0.02) {
        if let opening = openingFromEdge(
          edge,
          kind: kind,
          walls: walls,
          vertices: vertices,
          wallHeight: wallHeight
        ) {
          result.append(opening)
        }
      }
      for child in node.childNodes { visit(child) }
    }
    visit(scene.rootNode)
    return result
  }

  private static func openingFromEdge(
    _ edge: XZEdge,
    kind: EditableOpeningKind,
    walls: [EditableWall],
    vertices: [EditableVertex],
    wallHeight: Double
  ) -> EditableOpening? {
    guard let match = nearestWall(
      toSegmentFrom: (edge.startX, edge.startZ),
      to: (edge.endX, edge.endZ),
      walls: walls,
      vertices: vertices
    ) else { return nil }

    let wallStart = match.start
    let wallEnd = match.end
    let wallDx = wallEnd.x - wallStart.x
    let wallDz = wallEnd.z - wallStart.z
    let wallLen = hypot(wallDx, wallDz)
    guard wallLen > 1e-4 else { return nil }

    let midX = (edge.startX + edge.endX) * 0.5
    let midZ = (edge.startZ + edge.endZ) * 0.5
    let offset = ((midX - wallStart.x) * wallDx + (midZ - wallStart.z) * wallDz) / wallLen
    let width = edge.length

    return EditableOpening(
      id: UUID(),
      wallId: match.wallId,
      type: kind,
      offsetFromWallStart: max(0, min(offset - width * 0.5, wallLen - width)),
      width: width,
      height: kind == .window ? wallHeight * 0.45 : wallHeight * 0.85,
      bottomOffset: kind == .window ? wallHeight * 0.35 : 0,
      keepRelativePosition: true
    )
  }

  private static func attachOpeningsToWalls(
    openings: inout [EditableOpening],
    walls: inout [EditableWall]
  ) {
    for opening in openings {
      guard let idx = walls.firstIndex(where: { $0.id == opening.wallId }) else { continue }
      if !walls[idx].openingIds.contains(opening.id) {
        walls[idx].openingIds.append(opening.id)
      }
    }
  }

  // MARK: - Objects

  private static func extractObjects(
    from scene: SCNScene,
    sceneBounds: (min: SCNVector3, max: SCNVector3),
    wallHeight: Double,
    walls: [EditableWall],
    vertices: [EditableVertex]
  ) -> [EditableObject] {
    var objects: [EditableObject] = []
    let sceneHeight = max(sceneBounds.max.y - sceneBounds.min.y, 0.12)

    func visit(_ node: SCNNode) {
      guard node.geometry != nil, node.name != "UydoshFramingCamera" else {
        for child in node.childNodes { visit(child) }
        return
      }
      let name = (node.name ?? "").lowercased()
      if name.contains("wall") || name.contains("door") || name.contains("window")
        || name.contains("opening") || name.contains("floor") || name.contains("ceiling")
      {
        for child in node.childNodes { visit(child) }
        return
      }
      if isOnFloorObject(node, sceneBounds: sceneBounds, sceneHeight: sceneHeight),
        let footprint = orientedBottomFootprintXZ(of: node)
      {
        let type = objectType(from: node.name ?? "Object")
        let anchor = nearestWallAnchor(
          centerX: footprint.centerX,
          centerZ: footprint.centerZ,
          walls: walls,
          vertices: vertices
        )
        objects.append(
          EditableObject(
            id: UUID(),
            type: type,
            centerX: footprint.centerX,
            centerZ: footprint.centerZ,
            cornersXZ: footprint.cornersXZ,
            width: footprint.width,
            length: footprint.length,
            rotationRadians: footprint.rotation,
            height: Double(footprint.height),
            anchor: anchor,
            isOutsideBounds: false
          )
        )
      }
      for child in node.childNodes { visit(child) }
    }
    visit(scene.rootNode)
    return dedupeObjects(objects)
  }

  private static func dedupeObjects(_ objects: [EditableObject]) -> [EditableObject] {
    let sorted = objects.sorted { ($0.width * $0.length) > ($1.width * $1.length) }
    var kept: [EditableObject] = []
    for object in sorted {
      let duplicate = kept.contains { other in
        let dx = object.centerX - other.centerX
        let dz = object.centerZ - other.centerZ
        let dist = hypot(dx, dz)
        return dist < max(other.width, other.length) * 0.4
      }
      if !duplicate { kept.append(object) }
    }
    return kept
  }

  private static func objectType(from name: String) -> EditableObjectType {
    EditableObjectType.from(nodeName: name)
  }

  private static func nearestWallAnchor(
    centerX: Double,
    centerZ: Double,
    walls: [EditableWall],
    vertices: [EditableVertex]
  ) -> EditableObjectAnchor {
    var bestDist = Double.greatestFiniteMagnitude
    var bestWallId: WallId?
    var bestOffset: Double?

    for wall in walls {
      guard let start = vertices.first(where: { $0.id == wall.startVertexId }),
        let end = vertices.first(where: { $0.id == wall.endVertexId })
      else { continue }
      let dx = end.x - start.x
      let dz = end.z - start.z
      let len = hypot(dx, dz)
      guard len > 1e-4 else { continue }
      let t = ((centerX - start.x) * dx + (centerZ - start.z) * dz) / (len * len)
      let clamped = max(0, min(1, t))
      let px = start.x + dx * clamped
      let pz = start.z + dz * clamped
      let dist = hypot(centerX - px, centerZ - pz)
      if dist < bestDist {
        bestDist = dist
        bestWallId = wall.id
        bestOffset = clamped * len
      }
    }

    if let wallId = bestWallId, bestDist < 1.2 {
      return EditableObjectAnchor(
        type: .wallId,
        wallId: wallId,
        offsetFromWall: bestOffset,
        distanceFromWall: bestDist
      )
    }
    return EditableObjectAnchor(type: .free, wallId: nil, offsetFromWall: nil, distanceFromWall: nil)
  }

  // MARK: - Geometry helpers

  private struct XZEdge {
    var startX: Double
    var startZ: Double
    var endX: Double
    var endZ: Double
    var length: Double
  }

  private struct XZFootprint {
    var centerX: Double
    var centerZ: Double
    var cornersXZ: [EditablePointXZ]
    var width: Double
    var length: Double
    var rotation: Double
    var height: Float
  }

  private struct WallMatch {
    var wallId: WallId
    var start: EditableVertex
    var end: EditableVertex
  }

  private struct WallSegmentXZ {
    var startX: Double
    var startZ: Double
    var endX: Double
    var endZ: Double
    var thickness: Double
    var length: Double
  }

  /// Accumulates wall endpoints into shared corner vertices, snapping points within `snap` meters to
  /// an existing vertex so connected walls reference the same corner.
  private struct VertexPool {
    private(set) var vertices: [EditableVertex] = []
    let snap: Double

    init(snap: Double) {
      self.snap = snap
    }

    mutating func vertexId(x: Double, z: Double) -> VertexId {
      if let existing = vertices.first(where: { hypot($0.x - x, $0.z - z) <= snap }) {
        return existing.id
      }
      let vertex = EditableVertex(id: UUID(), x: x, z: z, locked: false)
      vertices.append(vertex)
      return vertex.id
    }
  }

  // MARK: - Debug

  private static func logWalls(_ walls: [EditableWall], vertices: [EditableVertex], label: String) {
    guard FloorPlanDebug.isEnabled else { return }
    func vertex(_ id: VertexId) -> EditableVertex? { vertices.first { $0.id == id } }
    FloorPlanDebug.log("mapper walls source=\(label) count=\(walls.count)")
    for (index, wall) in walls.enumerated() {
      guard let start = vertex(wall.startVertexId), let end = vertex(wall.endVertexId) else { continue }
      let centerX = (start.x + end.x) * 0.5
      let centerZ = (start.z + end.z) * 0.5
      let rotation = atan2(end.z - start.z, end.x - start.x)
      FloorPlanDebug.log(
        String(
          format:
            "wall[%d] center3D=(%.2f, %.2f) len=%.2f thick=%.2f rotRad=%.3f start=(%.2f, %.2f) end=(%.2f, %.2f)",
          index, centerX, centerZ, wall.computedLength, wall.thickness, rotation,
          start.x, start.z, end.x, end.z
        )
      )
    }
  }

  private static func longestFloorEdgeXZ(of node: SCNNode, minLength: Double) -> XZEdge? {
    guard let b = worldBounds(of: node) else { return nil }
    let floorY = b.min.y
    let yTol = max(0.06, 0.04 * max(b.max.y - b.min.y, 0.1))
    var points = worldVertices(of: node)
      .filter { abs($0.y - floorY) <= yTol }
      .map { (x: Double($0.x), z: Double($0.z)) }
    points = dedupeXZ(points, epsilon: 0.03)
    guard points.count >= 2 else { return nil }

    var best: XZEdge?
    for i in 0..<points.count {
      for j in (i + 1)..<points.count {
        let a = points[i]
        let bpt = points[j]
        let dx = bpt.x - a.x
        let dz = bpt.z - a.z
        let len = hypot(dx, dz)
        guard len >= minLength else { continue }
        if best == nil || len > best!.length {
          best = XZEdge(startX: a.x, startZ: a.z, endX: bpt.x, endZ: bpt.z, length: len)
        }
      }
    }
    return best
  }

  private static func orientedBottomFootprintXZ(of node: SCNNode) -> XZFootprint? {
    guard node.geometry != nil else { return nil }
    let box = node.boundingBox
    let localY = box.min.y + 0.002
    let localCorners = [
      SCNVector3(box.min.x, localY, box.min.z),
      SCNVector3(box.max.x, localY, box.min.z),
      SCNVector3(box.max.x, localY, box.max.z),
      SCNVector3(box.min.x, localY, box.max.z),
    ]
    let corners = localCorners.map { c -> (x: Double, z: Double) in
      let w = node.convertPosition(c, to: nil)
      return (x: Double(w.x), z: Double(w.z))
    }
    let cx = corners.map(\.x).reduce(0, +) / 4
    let cz = corners.map(\.z).reduce(0, +) / 4
    let e01 = hypot(corners[1].x - corners[0].x, corners[1].z - corners[0].z)
    let e12 = hypot(corners[2].x - corners[1].x, corners[2].z - corners[1].z)
    guard max(e01, e12) > 0.02 else { return nil }
    let width: Double
    let length: Double
    let rotation: Double
    if e01 >= e12 {
      length = e01
      width = e12
      rotation = atan2(corners[1].z - corners[0].z, corners[1].x - corners[0].x)
    } else {
      length = e12
      width = e01
      rotation = atan2(corners[2].z - corners[1].z, corners[2].x - corners[1].x)
    }
    let height = box.max.y - box.min.y
    return XZFootprint(
      centerX: cx,
      centerZ: cz,
      cornersXZ: corners.map { EditablePointXZ(x: $0.x, z: $0.z) },
      width: width,
      length: length,
      rotation: rotation,
      height: height
    )
  }

  private static func nearestWall(
    toSegmentFrom start: (Double, Double),
    to end: (Double, Double),
    walls: [EditableWall],
    vertices: [EditableVertex]
  ) -> WallMatch? {
    let midX = (start.0 + end.0) * 0.5
    let midZ = (start.1 + end.1) * 0.5
    var best: (dist: Double, match: WallMatch)?

    for wall in walls {
      guard let s = vertices.first(where: { $0.id == wall.startVertexId }),
        let e = vertices.first(where: { $0.id == wall.endVertexId })
      else { continue }
      let dx = e.x - s.x
      let dz = e.z - s.z
      let len = hypot(dx, dz)
      guard len > 1e-4 else { continue }
      let t = ((midX - s.x) * dx + (midZ - s.z) * dz) / (len * len)
      let clamped = max(0, min(1, t))
      let px = s.x + dx * clamped
      let pz = s.z + dz * clamped
      let dist = hypot(midX - px, midZ - pz)
      if best == nil || dist < best!.dist {
        best = (dist, WallMatch(wallId: wall.id, start: s, end: e))
      }
    }
    return best?.match
  }

  private static func dedupeXZ(_ points: [(x: Double, z: Double)], epsilon: Double) -> [(x: Double, z: Double)] {
    var out: [(x: Double, z: Double)] = []
    for p in points {
      if !out.contains(where: { hypot($0.x - p.x, $0.z - p.z) < epsilon }) {
        out.append(p)
      }
    }
    return out
  }

  private static func worldBounds(of node: SCNNode) -> (min: SCNVector3, max: SCNVector3)? {
    guard node.geometry != nil else { return nil }
    let box = node.boundingBox
    let corners: [SCNVector3] = [
      SCNVector3(box.min.x, box.min.y, box.min.z),
      SCNVector3(box.max.x, box.max.y, box.max.z),
      SCNVector3(box.min.x, box.max.y, box.max.z),
      SCNVector3(box.max.x, box.min.y, box.max.z),
    ]
    var minV = SCNVector3(
      Float.greatestFiniteMagnitude,
      Float.greatestFiniteMagnitude,
      Float.greatestFiniteMagnitude
    )
    var maxV = SCNVector3(
      -Float.greatestFiniteMagnitude,
      -Float.greatestFiniteMagnitude,
      -Float.greatestFiniteMagnitude
    )
    for c in corners {
      let w = node.convertPosition(c, to: nil)
      minV.x = min(minV.x, w.x)
      minV.y = min(minV.y, w.y)
      minV.z = min(minV.z, w.z)
      maxV.x = max(maxV.x, w.x)
      maxV.y = max(maxV.y, w.y)
      maxV.z = max(maxV.z, w.z)
    }
    return (minV, maxV)
  }

  private static func worldVertices(of node: SCNNode) -> [SCNVector3] {
    guard let geo = node.geometry,
      let src = geo.sources(for: .vertex).first
    else { return [] }
    let stride = src.dataStride
    let offset = src.dataOffset
    let count = src.vectorCount
    let data = src.data as NSData
    var out: [SCNVector3] = []
    out.reserveCapacity(count)
    for i in 0..<count {
      var vx = Float(0)
      var vy = Float(0)
      var vz = Float(0)
      data.getBytes(&vx, range: NSRange(location: i * stride + offset, length: MemoryLayout<Float>.size))
      data.getBytes(
        &vy,
        range: NSRange(location: i * stride + offset + MemoryLayout<Float>.size, length: MemoryLayout<Float>.size)
      )
      data.getBytes(
        &vz,
        range: NSRange(
          location: i * stride + offset + 2 * MemoryLayout<Float>.size,
          length: MemoryLayout<Float>.size
        )
      )
      out.append(node.convertPosition(SCNVector3(vx, vy, vz), to: nil))
    }
    return out
  }

  private static func isOnFloorObject(
    _ node: SCNNode,
    sceneBounds: (min: SCNVector3, max: SCNVector3),
    sceneHeight: Float
  ) -> Bool {
    guard let b = worldBounds(of: node) else { return false }
    let sceneMinY = sceneBounds.min.y
    let bottomY = b.min.y
    guard bottomY >= sceneMinY - 0.08, bottomY <= sceneMinY + 0.22 * sceneHeight + 0.06 else {
      return false
    }
    return b.max.y - b.min.y > 0.025
  }
}
