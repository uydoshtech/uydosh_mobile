import SceneKit
import UIKit

/// Regenerates simplified 3D room geometry from EditableFloorPlanModel.
enum Scene3DRegenerationService {
  static let generatedRootName = "UydoshGeneratedRoot"
  /// Invisible cap that blocks overhead sunlight without occluding the user's top-down view.
  /// Name contains "ceiling" so the viewer's shadow/visibility logic treats it like other ceilings.
  static let shadowCeilingNodeName = "UydoshGeneratedShadowCeiling"

  static func regenerate(
    in scene: SCNScene,
    model: EditableFloorPlanModel,
    stylizedMaterials: Bool
  ) {
    removeGeneratedRoot(from: scene)
    let root = SCNNode()
    root.name = generatedRootName

    root.addChildNode(buildFloorNode(model: model, stylized: stylizedMaterials))
    if model.ceilingEnabled {
      // Visible decorative roof — opaque, so it already blocks overhead sunlight.
      root.addChildNode(buildCeilingNode(model: model, stylized: stylizedMaterials))
    } else if let shadowCeiling = buildShadowCeilingNode(model: model) {
      // No visible ceiling: add an invisible cap so the sun can't flood the room from above
      // while keeping the interior open to the user when orbiting overhead.
      root.addChildNode(shadowCeiling)
    }
    for wallNode in buildWallNodes(model: model, stylized: stylizedMaterials) {
      root.addChildNode(wallNode)
    }
    for objectNode in buildObjectNodes(model: model, stylized: stylizedMaterials) {
      root.addChildNode(objectNode)
    }

    scene.rootNode.addChildNode(root)
    setOriginalRoomStructureHidden(in: scene, hidden: model.metadata.isEdited)
  }

  static func setOriginalRoomStructureHidden(in scene: SCNScene, hidden: Bool) {
    func visit(_ node: SCNNode) {
      if node.name == generatedRootName || node.name == "UydoshFramingCamera" {
        for child in node.childNodes { visit(child) }
        return
      }
      if node.parent?.name == generatedRootName {
        for child in node.childNodes { visit(child) }
        return
      }
      if let geo = node.geometry {
        let name = (node.name ?? "").lowercased()
        let isStructure = name.contains("wall") || name.contains("floor") || name.contains("ground")
          || name.contains("ceiling") || name.contains("door") || name.contains("window")
          || name.contains("opening")
        if isStructure {
          node.isHidden = hidden
        }
      }
      for child in node.childNodes { visit(child) }
    }
    visit(scene.rootNode)
  }

  static func removeGeneratedRoot(from scene: SCNScene) {
    scene.rootNode.childNode(withName: generatedRootName, recursively: false)?.removeFromParentNode()
  }

  // MARK: - Floor / ceiling

  private static func buildFloorNode(model: EditableFloorPlanModel, stylized: Bool) -> SCNNode {
    let node = SCNNode()
    node.name = "UydoshGeneratedFloor"
    let points = model.floorPolygon.compactMap { id -> (x: Float, z: Float)? in
      guard let v = model.vertex(id) else { return nil }
      return (Float(v.x), Float(v.z))
    }
    guard points.count >= 3 else { return node }

    let geometry = polygonGeometry(
      points: points,
      y: Float(model.floorY) + 0.002,
      materialColor: stylized
        ? UIColor(red: 122 / 255, green: 92 / 255, blue: 79 / 255, alpha: 1)
        : UIColor(white: 0.82, alpha: 1)
    )
    node.geometry = geometry
    return node
  }

  private static func buildCeilingNode(model: EditableFloorPlanModel, stylized: Bool) -> SCNNode {
    let node = SCNNode()
    node.name = "UydoshGeneratedCeiling"
    let points = model.floorPolygon.compactMap { id -> (x: Float, z: Float)? in
      guard let v = model.vertex(id) else { return nil }
      return (Float(v.x), Float(v.z))
    }
    guard points.count >= 3 else { return node }
    let y = Float(model.floorY + model.wallHeight) - 0.01
    let geometry = polygonGeometry(
      points: points,
      y: y,
      materialColor: stylized
        ? UIColor(red: 232 / 255, green: 223 / 255, blue: 207 / 255, alpha: 1)
        : UIColor(white: 0.92, alpha: 1)
    )
    node.geometry = geometry
    return node
  }

