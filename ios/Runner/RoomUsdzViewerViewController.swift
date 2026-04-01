import Flutter
import SceneKit
import UIKit

/// Full-screen 3D viewer for a local USDZ (object-only, no Quick Look AR/Object toggle).
final class RoomUsdzViewerViewController: UIViewController {
  private let fileURL: URL
  private let sceneView = SCNView()
  private var loadedScene: SCNScene?

  init(fileURL: URL) {
    self.fileURL = fileURL
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black
    title = "3D"

    navigationItem.leftBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .close,
      target: self,
      action: #selector(closeTapped)
    )

    sceneView.translatesAutoresizingMaskIntoConstraints = false
    sceneView.backgroundColor = .black
    sceneView.allowsCameraControl = true
    sceneView.antialiasingMode = .multisampling4X
    sceneView.autoenablesDefaultLighting = true
    view.addSubview(sceneView)

    NSLayoutConstraint.activate([
      sceneView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])

    loadScene()
  }

  private func loadScene() {
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      guard let self = self else { return }
      do {
        let scene = try SCNScene(url: self.fileURL, options: nil)
        DispatchQueue.main.async {
          self.loadedScene = scene
          self.sceneView.scene = scene
        }
      } catch {
        DispatchQueue.main.async {
          self.presentLoadError(error)
        }
      }
    }
  }

  private func presentLoadError(_ error: Error) {
    let alert = UIAlertController(
      title: "Could not load 3D model",
      message: error.localizedDescription,
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
      self?.dismissViewer()
    })
    present(alert, animated: true)
  }

  @objc private func closeTapped() {
    dismissViewer()
  }

  private func dismissViewer() {
    sceneView.scene = nil
    loadedScene = nil
    dismiss(animated: true)
  }

  deinit {
    sceneView.scene = nil
  }
}

enum RoomUsdzViewerPresenter {
  static func present(filePath: String, result: @escaping FlutterResult) {
    guard FileManager.default.fileExists(atPath: filePath) else {
      result(
        FlutterError(
          code: "missing_file",
          message: "USDZ not found",
          details: filePath
        )
      )
      return
    }
    let url = URL(fileURLWithPath: filePath)
    guard let host = topViewController() else {
      result(
        FlutterError(
          code: "no_vc",
          message: "Cannot present 3D viewer",
          details: nil
        )
      )
      return
    }

    let viewer = RoomUsdzViewerViewController(fileURL: url)
    let nav = UINavigationController(rootViewController: viewer)
    nav.modalPresentationStyle = .fullScreen
    nav.navigationBar.prefersLargeTitles = false

    host.present(nav, animated: true) {
      result(true)
    }
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
