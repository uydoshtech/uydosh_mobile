import SceneKit
import UIKit

/// Adds a synthetic ceiling cap to RoomPlan USDZ scans (Apple does not export ceiling geometry).
enum ScanCeilingService {
  static let auxRootName = "UydoshScanAuxRoot"
  static let ceilingNodeName = "UydoshScanCeiling"

  static func apply(to scene: SCNScene, stylizedMaterials: Bool) {
    remove(from: scene)
    guard !hasNativeCeiling(in: scene),
      let footprint = RoomScanMetricsComputer.floorFootprint(for: scene)
    else { return }

    let root = SCNNode()
    root.name = auxRootName

    let ceiling = SCNNode()
    ceiling.name = ceilingNodeName
    ceiling.castsShadow = true
    ceiling.renderingOrder = -10
    ceiling.geometry = polygonGeometry(
      points: footprint.polygonXZ,
      y: footprint.ceilingY,
      material: invisibleShadowMaterial()
    )
    root.addChildNode(ceiling)
    scene.rootNode.addChildNode(root)
    _ = stylizedMaterials
  }

  static func remove(from scene: SCNScene) {
    scene.rootNode.childNode(withName: auxRootName, recursively: false)?.removeFromParentNode()
  }

  static func updateMaterials(in scene: SCNScene, stylizedMaterials: Bool) {
    guard let ceiling = scene.rootNode.childNode(withName: ceilingNodeName, recursively: true),
      let geometry = ceiling.geometry
    else { return }
    geometry.materials = [invisibleShadowMaterial()]
    ceiling.castsShadow = true
    _ = stylizedMaterials
  }

  /// Fully invisible, non-occluding material. NOTE: this does not cast a shadow — SceneKit can only
  /// shadow from depth-writing geometry, which would occlude the cutaway camera. Overhead-light
  /// blocking is therefore handled non-geometrically by `SunSimulationController` dimming the sun
  /// as it climbs toward the zenith. This material just keeps the ceiling node harmless/invisible.
  static func invisibleShadowMaterial() -> SCNMaterial {
    let material = SCNMaterial()
    material.lightingModel = .constant
    material.diffuse.contents = UIColor.black
    material.transparency = 1.0
    material.transparencyMode = .aOne
    material.isDoubleSided = true
    material.writesToDepthBuffer = false
    material.readsFromDepthBuffer = false
    if #available(iOS 13.0, *) {
      material.colorBufferWriteMask = []
    }
    return material
  }

  private static func hasNativeCeiling(in scene: SCNScene) -> Bool {
    var found = false
    func visit(_ node: SCNNode) {
      guard !found else { return }
      if node.name == auxRootName || node.name == "UydoshGeneratedRoot" || node.name == "UydoshFramingCamera" {
        for child in node.childNodes { visit(child) }
        return
      }
      if node.geometry != nil, (node.name ?? "").lowercased().contains("ceiling") {
        found = true
        return
      }
      for child in node.childNodes { visit(child) }
    }
    visit(scene.rootNode)
    return found
  }

  private static func polygonGeometry(
    points: [(x: Float, z: Float)],
    y: Float,
    material: SCNMaterial
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
    let geometry = SCNGeometry(sources: [source], elements: [element])
    geometry.materials = [material]
    return geometry
  }
}
