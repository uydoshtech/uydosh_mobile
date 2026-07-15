import SceneKit
import UIKit

/// Loads bundled CC0 furniture meshes (Kenney Furniture Kit) and fits them to an
/// `EditableObject` footprint: same center, Y-rotation, and width×height×length as the
/// former `SCNBox` placeholders in `Scene3DRegenerationService`.
enum FurnitureModelCatalog {
  private static var templateCache: [String: SCNNode] = [:]
  private static let cacheQueue = DispatchQueue(label: "uydosh.furnitureModelCatalog")

  /// Resource stem under `FurnitureModels/` for types that have a real mesh.
  static func resourceName(for type: EditableObjectType) -> String? {
    switch type {
    case .bed: return "bed"
    case .chair: return "chair"
    case .table: return "table"
    case .sofa: return "sofa"
    case .storage: return "storage"
    default: return nil
    }
  }

  /// Returns a node sized to `(width, height, length)`, sitting on `floorY`, centered at
  /// `(centerX, centerZ)`, rotated by `-rotationRadians` about Y — matching `SCNBox` placement.
  /// Use for fully regenerated scenes where walls and furniture share editable-model space.
  static func makeNode(
    for type: EditableObjectType,
    width: Float,
    height: Float,
    length: Float,
    centerX: Float,
    centerZ: Float,
    floorY: Float,
    rotationRadians: Float,
    stylized: Bool,
    outsideBounds: Bool
  ) -> SCNNode? {
    guard let mesh = makeScaledMesh(
      for: type,
      sizeX: width,
      sizeY: height,
      sizeZ: length,
      stylized: stylized,
      outsideBounds: outsideBounds
    ) else { return nil }

    let wrapper = SCNNode()
    wrapper.name = "UydoshGeneratedObject"
    wrapper.addChildNode(mesh)
    wrapper.position = SCNVector3(centerX, floorY, centerZ)
    wrapper.eulerAngles.y = -rotationRadians
    wrapper.castsShadow = true
    return wrapper
  }

  /// Fits a catalog mesh into `host`'s local AABB and parents it under `host`, clearing the
  /// original box geometry. Preserves the host's world transform — required for unedited USDZ
  /// scenes where editable-model XZ is rotated for the 2D plan and must not drive 3D placement.
  @discardableResult
  static func replaceGeometryInPlace(
    on host: SCNNode,
    type: EditableObjectType,
    stylized: Bool
  ) -> Bool {
    if host.childNode(withName: catalogMeshName, recursively: false) != nil {
      return true
    }
    let (bmin, bmax) = host.boundingBox
    let dstX = bmax.x - bmin.x
    let dstY = bmax.y - bmin.y
    let dstZ = bmax.z - bmin.z
    guard dstX > 1e-4, dstY > 1e-4, dstZ > 1e-4 else { return false }
    guard let template = template(for: type) else { return false }

    let mesh = template.clone()
    deepCopyGeometries(on: mesh)
    let (smin, smax) = mesh.boundingBox
    let srcX = smax.x - smin.x
    let srcY = smax.y - smin.y
    let srcZ = smax.z - smin.z
    guard srcX > 1e-4, srcY > 1e-4, srcZ > 1e-4 else { return false }

    // Map source AABB → host local AABB with scale+position only (no pivot — SceneKit pivot+scale
    // has caused world-space offsets that pushed furniture outside the walls).
    let sx = dstX / srcX
    let sy = dstY / srcY
    let sz = dstZ / srcZ
    mesh.pivot = SCNMatrix4Identity
    mesh.scale = SCNVector3(sx, sy, sz)
    mesh.position = SCNVector3(
      bmin.x - smin.x * sx,
      bmin.y - smin.y * sy,
      bmin.z - smin.z * sz
    )
    mesh.name = catalogMeshName
    applyMaterials(to: mesh, stylized: stylized, outsideBounds: false)

    host.geometry = nil
    for child in host.childNodes where child.name != catalogMeshName {
      child.removeFromParentNode()
    }
    host.addChildNode(mesh)
    host.castsShadow = true
    return true
  }

  static let catalogMeshName = "UydoshCatalogMesh"

  // MARK: - Loading

