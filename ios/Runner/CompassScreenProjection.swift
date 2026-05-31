import SceneKit
import UIKit

/// Projects geographic north from the scan into screen space for the 3D compass rose.
enum CompassScreenProjection {
  /// Angle (radians) on screen from the room center toward true north; UIKit coords, for `SunCompassOverlayView`.
  static func northScreenAngleRad(
    sceneView: SCNView,
    roomCenter: SCNVector3,
    trueNorthPlanAngleRad: Double
  ) -> CGFloat? {
    // `projectPoint` asserts ("scene failed. Null argument") if the view has no scene, which can
    // happen if this is called mid/after teardown. Bail out instead of crashing the main thread.
    guard sceneView.scene != nil else { return nil }

    let nx = Float(cos(trueNorthPlanAngleRad))
    let nz = Float(-sin(trueNorthPlanAngleRad))
    let probeDistance: Float = max(0.5, roomCenter.y * 0.1 + 0.5)

    let centerScreen = sceneView.projectPoint(roomCenter)
    let northScreen = sceneView.projectPoint(
      SCNVector3(
        roomCenter.x + nx * probeDistance,
        roomCenter.y,
        roomCenter.z + nz * probeDistance
      )
    )

    guard centerScreen.z.isFinite, northScreen.z.isFinite,
      centerScreen.z < 1, northScreen.z < 1
    else { return nil }

    let dx = northScreen.x - centerScreen.x
    let dy = northScreen.y - centerScreen.y
    guard hypot(dx, dy) > 0.5 else { return nil }
    return CGFloat(atan2(dy, dx))
  }
}
