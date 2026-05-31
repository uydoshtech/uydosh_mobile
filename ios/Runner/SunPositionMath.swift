import Foundation
import SceneKit
import UIKit

/// Sky backdrop for the 3D room viewer — follows sun azimuth/elevation (day–night cycle).
enum RoomSceneAppearance {
  /// Default midday sky (used before sun rig attaches).
  static let skyBackgroundColor = skyBackgroundColor(azimuthDeg: 180, elevationDeg: 70)

  static func skyBackgroundColor(azimuthDeg: Float, elevationDeg: Float) -> UIColor {
    // Allow negative elevation (sun below horizon) so deep night renders dark.
    let el = min(90, elevationDeg)

    // --- Cool base sky, driven by elevation (deep night → daytime blue → zenith). ---
    let deepNight = rgb(0.03, 0.04, 0.09)
    let night = rgb(0.06, 0.08, 0.17)
    let blueHour = rgb(0.14, 0.17, 0.34)
    let horizon = rgb(0.42, 0.50, 0.66)
    let dayLow = rgb(0.52, 0.70, 0.92)
    let midday = rgb(0.46, 0.71, 0.95)
    let zenith = rgb(0.30, 0.56, 0.86)

    let base: UIColor
    switch el {
    case ..<(-12):
      base = deepNight
    case ..<(-6):
      base = lerpColor(deepNight, night, t: (el + 12) / 6)
    case ..<(-1):
      base = lerpColor(night, blueHour, t: (el + 6) / 5)
    case ..<6:
      base = lerpColor(blueHour, horizon, t: (el + 1) / 7)
    case ..<16:
      base = lerpColor(horizon, dayLow, t: (el - 6) / 10)
    case ..<45:
      base = lerpColor(dayLow, midday, t: (el - 16) / 29)
    default:
      base = lerpColor(midday, zenith, t: min(1, (el - 45) / 30))
    }

    // --- Twilight tints layered on the base, strongest near the horizon. ---
    // Two overlapping bands give a natural progression as the sun crosses the horizon:
    //   gold (sun just above)  →  pink/violet afterglow (sun just below).
    let az = normalizedAzimuth(azimuthDeg)
    let goldWeight = gaussian(el, center: 2, sigma: 7)
    let glowWeight = gaussian(el, center: -5, sigma: 5)

    var sky = base

    if goldWeight > 0.02 {
      let east = gaussian(az, center: 90, sigma: 52)
      let west = gaussian(az, center: 270, sigma: 52)
      let morningGold = rgb(0.99, 0.72, 0.45)
      let eveningGold = rgb(0.96, 0.50, 0.32)
      let gold = lerpColor(morningGold, eveningGold, t: west / max(east + west, 0.001))
      sky = lerpColor(sky, gold, t: goldWeight * 0.62)
    }

    if glowWeight > 0.02 {
      let east = gaussian(az, center: 90, sigma: 60)
      let west = gaussian(az, center: 270, sigma: 60)
      let dawnGlow = rgb(0.42, 0.38, 0.62)
      let duskGlow = rgb(0.55, 0.33, 0.49)
      let glow = lerpColor(dawnGlow, duskGlow, t: west / max(east + west, 0.001))
      sky = lerpColor(sky, glow, t: glowWeight * 0.5)
    }

    return sky
  }

  private static func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
    UIColor(red: r, green: g, blue: b, alpha: 1)
  }

  private static func normalizedAzimuth(_ degrees: Float) -> Float {
    var value = degrees.truncatingRemainder(dividingBy: 360)
    if value < 0 { value += 360 }
    return value
  }

  /// Bell curve peaking when azimuth is near `center` (degrees).
  private static func gaussian(_ azimuth: Float, center: Float, sigma: Float) -> Float {
    let delta = min(abs(azimuth - center), 360 - abs(azimuth - center))
    let x = delta / max(sigma, 1)
    return exp(-0.5 * x * x)
  }

  private static func lerpColor(_ a: UIColor, _ b: UIColor, t: Float) -> UIColor {
    let clamped = min(1, max(0, t))
    var ar: CGFloat = 0
    var ag: CGFloat = 0
    var ab: CGFloat = 0
    var aa: CGFloat = 0
    var br: CGFloat = 0
    var bg: CGFloat = 0
    var bb: CGFloat = 0
    var ba: CGFloat = 0
    a.getRed(&ar, green: &ag, blue: &ab, alpha: &aa)
    b.getRed(&br, green: &bg, blue: &bb, alpha: &ba)
    let u = CGFloat(clamped)
    return UIColor(
      red: ar + (br - ar) * u,
      green: ag + (bg - ag) * u,
      blue: ab + (bb - ab) * u,
      alpha: aa + (ba - aa) * u
    )
  }
}

