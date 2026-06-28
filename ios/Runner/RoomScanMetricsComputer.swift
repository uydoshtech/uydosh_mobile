import SceneKit

/// Footprint metrics extracted from RoomPlan USDZ floor geometry (not full-scene AABB).
/// Multi-room scans sum each room floor mesh area; long×short is the overall OBB footprint.
struct RoomScanMetricsResult {
  let floorLongM: Double
  let floorShortM: Double
  let heightM: Double
  let floorAreaM2: Double
  /// World-space axis-aligned footprint bounds on the X/Z plane.
  let minX: Float
  let maxX: Float
  let minZ: Float
  let maxZ: Float
  /// OBB footprint center in world X/Z — matches floorLongM × floorShortM.
  let footprintCenterX: Float
  let footprintCenterZ: Float
  /// Yaw (radians) that aligns the long footprint edge with +X in world space.
  let footprintYaw: Float
  let footprintSource: String
  let polygonVertexCount: Int
}

/// Floor outline extracted from scan geometry — used to auto-build a ceiling cap.
struct ScanFloorFootprint {
  let polygonXZ: [(x: Float, z: Float)]
  let floorY: Float
  let ceilingY: Float
}

/// One scanned room's floor mesh footprint (RoomPlan exports a separate floor node per room).
private struct RoomFloorFootprint {
  var points: [(x: Float, z: Float)]
  var triangles: [[(x: Float, z: Float)]]
}

/// Computes room dimensions from floor polygon geometry with fallbacks.
enum RoomScanMetricsComputer {
  static func metrics(for scene: SCNScene) -> RoomScanMetricsResult? {
    guard let sceneBounds = unionWorldBounds(of: scene.rootNode) else { return nil }

    let height = Double(sceneBounds.max.y - sceneBounds.min.y)
    guard height > 1e-6 else { return nil }

    let footprint = computeFootprintMetrics(scene: scene, sceneBounds: sceneBounds)
    return footprint
  }

  /// Convex floor outline in world X/Z, derived from the scan floor mesh (same footprint used for metrics).
  static func floorFootprint(for scene: SCNScene) -> ScanFloorFootprint? {
    guard let sceneBounds = unionWorldBounds(of: scene.rootNode) else { return nil }

    var floorPoints = collectFloorPoints(from: scene, sceneBounds: sceneBounds)
    if floorPoints.count < 3 {
      floorPoints = wallBasePoints(scene: scene, sceneBounds: sceneBounds)
    }
    if floorPoints.count < 3 {
      floorPoints = [
        (x: sceneBounds.min.x, z: sceneBounds.min.z),
        (x: sceneBounds.max.x, z: sceneBounds.min.z),
        (x: sceneBounds.max.x, z: sceneBounds.max.z),
        (x: sceneBounds.min.x, z: sceneBounds.max.z),
      ]
    }

    let hull = convexHull(dedupePoints(floorPoints, epsilon: 0.02))
    guard hull.count >= 3 else { return nil }

    return ScanFloorFootprint(
      polygonXZ: hull,
      floorY: sceneBounds.min.y,
      ceilingY: sceneBounds.max.y - 0.01
    )
  }

  static func metrics(forUsdPath path: String) -> [String: Double]? {
    guard FileManager.default.fileExists(atPath: path) else { return nil }
    let url = URL(fileURLWithPath: path)
    guard let scene = try? SCNScene(url: url, options: nil),
      let result = metrics(for: scene)
    else { return nil }

    return [
      "floor_long_m": result.floorLongM,
      "floor_short_m": result.floorShortM,
      "height_m": result.heightM,
      "floor_area_m2": result.floorAreaM2,
    ]
  }

  // MARK: - Footprint

  private static func roomFootprintHasGeometry(_ footprint: RoomFloorFootprint) -> Bool {
    !footprint.triangles.isEmpty || footprint.points.count >= 3
  }

