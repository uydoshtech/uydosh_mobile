import SceneKit
import UIKit

/// Manages sun indicator, directional light, optional ray, and shadow casters for the room scene.
final class SunSimulationController {
  static let rigName = "UydoshSunRig"
  static let sunNodeName = "UydoshSunIndicator"
  static let lightNodeName = "UydoshSunLight"
  static let rayNodeName = "UydoshSunRay"
  static let ambientNodeName = "UydoshSunAmbient"
  static let fillLightNodeName = "UydoshSunFill"

  private(set) var isEnabled = false
  private(set) var azimuthDeg: Float = SunPositionMath.TimePreset.noon.azimuthDeg
  private(set) var elevationDeg: Float = SunPositionMath.TimePreset.noon.elevationDeg
  private(set) var lightIntensity: CGFloat = 1400

  private weak var scene: SCNScene?
  private var rigNode: SCNNode?
  private var sunNode: SCNNode?
  private var lightNode: SCNNode?
  private var roomCenter = SCNVector3Zero
  private var sunRadius: Float = 8
  private var worldEastPlanAngleRad: Double = 0
  private var scanWorldPlusXBearingDeg: Double?
  private var northCorrectionDeg: Double = 0
  /// Called whenever azimuth or elevation changes (sliders, presets, attach).
  var onSunPositionChanged: ((Float, Float) -> Void)?

  func attach(
    to scene: SCNScene,
    roomCenter: SCNVector3,
    sceneBounds: (min: SCNVector3, max: SCNVector3),
    worldEastPlanAngleRad: Double,
    scanWorldPlusXBearingDeg: Double?,
    northCorrectionDeg: Double
  ) {
    detach()
    self.scene = scene
    self.roomCenter = roomCenter
    self.worldEastPlanAngleRad = worldEastPlanAngleRad
    self.scanWorldPlusXBearingDeg = scanWorldPlusXBearingDeg
    self.northCorrectionDeg = northCorrectionDeg

    let dx = sceneBounds.max.x - sceneBounds.min.x
    let dy = sceneBounds.max.y - sceneBounds.min.y
    let dz = sceneBounds.max.z - sceneBounds.min.z
    let halfDiagonal = 0.5 * sqrt(dx * dx + dy * dy + dz * dz)
    sunRadius = max(halfDiagonal * 2.8, 3)

    let rig = SCNNode()
    rig.name = Self.rigName

    let ambientNode = SCNNode()
    ambientNode.name = Self.ambientNodeName
    let ambient = SCNLight()
    ambient.type = .ambient
    ambient.intensity = Self.ambientIntensity(forDirectional: lightIntensity)
    ambient.color = UIColor(red: 0.88, green: 0.91, blue: 0.96, alpha: 1)
    ambientNode.light = ambient
    rig.addChildNode(ambientNode)

    let fillNode = SCNNode()
    fillNode.name = Self.fillLightNodeName
    let fill = SCNLight()
    fill.type = .directional
    fill.intensity = Self.fillLightIntensity(forDirectional: lightIntensity)
    fill.color = UIColor(red: 0.82, green: 0.86, blue: 0.94, alpha: 1)
    fill.castsShadow = false
    fillNode.light = fill
    rig.addChildNode(fillNode)

    let sun = SCNNode()
    sun.name = Self.sunNodeName
    let sphere = SCNSphere(radius: max(0.08, CGFloat(sunRadius) * 0.035))
    let mat = SCNMaterial()
    mat.lightingModel = .constant
    mat.emission.contents = UIColor(red: 1, green: 0.92, blue: 0.55, alpha: 1)
    mat.diffuse.contents = UIColor(red: 1, green: 0.85, blue: 0.35, alpha: 1)
    sphere.materials = [mat]
    sun.geometry = sphere
    rig.addChildNode(sun)
    sunNode = sun

    let lightHolder = SCNNode()
    lightHolder.name = Self.lightNodeName
    let directional = SCNLight()
    directional.type = .directional
    directional.color = UIColor(red: 1, green: 0.96, blue: 0.88, alpha: 1)
    directional.intensity = lightIntensity
    directional.castsShadow = true
    directional.shadowMode = .deferred
    directional.shadowSampleCount = 12
    directional.shadowRadius = 6
    directional.shadowColor = UIColor(red: 0.28, green: 0.30, blue: 0.36, alpha: 1)
    directional.automaticallyAdjustsShadowProjection = true
    if #available(iOS 13.0, *) {
      directional.shadowMapSize = CGSize(width: 1024, height: 1024)
    }
    lightHolder.light = directional
    rig.addChildNode(lightHolder)
    lightNode = lightHolder

    let ray = buildRayNode(length: sunRadius * 0.92)
    ray.name = Self.rayNodeName
    rig.addChildNode(ray)

    scene.rootNode.addChildNode(rig)
    rigNode = rig

