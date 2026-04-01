import Flutter
import UIKit
import YandexMapsMobile

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // YMKMapKit.setLocale("en_US") // Let it default to system language
    YMKMapKit.setApiKey("b7e30079-55fe-44d0-960c-50a03c3715e6") // Your generated API key
    GeneratedPluginRegistrant.register(with: self)
    let ok = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "uydosh/room_usdz_viewer",
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { call, result in
        if call.method == "presentLocalFile" {
          guard let args = call.arguments as? [String: Any],
            let path = args["path"] as? String,
            let strings = args["strings"] as? [String: String]
          else {
            result(
              FlutterError(
                code: "bad_args",
                message: "Expected map with path and strings",
                details: nil
              )
            )
            return
          }
          RoomUsdzViewerPresenter.present(filePath: path, strings: strings, result: result)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }
    return ok
  }
}
