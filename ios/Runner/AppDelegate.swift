import Flutter
import UIKit
import YandexMapsMobile

@main
@objc class AppDelegate: FlutterAppDelegate {
  /// Scene-based apps (see `Info.plist` → `FlutterSceneDelegate`) own the `UIWindow` on the
  /// `UIWindowScene`, not on the `UIApplicationDelegate`. Plugins (e.g. `flutter_roomplan`) still
  /// reach for `UIApplication.shared.delegate?.window??.rootViewController`, which is `nil` under
  /// scenes and causes their `present(...)` / result callbacks to silently no-op. Exposing the
  /// active scene's key window here keeps those legacy lookups working.
  private var _appDelegateWindow: UIWindow?
  override var window: UIWindow? {
    get {
      if let w = _appDelegateWindow { return w }
      for case let scene as UIWindowScene in UIApplication.shared.connectedScenes {
        if let w = scene.windows.first(where: { $0.isKeyWindow }) ?? scene.windows.first {
          return w
        }
      }
      return nil
    }
    set { _appDelegateWindow = newValue }
  }

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // YMKMapKit.setLocale("en_US") // Let it default to system language
    YMKMapKit.setApiKey("b7e30079-55fe-44d0-960c-50a03c3715e6") // Your generated API key
    let ok = super.application(application, didFinishLaunchingWithOptions: launchOptions)

    // Register plugins + set up custom channels against the main Flutter engine.
    GeneratedPluginRegistrant.register(with: self)

    if let flutterVC = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(
        name: "uydosh/room_usdz_viewer",
        binaryMessenger: flutterVC.binaryMessenger
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