    refreshShadowCasters()
    setEnabled(true)
    updateSunPosition()
    updateDirectionalLight()
    notifySunPositionChanged()
  }

  func detach() {
    rigNode?.removeFromParentNode()
    rigNode = nil
    sunNode = nil
    lightNode = nil
    scene = nil
    isEnabled = false
  }

  func setOrientationContext(
    worldEastPlanAngleRad: Double,
    scanWorldPlusXBearingDeg: Double?,
    northCorrectionDeg: Double
  ) {
    self.worldEastPlanAngleRad = worldEastPlanAngleRad
    self.scanWorldPlusXBearingDeg = scanWorldPlusXBearingDeg
    self.northCorrectionDeg = northCorrectionDeg
    if isEnabled {
      updateSunPosition()
      updateDirectionalLight()
      notifySunPositionChanged()
    }
  }

  func setEnabled(_ enabled: Bool) {
    isEnabled = enabled
    rigNode?.isHidden = !enabled
  }

  func setSunAzimuth(degrees: Float) {
    var value = degrees.truncatingRemainder(dividingBy: 360)
    if value < 0 { value += 360 }
    azimuthDeg = value
    updateSunPosition()
    updateDirectionalLight()
    notifySunPositionChanged()
  }

  func setSunElevation(degrees: Float) {
    elevationDeg = min(90, max(0, degrees))
    updateSunPosition()
    updateDirectionalLight()
    notifySunPositionChanged()
  }

  func applyPreset(_ preset: SunPositionMath.TimePreset) {
    setSunAzimuth(degrees: preset.azimuthDeg)
    setSunElevation(degrees: preset.elevationDeg)
  }

  func setLightIntensity(_ value: CGFloat) {
    lightIntensity = min(3000, max(200, value))
    lightNode?.light?.intensity = lightIntensity
    rigNode?.childNode(withName: Self.ambientNodeName, recursively: true)?
      .light?.intensity = Self.ambientIntensity(forDirectional: lightIntensity)
    rigNode?.childNode(withName: Self.fillLightNodeName, recursively: true)?
      .light?.intensity = Self.fillLightIntensity(forDirectional: lightIntensity)
  }

  func updateSunPosition() {
    guard let sunNode else { return }
    let pos = SunPositionMath.sunWorldPosition(
      roomCenter: roomCenter,
      compassAzimuthDeg: azimuthDeg,
      elevationDeg: elevationDeg,
      radius: sunRadius,
      worldEastPlanAngleRad: worldEastPlanAngleRad,
      scanWorldPlusXBearingDeg: scanWorldPlusXBearingDeg,
      northCorrectionDeg: northCorrectionDeg
    )
    sunNode.position = pos
    updateRay(from: pos, to: roomCenter)
  }

  func updateDirectionalLight() {
    guard let lightNode, let sunNode else { return }
    let sunPos = sunNode.position
    lightNode.position = sunPos
    lightNode.look(at: roomCenter, up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))

    if let fillNode = rigNode?.childNode(withName: Self.fillLightNodeName, recursively: false) {
      let fx = roomCenter.x - (sunPos.x - roomCenter.x)
      let fy = max(roomCenter.y + sunRadius * 0.35, sunPos.y * 0.25)
      let fz = roomCenter.z - (sunPos.z - roomCenter.z)
      fillNode.position = SCNVector3(fx, fy, fz)
      fillNode.look(at: roomCenter, up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
    }
  }

  private static func ambientIntensity(forDirectional directional: CGFloat) -> CGFloat {
    520 + directional * 0.22
  }

  private static func fillLightIntensity(forDirectional directional: CGFloat) -> CGFloat {
    260 + directional * 0.12
  }

  func refreshShadowCasters() {
    guard let scene else { return }
    func visit(_ node: SCNNode) {
      let name = node.name ?? ""
      if name == Self.rigName || name == "UydoshFramingCamera" || name.hasPrefix("UydoshFootprintDebug")
        || name == ScanCeilingService.auxRootName
      {
        for child in node.childNodes { visit(child) }
        return
      }
      if node.parent?.name == Self.rigName {
        return
      }
      if node.geometry != nil {
        let lower = name.lowercased()
        let isOpening = lower.contains("window") || lower.contains("opening")
        let isSunPart = lower.contains("sun")
        node.castsShadow = !isOpening && !isSunPart
        if isOpening {
          node.renderingOrder = 10
          node.castsShadow = false
          for mat in node.geometry?.materials ?? [] {
            if mat.transparency > 0.99 {
              mat.transparency = 0.35
            }
            mat.isDoubleSided = true
          }
        }
      }
      for child in node.childNodes { visit(child) }
    }
    visit(scene.rootNode)
  }

  private func buildRayNode(length: Float) -> SCNNode {
    let cylinder = SCNCylinder(radius: 0.004, height: CGFloat(length))
    let mat = SCNMaterial()
    mat.lightingModel = .constant
    mat.emission.contents = UIColor(red: 1, green: 0.95, blue: 0.6, alpha: 0.35)
    mat.diffuse.contents = UIColor(red: 1, green: 0.9, blue: 0.5, alpha: 0.2)
    mat.transparency = 0.35
    cylinder.materials = [mat]
    let node = SCNNode(geometry: cylinder)
    node.pivot = SCNMatrix4MakeTranslation(0, -Float(cylinder.height) * 0.5, 0)
    return node
  }

  private func updateRay(from sunPos: SCNVector3, to center: SCNVector3) {
    guard let ray = rigNode?.childNode(withName: Self.rayNodeName, recursively: false),
      let cylinder = ray.geometry as? SCNCylinder
    else { return }
    let dx = center.x - sunPos.x
    let dy = center.y - sunPos.y
    let dz = center.z - sunPos.z
    let dist = sqrt(dx * dx + dy * dy + dz * dz)
    guard dist > 0.01 else { return }
    cylinder.height = CGFloat(dist)
    ray.pivot = SCNMatrix4MakeTranslation(0, -Float(dist) * 0.5, 0)
    ray.position = sunPos
    ray.look(at: center, up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 1, 0))
  }

  private func notifySunPositionChanged() {
    onSunPositionChanged?(azimuthDeg, elevationDeg)
  }
}
