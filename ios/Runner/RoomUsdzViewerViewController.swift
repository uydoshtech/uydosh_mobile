import Flutter
import SceneKit
import UIKit

/// Strings resolved in Flutter ([AppStrings] by language) and passed through the method channel.
struct RoomViewerStrings {
  let title: String
  let dimensionsCaption: String
  let dimensionsLineTemplate: String
  let gestureHint: String
  let loadErrorTitle: String
  let alertOk: String

  init(
    title: String,
    dimensionsCaption: String,
    dimensionsLineTemplate: String,
    gestureHint: String,
    loadErrorTitle: String,
    alertOk: String
  ) {
    self.title = title
    self.dimensionsCaption = dimensionsCaption
    self.dimensionsLineTemplate = dimensionsLineTemplate
    self.gestureHint = gestureHint
    self.loadErrorTitle = loadErrorTitle
    self.alertOk = alertOk
  }

  init?(dict: [String: String]) {
    guard let title = dict["title"],
      let dimensionsCaption = dict["dimensionsCaption"],
      let dimensionsLineTemplate = dict["dimensionsLineTemplate"],
      let gestureHint = dict["gestureHint"],
      let loadErrorTitle = dict["loadErrorTitle"],
      let alertOk = dict["alertOk"]
    else { return nil }
    self.init(
      title: title,
      dimensionsCaption: dimensionsCaption,
      dimensionsLineTemplate: dimensionsLineTemplate,
      gestureHint: gestureHint,
      loadErrorTitle: loadErrorTitle,
      alertOk: alertOk
    )
  }

  static let englishFallback = RoomViewerStrings(
    title: "3D",
    dimensionsCaption: "Approximate dimensions (full scan bounds)",
    dimensionsLineTemplate: "{floorLong} × {floorShort} m floor · {height} m high",
    gestureHint:
      "Drag with one finger to look around the model.\n"
      + "Pinch with two fingers to zoom in or out.",
    loadErrorTitle: "Could not load 3D model",
    alertOk: "OK"
  )
}

/// Full-screen 3D viewer for a local USDZ (object-only, no Quick Look AR/Object toggle).
final class RoomUsdzViewerViewController: UIViewController {
  private let fileURL: URL
  private let strings: RoomViewerStrings
  private let sceneView = SCNView()
  private let hintContainer = UIView()
  private let hintStack = UIStackView()
  private let dimensionsTitleLabel = UILabel()
  private let dimensionsValueLabel = UILabel()
  private let hintLabel = UILabel()
  private var loadedScene: SCNScene?

  init(fileURL: URL, strings: RoomViewerStrings) {
    self.fileURL = fileURL
    self.strings = strings
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black
    title = strings.title

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

    hintContainer.translatesAutoresizingMaskIntoConstraints = false
    hintContainer.backgroundColor = UIColor.black.withAlphaComponent(0.52)
    hintContainer.layer.cornerRadius = 12
    if #available(iOS 13.0, *) {
      hintContainer.layer.cornerCurve = .continuous
    }
    hintContainer.clipsToBounds = true

    dimensionsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
    dimensionsTitleLabel.textAlignment = .center
    dimensionsTitleLabel.numberOfLines = 0
    dimensionsTitleLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
    dimensionsTitleLabel.adjustsFontForContentSizeCategory = true
    dimensionsTitleLabel.textColor = UIColor.white.withAlphaComponent(0.68)
    dimensionsTitleLabel.text = strings.dimensionsCaption
    dimensionsTitleLabel.isHidden = true

    dimensionsValueLabel.translatesAutoresizingMaskIntoConstraints = false
    dimensionsValueLabel.textAlignment = .center
    dimensionsValueLabel.numberOfLines = 0
    dimensionsValueLabel.adjustsFontForContentSizeCategory = true
    dimensionsValueLabel.textColor = UIColor.white.withAlphaComponent(0.98)
    let subHead = UIFont.preferredFont(forTextStyle: .subheadline)
    if let boldDesc = subHead.fontDescriptor.withSymbolicTraits(.traitBold) {
      dimensionsValueLabel.font = UIFont(descriptor: boldDesc, size: 0)
    } else {
      dimensionsValueLabel.font = subHead
    }
    dimensionsValueLabel.isHidden = true

    hintLabel.translatesAutoresizingMaskIntoConstraints = false
    hintLabel.numberOfLines = 0
    hintLabel.textAlignment = .center
    hintLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
    hintLabel.adjustsFontForContentSizeCategory = true
    hintLabel.textColor = UIColor.white.withAlphaComponent(0.95)
    hintLabel.text = strings.gestureHint

    hintStack.translatesAutoresizingMaskIntoConstraints = false
    hintStack.axis = .vertical
    hintStack.alignment = .fill
    hintStack.spacing = 4
    hintStack.addArrangedSubview(dimensionsTitleLabel)
    hintStack.addArrangedSubview(dimensionsValueLabel)
    hintStack.setCustomSpacing(12, after: dimensionsValueLabel)
    hintStack.addArrangedSubview(hintLabel)

    hintContainer.addSubview(hintStack)
    view.addSubview(hintContainer)

