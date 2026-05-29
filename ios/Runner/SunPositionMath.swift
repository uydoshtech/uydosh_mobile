import Foundation
import SceneKit
import UIKit

/// Sky backdrop for the 3D room viewer — follows sun azimuth/elevation (day–night cycle).
enum RoomSceneAppearance {
  /// Default midday sky (used before sun rig attaches).
  static let skyBackgroundColor = skyBackgroundColor(azimuthDeg: 180, elevationDeg: 70)

  static func skyBackgroundColor(azimuthDeg: Float, elevationDeg: Float) -> UIColor {
    let el = min(90, max(0, elevationDeg))

    // Elevation-driven base sky (0° = horizon/night, 90° = zenith blue).
    let night = rgb(0.07, 0.09, 0.16)
    let twilight = rgb(0.22, 0.28, 0.42)
    let dawn = rgb(0.52, 0.68, 0.88)
    let midday = rgb(0.48, 0.72, 0.94)
    let zenith = rgb(0.34, 0.58, 0.84)

    let base: UIColor
    switch el {
    case ..<6:
      base = lerpColor(night, twilight, t: el / 6)
    case 6..<18:
      base = lerpColor(twilight, dawn, t: (el - 6) / 12)
    case 18..<45:
      base = lerpColor(dawn, midday, t: (el - 18) / 27)
    case 45..<72:
      base = lerpColor(midday, zenith, t: (el - 45) / 27)
    default:
      base = zenith
    }

    // Golden-hour warmth when the sun is low; morning (E) vs evening (W) tint.
    let warmWeight = max(0, (32 - el) / 32)
    guard warmWeight > 0.02 else { return base }

    let az = normalizedAzimuth(azimuthDeg)
    let morningWarmth = gaussian(az, center: 90, sigma: 38)
    let eveningWarmth = gaussian(az, center: 270, sigma: 38)
    let morningTint = rgb(0.96, 0.62, 0.38)
    let eveningTint = rgb(0.88, 0.42, 0.34)
    let warmTint = lerpColor(morningTint, eveningTint, t: eveningWarmth / max(morningWarmth + eveningWarmth, 0.001))
    return lerpColor(base, warmTint, t: warmWeight * 0.58)
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
    let eastPlanAngle = northPlanAngle + .pi / 2

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
