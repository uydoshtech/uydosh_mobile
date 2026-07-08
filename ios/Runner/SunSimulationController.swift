import SceneKit
import UIKit

/// Manages sun indicator, directional light, optional ray, and shadow casters for the room scene.
final class SunSimulationController {
  static let rigName = "UydoshSunRig"
  static let sunNodeName = "UydoshSunIndicator"
  static let lightNodeName = "UydoshSunLight"
  static let rayNodeName = "UydoshSunRay"
  static let ambientNodeName = "UydoshSunAmbient"
  static let moonNodeName = "UydoshMoonIndicator"
  static let starDomeNodeName = "UydoshStarDome"
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

  /// Cosmetic only — same spherical falloff trick as the sun, but cooled so the pale disc reads as
  /// a 3D moon rather than a flat sticker. Carries no light/shadow of its own.
  private static let moonSurfaceShaderModifier = """
  #pragma body
  vec3 _moonViewDir = normalize(_surface.view);
  vec3 _moonNormal = normalize(_surface.normal);
  float _moonFacing = clamp(dot(_moonViewDir, _moonNormal), 0.0, 1.0);
  float _moonCore = pow(_moonFacing, 0.85);
  vec3 _moonBase = _surface.emission.rgb;
  vec3 _moonEdge = _moonBase * vec3(0.42, 0.48, 0.62);
  vec3 _moonColor = mix(_moonEdge, _moonBase, _moonCore);
  _surface.diffuse.rgb = _moonColor;
  _surface.emission.rgb = _moonColor;
  """

  /// Pale base tint for the cosmetic moon disc.
  private static let moonBaseColor = UIColor(red: 0.86, green: 0.89, blue: 0.96, alpha: 1)

  /// Generated once: a black canvas scattered with faint blue-white dots, used as the sky dome's
  /// emission texture. With additive blending the black contributes nothing, so only the dots show.
  private static let starFieldImage: UIImage = makeStarFieldImage()

  private static func makeStarFieldImage() -> UIImage {
    let size = CGSize(width: 1024, height: 512)
    let format = UIGraphicsImageRendererFormat.default()
    format.opaque = true
    format.scale = 1
    let renderer = UIGraphicsImageRenderer(size: size, format: format)
    return renderer.image { ctx in
      let cg = ctx.cgContext
      cg.setFillColor(UIColor.black.cgColor)
      cg.fill(CGRect(origin: .zero, size: size))
      // Deterministic PRNG so the starfield is stable across launches.
      var seed: UInt64 = 0x9E37_79B9_7F4A_7C15
      func rnd() -> Double {
        seed = seed &* 6_364_136_223_846_793_005 &+ 1_442_695_040_888_963_407
        return Double(seed >> 11) / Double(UInt64(1) << 53)
      }
      let starCount = 420
      for _ in 0..<starCount {
        let x = rnd() * Double(size.width)
        let y = rnd() * Double(size.height)
        let radius = 0.4 + rnd() * 1.1
        let brightness = 0.5 + rnd() * 0.5
        let color = UIColor(
          red: CGFloat(0.80 * brightness),
          green: CGFloat(0.85 * brightness),
          blue: CGFloat(1.00 * brightness),
          alpha: 1
        )
        cg.setFillColor(color.cgColor)
        cg.fillEllipse(in: CGRect(
          x: x - radius, y: y - radius, width: radius * 2, height: radius * 2
        ))
      }
    }
  }

