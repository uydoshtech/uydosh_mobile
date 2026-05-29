import Foundation
import SceneKit
import UIKit

/// Sky backdrop for the 3D room viewer (replaces flat black).
enum RoomSceneAppearance {
  static let skyBackgroundColor = UIColor(red: 0.48, green: 0.72, blue: 0.94, alpha: 1)
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
