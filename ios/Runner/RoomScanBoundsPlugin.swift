import Flutter
import SceneKit

/// Computes axis-aligned USDZ bounds (same convention as [RoomUsdzViewerViewController]):
/// horizontal spans → floor long/short, vertical span → height, area = long × short.
final class RoomScanBoundsPlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "uydosh/room_scan_bounds",
      binaryMessenger: registrar.messenger()
    )
    let instance = RoomScanBoundsPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "computeFromUsdPath" else {
      result(FlutterMethodNotImplemented)
      return
    }
    guard
      let args = call.arguments as? [String: Any],
      let path = args["path"] as? String,
      !path.isEmpty
    else {
      result(
        FlutterError(
          code: "bad_args",
          message: "Expected {path: String}",
          details: call.arguments
        )
      )
      return
    }

    DispatchQueue.global(qos: .userInitiated).async {
      let payload = Self.metrics(forUsdPath: path)
      DispatchQueue.main.async {
        result(payload)
      }
    }
  }

  private static func metrics(forUsdPath path: String) -> [String: Double]? {
    guard FileManager.default.fileExists(atPath: path) else { return nil }
    let url = URL(fileURLWithPath: path)
    guard let scene = try? SCNScene(url: url, options: nil) else { return nil }
    guard let bounds = unionWorldBounds(of: scene.rootNode) else { return nil }

    let minB = bounds.min
    let maxB = bounds.max
    let dx = maxB.x - minB.x
    let dy = maxB.y - minB.y
    let dz = maxB.z - minB.z
    guard dx > 1e-6 || dy > 1e-6 || dz > 1e-6 else { return nil }

    let floorLong = Double(max(dx, dz))
    let floorShort = Double(min(dx, dz))
    let height = Double(dy)
    let floorArea = floorLong * floorShort

    return [
      "floor_long_m": floorLong,
      "floor_short_m": floorShort,
      "height_m": height,
      "floor_area_m2": floorArea,
    ]
  }

  /// World-space union of all geometry bounding boxes (root’s own `boundingBox` ignores children).
  private static func unionWorldBounds(of root: SCNNode) -> (min: SCNVector3, max: SCNVector3)? {
    var minV = SCNVector3(
      Float.greatestFiniteMagnitude,
      Float.greatestFiniteMagnitude,
      Float.greatestFiniteMagnitude
    )
    var maxV = SCNVector3(
      -Float.greatestFiniteMagnitude,
      -Float.greatestFiniteMagnitude,
      -Float.greatestFiniteMagnitude
    )
    var any = false

    func visit(_ node: SCNNode) {
      if node.geometry != nil {
        let box = node.boundingBox
        let corners: [SCNVector3] = [
          SCNVector3(box.min.x, box.min.y, box.min.z),
          SCNVector3(box.max.x, box.min.y, box.min.z),
          SCNVector3(box.min.x, box.max.y, box.min.z),
          SCNVector3(box.max.x, box.max.y, box.min.z),
          SCNVector3(box.min.x, box.min.y, box.max.z),
          SCNVector3(box.max.x, box.min.y, box.max.z),
          SCNVector3(box.min.x, box.max.y, box.max.z),
          SCNVector3(box.max.x, box.max.y, box.max.z),
        ]
        for c in corners {
          let w = node.convertPosition(c, to: nil)
          minV.x = Swift.min(minV.x, w.x)
          minV.y = Swift.min(minV.y, w.y)
          minV.z = Swift.min(minV.z, w.z)
          maxV.x = Swift.max(maxV.x, w.x)
          maxV.y = Swift.max(maxV.y, w.y)
          maxV.z = Swift.max(maxV.z, w.z)
          any = true
        }
      }
      for child in node.childNodes {
        visit(child)
      }
    }

    visit(root)
    guard any else { return nil }
    return (minV, maxV)
  }
}