  /// Invisible, opaque-to-light cap at ceiling height. Hidden from the camera but kept in the
  /// shadow pass (see `ScanCeilingService.invisibleShadowMaterial`) so overhead sun is blocked.
  private static func buildShadowCeilingNode(model: EditableFloorPlanModel) -> SCNNode? {
    let points = model.floorPolygon.compactMap { id -> (x: Float, z: Float)? in
      guard let v = model.vertex(id) else { return nil }
      return (Float(v.x), Float(v.z))
    }
    guard points.count >= 3 else { return nil }

    let node = SCNNode()
    node.name = shadowCeilingNodeName
    node.castsShadow = true
    node.renderingOrder = -10
    let y = Float(model.floorY + model.wallHeight) - 0.005
    let geometry = polygonShape(points: points, y: y)
    geometry.materials = [ScanCeilingService.invisibleShadowMaterial()]
    node.geometry = geometry
    return node
  }

  // MARK: - Walls

  private static func buildWallNodes(model: EditableFloorPlanModel, stylized: Bool) -> [SCNNode] {
    model.walls.compactMap { wall -> SCNNode? in
      guard let start = model.vertex(wall.startVertexId),
        let end = model.vertex(wall.endVertexId)
      else { return nil }
      let dx = end.x - start.x
      let dz = end.z - start.z
      let length = hypot(dx, dz)
      guard length > 0.02 else { return nil }

      let box = SCNBox(
        width: CGFloat(length),
        height: CGFloat(wall.height),
        length: CGFloat(wall.thickness),
        chamferRadius: 0
      )
      let material = SCNMaterial()
      if stylized {
        material.lightingModel = .physicallyBased
        material.metalness.contents = 0
        if wall.type == .exterior {
          // Tileable red-brick texture, repeated so brick size stays physically
          // consistent regardless of wall length/height (~1 m per image tile).
          material.diffuse.contents = BrickTexture.shared
          material.diffuse.wrapS = .repeat
          material.diffuse.wrapT = .repeat
          let repeatS = Float(max(length / BrickTexture.tileMeters, 1))
          let repeatT = Float(max(wall.height / BrickTexture.tileMeters, 1))
          material.diffuse.contentsTransform = SCNMatrix4MakeScale(repeatS, repeatT, 1)
          material.roughness.contents = 0.95
        } else {
          material.diffuse.contents = UIColor(red: 232 / 255, green: 223 / 255, blue: 207 / 255, alpha: 1)
          material.roughness.contents = 0.86
        }
      } else {
        material.diffuse.contents = UIColor(white: 0.88, alpha: 1)
      }
      box.materials = [material]

      let node = SCNNode(geometry: box)
      node.name = "UydoshGeneratedWall"
      let midX = (start.x + end.x) * 0.5
      let midZ = (start.z + end.z) * 0.5
      node.position = SCNVector3(
        Float(midX),
        Float(model.floorY + wall.height * 0.5),
        Float(midZ)
      )
      node.eulerAngles.y = Float(-atan2(dz, dx))
      return node
    }
  }

  // MARK: - Objects

  private static func buildObjectNodes(model: EditableFloorPlanModel, stylized: Bool) -> [SCNNode] {
    model.objects.map { object in
      let height = Float(object.height ?? model.wallHeight * 0.45)
      let box = SCNBox(
        width: CGFloat(object.width),
        height: CGFloat(height),
        length: CGFloat(object.length),
        chamferRadius: 0.01
      )
      let material = SCNMaterial()
      if object.isOutsideBounds {
        material.diffuse.contents = UIColor.systemOrange.withAlphaComponent(0.75)
      } else if stylized {
        material.diffuse.contents = UIColor(red: 79 / 255, green: 125 / 255, blue: 138 / 255, alpha: 1)
      } else {
        material.diffuse.contents = UIColor(white: 0.72, alpha: 1)
      }
      box.materials = [material]

      let node = SCNNode(geometry: box)
      node.name = "UydoshGeneratedObject"
      node.position = SCNVector3(
        Float(object.centerX),
        Float(model.floorY + Double(height) * 0.5),
        Float(object.centerZ)
      )
      node.eulerAngles.y = Float(-object.rotationRadians)
      return node
    }
  }

