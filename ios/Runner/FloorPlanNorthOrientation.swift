import Foundation

/// Computes floor-plan compass angles from scan bearing + manual correction.
enum FloorPlanNorthOrientation {
  static func effectiveWorldPlusXBearingDeg(scanBearing: Double, correctionDeg: Double) -> Double {
    var bearing = scanBearing + correctionDeg
    bearing = bearing.truncatingRemainder(dividingBy: 360)
    if bearing < 0 { bearing += 360 }
    return bearing
  }

  static func trueNorthPlanAngleRad(
    worldEastPlanAngleRad: Double,
    scanBearing: Double?,
    correctionDeg: Double
  ) -> Double {
    let basePlanNorth: Double
    if let scanBearing {
      let effective = effectiveWorldPlusXBearingDeg(
        scanBearing: scanBearing,
        correctionDeg: correctionDeg
      )
      basePlanNorth = worldEastPlanAngleRad - effective * Double.pi / 180
    } else {
      // No compass at scan time: world −Z is the scan "forward" direction on the plan.
      basePlanNorth = worldEastPlanAngleRad + Double.pi / 2
        + correctionDeg * Double.pi / 180
    }
    return basePlanNorth
  }

  static func applyTrueNorth(
    to model: inout EditableFloorPlanModel,
    correctionDeg: Double
  ) {
    model.northCorrectionDeg = correctionDeg
    model.trueNorthPlanAngleRad = trueNorthPlanAngleRad(
      worldEastPlanAngleRad: model.worldEastPlanAngleRad,
      scanBearing: model.scanWorldPlusXBearingDeg,
      correctionDeg: correctionDeg
    )
  }
}