  private static func computeFootprintMetrics(
    scene: SCNScene,
    sceneBounds: (min: SCNVector3, max: SCNVector3)
  ) -> RoomScanMetricsResult? {
    let roomFootprints = collectFloorFootprintsByRoom(from: scene, sceneBounds: sceneBounds)
      .filter(roomFootprintHasGeometry)

    var floorPoints: [(x: Float, z: Float)] = []
    var floorTriangles: [[(x: Float, z: Float)]] = []
    var source = "floor_polygon"

    if !roomFootprints.isEmpty {
      floorPoints = roomFootprints.flatMap(\.points)
      floorTriangles = roomFootprints.flatMap(\.triangles)
      if roomFootprints.count > 1 {
        source = "multi_room_floor_sum"
      }
    } else {
      floorPoints = collectFloorPoints(from: scene, sceneBounds: sceneBounds)
      floorTriangles = collectFloorTriangles(from: scene, sceneBounds: sceneBounds)
    }

    var hasFloorGeometry = !floorTriangles.isEmpty || floorPoints.count >= 3
    if !hasFloorGeometry {
      floorPoints = wallBasePoints(scene: scene, sceneBounds: sceneBounds)
      floorTriangles.removeAll()
      source = floorPoints.count >= 3 ? "wall_bases" : "scene_aabb"
      hasFloorGeometry = floorPoints.count >= 3
    }

    if !hasFloorGeometry {
      let dx = sceneBounds.max.x - sceneBounds.min.x
      let dz = sceneBounds.max.z - sceneBounds.min.z
      guard dx > 1e-6 || dz > 1e-6 else { return nil }
      return RoomScanMetricsResult(
        floorLongM: Double(max(dx, dz)),
        floorShortM: Double(min(dx, dz)),
        heightM: Double(sceneBounds.max.y - sceneBounds.min.y),
        floorAreaM2: Double(dx) * Double(dz),
        minX: sceneBounds.min.x,
        maxX: sceneBounds.max.x,
        minZ: sceneBounds.min.z,
        maxZ: sceneBounds.max.z,
        footprintCenterX: (sceneBounds.min.x + sceneBounds.max.x) * 0.5,
        footprintCenterZ: (sceneBounds.min.z + sceneBounds.max.z) * 0.5,
        footprintYaw: dx >= dz ? 0 : Float.pi / 2,
        footprintSource: source,
        polygonVertexCount: 0
      )
    }

    if floorPoints.count < 3, !floorTriangles.isEmpty {
      floorPoints = floorTriangles.flatMap { tri in tri.map { (x: $0.x, z: $0.z) } }
    }

    let obb = minimumAreaBoundingRect(points: floorPoints)
    let polygonArea: Double
    if roomFootprints.count > 1 {
      polygonArea = roomFootprints.reduce(0) { partial, footprint in
        partial + polygonAreaM2(from: footprint.triangles, fallbackPoints: footprint.points)
      }
    } else {
      polygonArea = polygonAreaM2(from: floorTriangles, fallbackPoints: floorPoints)
    }
    let minX = floorPoints.map(\.x).min() ?? sceneBounds.min.x
    let maxX = floorPoints.map(\.x).max() ?? sceneBounds.max.x
    let minZ = floorPoints.map(\.z).min() ?? sceneBounds.min.z
    let maxZ = floorPoints.map(\.z).max() ?? sceneBounds.max.z

    return RoomScanMetricsResult(
      floorLongM: Double(obb.long),
      floorShortM: Double(obb.short),
      heightM: Double(sceneBounds.max.y - sceneBounds.min.y),
      floorAreaM2: polygonArea,
      minX: minX,
      maxX: maxX,
      minZ: minZ,
      maxZ: maxZ,
      footprintCenterX: obb.centerX,
      footprintCenterZ: obb.centerZ,
      footprintYaw: obb.yaw,
      footprintSource: source,
      polygonVertexCount: floorPoints.count
    )
  }