  // MARK: - Geometry helpers

  private static func polygonGeometry(
    points: [(x: Float, z: Float)],
    y: Float,
    materialColor: UIColor
  ) -> SCNGeometry {
    let geometry = polygonShape(points: points, y: y)
    let material = SCNMaterial()
    material.diffuse.contents = materialColor
    material.isDoubleSided = true
    geometry.materials = [material]
    return geometry
  }

  /// Builds a flat, horizontal triangle-fan polygon at height `y`. Material is left to the caller.
  private static func polygonShape(
    points: [(x: Float, z: Float)],
    y: Float
  ) -> SCNGeometry {
    var vertices: [SCNVector3] = []
    var indices: [Int32] = []
    guard !points.isEmpty else {
      return SCNBox(width: 0.01, height: 0.01, length: 0.01, chamferRadius: 0)
    }

    let cx = points.map(\.x).reduce(0, +) / Float(points.count)
    let cz = points.map(\.z).reduce(0, +) / Float(points.count)
    vertices.append(SCNVector3(cx, y, cz))
    for p in points {
      vertices.append(SCNVector3(p.x, y, p.z))
    }
    for i in 1..<points.count {
      indices.append(0)
      indices.append(Int32(i))
      indices.append(Int32(i + 1))
    }
    indices.append(0)
    indices.append(Int32(points.count))
    indices.append(1)

    let source = SCNGeometrySource(vertices: vertices)
    let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
    return SCNGeometry(sources: [source], elements: [element])
  }
}

/// Procedurally generated, tileable red-brick texture for exterior walls.
/// Rendered once and shared by every wall material, so it adds only a single
/// small texture to GPU memory regardless of how many walls there are.
enum BrickTexture {
  /// Physical size (in metres) that one repetition of the image represents.
  static let tileMeters: Double = 1.0

  /// Cached tileable brick image. Generated lazily on first access.
  static let shared: UIImage = makeImage(size: 512, bricksPerRow: 4, coursesPerColumn: 13)

  private static func makeImage(size: Int, bricksPerRow: Int, coursesPerColumn: Int) -> UIImage {
    let dimension = CGFloat(size)
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: dimension, height: dimension))
    return renderer.image { context in
      let cg = context.cgContext

      // Mortar background.
      let mortar = UIColor(red: 222 / 255, green: 214 / 255, blue: 201 / 255, alpha: 1)
      mortar.setFill()
      cg.fill(CGRect(x: 0, y: 0, width: dimension, height: dimension))

      let courseHeight = dimension / CGFloat(coursesPerColumn)
      let brickWidth = dimension / CGFloat(bricksPerRow)
      let mortarGap = max(dimension / 160, 1.5)

      // Slight per-brick colour variation around a warm red.
      func brickColor(_ seed: Int) -> UIColor {
        let jitter = CGFloat((seed * 2654435761 & 0x3F)) / 63.0 - 0.5
        let r = (170 + jitter * 26) / 255
        let g = (74 + jitter * 18) / 255
        let b = (58 + jitter * 14) / 255
        return UIColor(red: r, green: g, blue: b, alpha: 1)
      }

      var seed = 0
      var course = -1
      // Draw an extra course/column on each edge so the running-bond offset
      // tiles seamlessly when the image repeats.
      while CGFloat(course) * courseHeight < dimension {
        let y = CGFloat(course) * courseHeight
        let rowOffset = (course % 2 == 0) ? 0 : -brickWidth / 2
        var x = rowOffset - brickWidth
        while x < dimension {
          let rect = CGRect(
            x: x + mortarGap / 2,
            y: y + mortarGap / 2,
            width: brickWidth - mortarGap,
            height: courseHeight - mortarGap
          )
          brickColor(seed).setFill()
          let path = UIBezierPath(roundedRect: rect, cornerRadius: mortarGap / 2)
          path.fill()
          seed += 1
          x += brickWidth
        }
        course += 1
      }
    }
  }
}
