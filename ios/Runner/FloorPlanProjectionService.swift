import SceneKit

/// Converts RoomPlan / LiDAR USDZ scene geometry into a 2D floor plan model.
enum RoomPlan3DToFloorPlanMapper {
  static func map(scene: SCNScene, metrics: RoomScanMetricsResult) -> FloorPlanModel? {
    guard let sceneBounds = RoomScanMetricsComputer.unionWorldBounds(of: scene.rootNode) else {
      return nil
    }
    return FloorPlanProjectionService.buildModel(
      scene: scene,
      sceneBounds: sceneBounds,
      metrics: metrics
    )
  }
}

/// Projects 3D room coordinates onto a 2D floor plan plane (X → X, −Z → Y).
/// The Z negation matches SceneKit top-down (`eulerAngles(-π/2, footprintYaw, 0)`).
enum FloorPlanProjectionService {
  private static let metersFormat = "%.2f m"

  /// World X/Z → plan 2D, aligned with the native 3D furniture top-down camera.
  private static func planPoint(x: Float, z: Float) -> FloorPlanPoint2D {
    FloorPlanPoint2D(x: CGFloat(x), y: CGFloat(-z))
  }

  private static func planPoint(x: CGFloat, z: CGFloat) -> FloorPlanPoint2D {
    FloorPlanPoint2D(x: x, y: -z)
  }

  static func buildModel(
    scene: SCNScene,
    sceneBounds: (min: SCNVector3, max: SCNVector3),
    metrics: RoomScanMetricsResult,
    objectLabels: FloorPlanObjectLabels = .englishFallback
  ) -> FloorPlanModel {
    let sceneHeight = max(sceneBounds.max.y - sceneBounds.min.y, 0.12)

    var walls: [FloorPlanWall] = []
    var objects: [FloorPlanObject] = []
    var doors: [FloorPlanOpening] = []
    var windows: [FloorPlanOpening] = []
    var miscOpenings: [FloorPlanOpening] = []

    func visit(_ node: SCNNode) {
      guard node.geometry != nil, node.name != "UydoshFramingCamera" else {
        for child in node.childNodes { visit(child) }
        return
      }

      let name = (node.name ?? "").lowercased()
      if name.contains("door") {
        if let opening = opening(from: node, type: .door) { doors.append(opening) }
      } else if name.contains("window") {
        if let opening = opening(from: node, type: .window) { windows.append(opening) }
      } else if name.contains("opening") {
        if let opening = opening(from: node, type: .opening) { miscOpenings.append(opening) }
      } else if name.contains("wall") {
        if let wall = wallSegment(from: node) { walls.append(wall) }
      } else if isLeafGeometry(node),
        isOnFloorObject(node, sceneBounds: sceneBounds, sceneHeight: sceneHeight)
      {
        if let object = floorObject(from: node, objectLabels: objectLabels) { objects.append(object) }
      }

      for child in node.childNodes { visit(child) }
    }
    visit(scene.rootNode)
    objects = dedupeObjects(objects)

    let boundary = boundaryPolygon(scene: scene, sceneBounds: sceneBounds, metrics: metrics)
    let bounds = boundsFor(points: boundary.isEmpty ? wallBoundsPoints(walls) : boundary)

    let overallWidth = CGFloat(metrics.floorShortM)
    let overallLength = CGFloat(metrics.floorLongM)
    let planCenter = bounds.center
    let longestYaw = longestWallYaw(walls)

    let overallDimensions = orientedOverallDimensions(
      center: planCenter,
      width: overallWidth,
      length: overallLength,
      yaw: longestYaw
    )
    let wallSegmentDimensions = wallSegmentDimensions(for: walls)

    return FloorPlanModel(
      walls: walls,
      objects: objects,
      doors: doors,
      windows: windows,
      openings: miscOpenings,
      boundary: boundary,
      bounds: bounds,
      overallWidth: overallWidth,
      overallLength: overallLength,
      overallDimensions: overallDimensions,
      wallSegmentDimensions: wallSegmentDimensions,
      footprintYaw: 0,
      planCenter: planCenter,
      orientationEastPlanAngleRad: 0,
      orientationTrueNorthPlanAngleRad: CGFloat.pi / 2,
      orientationScanWorldPlusXBearingDeg: nil,
      orientationNorthCorrectionDeg: 0,
      orientationHasGeographicNorth: false
    )
  }

  // MARK: - Extraction

