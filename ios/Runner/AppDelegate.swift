import Flutter
import UIKit
import QuickLook
import YandexMapsMobile

/// Presents a local USDZ via Quick Look using the key window’s top VC (fixes `keyWindow == nil` on modern iOS).
private final class UsdzQuickLookPresenter: NSObject, QLPreviewControllerDataSource {
  private var fileURL: URL?
  private var previewController: QLPreviewController?

  func present(filePath: String, result: @escaping FlutterResult) {
    guard FileManager.default.fileExists(atPath: filePath) else {
      result(FlutterError(code: "missing_file", message: "USDZ not found", details: filePath))
      return
    }
    fileURL = URL(fileURLWithPath: filePath)
    let ql = QLPreviewController()
    ql.dataSource = self
    guard let host = Self.topViewController() else {
      result(FlutterError(code: "no_vc", message: "Cannot present Quick Look (no host VC)", details: nil))
      return
    }
    previewController = ql
    host.present(ql, animated: true) {
      result(true)
    }
  }

  func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
    return fileURL != nil ? 1 : 0
  }

  func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
    fileURL! as QLPreviewItem
  }

  private static func topViewController() -> UIViewController? {
    for scene in UIApplication.shared.connectedScenes {
      guard let windowScene = scene as? UIWindowScene else { continue }
      let windows = windowScene.windows
      let root = windows.first(where: { $0.isKeyWindow })?.rootViewController
        ?? windows.first?.rootViewController
      if let root = root {
        return findTop(from: root)
      }
    }
    return nil
  }

  private static func findTop(from vc: UIViewController) -> UIViewController {
    if let presented = vc.presentedViewController {
      return findTop(from: presented)
    }
    if let nav = vc as? UINavigationController, let visible = nav.visibleViewController {
      return findTop(from: visible)
    }
    if let tab = vc as? UITabBarController, let selected = tab.selectedViewController {
      return findTop(from: selected)
    }
    return vc
  }
}

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var usdzQuickLookPresenter: UsdzQuickLookPresenter?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // YMKMapKit.setLocale("en_US") // Let it default to system language
    YMKMapKit.setApiKey("b7e30079-55fe-44d0-960c-50a03c3715e6") // Your generated API key
    GeneratedPluginRegistrant.register(with: self)
    let ok = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    if let controller = window?.rootViewController as? FlutterViewController {
      usdzQuickLookPresenter = UsdzQuickLookPresenter()
      let channel = FlutterMethodChannel(
        name: "uydosh/usdz_quick_look",
        binaryMessenger: controller.binaryMessenger
      )
      channel.setMethodCallHandler { [weak self] call, result in
        guard let presenter = self?.usdzQuickLookPresenter else {
          result(FlutterError(code: "no_presenter", message: nil, details: nil))
          return
        }
        if call.method == "presentLocalFile" {
          guard let path = call.arguments as? String else {
            result(FlutterError(code: "bad_args", message: "Expected file path", details: nil))
            return
          }
          presenter.present(filePath: path, result: result)
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }
    return ok
  }
}