/// Converts compass sun angles to SceneKit world offsets (Y-up, plan: X → X, −Z → Y).
enum SunPositionMath {
  enum TimePreset: CaseIterable {
    case morning
    case noon
    case evening

    var azimuthDeg: Float {
      switch self {
      case .morning: return 90
      case .noon: return 180
      case .evening: return 270
      }
    }

    var elevationDeg: Float {
      switch self {
      case .morning: return 25
      case .noon: return 70
      case .evening: return 20
      }
    }
  }

  /// Horizontal offset in world X/Z for a compass azimuth (0° = north, 90° = east).
  static func horizontalWorldOffset(
    compassAzimuthDeg: Float,
    elevationDeg: Float,
    radius: Float,
    worldEastPlanAngleRad: Double,
    scanWorldPlusXBearingDeg: Double?,
    northCorrectionDeg: Double
  ) -> SCNVector3 {
    let azRad = Double(compassAzimuthDeg) * .pi / 180
    let elRad = Double(elevationDeg) * .pi / 180
    let horiz = Double(radius) * cos(elRad)
    let geoEast = sin(azRad)
    let geoNorth = cos(azRad)

    let northPlanAngle: Double
    if let scanBearing = scanWorldPlusXBearingDeg {
      let effective = FloorPlanNorthOrientation.effectiveWorldPlusXBearingDeg(
        scanBearing: scanBearing,
        correctionDeg: northCorrectionDeg
      )
      northPlanAngle = worldEastPlanAngleRad - effective * .pi / 180
    } else {
      northPlanAngle = worldEastPlanAngleRad + .pi / 2
        + northCorrectionDeg * .pi / 180
    }
    // Geographic east is 90° clockwise from north. In plan-angle space (CCW-positive,
    // since worldXZ maps φ → plan direction (cos φ, sin φ)), clockwise means subtracting.
    // Using +π/2 here mirrors east↔west, which placed the sunrise in the west.
    let eastPlanAngle = northPlanAngle - .pi / 2

    let (ex, ez) = worldXZ(fromPlanAngle: eastPlanAngle)
    let (nx, nz) = worldXZ(fromPlanAngle: northPlanAngle)
    let ox = Float(horiz * (geoEast * Double(ex) + geoNorth * Double(nx)))
    let oz = Float(horiz * (geoEast * Double(ez) + geoNorth * Double(nz)))
    let oy = Float(Double(radius) * sin(elRad))
    return SCNVector3(ox, oy, oz)
  }

  static func sunWorldPosition(
    roomCenter: SCNVector3,
    compassAzimuthDeg: Float,
    elevationDeg: Float,
    radius: Float,
    worldEastPlanAngleRad: Double,
    scanWorldPlusXBearingDeg: Double?,
    northCorrectionDeg: Double
  ) -> SCNVector3 {
    let offset = horizontalWorldOffset(
      compassAzimuthDeg: compassAzimuthDeg,
      elevationDeg: elevationDeg,
      radius: radius,
      worldEastPlanAngleRad: worldEastPlanAngleRad,
      scanWorldPlusXBearingDeg: scanWorldPlusXBearingDeg,
      northCorrectionDeg: northCorrectionDeg
    )
    return SCNVector3(
      roomCenter.x + offset.x,
      roomCenter.y + offset.y,
      roomCenter.z + offset.z
    )
  }

  /// Plan angle φ → world (X, Z) unit vector (matches [FloorPlanProjectionService]).
  private static func worldXZ(fromPlanAngle planAngle: Double) -> (Float, Float) {
    (Float(cos(planAngle)), Float(-sin(planAngle)))
  }
}