  private static func wallSegment(from node: SCNNode) -> FloorPlanWall? {
    if let edge = longestFloorEdge(of: node, minLength: 0.04) {
      return FloorPlanWall(
        start: edge.start,
        end: edge.end,
        thickness: edge.thickness,
        length: edge.length
      )
    }
    return axisAlignedWallFallback(from: node)
  }

  private static func opening(from node: SCNNode, type: FloorPlanOpeningType) -> FloorPlanOpening? {
    if let edge = longestFloorEdge(of: node, minLength: 0.02) {
      return FloorPlanOpening(type: type, start: edge.start, end: edge.end, width: edge.length)
    }
    return axisAlignedOpeningFallback(from: node, type: type)
  }

  private static func floorObject(
    from node: SCNNode,
    objectLabels: FloorPlanObjectLabels
  ) -> FloorPlanObject? {
    guard let footprint = orientedBottomFootprint(of: node) else { return nil }
    let rawName = node.name ?? "Object"
    let category = objectCategory(from: rawName)
    let label = objectLabels.label(forCategory: category, fallback: rawName)

    return FloorPlanObject(
      center: footprint.center,
      corners: footprint.corners,
      width: footprint.width,
      length: footprint.length,
      rotation: footprint.rotation,
      category: category,
      label: label
    )
  }

  private static func isLeafGeometry(_ node: SCNNode) -> Bool {
    !node.childNodes.contains { $0.geometry != nil }
  }

  private static func dedupeObjects(_ objects: [FloorPlanObject]) -> [FloorPlanObject] {
    let sorted = objects.sorted { ($0.width * $0.length) > ($1.width * $1.length) }
    var kept: [FloorPlanObject] = []
    for object in sorted {
      let duplicate = kept.contains { other in
        let dx = object.center.x - other.center.x
        let dy = object.center.y - other.center.y
        let dist = hypot(dx, dy)
        let threshold = max(other.width, other.length) * 0.4
        return dist < threshold
      }
      if !duplicate {
        kept.append(object)
      }
    }
    return kept
  }

  private struct FloorEdge {
    var start: FloorPlanPoint2D
    var end: FloorPlanPoint2D
    var length: CGFloat
    var thickness: CGFloat
  }

  private struct OrientedFootprint {
    var center: FloorPlanPoint2D
    var corners: [FloorPlanPoint2D]
    var width: CGFloat
    var length: CGFloat
    var rotation: CGFloat
  }

  /// Longest edge on the mesh bottom face — matches actual wall/object orientation in the scan.
  private static func longestFloorEdge(of node: SCNNode, minLength: CGFloat) -> FloorEdge? {
    guard let b = worldBounds(of: node) else { return nil }
    let floorY = b.min.y
    let yTol = max(0.06, 0.04 * max(b.max.y - b.min.y, 0.1))
    var points = worldVertices(of: node)
      .filter { abs($0.y - floorY) <= yTol }
      .map { planPoint(x: $0.x, z: $0.z) }
    points = dedupePlanPoints(points, epsilon: 0.03)
    guard points.count >= 2 else { return nil }

    var best: FloorEdge?
    for i in 0..<points.count {
      for j in (i + 1)..<points.count {
        let a = points[i]
        let bpt = points[j]
        let dx = bpt.x - a.x
        let dy = bpt.y - a.y
        let len = hypot(dx, dy)
        guard len >= minLength else { continue }
        if best == nil || len > best!.length {
          best = FloorEdge(start: a, end: bpt, length: len, thickness: 0.12)
        }
      }
    }
    return best
  }

  private static func orientedBottomFootprint(of node: SCNNode) -> OrientedFootprint? {
    guard node.geometry != nil else { return nil }
    let box = node.boundingBox
    let localY = box.min.y + 0.002
    let localCorners = [
      SCNVector3(box.min.x, localY, box.min.z),
      SCNVector3(box.max.x, localY, box.min.z),
      SCNVector3(box.max.x, localY, box.max.z),
      SCNVector3(box.min.x, localY, box.max.z),
    ]
    let corners = localCorners.map { c -> FloorPlanPoint2D in
      let w = node.convertPosition(c, to: nil)
      return planPoint(x: w.x, z: w.z)
    }

    let cx = corners.map(\.x).reduce(0, +) / 4
    let cy = corners.map(\.y).reduce(0, +) / 4
    let e01 = hypot(corners[1].x - corners[0].x, corners[1].y - corners[0].y)
    let e12 = hypot(corners[2].x - corners[1].x, corners[2].y - corners[1].y)
    guard max(e01, e12) > 0.02 else { return nil }

    let width: CGFloat
    let length: CGFloat
    let rotation: CGFloat
    if e01 >= e12 {
      length = e01
      width = e12
      rotation = atan2(corners[1].y - corners[0].y, corners[1].x - corners[0].x)
    } else {
      length = e12
      width = e01
      rotation = atan2(corners[2].y - corners[1].y, corners[2].x - corners[1].x)
    }
    return OrientedFootprint(
      center: FloorPlanPoint2D(x: cx, y: cy),
      corners: corners,
      width: width,
      length: length,
      rotation: rotation
    )
  }