    NSLayoutConstraint.activate([
      sceneView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      sceneView.bottomAnchor.constraint(equalTo: hintContainer.topAnchor, constant: -12),

      hintStack.topAnchor.constraint(equalTo: hintContainer.topAnchor, constant: 10),
      hintStack.leadingAnchor.constraint(equalTo: hintContainer.leadingAnchor, constant: 14),
      hintStack.trailingAnchor.constraint(equalTo: hintContainer.trailingAnchor, constant: -14),
      hintStack.bottomAnchor.constraint(equalTo: hintContainer.bottomAnchor, constant: -10),

      hintContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      hintContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      hintContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
    ])

    loadScene()
  }

  /// World-space union of all geometry bounding boxes (root’s own `boundingBox` ignores children).
  private func unionWorldBounds(of root: SCNNode) -> (min: SCNVector3, max: SCNVector3)? {
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

  /// RoomPlan / SceneKit: meters, Y-up. Uses horizontal spans (X, Z) as floor footprint and Y as height.
  private func updateDimensionsDisplay(dx: Float, dy: Float, dz: Float) {
    let floorLong = max(dx, dz)
    let floorShort = min(dx, dz)
    let height = dy
    func fmt(_ v: Float) -> String {
      String(format: "%.1f", v)
    }
    var line = strings.dimensionsLineTemplate
    line = line.replacingOccurrences(of: "{floorLong}", with: fmt(floorLong))
    line = line.replacingOccurrences(of: "{floorShort}", with: fmt(floorShort))
    line = line.replacingOccurrences(of: "{height}", with: fmt(height))
    dimensionsValueLabel.text = line
    dimensionsTitleLabel.isHidden = false
    dimensionsValueLabel.isHidden = false
  }

  /// Places the camera so the whole model fits the viewport (avoids default “inside the mesh” zoom).
  private func frameCamera(for scene: SCNScene, in view: SCNView) {
    guard let bounds = unionWorldBounds(of: scene.rootNode) else { return }

    let minB = bounds.min
    let maxB = bounds.max
    let dx = maxB.x - minB.x
    let dy = maxB.y - minB.y
    let dz = maxB.z - minB.z
    guard dx > 1e-6 || dy > 1e-6 || dz > 1e-6 else { return }

    updateDimensionsDisplay(dx: dx, dy: dy, dz: dz)

    let centerWorld = SCNVector3(
      (minB.x + maxB.x) * 0.5,
      (minB.y + maxB.y) * 0.5,
      (minB.z + maxB.z) * 0.5
    )

    // Half diagonal of the axis-aligned box; enclosing sphere radius for a conservative fit.
    let halfDiagonal =
      0.5 * sqrt(dx * dx + dy * dy + dz * dz)
    guard halfDiagonal > 1e-4 else { return }

    let cameraNode = SCNNode()
    cameraNode.name = "UydoshFramingCamera"
    let cam = SCNCamera()
    cameraNode.camera = cam

    let vfovDegrees: CGFloat = 60
    cam.fieldOfView = vfovDegrees
    let vfov = vfovDegrees * .pi / 180
    // Portrait phones are tall: horizontal FOV is narrower than vertical. Framing using only
    // vertical FOV leaves the model cropped on the sides (still “too close” for room scans).
    let w = max(view.bounds.width, 1)
    let h = max(view.bounds.height, 1)
    let aspect = w / h
    let tanHalfV = tan(vfov / 2)
    let tanHalfH = aspect * tanHalfV
    let tanHalfLimit = min(tanHalfV, tanHalfH)
    let padding: CGFloat = 1.38
    let distance = CGFloat(halfDiagonal) / tanHalfLimit * padding

    // Slightly elevated “corner” view reads well for room scans.
    let vx: Float = 0.55
    let vy: Float = 0.38
    let vz: Float = 0.75
    let len = sqrt(vx * vx + vy * vy + vz * vz)
    let ox = vx / len * Float(distance)
    let oy = vy / len * Float(distance)
    let oz = vz / len * Float(distance)

    let worldCam = SCNVector3(
      centerWorld.x + ox,
      centerWorld.y + oy,
      centerWorld.z + oz
    )

    cam.zNear = Double(max(0.001, CGFloat(halfDiagonal) * 0.0005))
    cam.zFar = Double(max(100, CGFloat(halfDiagonal) * 50))

    let root = scene.rootNode
    cameraNode.position = root.convertPosition(worldCam, from: nil)
    cameraNode.look(at: centerWorld, up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))

    root.addChildNode(cameraNode)
    view.pointOfView = cameraNode

    view.defaultCameraController.target = centerWorld
  }

  private func loadScene() {
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      guard let self = self else { return }
      do {
        let scene = try SCNScene(url: self.fileURL, options: nil)
        DispatchQueue.main.async {
          self.loadedScene = scene
          self.sceneView.scene = scene
          self.frameCamera(for: scene, in: self.sceneView)
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
      title: strings.loadErrorTitle,
      message: error.localizedDescription,
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: strings.alertOk, style: .default) { [weak self] _ in
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
  static func present(filePath: String, strings: [String: String], result: @escaping FlutterResult) {
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

    let resolved = RoomViewerStrings(dict: strings) ?? RoomViewerStrings.englishFallback
    let viewer = RoomUsdzViewerViewController(fileURL: url, strings: resolved)
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
