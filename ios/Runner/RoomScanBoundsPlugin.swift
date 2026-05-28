import Flutter
import SceneKit

/// Computes USDZ room metrics from floor polygon footprint (same convention as [RoomUsdzViewerViewController]).
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
      let payload = RoomScanMetricsComputer.metrics(forUsdPath: path)
      DispatchQueue.main.async {
        result(payload)
      }
    }
  }
}
