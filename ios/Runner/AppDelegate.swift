import Flutter
import UIKit
import YandexMapsMobile

/// Registers the `uydosh/room_usdz_viewer` method channel.
/// Kept in this file to ensure it is compiled into the Runner target.
final class RoomUsdzViewerPlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "uydosh/room_usdz_viewer",
      binaryMessenger: registrar.messenger()
    )
    let instance = RoomUsdzViewerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "presentLocalFile" else {
      result(FlutterMethodNotImplemented)
      return
    }
    guard
      let args = call.arguments as? [String: Any],
      let path = args["path"] as? String,
      let strings = args["strings"] as? [String: String]
    else {
      result(
        FlutterError(
          code: "bad_args",
          message: "Expected {path: String, strings: Map<String,String>}",
          details: call.arguments
        )
      )
      return
    }
    DispatchQueue.main.async {
      RoomUsdzViewerPresenter.present(filePath: path, strings: strings, result: result)
    }
  }
}

/// Registers the `uydosh/native_language` method channel to allow Flutter to
/// sync the in-app selected language to iOS native UI (e.g. RoomPlan).
final class NativeLanguagePlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "uydosh/native_language",
      binaryMessenger: registrar.messenger()
    )
    let instance = NativeLanguagePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "setPreferredLanguage" else {
      result(FlutterMethodNotImplemented)
      return
    }
    guard
      let args = call.arguments as? [String: Any],
      let code = args["languageCode"] as? String,
      !code.isEmpty
    else {
      result(
        FlutterError(
          code: "bad_args",
          message: "Expected {languageCode: String}",
          details: call.arguments
        )
      )
      return
    }

    // Setting AppleLanguages is best-effort. Many native controllers read the
    // preferred language at presentation time.
    UserDefaults.standard.set([code], forKey: "AppleLanguages")
    UserDefaults.standard.set(code, forKey: "AppleLocale")
    UserDefaults.standard.synchronize()
    result(true)
  }
}

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // YMKMapKit.setLocale("en_US") // Let it default to system language
    YMKMapKit.setApiKey("b7e30079-55fe-44d0-960c-50a03c3715e6") // Your generated API key
    GeneratedPluginRegistrant.register(with: self)

    // Register the native USDZ viewer as a real plugin (scene-safe).
    if let registrar = self.registrar(forPlugin: "RoomUsdzViewerPlugin") {
      RoomUsdzViewerPlugin.register(with: registrar)
    }

    // Register native language sync for native UI.
    if let registrar = self.registrar(forPlugin: "NativeLanguagePlugin") {
      NativeLanguagePlugin.register(with: registrar)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
