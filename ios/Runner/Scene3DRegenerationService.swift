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
      let material: SCNMaterial
      if object.isOutsideBounds {
        material = SCNMaterial()
        material.diffuse.contents = UIColor.systemOrange.withAlphaComponent(0.75)
      } else if stylized {
        material = FurnitureMaterials.material(for: object.type)
      } else {
        material = SCNMaterial()
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

// MARK: - Shared surface shaders

enum SurfaceShaders {
  /// World-space triplanar projection of a material's diffuse texture, blended by the surface
  /// normal. Requires no UV coordinates, so it maps textures correctly onto RoomPlan scan meshes
  /// (walls/furniture) that often lack usable texcoords, and keeps texel size physically
  /// consistent. Tile size (metres) is supplied via the `triTileMeters` material argument.
  static let triplanar = """
  #pragma arguments
  float triTileMeters;
  #pragma body
  float tile = max(triTileMeters, 0.001);
  float4x4 invView = scn_frame.inverseViewTransform;
  float3 worldPos = (invView * float4(_surface.position, 1.0)).xyz;
  float3 worldNrm = normalize((invView * float4(_surface.normal, 0.0)).xyz);
  float3 blend = abs(worldNrm);
  blend /= (blend.x + blend.y + blend.z + 1e-5);
  float2 uvX = worldPos.zy / tile;
  float2 uvY = worldPos.xz / tile;
  float2 uvZ = worldPos.xy / tile;
  float4 cx = u_diffuseTexture.sample(u_diffuseTextureSampler, uvX);
  float4 cy = u_diffuseTexture.sample(u_diffuseTextureSampler, uvY);
  float4 cz = u_diffuseTexture.sample(u_diffuseTextureSampler, uvZ);
  _surface.diffuse = cx * blend.x + cy * blend.y + cz * blend.z;
  """

  /// Builds a PBR material that projects `texture` via world-space triplanar mapping.
  static func triplanarMaterial(
    texture: UIImage,
    tileMeters: Float,
    roughness: CGFloat,
    metalness: CGFloat
  ) -> SCNMaterial {
    let m = SCNMaterial()
    m.lightingModel = .physicallyBased
    m.diffuse.contents = texture
    m.diffuse.wrapS = .repeat
    m.diffuse.wrapT = .repeat
    m.roughness.contents = NSNumber(value: Double(roughness))
    m.metalness.contents = NSNumber(value: Double(metalness))
    m.shaderModifiers = [.surface: triplanar]
    m.setValue(NSNumber(value: tileMeters), forKey: "triTileMeters")
    return m
  }
}

// MARK: - Procedural furniture textures

/// Procedurally generated, tileable furniture textures. Each image is rendered once and cached,
/// then shared across every matching item, so the whole set adds only a few small textures to
/// GPU memory regardless of how many objects are in the room.
enum FurnitureTextures {
  static let wood: UIImage = makeWood(size: 512, planks: 5)
  static let fabricTeal: UIImage = makeFabric(
    size: 256, base: UIColor(red: 79 / 255, green: 125 / 255, blue: 138 / 255, alpha: 1))
  static let fabricLinen: UIImage = makeFabric(
    size: 256, base: UIColor(red: 206 / 255, green: 197 / 255, blue: 178 / 255, alpha: 1))
  static let metal: UIImage = makeMetal(size: 256)

  private static func jitter(_ seed: Int) -> CGFloat {
    CGFloat((seed &* 2_654_435_761 & 0x3F)) / 63.0 - 0.5
  }

  /// Warm wood with horizontal planks, seam lines, and subtle vertical grain.
  private static func makeWood(size: Int, planks: Int) -> UIImage {
    let dim = CGFloat(size)
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: dim, height: dim))
    return renderer.image { ctx in
      let cg = ctx.cgContext
      UIColor(red: 138 / 255, green: 98 / 255, blue: 64 / 255, alpha: 1).setFill()
      cg.fill(CGRect(x: 0, y: 0, width: dim, height: dim))

      let plankHeight = dim / CGFloat(planks)
      for p in 0..<planks {
        let j = jitter(p &+ 7)
        let r = (138 + j * 30) / 255
        let g = (98 + j * 22) / 255
        let b = (64 + j * 16) / 255
        UIColor(red: r, green: g, blue: b, alpha: 1).setFill()
        cg.fill(CGRect(x: 0, y: CGFloat(p) * plankHeight, width: dim, height: plankHeight))

        // Vertical grain streaks within the plank.
        cg.saveGState()
        cg.clip(to: CGRect(x: 0, y: CGFloat(p) * plankHeight, width: dim, height: plankHeight))
        for s in 0..<14 {
          let gx = jitter(p &* 31 &+ s)
          let x = (CGFloat(s) / 14.0 + gx * 0.03) * dim
          UIColor(white: gx > 0 ? 1 : 0, alpha: 0.05).setStroke()
          let line = UIBezierPath()
          line.move(to: CGPoint(x: x, y: CGFloat(p) * plankHeight))
          line.addLine(to: CGPoint(x: x + gx * 6, y: CGFloat(p + 1) * plankHeight))
          line.lineWidth = 1
          line.stroke()
        }
        cg.restoreGState()

        // Dark seam between planks.
        UIColor(red: 60 / 255, green: 40 / 255, blue: 26 / 255, alpha: 0.85).setFill()
        cg.fill(CGRect(x: 0, y: CGFloat(p) * plankHeight, width: dim, height: max(dim / 220, 1)))
      }
    }
  }

  /// Woven cloth: a base colour with a fine crosshatch weave to read as fabric.
  private static func makeFabric(size: Int, base: UIColor) -> UIImage {
    let dim = CGFloat(size)
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: dim, height: dim))
    return renderer.image { ctx in
      let cg = ctx.cgContext
      base.setFill()
      cg.fill(CGRect(x: 0, y: 0, width: dim, height: dim))

      let threads = 32
      let step = dim / CGFloat(threads)
      for i in 0..<threads {
        let pos = CGFloat(i) * step
        // Alternating light/dark threads give the woven look.
        UIColor(white: i % 2 == 0 ? 1 : 0, alpha: 0.06).setFill()
        cg.fill(CGRect(x: pos, y: 0, width: step / 2, height: dim))
        cg.fill(CGRect(x: 0, y: pos, width: dim, height: step / 2))
      }
    }
  }

  /// Brushed neutral metal: gray base with fine horizontal streaks.
  private static func makeMetal(size: Int) -> UIImage {
    let dim = CGFloat(size)
    let renderer = UIGraphicsImageRenderer(size: CGSize(width: dim, height: dim))
    return renderer.image { ctx in
      let cg = ctx.cgContext
      UIColor(white: 0.62, alpha: 1).setFill()
      cg.fill(CGRect(x: 0, y: 0, width: dim, height: dim))
      for s in 0..<Int(dim) {
        let j = jitter(s)
        UIColor(white: j > 0 ? 0.85 : 0.45, alpha: 0.08).setStroke()
        let y = CGFloat(s)
        let line = UIBezierPath()
        line.move(to: CGPoint(x: 0, y: y))
        line.addLine(to: CGPoint(x: dim, y: y))
        line.lineWidth = 1
        line.stroke()
      }
    }
  }
}