  private static func makeScaledMesh(
    for type: EditableObjectType,
    sizeX: Float,
    sizeY: Float,
    sizeZ: Float,
    stylized: Bool,
    outsideBounds: Bool
  ) -> SCNNode? {
    guard let template = template(for: type) else { return nil }
    let mesh = template.clone()
    deepCopyGeometries(on: mesh)
    let (minVec, maxVec) = mesh.boundingBox
    let srcX = maxVec.x - minVec.x
    let srcY = maxVec.y - minVec.y
    let srcZ = maxVec.z - minVec.z
    guard srcX > 1e-4, srcY > 1e-4, srcZ > 1e-4 else { return nil }

    let sx = sizeX / srcX
    let sy = sizeY / srcY
    let sz = sizeZ / srcZ
    // Bottom-center at local origin without using pivot (avoids SceneKit pivot+scale offsets).
    let bcX = (minVec.x + maxVec.x) * 0.5
    let bcZ = (minVec.z + maxVec.z) * 0.5
    mesh.pivot = SCNMatrix4Identity
    mesh.scale = SCNVector3(sx, sy, sz)
    mesh.position = SCNVector3(-sx * bcX, -sy * minVec.y, -sz * bcZ)
    applyMaterials(to: mesh, stylized: stylized, outsideBounds: outsideBounds)
    return mesh
  }

  private static func template(for type: EditableObjectType) -> SCNNode? {
    guard let name = resourceName(for: type) else { return nil }
    return cacheQueue.sync {
      if let cached = templateCache[name] { return cached }
      guard let loaded = loadObj(named: name) else { return nil }
      templateCache[name] = loaded
      return loaded
    }
  }

  private static func loadObj(named name: String) -> SCNNode? {
    let url =
      Bundle.main.url(forResource: name, withExtension: "obj", subdirectory: "FurnitureModels")
      ?? Bundle.main.url(forResource: name, withExtension: "obj")
    guard let url else {
      NSLog("[FurnitureModelCatalog] missing \(name).obj in bundle")
      return nil
    }
    do {
      let scene = try SCNScene(
        url: url,
        options: [
          .checkConsistency: true,
          .createNormalsIfAbsent: true,
          .flattenScene: false,
        ]
      )
      let root = SCNNode()
      for child in scene.rootNode.childNodes {
        root.addChildNode(child.clone())
      }
      // Force bounding-box evaluation of merged children.
      _ = root.boundingBox
      return root
    } catch {
      NSLog("[FurnitureModelCatalog] failed to load \(name).obj: \(error)")
      return nil
    }
  }

  // MARK: - Materials

  /// `SCNNode.clone()` shares geometry/materials with the source; copy them so per-instance
  /// styling (outside-bounds orange, non-stylized gray) cannot mutate the cached template.
  private static func deepCopyGeometries(on node: SCNNode) {
    node.enumerateHierarchy { child, _ in
      guard let geometry = child.geometry else { return }
      guard let copy = geometry.copy() as? SCNGeometry else { return }
      copy.materials = geometry.materials.map { ($0.copy() as? SCNMaterial) ?? SCNMaterial() }
      child.geometry = copy
    }
  }

  private static func applyMaterials(to node: SCNNode, stylized: Bool, outsideBounds: Bool) {
    node.enumerateHierarchy { child, _ in
      guard let geometry = child.geometry else { return }
      for material in geometry.materials {
        if outsideBounds {
          material.lightingModel = .blinn
          material.diffuse.contents = UIColor.systemOrange.withAlphaComponent(0.75)
          material.transparency = 0.75
          material.isDoubleSided = true
          continue
        }
        if !stylized {
          material.lightingModel = .blinn
          material.diffuse.contents = UIColor(white: 0.72, alpha: 1)
          material.metalness.contents = nil
          material.roughness.contents = nil
          continue
        }
        // Keep Kenney MTL colors; upgrade to PBR so they match room lighting.
        material.lightingModel = .physicallyBased
        if material.metalness.contents == nil {
          material.metalness.contents = NSNumber(value: 0.05)
        }
        if material.roughness.contents == nil {
          material.roughness.contents = NSNumber(value: 0.75)
        }
        material.isDoubleSided = false
      }
    }
  }
}