  /// Builds an open sky "dome" — a spherical cap from the top pole down to `cutoffPolarAngle`
  /// (measured from the top pole; > π/2 reaches past the equator) — instead of a full SCNSphere.
  /// Kept centered on the room like the old full sphere (so the camera stays near its middle,
  /// away from any pole, avoiding the texture stretching a full sphere shows near its poles);
  /// the cap is simply cut off before it reaches the floor, so there's no geometry left below it
  /// for stars to render on, without needing shaders or repositioning the whole sphere.
  private static func makeStarDomeGeometry(
    radius: Float,
    cutoffPolarAngle: Float,
    segments: Int = 64,
    rings: Int = 32
  ) -> SCNGeometry {
    var vertices: [SCNVector3] = []
    var normals: [SCNVector3] = []
    var texCoords: [CGPoint] = []

    let ringCount = max(2, rings)
    let segmentCount = max(3, segments)
    let vertsPerRing = segmentCount + 1

    for ring in 0...ringCount {
      let theta = cutoffPolarAngle * Float(ring) / Float(ringCount)
      let y = radius * cos(theta)
      let ringRadius = radius * sin(theta)
      let v = Float(ring) / Float(ringCount)
      for seg in 0...segmentCount {
        let phi = 2 * Float.pi * Float(seg) / Float(segmentCount)
        let x = ringRadius * cos(phi)
        let z = ringRadius * sin(phi)
        vertices.append(SCNVector3(x, y, z))
        normals.append(SCNVector3(x / radius, y / radius, z / radius))
        texCoords.append(CGPoint(x: CGFloat(Float(seg) / Float(segmentCount)), y: CGFloat(v)))
      }
    }

    var indices: [Int32] = []
    for ring in 0..<ringCount {
      for seg in 0..<segmentCount {
        let a = Int32(ring * vertsPerRing + seg)
        let b = Int32(ring * vertsPerRing + seg + 1)
        let c = Int32((ring + 1) * vertsPerRing + seg)
        let d = Int32((ring + 1) * vertsPerRing + seg + 1)
        indices.append(contentsOf: [a, c, b, b, c, d])
      }
    }

    let element = SCNGeometryElement(indices: indices, primitiveType: .triangles)
    return SCNGeometry(
      sources: [
        SCNGeometrySource(vertices: vertices),
        SCNGeometrySource(normals: normals),
        SCNGeometrySource(textureCoordinates: texCoords),
      ],
      elements: [element]
    )
  }

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
  private var moonNode: SCNNode?
  private var starDomeNode: SCNNode?
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

    // Cosmetic night moon: a pale disc that rides roughly opposite the sun and fades in once the
    // sun is below the horizon. It carries no light or shadow — purely to fill the night sky.
    let moon = SCNNode()
    moon.name = Self.moonNodeName
    let moonSphere = SCNSphere(radius: max(0.07, CGFloat(sunRadius) * 0.030))
    moonSphere.segmentCount = 48
    let moonMat = SCNMaterial()
    moonMat.lightingModel = .constant
    moonMat.emission.contents = Self.moonBaseColor
    moonMat.diffuse.contents = Self.moonBaseColor
    moonMat.shaderModifiers = [.surface: Self.moonSurfaceShaderModifier]
    moonSphere.materials = [moonMat]
    moon.geometry = moonSphere
    moon.castsShadow = false
    moon.opacity = 0
    rig.addChildNode(moon)
    moonNode = moon

    // Cosmetic starfield: a large inverted sky dome centered on the room, same as the sun/moon
    // rig. Renders first, ignores depth, and uses additive blending so its black body is
    // invisible and only the star texture's dots brighten the sky (room geometry, drawn after,
    // occludes it from most angles). Rather than a full sphere — half of which would sit below
    // the floor, showing stars "underground" whenever the camera looks past the room's edges — the
    // dome geometry itself is cut off right at floor height, so there's simply nothing left below
    // it to ever render. `emission.intensity` ramps the stars from invisible by day to visible at
    // night (see updateDirectionalLight).
    let dome = SCNNode()
    dome.name = Self.starDomeNodeName
    let domeRadius = sunRadius * 1.3
    // Floor height in the dome's local space (it's centered on roomCenter), nudged up a touch so
    // the cutoff sits comfortably above the true floor rather than exactly on it.
    let floorMargin = max(0.3, domeRadius * 0.01)
    let floorLocalY = min(domeRadius * 0.98, sceneBounds.min.y - roomCenter.y + floorMargin)
    let domeCutoffPolarAngle = acos(max(-1, min(1, floorLocalY / domeRadius)))
    let domeGeometry = Self.makeStarDomeGeometry(radius: domeRadius, cutoffPolarAngle: domeCutoffPolarAngle)
    let domeMat = SCNMaterial()
    domeMat.lightingModel = .constant
    domeMat.diffuse.contents = UIColor.black
    domeMat.emission.contents = Self.starFieldImage
    domeMat.emission.intensity = 0
    domeMat.isDoubleSided = true
    domeMat.writesToDepthBuffer = false
    domeMat.readsFromDepthBuffer = false
    domeMat.blendMode = .add
    domeGeometry.materials = [domeMat]
    dome.geometry = domeGeometry
    dome.castsShadow = false
    dome.renderingOrder = -100
    dome.position = roomCenter
    rig.addChildNode(dome)
    starDomeNode = dome

    let lightHolder = SCNNode()
    lightHolder.name = Self.lightNodeName
    let directional = SCNLight()
    directional.type = .directional
    directional.color = UIColor(red: 1, green: 0.96, blue: 0.88, alpha: 1)
    directional.intensity = lightIntensity
    directional.castsShadow = true
    directional.shadowMode = .deferred
    directional.shadowSampleCount = 16
    directional.shadowRadius = 10
    directional.shadowColor = Self.baseShadowColor.withAlphaComponent(Self.maxShadowOpacity)
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
    moonNode = nil
    starDomeNode = nil
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
      // The shadow pass ignores light intensity, so a clamped-to-horizon dusk sun would keep
      // painting hard, grazing shadow slabs with no light to justify them. Fade the shadow out
      // (and stop casting entirely) as the sun nears/drops below the horizon.
      let shadowStrength = Self.shadowStrength(forElevation: el)
      direct.castsShadow = shadowStrength > 0.01
      direct.shadowColor = Self.baseShadowColor
        .withAlphaComponent(Self.maxShadowOpacity * shadowStrength)
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