  private static func axisAlignedWallFallback(from node: SCNNode) -> FloorPlanWall? {
    guard let b = worldBounds(of: node) else { return nil }
    let dx = CGFloat(b.max.x - b.min.x)
    let dz = CGFloat(b.max.z - b.min.z)
    guard max(dx, dz) > 0.04 else { return nil }
    if dx >= dz {
      let z = (b.min.z + b.max.z) * 0.5
      return FloorPlanWall(
        start: planPoint(x: b.min.x, z: z),
        end: planPoint(x: b.max.x, z: z),
        thickness: dz,
        length: dx
      )
    }
    let x = (b.min.x + b.max.x) * 0.5
    return FloorPlanWall(
      start: planPoint(x: x, z: b.min.z),
      end: planPoint(x: x, z: b.max.z),
      thickness: dx,
      length: dz
    )
  }

  private static func axisAlignedOpeningFallback(
    from node: SCNNode,
    type: FloorPlanOpeningType
  ) -> FloorPlanOpening? {
    guard let wall = axisAlignedWallFallback(from: node) else { return nil }
    return FloorPlanOpening(
      type: type,
      start: wall.start,
      end: wall.end,
      width: wall.length
    )
  }

  private static func wallBoundsPoints(_ walls: [FloorPlanWall]) -> [FloorPlanPoint2D] {
    walls.flatMap { [$0.start, $0.end] }
  }

  /// Minimum-area bounding rectangle in plan coordinates; yaw aligns the long edge with +X.
  private static func minimumAreaBoundingRectPlan(
    points: [FloorPlanPoint2D]
  ) -> (centerX: CGFloat, centerY: CGFloat, long: CGFloat, short: CGFloat, yaw: CGFloat)? {
    guard points.count >= 2 else { return nil }
    let unique = dedupePlanPoints(points, epsilon: 0.02)
    guard unique.count >= 2 else { return nil }

    let ring: [FloorPlanPoint2D] = {
      let hull = convexHullPlan(unique)
      return hull.count >= 3 ? hull : unique
    }()

    var bestArea = CGFloat.greatestFiniteMagnitude
    var bestLong: CGFloat = 0
    var bestShort: CGFloat = 0
    var bestYaw: CGFloat = 0
    var bestCenter = unique[0]

    for i in 0..<ring.count {
      let p1 = ring[i]
      let p2 = ring[(i + 1) % ring.count]
      let edgeYaw = atan2(p2.y - p1.y, p2.x - p1.x)
      let cosA = cos(-edgeYaw)
      let sinA = sin(-edgeYaw)
      var minRX = CGFloat.greatestFiniteMagnitude
      var maxRX = -CGFloat.greatestFiniteMagnitude
      var minRY = CGFloat.greatestFiniteMagnitude
      var maxRY = -CGFloat.greatestFiniteMagnitude
      for p in unique {
        let rx = p.x * cosA - p.y * sinA
        let ry = p.x * sinA + p.y * cosA
        minRX = min(minRX, rx)
        maxRX = max(maxRX, rx)
        minRY = min(minRY, ry)
        maxRY = max(maxRY, ry)
      }
      let w = maxRX - minRX
      let h = maxRY - minRY
      let area = w * h
      if area < bestArea {
        bestArea = area
        let long = max(w, h)
        let short = min(w, h)
        let rectYaw = w >= h ? edgeYaw : edgeYaw + .pi / 2
        bestLong = long
        bestShort = short
        bestYaw = rectYaw
        let cx = (minRX + maxRX) * 0.5
        let cy = (minRY + maxRY) * 0.5
        bestCenter = FloorPlanPoint2D(
          x: cx * cos(edgeYaw) - cy * sin(edgeYaw),
          y: cx * sin(edgeYaw) + cy * cos(edgeYaw)
        )
      }
    }

    guard bestLong > 1e-4 else { return nil }
    return (centerX: bestCenter.x, centerY: bestCenter.y, long: bestLong, short: bestShort, yaw: bestYaw)
  }

