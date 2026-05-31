import SceneKit
import UIKit

/// Manages sun indicator, directional light, optional ray, and shadow casters for the room scene.
final class SunSimulationController {
  static let rigName = "UydoshSunRig"
  static let sunNodeName = "UydoshSunIndicator"
  static let lightNodeName = "UydoshSunLight"
  static let rayNodeName = "UydoshSunRay"
  static let ambientNodeName = "UydoshSunAmbient"
  /// Invisible opaque cap attached to a door so it blocks sunlight while staying see-through.
  static let lightBlockerProxyName = "UydoshLightBlockerProxy"

  /// Surface shader modifier that fakes spherical shading on the constant-lit sun: it takes the
  /// per-frame base tint (the material's emission, recolored by elevation) and brightens the
  /// camera-facing core while warming/darkening the silhouette — so the flat disk reads as a
  /// glowing 3D orb whose hue still follows the time of day.
  private static let sunSurfaceShaderModifier = """
  #pragma body
  vec3 _sunViewDir = normalize(_surface.view);
  vec3 _sunNormal = normalize(_surface.normal);
  float _sunFacing = clamp(dot(_sunViewDir, _sunNormal), 0.0, 1.0);
  float _sunCore = pow(_sunFacing, 0.55);
  vec3 _sunBase = _surface.emission.rgb;
  vec3 _sunEdge = _sunBase * vec3(0.95, 0.72, 0.45);
  vec3 _sunColor = mix(_sunEdge, _sunBase, _sunCore);
  _surface.diffuse.rgb = _sunColor;
  _surface.emission.rgb = _sunColor;
  """
  static let fillLightNodeName = "UydoshSunFill"

