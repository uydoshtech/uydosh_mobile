import Flutter
import UIKit
import YandexMapsMobile

/// Maps an in-app language code to the iOS `AppleLanguages` preference list.
///
/// Apple's RoomPlan / ARKit frameworks ship a fixed set of localizations
/// (English, Russian, and other majors — but not Uzbek). When `AppleLanguages`
/// is set to a single locale that the framework doesn't translate, iOS falls
/// back to the development region (English) instead of the next-best language
/// the user actually understands. We therefore expand the chosen language into
/// a fallback chain so e.g. an Uzbek user still sees Russian coaching strings
/// inside the native scan UI rather than English.
func uydoshAppleLanguagesList(for code: String) -> [String] {
  switch code {
  case "uz": return ["uz", "ru", "en"]
  case "ru": return ["ru", "en"]
  default: return [code]
  }
}

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

/// Registers the `uydosh/room_usdz_viewer` method channel.
/// Kept in this file to ensure it is compiled into the Runner target.
final class RoomUsdzViewerPlugin: NSObject, FlutterPlugin {
  /// Retained for invoking Flutter from the native viewer (room-scan metrics backfill).
  fileprivate static var binaryMessenger: FlutterBinaryMessenger?

  static func register(with registrar: FlutterPluginRegistrar) {
    Self.binaryMessenger = registrar.messenger()
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
    let listingId = (args["listingId"] as? NSNumber)?.intValue ?? 0
    let publishMetricsIfMissing: Bool = {
      if let b = args["publishMetricsIfMissing"] as? Bool { return b }
      if let n = args["publishMetricsIfMissing"] as? NSNumber { return n.boolValue }
      return false
    }()
    let worldPlusXTrueBearingDeg: Double? = {
      if let d = args["worldPlusXBearingDeg"] as? Double { return d }
      if let n = args["worldPlusXBearingDeg"] as? NSNumber { return n.doubleValue }
      return nil
    }()
    let northCorrectionDeg: Double = {
      if let d = args["northCorrectionDeg"] as? Double { return d }
      if let n = args["northCorrectionDeg"] as? NSNumber { return n.doubleValue }
      return 0
    }()
    let isListingOwner: Bool = {
      if let b = args["isListingOwner"] as? Bool { return b }
      if let n = args["isListingOwner"] as? NSNumber { return n.boolValue }
      return false
    }()
    DispatchQueue.main.async {
      RoomUsdzViewerPresenter.present(
        filePath: path,
        strings: strings,
        messenger: Self.binaryMessenger,
        listingId: listingId,
        publishMetricsIfMissing: publishMetricsIfMissing,
        worldPlusXTrueBearingDeg: worldPlusXTrueBearingDeg,
        northCorrectionDeg: northCorrectionDeg,
        isListingOwner: isListingOwner,
        result: result
      )
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

    // Always persisted for the next app launch: the launch-time read in
    // `application(_:didFinishLaunchingWithOptions:)` is the only *guaranteed*
    // way this reaches RoomPlan/ARKit, since those frameworks may have already
    // resolved and cached their own bundle's localized strings earlier in this
    // process. We still set it live (with an explicit `synchronize()` flush to
    // `cfprefsd`) on the chance that a framework bundle hasn't been touched yet
    // this session — e.g. the very first RoomPlan scan — in which case its next
    // localized-string lookup can pick up the new value immediately.
    UserDefaults.standard.set(uydoshAppleLanguagesList(for: code), forKey: "AppleLanguages")
    UserDefaults.standard.set(code, forKey: "AppleLocale")
    UserDefaults.standard.synchronize()
    result(true)
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
    // Apply the in-app language to `AppleLanguages` BEFORE any framework
    // bundle resolution happens (i.e. before Flutter / RoomPlan / ARKit load).
    // shared_preferences on iOS stores Dart keys in NSUserDefaults under the
    // "flutter." prefix, so we read the same value Dart wrote in
    // `LanguageState.setLanguage` / `initialize`. Without this, RoomPlan's
    // coaching overlay (e.g. "More light required", "Move device to start")
    // shows in whatever language was cached at process start rather than the
    // currently-selected in-app language.
    let defaults = UserDefaults.standard
    var persistedLang: String?
    if let persisted = defaults.string(forKey: "flutter.selected_language"), !persisted.isEmpty {
      persistedLang = persisted
      defaults.set(uydoshAppleLanguagesList(for: persisted), forKey: "AppleLanguages")
      defaults.set(persisted, forKey: "AppleLocale")
    }

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

    // Register the native USDZ viewer as a real plugin (scene-safe).
    if let registrar = self.registrar(forPlugin: "RoomUsdzViewerPlugin") {
      RoomUsdzViewerPlugin.register(with: registrar)
    }

    // Register native language sync for native UI.
    if let registrar = self.registrar(forPlugin: "NativeLanguagePlugin") {
      NativeLanguagePlugin.register(with: registrar)
    }

    if let registrar = self.registrar(forPlugin: "MapKitLocalePlugin") {
      MapKitLocalePlugin.register(with: registrar)
    }

    if let registrar = self.registrar(forPlugin: "RoomScanBoundsPlugin") {
      RoomScanBoundsPlugin.register(with: registrar)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