  private static func convexHullPlan(_ points: [FloorPlanPoint2D]) -> [FloorPlanPoint2D] {
    let sorted = points.sorted {
      if $0.x == $1.x { return $0.y < $1.y }
      return $0.x < $1.x
    }
    guard sorted.count >= 3 else { return sorted }

    func cross(_ o: FloorPlanPoint2D, _ a: FloorPlanPoint2D, _ b: FloorPlanPoint2D) -> CGFloat {
      (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x)
    }

    var lower: [FloorPlanPoint2D] = []
    for p in sorted {
      while lower.count >= 2 && cross(lower[lower.count - 2], lower[lower.count - 1], p) <= 0 {
        lower.removeLast()
      }
      lower.append(p)
    }

    var upper: [FloorPlanPoint2D] = []
    for p in sorted.reversed() {
      while upper.count >= 2 && cross(upper[upper.count - 2], upper[upper.count - 1], p) <= 0 {
        upper.removeLast()
      }
      upper.append(p)
    }

    lower.removeLast()
    upper.removeLast()
    return lower + upper
  }

  private static func dedupePlanPoints(_ points: [FloorPlanPoint2D], epsilon: CGFloat) -> [FloorPlanPoint2D] {
    var out: [FloorPlanPoint2D] = []
    for p in points {
      if !out.contains(where: { hypot($0.x - p.x, $0.y - p.y) < epsilon }) {
        out.append(p)
      }
    }
    return out
  }

  private static func objectCategory(from name: String) -> String {
    let n = name.lowercased()
    if n.contains("bed") { return "bed" }
    if n.contains("sofa") || n.contains("couch") { return "sofa" }
    if n.contains("table") || n.contains("desk") { return "table" }
    if n.contains("chair") || n.contains("stool") { return "chair" }
    if n.contains("storage") || n.contains("shelf") || n.contains("bookcase") { return "storage" }
    if n.contains("cabinet") || n.contains("cupboard") { return "cabinet" }
    if n.contains("refrigerator") || n.contains("fridge") || n.contains("oven")
      || n.contains("stove") || n.contains("washer") || n.contains("dryer")
      || n.contains("dishwasher") || n.contains("appliance")
    {
      return "appliance"
    }
    if n.contains("television") || n.contains("tv") { return "television" }
    if n.contains("bathtub") || n.contains("toilet") || n.contains("sink") { return "fixture" }
    return "object"
  }

  private static func isOnFloorObject(
    _ node: SCNNode,
    sceneBounds: (min: SCNVector3, max: SCNVector3),
    sceneHeight: Float
  ) -> Bool {
    let name = (node.name ?? "").lowercased()
    if name.contains("wall") || name.contains("ceiling") || name.contains("floor")
      || name.contains("ground") || name.contains("door") || name.contains("window")
      || name.contains("opening")
    {
      return false
    }
    guard let b = worldBounds(of: node) else { return false }
    if isLikelyFloorSlab(b, sceneBounds: sceneBounds) { return false }
    if isLikelyVerticalWallSlab(b, sceneHeight: sceneHeight) { return false }
    let sceneMinY = sceneBounds.min.y
    let bottomY = b.min.y
    guard bottomY >= sceneMinY - 0.08, bottomY <= sceneMinY + 0.22 * sceneHeight + 0.06 else {
      return false
    }
    let dy = b.max.y - b.min.y
    return dy > 0.025
  }

  private static func boundaryPolygon(
    scene: SCNScene,
    sceneBounds: (min: SCNVector3, max: SCNVector3),
    metrics: RoomScanMetricsResult
  ) -> [FloorPlanPoint2D] {
    var floorPoints: [(x: Float, z: Float)] = []
    func visit(_ node: SCNNode) {
      if let geo = node.geometry {
        let name = (node.name ?? "").lowercased()
        let isNamedFloor = name.contains("floor") || name.contains("ground")
        let nodeBounds = worldBounds(of: node)
        let isSlab = nodeBounds.map { isLikelyFloorSlab($0, sceneBounds: sceneBounds) } ?? false
        if isNamedFloor || isSlab, let nb = nodeBounds {
          let floorY = nb.min.y
          let yTol = max(0.08, 0.06 * max(sceneBounds.max.y - sceneBounds.min.y, 0.12))
          for v in worldVertices(of: node) where abs(v.y - floorY) <= yTol {
            floorPoints.append((x: v.x, z: v.z))
          }
        }
      }
      for child in node.childNodes { visit(child) }
    }
    visit(scene.rootNode)

    if floorPoints.count >= 3 {
      let hull = convexHull(floorPoints)
      if hull.count >= 3 {
        return hull.map { planPoint(x: $0.x, z: $0.z) }
      }
    }

    return [
      planPoint(x: metrics.minX, z: metrics.minZ),
      planPoint(x: metrics.maxX, z: metrics.minZ),
      planPoint(x: metrics.maxX, z: metrics.maxZ),
      planPoint(x: metrics.minX, z: metrics.maxZ),
    ]
  }

