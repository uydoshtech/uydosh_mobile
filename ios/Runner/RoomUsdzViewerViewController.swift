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
  let floorOnlyButtonTitle: String
  let fullRoomButtonTitle: String
  let floorOnlyUnavailableMessage: String
  /// RGB hex `RRGGBB` from [AppColors.floorObject3dTint] (Material brown).
  let onFloorObjectTint: UIColor

  init(
    title: String,
    dimensionsCaption: String,
    dimensionsLineTemplate: String,
    gestureHint: String,
    loadErrorTitle: String,
    alertOk: String,
    floorOnlyButtonTitle: String,
    fullRoomButtonTitle: String,
    floorOnlyUnavailableMessage: String,
    onFloorObjectTint: UIColor
  ) {
    self.title = title
    self.dimensionsCaption = dimensionsCaption
    self.dimensionsLineTemplate = dimensionsLineTemplate
    self.gestureHint = gestureHint
    self.loadErrorTitle = loadErrorTitle
    self.alertOk = alertOk
    self.floorOnlyButtonTitle = floorOnlyButtonTitle
    self.fullRoomButtonTitle = fullRoomButtonTitle
    self.floorOnlyUnavailableMessage = floorOnlyUnavailableMessage
    self.onFloorObjectTint = onFloorObjectTint
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
      alertOk: alertOk,
      floorOnlyButtonTitle: dict["floorOnlyButton"] ?? "Hide walls",
      fullRoomButtonTitle: dict["fullRoomButton"] ?? "Full room",
      floorOnlyUnavailableMessage: dict["floorOnlyUnavailable"]
        ?? "No wall meshes were found by name in this file.",
      onFloorObjectTint: Self.uiColorFromRgbHex6(dict["onFloorTintRgb"] ?? "795548")
    )
  }

  /// `RRGGBB` (e.g. Material brown `795548`).
  private static func uiColorFromRgbHex6(_ hex: String) -> UIColor {
    var h = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    if h.hasPrefix("#") { h.removeFirst() }
    guard h.count == 6, let v = UInt32(h, radix: 16) else {
      return UIColor(red: 121 / 255, green: 85 / 255, blue: 72 / 255, alpha: 1)
    }
    let r = CGFloat((v >> 16) & 0xFF) / 255
    let g = CGFloat((v >> 8) & 0xFF) / 255
    let b = CGFloat(v & 0xFF) / 255
    return UIColor(red: r, green: g, blue: b, alpha: 1)
  }

  static let englishFallback = RoomViewerStrings(
    title: "3D",
    dimensionsCaption: "Approximate dimensions (full scan bounds)",
    dimensionsLineTemplate: "{floorLong} × {floorShort} m floor · {height} m high",
    gestureHint:
      "Drag with one finger to look around the model.\n"
      + "Pinch with two fingers to zoom in or out.",
    loadErrorTitle: "Could not load 3D model",
    alertOk: "OK",
    floorOnlyButtonTitle: "Hide walls",
    fullRoomButtonTitle: "Full room",
    floorOnlyUnavailableMessage:
      "No wall meshes were found by name in this file.",
    onFloorObjectTint: Self.uiColorFromRgbHex6("795548")
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
  /// App mark (blue tile, U, red roof) over the 3D viewport — same artwork as the app icon.
  private let brandMarkView = UIImageView()
  private var loadedScene: SCNScene?
  /// When true, architectural shells (walls/ceiling/openings) are hidden; floor and furniture stay.
  private var wallsHidden = false
  private var floorModeBarButton: UIBarButtonItem?
  private var sceneWorldBounds: (min: SCNVector3, max: SCNVector3)?
  private var didCacheOriginalMaterials = false
  private var originalMaterialsByGeometry = [ObjectIdentifier: [SCNMaterial]]()

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
    let wallBtn = UIBarButtonItem(
      title: strings.floorOnlyButtonTitle,
      style: .plain,
      target: self,
      action: #selector(toggleWallsHiddenMode)
    )
    floorModeBarButton = wallBtn
    navigationItem.rightBarButtonItem = wallBtn

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

    brandMarkView.translatesAutoresizingMaskIntoConstraints = false
    brandMarkView.image = UIImage(named: "UydoshBrandMark")
    brandMarkView.isHidden = brandMarkView.image == nil
    brandMarkView.contentMode = .scaleAspectFit
    brandMarkView.accessibilityIgnoresInvertColors = true
    brandMarkView.isAccessibilityElement = true
    brandMarkView.accessibilityLabel = "UiDosha"
    brandMarkView.layer.shadowColor = UIColor.black.cgColor
    brandMarkView.layer.shadowOpacity = 0.4
    brandMarkView.layer.shadowOffset = CGSize(width: 0, height: 1)
    brandMarkView.layer.shadowRadius = 5
    brandMarkView.layer.masksToBounds = false
    view.addSubview(brandMarkView)

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

      brandMarkView.leadingAnchor.constraint(equalTo: sceneView.leadingAnchor, constant: 12),
      brandMarkView.topAnchor.constraint(equalTo: sceneView.topAnchor, constant: 10),
      brandMarkView.widthAnchor.constraint(equalToConstant: 52),
      brandMarkView.heightAnchor.constraint(equalToConstant: 52),
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

  private func worldBounds(of node: SCNNode) -> (min: SCNVector3, max: SCNVector3)? {
    guard node.geometry != nil else { return nil }
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
    for c in corners {
      let w = node.convertPosition(c, to: nil)
      minV.x = Swift.min(minV.x, w.x)
      minV.y = Swift.min(minV.y, w.y)
      minV.z = Swift.min(minV.z, w.z)
      maxV.x = Swift.max(maxV.x, w.x)
      maxV.y = Swift.max(maxV.y, w.y)
      maxV.z = Swift.max(maxV.z, w.z)
    }
    return (minV, maxV)
  }

  private func isLikelyFloorSlab(
    _ b: (min: SCNVector3, max: SCNVector3),
    sceneBounds: (min: SCNVector3, max: SCNVector3)
  ) -> Bool {
    let dx = b.max.x - b.min.x
    let dy = b.max.y - b.min.y
    let dz = b.max.z - b.min.z
    let foot = max(dx, dz)
    guard foot > 0.06 else { return false }
    guard dy < max(0.05, 0.12 * foot) else { return false }
    let sceneH = max(sceneBounds.max.y - sceneBounds.min.y, 0.12)
    return b.min.y <= sceneBounds.min.y + 0.14 * sceneH + 0.04
  }

  private func isLikelyVerticalWallSlab(
    _ b: (min: SCNVector3, max: SCNVector3),
    sceneHeight: Float
  ) -> Bool {
    let dx = b.max.x - b.min.x
    let dy = b.max.y - b.min.y
    let dz = b.max.z - b.min.z
    let hMax = max(dx, dz)
    let hMin = min(dx, dz)
    guard dy > 0.18 else { return false }
    guard dy > 0.28 * max(hMax, 0.08) else { return false }
    guard hMin < 0.26 * hMax else { return false }
    return dy > 0.22 * max(sceneHeight, 0.2)
  }

  /// Anything that sits on the floor plane: not the floor mesh itself, not walls/doors/ceiling by name or shape.
  private func isOnFloorObject(_ node: SCNNode, sceneBounds: (min: SCNVector3, max: SCNVector3)) -> Bool {
    if node.name == "UydoshFramingCamera" { return false }
    if shouldHideWallLikeSurface(node) { return false }
    let name = (node.name ?? "").lowercased()
    if name.contains("ceiling") { return false }
    if name.contains("floor") || name.contains("ground") { return false }
    guard let b = worldBounds(of: node) else { return false }
    let sceneMinY = sceneBounds.min.y
    let sceneH = max(sceneBounds.max.y - sceneBounds.min.y, 0.12)
    if isLikelyFloorSlab(b, sceneBounds: sceneBounds) { return false }
    if isLikelyVerticalWallSlab(b, sceneHeight: sceneH) { return false }
    let bottomY = b.min.y
    guard bottomY >= sceneMinY - 0.08, bottomY <= sceneMinY + 0.22 * sceneH + 0.06 else { return false }
    let dy = b.max.y - b.min.y
    guard dy > 0.025 else { return false }
    return true
  }

  private func cacheOriginalMaterialsIfNeeded() {
    guard !didCacheOriginalMaterials, let root = loadedScene?.rootNode else { return }
    func visit(_ node: SCNNode) {
      if let geo = node.geometry {
        let id = ObjectIdentifier(geo)
        if originalMaterialsByGeometry[id] == nil {
          originalMaterialsByGeometry[id] = geo.materials.map { mat in
            mat.copy() as! SCNMaterial
          }
        }
      }
      for child in node.childNodes {
        visit(child)
      }
    }
    visit(root)
    didCacheOriginalMaterials = true
  }

  /// Tints meshes that sit on the floor using app brown ([AppColors.floorObject3dTint]).
  private func applyOnFloorObjectTint() {
    guard let root = loadedScene?.rootNode, let sceneBounds = sceneWorldBounds else { return }
    cacheOriginalMaterialsIfNeeded()
    let tint = strings.onFloorObjectTint
    SCNTransaction.begin()
    SCNTransaction.animationDuration = 0
    func visit(_ node: SCNNode) {
      guard let geo = node.geometry else {
        for c in node.childNodes { visit(c) }
        return
      }
      let id = ObjectIdentifier(geo)
      guard let originals = originalMaterialsByGeometry[id] else {
        for c in node.childNodes { visit(c) }
        return
      }
      if isOnFloorObject(node, sceneBounds: sceneBounds) {
        geo.materials = originals.map { orig in
          let m = orig.copy() as! SCNMaterial
          m.diffuse.contents = tint
          return m
        }
      } else {
        geo.materials = originals.map { $0.copy() as! SCNMaterial }
      }
      for c in node.childNodes {
        visit(c)
      }
    }
    visit(root)
    SCNTransaction.commit()
  }

  /// Uses mesh node names from RoomPlan-style USDZ. Furniture stays visible unless its name matches these.
  private func shouldHideWallLikeSurface(_ node: SCNNode) -> Bool {
    if node.name == "UydoshFramingCamera" { return false }
    let name = (node.name ?? "").lowercased()
    if name.contains("floor") || name.contains("ground") { return false }
    if name.contains("wall") || name.contains("ceiling") { return true }
    if name.contains("door") || name.contains("window") || name.contains("opening") { return true }
    return false
  }

  private func setAllGeometryVisible(_ visible: Bool) {
    guard let root = loadedScene?.rootNode else { return }
    SCNTransaction.begin()
    SCNTransaction.animationDuration = 0
    func visit(_ node: SCNNode) {
      if node.geometry != nil {
        node.isHidden = !visible
      }
      for child in node.childNodes {
        visit(child)
      }
    }
    visit(root)
    SCNTransaction.commit()
  }

  private func applyWallsHiddenMode(_ hideWalls: Bool) {
    guard let root = loadedScene?.rootNode else { return }
    SCNTransaction.begin()
    SCNTransaction.animationDuration = 0
    func visit(_ node: SCNNode) {
      if node.geometry != nil {
        if hideWalls {
          node.isHidden = shouldHideWallLikeSurface(node)
        } else {
          node.isHidden = false
        }
      }
      for child in node.childNodes {
        visit(child)
      }
    }
    visit(root)
    SCNTransaction.commit()
  }

  @objc private func toggleWallsHiddenMode() {
    guard loadedScene != nil else { return }
    if wallsHidden {
      wallsHidden = false
      setAllGeometryVisible(true)
      floorModeBarButton?.title = strings.floorOnlyButtonTitle
      return
    }
    applyWallsHiddenMode(true)
    guard let root = loadedScene?.rootNode else { return }
    var anyHidden = false
    func checkHidden(_ node: SCNNode) {
      if node.geometry != nil, node.isHidden {
        anyHidden = true
        return
      }
      guard !anyHidden else { return }
      for c in node.childNodes {
        checkHidden(c)
      }
    }
    checkHidden(root)
    if anyHidden {
      wallsHidden = true
      floorModeBarButton?.title = strings.fullRoomButtonTitle
    } else {
      applyWallsHiddenMode(false)
      wallsHidden = false
      floorModeBarButton?.title = strings.floorOnlyButtonTitle
      let alert = UIAlertController(
        title: nil,
        message: strings.floorOnlyUnavailableMessage,
        preferredStyle: .alert
      )
      alert.addAction(UIAlertAction(title: strings.alertOk, style: .default))
      present(alert, animated: true)
    }
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

    sceneWorldBounds = (minB, maxB)
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

    cacheOriginalMaterialsIfNeeded()
    applyOnFloorObjectTint()
  }

  private func loadScene() {
    // Load on the main thread: SceneKit + SCNView expect scene graph work on main; background
    // loading has caused rare runtime issues with Metal/SceneKit state.
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      do {
        let scene = try SCNScene(url: self.fileURL, options: nil)
        self.loadedScene = scene
        self.sceneView.scene = scene
        self.frameCamera(for: scene, in: self.sceneView)
      } catch {
        self.presentLoadError(error)
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
    wallsHidden = false
    didCacheOriginalMaterials = false
    originalMaterialsByGeometry.removeAll(keepingCapacity: false)
    sceneWorldBounds = nil
    floorModeBarButton?.title = strings.floorOnlyButtonTitle
    sceneView.scene = nil
    loadedScene = nil
    dismiss(animated: true)
  }

  deinit {
    sceneView.scene = nil
  }
}

/// Flutter `FlutterResult` must run at most once; duplicate replies can abort the engine connection.
private final class OnceFlutterResult {
  private var consumed = false
  private let result: FlutterResult

  init(_ result: @escaping FlutterResult) {
    self.result = result
  }

  func send(_ value: Any?) {
    guard !consumed else { return }
    consumed = true
    result(value)
  }
}

enum RoomUsdzViewerPresenter {
  static func present(filePath: String, strings: [String: String], result: @escaping FlutterResult) {
    let once = OnceFlutterResult(result)

    guard FileManager.default.fileExists(atPath: filePath) else {
      once.send(
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
      once.send(
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
      once.send(true)
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