  /// Groups floor mesh geometry by SceneKit node — one footprint per scanned room.
  private static func collectFloorFootprintsByRoom(
    from scene: SCNScene,
    sceneBounds: (min: SCNVector3, max: SCNVector3)
  ) -> [RoomFloorFootprint] {
    var footprints: [RoomFloorFootprint] = []
    func visit(_ node: SCNNode) {
      if node.geometry != nil {
        let name = (node.name ?? "").lowercased()
        let isNamedFloor = name.contains("floor") || name.contains("ground")
        let nodeBounds = worldBounds(of: node)
        let isSlab = nodeBounds.map { isLikelyFloorSlab($0, sceneBounds: sceneBounds) } ?? false
        if isNamedFloor || isSlab {
          let floorY = nodeBounds?.min.y ?? sceneBounds.min.y
          let yTol = max(0.08, 0.06 * max(sceneBounds.max.y - sceneBounds.min.y, 0.12))
          var points: [(x: Float, z: Float)] = []
          var triangles: [[(x: Float, z: Float)]] = []
          for v in worldVertices(of: node) where abs(v.y - floorY) <= yTol {
            points.append((x: v.x, z: v.z))
          }
          for tri in worldTrianglesXZ(of: node, floorY: floorY, yTolerance: yTol) {
            triangles.append(tri)
          }
          if points.count >= 3 || !triangles.isEmpty {
            footprints.append(RoomFloorFootprint(points: points, triangles: triangles))
          }
        }
      }
      for child in node.childNodes { visit(child) }
    }
    visit(scene.rootNode)
    return footprints
  }

  private static func collectFloorPoints(
    from scene: SCNScene,
    sceneBounds: (min: SCNVector3, max: SCNVector3)
  ) -> [(x: Float, z: Float)] {
    var floorPoints: [(x: Float, z: Float)] = []
    func visit(_ node: SCNNode) {
      if node.geometry != nil {
        let name = (node.name ?? "").lowercased()
        let isNamedFloor = name.contains("floor") || name.contains("ground")
        let nodeBounds = worldBounds(of: node)
        let isSlab = nodeBounds.map { isLikelyFloorSlab($0, sceneBounds: sceneBounds) } ?? false
        if isNamedFloor || isSlab {
          let verts = worldVertices(of: node)
          let floorY = nodeBounds?.min.y ?? sceneBounds.min.y
          let yTol = max(0.08, 0.06 * max(sceneBounds.max.y - sceneBounds.min.y, 0.12))
          for v in verts where abs(v.y - floorY) <= yTol {
            floorPoints.append((x: v.x, z: v.z))
          }
        }
      }
      for child in node.childNodes { visit(child) }
    }
    visit(scene.rootNode)
    return floorPoints
  }

  private static func collectFloorTriangles(
    from scene: SCNScene,
    sceneBounds: (min: SCNVector3, max: SCNVector3)
  ) -> [[(x: Float, z: Float)]] {
    var floorTriangles: [[(x: Float, z: Float)]] = []
    func visit(_ node: SCNNode) {
      if node.geometry != nil {
        let name = (node.name ?? "").lowercased()
        let isNamedFloor = name.contains("floor") || name.contains("ground")
        let nodeBounds = worldBounds(of: node)
        let isSlab = nodeBounds.map { isLikelyFloorSlab($0, sceneBounds: sceneBounds) } ?? false
        if isNamedFloor || isSlab {
          let floorY = nodeBounds?.min.y ?? sceneBounds.min.y
          let yTol = max(0.08, 0.06 * max(sceneBounds.max.y - sceneBounds.min.y, 0.12))
          for tri in worldTrianglesXZ(of: node, floorY: floorY, yTolerance: yTol) {
            floorTriangles.append(tri)
          }
        }
      }
      for child in node.childNodes { visit(child) }
    }
    visit(scene.rootNode)
    return floorTriangles
  }