// MARK: - Furniture material mapping

/// Maps a furniture category to a stylized PBR material. Used by both the live scan view and the
/// regenerated/edited geometry so an item looks the same in either mode.
enum FurnitureMaterials {
  static func material(for type: EditableObjectType) -> SCNMaterial {
    switch type {
    case .table, .cabinet, .storage:
      return SurfaceShaders.triplanarMaterial(
        texture: FurnitureTextures.wood, tileMeters: 0.9, roughness: 0.7, metalness: 0)
    case .sofa, .chair:
      return SurfaceShaders.triplanarMaterial(
        texture: FurnitureTextures.fabricTeal, tileMeters: 0.4, roughness: 0.96, metalness: 0)
    case .bed:
      return SurfaceShaders.triplanarMaterial(
        texture: FurnitureTextures.fabricLinen, tileMeters: 0.5, roughness: 0.96, metalness: 0)
    case .appliance, .television, .fixture:
      return SurfaceShaders.triplanarMaterial(
        texture: FurnitureTextures.metal, tileMeters: 0.8, roughness: 0.32, metalness: 0.7)
    case .unknown:
      let m = SCNMaterial()
      m.lightingModel = .physicallyBased
      m.diffuse.contents = UIColor(red: 79 / 255, green: 125 / 255, blue: 138 / 255, alpha: 1)
      m.roughness.contents = NSNumber(value: 0.85)
      m.metalness.contents = NSNumber(value: 0.0)
      return m
    }
  }
}