  // MARK: - Dimensions

  private static func longestWallYaw(_ walls: [FloorPlanWall]) -> CGFloat {
    guard let wall = walls.max(by: { $0.length < $1.length }) else { return 0 }
    let dx = wall.end.x - wall.start.x
    let dy = wall.end.y - wall.start.y
    guard hypot(dx, dy) > 1e-4 else { return 0 }
    return atan2(dy, dx)
  }

  /// Overall dimensions aligned to plan axes (after auto-align).
  static func axisAlignedOverallDimensions(
    bounds: FloorPlanBounds,
    width: CGFloat,
    length: CGFloat
  ) -> [DimensionLine] {
    let offset = max(bounds.width, bounds.height) * 0.10 + 0.45
    let lengthY = bounds.minY - offset
    let lengthLine = DimensionLine(
      start: FloorPlanPoint2D(x: bounds.minX, y: lengthY),
      end: FloorPlanPoint2D(x: bounds.maxX, y: lengthY),
      label: String(format: metersFormat, length),
      offset: offset,
      type: .overall,
      witnessStart: FloorPlanPoint2D(x: bounds.minX, y: bounds.minY),
      witnessEnd: FloorPlanPoint2D(x: bounds.maxX, y: bounds.minY)
    )
    let widthX = bounds.maxX + offset
    let widthLine = DimensionLine(
      start: FloorPlanPoint2D(x: widthX, y: bounds.minY),
      end: FloorPlanPoint2D(x: widthX, y: bounds.maxY),
      label: String(format: metersFormat, width),
      offset: offset,
      type: .overall,
      witnessStart: FloorPlanPoint2D(x: bounds.maxX, y: bounds.minY),
      witnessEnd: FloorPlanPoint2D(x: bounds.maxX, y: bounds.maxY)
    )
    return [lengthLine, widthLine]
  }

  private static func orientedOverallDimensions(
    center: FloorPlanPoint2D,
    width: CGFloat,
    length: CGFloat,
    yaw: CGFloat
  ) -> [DimensionLine] {
    let offset = max(width, length) * 0.12 + 0.35
    let cosA = cos(yaw)
    let sinA = sin(yaw)
    let halfL = length * 0.5
    let halfW = width * 0.5
    // Perpendicular below the long edge once the view applies −yaw rotation.
    let perpX = -sinA
    let perpY = cosA
    let outerNear1 = FloorPlanPoint2D(
      x: center.x - cosA * halfL + perpX * halfW,
      y: center.y - sinA * halfL + perpY * halfW
    )
    let outerNear2 = FloorPlanPoint2D(
      x: center.x + cosA * halfL + perpX * halfW,
      y: center.y + sinA * halfL + perpY * halfW
    )
    let outerFar1 = FloorPlanPoint2D(
      x: center.x + cosA * halfL + perpX * offset - sinA * halfW,
      y: center.y + sinA * halfL + perpY * offset + cosA * halfW
    )
    let outerFar2 = FloorPlanPoint2D(
      x: center.x + cosA * halfL + perpX * offset + sinA * halfW,
      y: center.y + sinA * halfL + perpY * offset - cosA * halfW
    )

    let lengthLine = DimensionLine(
      start: FloorPlanPoint2D(
        x: center.x - cosA * halfL + perpX * (halfW + offset),
        y: center.y - sinA * halfL + perpY * (halfW + offset)
      ),
      end: FloorPlanPoint2D(
        x: center.x + cosA * halfL + perpX * (halfW + offset),
        y: center.y + sinA * halfL + perpY * (halfW + offset)
      ),
      label: String(format: metersFormat, length),
      offset: offset,
      type: .overall,
      witnessStart: outerNear1,
      witnessEnd: outerNear2
    )
    let widthLine = DimensionLine(
      start: outerFar1,
      end: outerFar2,
      label: String(format: metersFormat, width),
      offset: offset,
      type: .overall,
      witnessStart: FloorPlanPoint2D(
        x: center.x + cosA * halfL + perpX * halfW,
        y: center.y + sinA * halfL + perpY * halfW
      ),
      witnessEnd: FloorPlanPoint2D(
        x: center.x + cosA * halfL - perpX * halfW,
        y: center.y + sinA * halfL - perpY * halfW
      )
    )
    return [lengthLine, widthLine]
  }