  private static func wallBasePoints(
    scene: SCNScene,
    sceneBounds: (min: SCNVector3, max: SCNVector3)
  ) -> [(x: Float, z: Float)] {
    var points: [(x: Float, z: Float)] = []
    let floorY = sceneBounds.min.y
    let yTol = max(0.12, 0.08 * max(sceneBounds.max.y - sceneBounds.min.y, 0.12))

    func visit(_ node: SCNNode) {
      let name = (node.name ?? "").lowercased()
      if name.contains("wall") {
        for v in worldVertices(of: node) where abs(v.y - floorY) <= yTol {
          points.append((x: v.x, z: v.z))
        }
      }
      for child in node.childNodes { visit(child) }
    }
    visit(scene.rootNode)
    return dedupePoints(points, epsilon: 0.05)
  }

  // MARK: - Geometry helpers

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
      data.getBytes(&vy, range: NSRange(location: i * stride + offset + MemoryLayout<Float>.size, length: MemoryLayout<Float>.size))
      data.getBytes(&vz, range: NSRange(location: i * stride + offset + 2 * MemoryLayout<Float>.size, length: MemoryLayout<Float>.size))
      out.append(node.convertPosition(SCNVector3(vx, vy, vz), to: nil))
    }
    return out
  }

  private static func worldTrianglesXZ(
    of node: SCNNode,
    floorY: Float,
    yTolerance: Float
  ) -> [[(x: Float, z: Float)]] {
    guard let geo = node.geometry,
      let element = geo.elements.first
    else { return [] }

    let verts = worldVertices(of: node)
    guard !verts.isEmpty else { return [] }

    let indexCount = element.primitiveCount * 3
    let bytesPerIndex = element.bytesPerIndex
    let data = element.data as NSData
    var triangles: [[(x: Float, z: Float)]] = []

    func vertexIndex(at slot: Int) -> Int? {
      let offset = slot * bytesPerIndex
      guard offset + bytesPerIndex <= data.length else { return nil }
      if bytesPerIndex == 2 {
        var idx = UInt16(0)
        data.getBytes(&idx, range: NSRange(location: offset, length: 2))
        return Int(idx)
      }
      var idx = UInt32(0)
      data.getBytes(&idx, range: NSRange(location: offset, length: 4))
      return Int(idx)
    }

    for t in 0..<element.primitiveCount {
      guard let i0 = vertexIndex(at: t * 3),
        let i1 = vertexIndex(at: t * 3 + 1),
        let i2 = vertexIndex(at: t * 3 + 2),
        i0 < verts.count, i1 < verts.count, i2 < verts.count
      else { continue }
      let a = verts[i0]
      let b = verts[i1]
      let c = verts[i2]
      let avgY = (a.y + b.y + c.y) / 3
      guard abs(avgY - floorY) <= yTolerance else { continue }
      triangles.append([(x: a.x, z: a.z), (x: b.x, z: b.z), (x: c.x, z: c.z)])
    }
    return triangles
  }

  private static func polygonAreaM2(
    from triangles: [[(x: Float, z: Float)]],
    fallbackPoints: [(x: Float, z: Float)]
  ) -> Double {
    if !triangles.isEmpty {
      var sum: Double = 0
      for tri in triangles where tri.count == 3 {
        let ax = Double(tri[0].x)
        let az = Double(tri[0].z)
        let bx = Double(tri[1].x)
        let bz = Double(tri[1].z)
        let cx = Double(tri[2].x)
        let cz = Double(tri[2].z)
        sum += abs((bx - ax) * (cz - az) - (cx - ax) * (bz - az)) * 0.5
      }
      if sum > 1e-4 { return sum }
    }
    let obb = minimumAreaBoundingRect(points: fallbackPoints)
    return Double(obb.long) * Double(obb.short)
  }

  private static func minimumAreaBoundingRect(
    points: [(x: Float, z: Float)]
  ) -> (long: Float, short: Float, yaw: Float, centerX: Float, centerZ: Float) {
    let unique = dedupePoints(points, epsilon: 0.02)
    guard unique.count >= 2 else {
      return (long: 1, short: 1, yaw: 0, centerX: 0, centerZ: 0)
    }

    let hull = convexHull(unique)
    let ring = hull.count >= 3 ? hull : unique

    var bestArea: Float = .greatestFiniteMagnitude
    var bestLong: Float = 0
    var bestShort: Float = 0
    var bestYaw: Float = 0
    var bestCenterX: Float = unique[0].x
    var bestCenterZ: Float = unique[0].z

    for i in 0..<ring.count {
      let p1 = ring[i]
      let p2 = ring[(i + 1) % ring.count]
      let edgeYaw = atan2(p2.z - p1.z, p2.x - p1.x)
      let cosA = cos(-edgeYaw)
      let sinA = sin(-edgeYaw)
      var minRX = Float.greatestFiniteMagnitude
      var maxRX = -Float.greatestFiniteMagnitude
      var minRZ = Float.greatestFiniteMagnitude
      var maxRZ = -Float.greatestFiniteMagnitude
      for p in unique {
        let rx = p.x * cosA - p.z * sinA
        let rz = p.x * sinA + p.z * cosA
        minRX = min(minRX, rx)
        maxRX = max(maxRX, rx)
        minRZ = min(minRZ, rz)
        maxRZ = max(maxRZ, rz)
      }
      let w = maxRX - minRX
      let h = maxRZ - minRZ
      let area = w * h
      if area < bestArea {
        bestArea = area
        let long = max(w, h)
        let short = min(w, h)
        let rectYaw = w >= h ? edgeYaw : edgeYaw + Float.pi / 2
        bestLong = long
        bestShort = short
        bestYaw = rectYaw
        let cx = (minRX + maxRX) * 0.5
        let cz = (minRZ + maxRZ) * 0.5
        bestCenterX = cx * cos(rectYaw) + cz * sin(rectYaw)
        bestCenterZ = -cx * sin(rectYaw) + cz * cos(rectYaw)
      }
    }

    if bestLong <= 1e-6 {
      let minX = unique.map(\.x).min() ?? 0
      let maxX = unique.map(\.x).max() ?? 0
      let minZ = unique.map(\.z).min() ?? 0
      let maxZ = unique.map(\.z).max() ?? 0
      let dx = maxX - minX
      let dz = maxZ - minZ
      return (
        long: max(dx, dz),
        short: min(dx, dz),
        yaw: dx >= dz ? 0 : Float.pi / 2,
        centerX: (minX + maxX) * 0.5,
        centerZ: (minZ + maxZ) * 0.5
      )
    }

    return (long: bestLong, short: bestShort, yaw: bestYaw, centerX: bestCenterX, centerZ: bestCenterZ)
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

  private static func dedupePoints(_ points: [(x: Float, z: Float)], epsilon: Float) -> [(x: Float, z: Float)] {
    var out: [(x: Float, z: Float)] = []
    for p in points {
      if !out.contains(where: { hypotf($0.x - p.x, $0.z - p.z) < epsilon }) {
        out.append(p)
      }
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

  /// World-space union of all geometry bounding boxes (root’s own `boundingBox` ignores children).
  static func unionWorldBounds(of root: SCNNode) -> (min: SCNVector3, max: SCNVector3)? {
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
    var any = false

    func visit(_ node: SCNNode) {
      if node.geometry != nil {
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
        for c in corners {
          let w = node.convertPosition(c, to: nil)
          minV.x = min(minV.x, w.x)
          minV.y = min(minV.y, w.y)
          minV.z = min(minV.z, w.z)
          maxV.x = max(maxV.x, w.x)
          maxV.y = max(maxV.y, w.y)
          maxV.z = max(maxV.z, w.z)
          any = true
        }
      }
      for child in node.childNodes {
        visit(child)
      }
    }

    visit(root)
    guard any else { return nil }
    return (minV, maxV)
  }
}