  private(set) var isEnabled = false
  private(set) var azimuthDeg: Float = SunPositionMath.TimePreset.noon.azimuthDeg
  private(set) var elevationDeg: Float = SunPositionMath.TimePreset.noon.elevationDeg
  private(set) var lightIntensity: CGFloat = 1400
  /// Elevation used only to drive light color/brightness mood. May dip below 0° at twilight
  /// (so the model cools/dims) even though the light's geometric elevation is clamped to 0.
  private var tintElevationDeg: Float = SunPositionMath.TimePreset.noon.elevationDeg

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
    sphere.segmentCount = 48
    let mat = SCNMaterial()
    mat.lightingModel = .constant
    mat.emission.contents = UIColor(red: 1, green: 0.92, blue: 0.55, alpha: 1)
    mat.diffuse.contents = UIColor(red: 1, green: 0.85, blue: 0.35, alpha: 1)
    // Constant shading renders a uniform disk; this radial falloff (bright core → warm rim,
    // based on the view/normal angle) makes the sphere read as a glowing 3D orb.
    mat.shaderModifiers = [.surface: Self.sunSurfaceShaderModifier]
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
    tintElevationDeg = elevationDeg
    updateSunPosition()
    updateDirectionalLight()
    notifySunPositionChanged()
  }

  func setSunElevation(degrees: Float) {
    elevationDeg = min(90, max(0, degrees))
    tintElevationDeg = elevationDeg
    updateSunPosition()
    updateDirectionalLight()
    notifySunPositionChanged()
  }

  func applyPreset(_ preset: SunPositionMath.TimePreset) {
    setSunAzimuth(degrees: preset.azimuthDeg)
    setSunElevation(degrees: preset.elevationDeg)
  }

  /// Sets azimuth + elevation in a single pass (one position/light update instead of two).
  /// Used by the per-frame day-cycle sweep; the caller drives sky/compass itself.
  /// `trueElevationDeg` (may be < 0) drives the light's warm/cool mood; the geometric
  /// elevation stays clamped to the horizon so the sun never sinks through the floor.
  func setSunAngles(azimuthDeg azim: Float, elevationDeg elev: Float, trueElevationDeg: Float? = nil) {
    var a = azim.truncatingRemainder(dividingBy: 360)
    if a < 0 { a += 360 }
    azimuthDeg = a
    elevationDeg = min(90, max(0, elev))
    tintElevationDeg = trueElevationDeg ?? elevationDeg
    updateSunPosition()
    updateDirectionalLight()
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

    let el = tintElevationDeg
    let scale = Self.intensityScale(forElevation: el)
    // Fake a roof: a roofed room gets little DIRECT sun on the floor when the sun is overhead, but
    // plenty of low/glancing light through windows. So fade the direct beam as the sun climbs.
    let roofScale = Self.roofedSunScale(forElevation: el)
    if let direct = lightNode.light {
      direct.color = Self.directionalColor(forElevation: el)
      direct.intensity = lightIntensity * scale * roofScale
    }

    // Orb tint follows the time of day; fade it out as it sinks below the horizon.
    if let mat = sunNode.geometry?.firstMaterial {
      let orb = Self.orbColor(forElevation: el)
      mat.emission.contents = orb
      mat.diffuse.contents = orb
    }
    sunNode.opacity = CGFloat(Self.orbOpacity(forElevation: el))

    if let ambient = rigNode?.childNode(withName: Self.ambientNodeName, recursively: false)?.light {
      ambient.color = Self.ambientColor(forElevation: el)
      // Never let the room go fully black at night — keep a cool ambient floor.
      ambient.intensity = Self.ambientIntensity(forDirectional: lightIntensity) * max(0.5, scale)
    }

    if let fillNode = rigNode?.childNode(withName: Self.fillLightNodeName, recursively: false) {
      let fx = roomCenter.x - (sunPos.x - roomCenter.x)
      let fy = max(roomCenter.y + sunRadius * 0.35, sunPos.y * 0.25)
      let fz = roomCenter.z - (sunPos.z - roomCenter.z)
      fillNode.position = SCNVector3(fx, fy, fz)
      fillNode.look(at: roomCenter, up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
      if let fillLight = fillNode.light {
        fillLight.color = Self.ambientColor(forElevation: el)
        fillLight.intensity = Self.fillLightIntensity(forDirectional: lightIntensity) * max(0.4, scale)
      }
    }
  }

  private static func ambientIntensity(forDirectional directional: CGFloat) -> CGFloat {
    520 + directional * 0.22
  }

  private static func fillLightIntensity(forDirectional directional: CGFloat) -> CGFloat {
    260 + directional * 0.12
  }

  /// Direct sunlight color: warm orange near the horizon (golden hour) → neutral white when high.
  private static func directionalColor(forElevation el: Float) -> UIColor {
    let golden = UIColor(red: 1.00, green: 0.64, blue: 0.38, alpha: 1)
    let warm = UIColor(red: 1.00, green: 0.84, blue: 0.62, alpha: 1)
    let day = UIColor(red: 1.00, green: 0.97, blue: 0.90, alpha: 1)
    switch el {
    case ..<2: return golden
    case ..<10: return lerp(golden, warm, (el - 2) / 8)
    case ..<32: return lerp(warm, day, (el - 10) / 22)
    default: return day
    }
  }

  /// Ambient/fill color: cool blue at twilight → warm near the horizon → cool-white daylight.
  private static func ambientColor(forElevation el: Float) -> UIColor {
    let night = UIColor(red: 0.40, green: 0.50, blue: 0.78, alpha: 1)
    let warm = UIColor(red: 0.97, green: 0.87, blue: 0.78, alpha: 1)
    let day = UIColor(red: 0.88, green: 0.91, blue: 0.96, alpha: 1)
    switch el {
    case ..<(-2): return night
    case ..<6: return lerp(night, warm, (el + 2) / 8)
    case ..<22: return lerp(warm, day, (el - 6) / 16)
    default: return day
    }
  }

  /// Orb base color: pale white-gold high in the sky → deep orange/red near and below the horizon.
  private static func orbColor(forElevation el: Float) -> UIColor {
    let low = UIColor(red: 1.00, green: 0.50, blue: 0.26, alpha: 1)
    let warm = UIColor(red: 1.00, green: 0.82, blue: 0.45, alpha: 1)
    let high = UIColor(red: 1.00, green: 0.97, blue: 0.82, alpha: 1)
    switch el {
    case ..<2: return low
    case ..<10: return lerp(low, warm, (el - 2) / 8)
    case ..<30: return lerp(warm, high, (el - 10) / 20)
    default: return high
    }
  }

  /// Fade the orb out as it drops below the horizon — no glowing sun hovering at night.
  private static func orbOpacity(forElevation el: Float) -> Float {
    switch el {
    case ..<(-4): return 0
    case ..<2: return (el + 4) / 6
    default: return 1
    }
  }

  /// Simulates an (invisible) roof without geometry: full direct sun at low/glancing angles where a
  /// real roof lets light stream through windows, fading toward the zenith where the roof would
  /// block it. Only the direct beam is scaled — ambient/fill keep the interior readable.
  private static func roofedSunScale(forElevation el: Float) -> CGFloat {
    switch el {
    case ..<30: return 1.0
    case ..<65: return CGFloat(1.0 - (el - 30) / 35) * 0.7 + 0.3
    default: return 0.3
    }
  }

  /// Brightness falloff so dusk/night dims out: full sun above ~8°, fading to dark below the horizon.
  private static func intensityScale(forElevation el: Float) -> CGFloat {
    switch el {
    case ..<(-6): return 0
    case ..<0: return CGFloat((el + 6) / 6) * 0.35
    case ..<8: return 0.35 + CGFloat(el / 8) * 0.65
    default: return 1
    }
  }

  private static func lerp(_ a: UIColor, _ b: UIColor, _ t: Float) -> UIColor {
    let u = CGFloat(min(1, max(0, t)))
    var ar: CGFloat = 0, ag: CGFloat = 0, ab: CGFloat = 0, aa: CGFloat = 0
    var br: CGFloat = 0, bg: CGFloat = 0, bb: CGFloat = 0, ba: CGFloat = 0
    a.getRed(&ar, green: &ag, blue: &ab, alpha: &aa)
    b.getRed(&br, green: &bg, blue: &bb, alpha: &ba)
    return UIColor(
      red: ar + (br - ar) * u,
      green: ag + (bg - ag) * u,
      blue: ab + (bb - ab) * u,
      alpha: aa + (ba - aa) * u
    )
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
      // Already-attached door light blockers are configured once; don't reprocess them.
      if name == Self.lightBlockerProxyName {
        return
      }
      if node.geometry != nil {
        let lower = name.lowercased()
        let isDoor = lower.contains("door")
        // Only true openings/windows let the sun stream through.
        let isLightOpening = lower.contains("window") || lower.contains("opening")
        let isSunPart = lower.contains("sun")
        // Doors are part of the wall: they block light like solid geometry.
        node.castsShadow = !isLightOpening && !isDoor && !isSunPart
        if isLightOpening || isDoor {
          // Doors get the same translucent "opening" look so they read as see-through.
          node.renderingOrder = 10
          for mat in node.geometry?.materials ?? [] {
            if mat.transparency > 0.99 {
              mat.transparency = 0.35
            }
            mat.isDoubleSided = true
          }
        }
        if isDoor {
          // The translucent door material is skipped by the shadow pass, so back it with an
          // invisible opaque proxy that occludes the sun without occluding the user's view.
          ensureLightBlockerProxy(for: node)
        }
      }
      for child in node.childNodes { visit(child) }
    }
    visit(scene.rootNode)
  }

  /// Attaches (once) an invisible, opaque-to-the-shadow-pass duplicate of the door geometry so the
  /// door blocks sunlight while its visible material stays translucent. Coincident with the door,
  /// so it occludes the sun from the same footprint.
  private func ensureLightBlockerProxy(for node: SCNNode) {
    if node.childNode(withName: Self.lightBlockerProxyName, recursively: false) != nil { return }
    guard let proxyGeometry = node.geometry?.copy() as? SCNGeometry else { return }
    proxyGeometry.materials = [ScanCeilingService.invisibleShadowMaterial()]
    let proxy = SCNNode(geometry: proxyGeometry)
    proxy.name = Self.lightBlockerProxyName
    proxy.castsShadow = true
    node.addChildNode(proxy)
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