    // Night-only cosmetics: ride the moon opposite the sun and ramp the starfield in after sunset.
    let nightF = Self.nightFactor(forElevation: el)
    if let moonNode {
      moonNode.position = SunPositionMath.sunWorldPosition(
        roomCenter: roomCenter,
        compassAzimuthDeg: azimuthDeg + 180,
        elevationDeg: max(0, -el),
        radius: sunRadius,
        worldEastPlanAngleRad: worldEastPlanAngleRad,
        scanWorldPlusXBearingDeg: scanWorldPlusXBearingDeg,
        northCorrectionDeg: northCorrectionDeg
      )
      moonNode.opacity = CGFloat(nightF)
    }
    starDomeNode?.geometry?.firstMaterial?.emission.intensity = CGFloat(nightF) * 0.9
  }

  /// Warm base tint for cast shadows. Kept warm (not cold blue) so shaded brick/wood still reads
  /// as the same material; its alpha is scaled by `maxShadowOpacity` and faded at dusk/night.
  private static let baseShadowColor = UIColor(red: 0.20, green: 0.16, blue: 0.13, alpha: 1)

  /// Cap on cast-shadow opacity so shadows darken surfaces without painting over the underlying
  /// texture — the floor tiles and wall brick stay visible in shade instead of flattening out.
  private static let maxShadowOpacity: CGFloat = 0.5

  /// Shadow opacity by sun elevation: full when the sun is comfortably up, fading to none as it
  /// nears the horizon (where real shadows lengthen and wash out) and off once it's below.
  private static func shadowStrength(forElevation el: Float) -> CGFloat {
    switch el {
    case ..<3: return 0
    case ..<15: return CGFloat((el - 3) / 12)
    default: return 1
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

  /// Orb base color: warm yellow-gold high in the sky → deep orange/red near and below the horizon.
  private static func orbColor(forElevation el: Float) -> UIColor {
    let low = UIColor(red: 1.00, green: 0.50, blue: 0.26, alpha: 1)
    let warm = UIColor(red: 1.00, green: 0.82, blue: 0.45, alpha: 1)
    let high = UIColor(red: 1.00, green: 0.88, blue: 0.50, alpha: 1)
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

  /// Night "darkness" weight driving the cosmetic moon + stars: 0 while the sun is up, ramping in as
  /// it sinks below the horizon and reaching full once it's ~8° down (well into twilight).
  private static func nightFactor(forElevation el: Float) -> Float {
    switch el {
    case ..<(-8): return 1
    case ..<0: return -el / 8
    default: return 0
    }
  }

  /// Simulates an (invisible) roof without geometry: full direct sun at low/glancing angles where a
  /// real roof lets light stream through windows, fading toward the zenith where the roof would
  /// block it. Only the direct beam is scaled — ambient/fill keep the interior readable.
  private static func roofedSunScale(forElevation el: Float) -> CGFloat {
    // Fakes a roof for this scan's ~70° noon peak: full direct sun while it's low enough to come
    // through windows (< 35°), fading as it climbs, mostly blocked once it's overhead (> 60°).
    // Only the direct beam is scaled — ambient/fill keep the interior readable, never black.
    switch el {
    case ..<35: return 1.0
    case ..<60: return CGFloat(1.0 - (el - 35) / 25) * 0.82 + 0.18
    default: return 0.18
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
        let isOpening = lower.contains("opening")
        // Only windows let the sun stream through. Doors and open doorways are treated as
        // permanently closed: they still read as see-through, but block sunlight.
        let isWindow = lower.contains("window")
        let isSunPart = lower.contains("sun")
        let blocksLight = isDoor || isOpening
        node.castsShadow = !isWindow && !blocksLight && !isSunPart
        if isWindow || blocksLight {
          // See-through look so the user can still see into the room through the opening.
          node.renderingOrder = 10
          for mat in node.geometry?.materials ?? [] {
            if mat.transparency > 0.99 {
              mat.transparency = 0.35
            }
            mat.isDoubleSided = true
          }
        }
        if blocksLight {
          // The translucent material is skipped by the shadow pass, so back doors and doorways
          // with an invisible opaque proxy that occludes the sun without occluding the view.
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
