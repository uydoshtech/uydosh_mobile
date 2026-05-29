import ARKit
import CoreLocation
import Foundation

/// Captures the geographic bearing of AR world +X at RoomPlan scan time.
enum RoomScanOrientationCapture {
  struct Snapshot: Equatable {
    let worldPlusXTrueBearingDeg: Double
  }

  private static let sidecarSuffix = ".orientation.json"

  /// Geographic bearing (degrees clockwise from true north) of AR world +X on the X/Z plane.
  static func worldPlusXTrueBearingDegrees(
    from frame: ARFrame,
    trueHeadingDegrees: Double
  ) -> Double {
    let transform = frame.camera.transform
    let deviceUpXZ = simd_normalize(
      SIMD2<Double>(Double(transform.columns.1.x), Double(transform.columns.1.z))
    )
    let worldPlusX = SIMD2<Double>(1, 0)
    let cross = deviceUpXZ.x * worldPlusX.y - deviceUpXZ.y * worldPlusX.x
    let dot = simd_dot(deviceUpXZ, worldPlusX)
    let ccwFromUpToWorldXRad = atan2(cross, dot)
    var bearing = trueHeadingDegrees + ccwFromUpToWorldXRad * 180.0 / .pi
    bearing = bearing.truncatingRemainder(dividingBy: 360)
    if bearing < 0 { bearing += 360 }
    return bearing
  }

  static func snapshot(
    from arSession: ARSession,
    trueHeadingDegrees: Double
  ) -> Snapshot? {
    guard trueHeadingDegrees >= 0,
      let frame = arSession.currentFrame
    else { return nil }
    let bearing = worldPlusXTrueBearingDegrees(
      from: frame,
      trueHeadingDegrees: trueHeadingDegrees
    )
    guard bearing.isFinite else { return nil }
    return Snapshot(worldPlusXTrueBearingDeg: bearing)
  }

  static func sidecarPath(forUsdzPath usdzPath: String) -> String {
    usdzPath + sidecarSuffix
  }

  static func writeSidecar(_ snapshot: Snapshot, forUsdzPath usdzPath: String) {
    let path = sidecarPath(forUsdzPath: usdzPath)
    let payload: [String: Any] = [
      "world_plus_x_bearing_deg": snapshot.worldPlusXTrueBearingDeg,
    ]
    guard JSONSerialization.isValidJSONObject(payload),
      let data = try? JSONSerialization.data(withJSONObject: payload, options: [])
    else { return }
    try? data.write(to: URL(fileURLWithPath: path), options: .atomic)
  }

  static func readSidecar(forUsdzPath usdzPath: String) -> Double? {
    let path = sidecarPath(forUsdzPath: usdzPath)
    guard let data = try? Data(contentsOf: URL(fileURLWithPath: path)),
      let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
      let bearing = json["world_plus_x_bearing_deg"] as? Double,
      bearing.isFinite, bearing >= 0, bearing < 360
    else { return nil }
    return bearing
  }
}

/// Lightweight heading reader for RoomPlan capture (best-effort true north).
final class RoomScanHeadingReader: NSObject, CLLocationManagerDelegate {
  private let manager = CLLocationManager()
  private(set) var trueHeadingDegrees: Double?

  override init() {
    super.init()
    manager.delegate = self
    manager.headingFilter = 1
  }

  func start() {
    manager.requestWhenInUseAuthorization()
    if CLLocationManager.headingAvailable() {
      manager.startUpdatingHeading()
    }
  }

  func stop() {
    manager.stopUpdatingHeading()
  }

  func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
    let value = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
    guard value >= 0 else { return }
    trueHeadingDegrees = value
  }
}
