import Flutter
import UIKit
import YandexMapsMobile
import room_scan_kit

/// Maps an in-app language code (`en`, `ru`, `uz`) to a Yandex MapKit locale tag.
func uydoshYandexMapKitLocaleTag(for code: String) -> String {
  switch code.lowercased() {
  case "ru": return "ru_RU"
  case "uz": return "uz_UZ"
  case "en": return "en_US"
  default:
    return Locale.current.identifier.replacingOccurrences(of: "-", with: "_")
  }
}

/// Syncs Yandex MapKit locale with the in-app language (via Flutter MethodChannel).
final class MapKitLocalePlugin: NSObject, FlutterPlugin {
  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "uydosh/mapkit_locale",
      binaryMessenger: registrar.messenger()
    )
    let instance = MapKitLocalePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard call.method == "setLocale" else {
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

    // Yandex MapKit on iOS allows [YMKMapKit.setLocale] only once per process,
    // strictly before any map/sharedR instance use ("Locale is already set!" otherwise).
    // We already set locale synchronously in AppDelegate.didFinishLaunchingWithOptions
    // from [flutter.selected_language] / device preference — matching Flutter startup order.
    // In-app language changes cannot remap MapKit labels until the next cold start.
#if DEBUG
    NSLog("[MapKitLocalePlugin] ignored setLocale after launch (requested: \(code))")
#endif
    result(true)
  }
}

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Two-way language sync BEFORE any framework bundle resolution happens
    // (i.e. before Flutter / RoomPlan / ARKit load):
    // - applies the in-app language to `AppleLanguages` so RoomPlan's coaching
    //   overlay (e.g. "More light required") follows the in-app language, and
    // - adopts the iOS per-app language (Settings › Apps › UyDosh › Language)
    //   into `flutter.selected_language` when the user changed it there.
    // shared_preferences on iOS stores Dart keys in NSUserDefaults under the
    // "flutter." prefix, so the helper reads/writes the same value Dart uses
    // in `LanguageState.setLanguage` / `initialize`.
    let persistedLang = RoomScanKitAppleLanguages.syncAtLaunch()

    let mapLangCode =
      persistedLang
      ?? Locale.preferredLanguages.first.flatMap { lang -> String? in
        lang.split(separator: "-").first.map(String.init)
      }
      ?? "en"

    YMKMapKit.setLocale(uydoshYandexMapKitLocaleTag(for: mapLangCode))
    YMKMapKit.setApiKey("b7e30079-55fe-44d0-960c-50a03c3715e6") // Your generated API key

    // Do not call `FirebaseApp.configure()` here. FlutterFire configures Firebase
    // from Dart (`Firebase.initializeApp` → `AppCheckBootstrap.activate`). An early
    // native configure starts Analytics/Messaging/etc. before Dart selects the App Check
    // debug provider; `firebase_app_check`'s plugin init also replaces any native
    // `AppCheckDebugProviderFactory` with its own factory that defaults to DeviceCheck
    // until Dart activates — producing `exchangeDeviceCheckToken` 403 + Auth placeholder
    // tokens during Sign in with Apple.

    GeneratedPluginRegistrant.register(with: self)

    if let registrar = self.registrar(forPlugin: "MapKitLocalePlugin") {
      MapKitLocalePlugin.register(with: registrar)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