  static func wallSegmentDimensions(for walls: [FloorPlanWall]) -> [DimensionLine] {
    walls.compactMap { wall in
      guard wall.length >= 0.25 else { return nil }
      let dx = wall.end.x - wall.start.x
      let dy = wall.end.y - wall.start.y
      let len = hypot(dx, dy)
      guard len > 1e-4 else { return nil }
      let nx = -dy / len
      let ny = dx / len
      let offset: CGFloat = 0.22
      return DimensionLine(
        start: FloorPlanPoint2D(x: wall.start.x + nx * offset, y: wall.start.y + ny * offset),
        end: FloorPlanPoint2D(x: wall.end.x + nx * offset, y: wall.end.y + ny * offset),
        label: String(format: metersFormat, wall.length),
        offset: offset,
        type: .wallSegment,
        witnessStart: wall.start,
        witnessEnd: wall.end
      )
    }
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

  // MARK: - Geometry helpers

  private static func worldBounds(of node: SCNNode) -> (min: SCNVector3, max: SCNVector3)? {
    guard node.geometry != nil else { return nil }
    let box = node.boundingBox
    let corners: [SCNVector3] = [
      SCNVector3(box.min.x, box.min.y, box.min.z),
      SCNVector3(box.max.x, box.min.y, box.min.z),
      SCNVector3(box.min.x, box.max.y, box.min.z),
      SCNVector3(box.max.x, box.max.y, box.min.z),
      SCNVector3(box.min.x, box.min.y, box.max.z),
      SCNVector3(box.max.x, box.min.y, box.max.z),
      SCNVector3(box.min.x, box.max.y, box.max.z),
      SCNVector3(box.max.x, box.max.y, box.max.z),
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

  private static func isLikelyFloorSlab(
    _ b: (min: SCNVector3, max: SCNVector3),
    sceneBounds: (min: SCNVector3, max: SCNVector3)
  ) -> Bool {
    let dx = b.max.x - b.min.x
    let dy = b.max.y - b.min.y
    let dz = b.max.z - b.min.z
    let foot = max(dx, dz)
    guard foot > 0.06 else { return false }
    guard dy < max(0.05, 0.12 * foot) else { return false }
    let sceneH = max(sceneBounds.max.y - sceneBounds.min.y, 0.12)
    return b.min.y <= sceneBounds.min.y + 0.14 * sceneH + 0.04
  }

  private static func isLikelyVerticalWallSlab(
    _ b: (min: SCNVector3, max: SCNVector3),
    sceneHeight: Float
  ) -> Bool {
    let dx = b.max.x - b.min.x
    let dy = b.max.y - b.min.y
    let dz = b.max.z - b.min.z
    let hMax = max(dx, dz)
    let hMin = min(dx, dz)
    guard dy > 0.18 else { return false }
    guard dy > 0.28 * max(hMax, 0.08) else { return false }
    guard hMin < 0.26 * hMax else { return false }
    return dy > 0.22 * max(sceneHeight, 0.2)
  }

  private static func convexHull(_ points: [(x: Float, z: Float)]) -> [(x: Float, z: Float)] {
    let sorted = points.sorted {
      if $0.x == $1.x { return $0.z < $1.z }
      return $0.x < $1.x
    }
    guard sorted.count >= 3 else { return sorted }

    func cross(_ o: (x: Float, z: Float), _ a: (x: Float, z: Float), _ b: (x: Float, z: Float)) -> Float {
      (a.x - o.x) * (b.z - o.z) - (a.z - o.z) * (b.x - o.x)
    }

    var lower: [(x: Float, z: Float)] = []
    for p in sorted {
      while lower.count >= 2 && cross(lower[lower.count - 2], lower[lower.count - 1], p) <= 0 {
        lower.removeLast()
      }
      lower.append(p)
    }

    var upper: [(x: Float, z: Float)] = []
    for p in sorted.reversed() {
      while upper.count >= 2 && cross(upper[upper.count - 2], upper[upper.count - 1], p) <= 0 {
        upper.removeLast()
      }
      upper.append(p)
    }

    lower.removeLast()
    upper.removeLast()
    return lower + upper
  }
}
