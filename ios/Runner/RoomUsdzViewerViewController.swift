import Flutter
import SceneKit
import UIKit

/// Strings resolved in Flutter ([AppStrings] by language) and passed through the method channel.
struct RoomViewerStrings {
  let title: String
  let dimensionsCaption: String
  let dimensionsLine1Template: String
  let dimensionsHeightTemplate: String
  let dimensionsLine2Template: String
  let loadErrorTitle: String
  let alertOk: String
  let floorOnlyButtonTitle: String
  let fullRoomButtonTitle: String
  let floorOnlyUnavailableMessage: String
  let zoomInA11yLabel: String
  let zoomOutA11yLabel: String
  let viewModeA11yLabel: String
  let viewModeA11yHint: String
  let materialsStyleA11yLabel: String
  let materialsStyleA11yHint: String
  let materialsStyleValueStylized: String
  let materialsStyleValueReal: String
  let brandMarkA11yLabel: String
  /// RGB hex `RRGGBB` from [AppColors.floorObject3dTint] (Material brown).
  let onFloorObjectTint: UIColor

  init(
    title: String,
    dimensionsCaption: String,
    dimensionsLine1Template: String,
    dimensionsHeightTemplate: String,
    dimensionsLine2Template: String,
    loadErrorTitle: String,
    alertOk: String,
    floorOnlyButtonTitle: String,
    fullRoomButtonTitle: String,
    floorOnlyUnavailableMessage: String,
    zoomInA11yLabel: String,
    zoomOutA11yLabel: String,
    viewModeA11yLabel: String,
    viewModeA11yHint: String,
    materialsStyleA11yLabel: String,
    materialsStyleA11yHint: String,
    materialsStyleValueStylized: String,
    materialsStyleValueReal: String,
    brandMarkA11yLabel: String,
    onFloorObjectTint: UIColor
  ) {
    self.title = title
    self.dimensionsCaption = dimensionsCaption
    self.dimensionsLine1Template = dimensionsLine1Template
    self.dimensionsHeightTemplate = dimensionsHeightTemplate
    self.dimensionsLine2Template = dimensionsLine2Template
    self.loadErrorTitle = loadErrorTitle
    self.alertOk = alertOk
    self.floorOnlyButtonTitle = floorOnlyButtonTitle
    self.fullRoomButtonTitle = fullRoomButtonTitle
    self.floorOnlyUnavailableMessage = floorOnlyUnavailableMessage
    self.zoomInA11yLabel = zoomInA11yLabel
    self.zoomOutA11yLabel = zoomOutA11yLabel
    self.viewModeA11yLabel = viewModeA11yLabel
    self.viewModeA11yHint = viewModeA11yHint
    self.materialsStyleA11yLabel = materialsStyleA11yLabel
    self.materialsStyleA11yHint = materialsStyleA11yHint
    self.materialsStyleValueStylized = materialsStyleValueStylized
    self.materialsStyleValueReal = materialsStyleValueReal
    self.brandMarkA11yLabel = brandMarkA11yLabel
    self.onFloorObjectTint = onFloorObjectTint
  }

  init?(dict: [String: String]) {
    guard let title = dict["title"],
      let dimensionsCaption = dict["dimensionsCaption"],
      let dimensionsLine1Template = dict["dimensionsLine1Template"],
      let dimensionsHeightTemplate = dict["dimensionsHeightTemplate"],
      let dimensionsLine2Template = dict["dimensionsLine2Template"],
      let loadErrorTitle = dict["loadErrorTitle"],
      let alertOk = dict["alertOk"]
    else { return nil }
    self.init(
      title: title,
      dimensionsCaption: dimensionsCaption,
      dimensionsLine1Template: dimensionsLine1Template,
      dimensionsHeightTemplate: dimensionsHeightTemplate,
      dimensionsLine2Template: dimensionsLine2Template,
      loadErrorTitle: loadErrorTitle,
      alertOk: alertOk,
      floorOnlyButtonTitle: dict["floorOnlyButton"] ?? "Hide walls",
      fullRoomButtonTitle: dict["fullRoomButton"] ?? "Full room",
      floorOnlyUnavailableMessage: dict["floorOnlyUnavailable"]
        ?? "No wall meshes were found by name in this file.",
      zoomInA11yLabel: dict["zoomIn"] ?? "Zoom in",
      zoomOutA11yLabel: dict["zoomOut"] ?? "Zoom out",
      viewModeA11yLabel: dict["viewModeLabel"] ?? "3D view mode",
      viewModeA11yHint: dict["viewModeHint"] ?? "Switch between full room, walls only, and furniture only.",
      materialsStyleA11yLabel: dict["materialsStyleLabel"] ?? "Materials style",
      materialsStyleA11yHint: dict["materialsStyleHint"] ?? "Toggle between real materials and stylized colors.",
      materialsStyleValueStylized: dict["materialsStylizedValue"] ?? "Stylized",
      materialsStyleValueReal: dict["materialsRealValue"] ?? "Real",
      brandMarkA11yLabel: dict["brandMarkA11yLabel"] ?? "UyDosh",
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
    dimensionsCaption: "Approximate dimensions",
    dimensionsLine1Template:
      "Dimensions: {floorLong} × {floorShort} m",
    dimensionsHeightTemplate: "Height: {height} m",
    dimensionsLine2Template: "Area: ~{floorArea} m²",
    loadErrorTitle: "Could not load 3D model",
    alertOk: "OK",
    floorOnlyButtonTitle: "Hide walls",
    fullRoomButtonTitle: "Full room",
    floorOnlyUnavailableMessage:
      "No wall meshes were found by name in this file.",
    zoomInA11yLabel: "Zoom in",
    zoomOutA11yLabel: "Zoom out",
    viewModeA11yLabel: "3D view mode",
    viewModeA11yHint: "Switch between full room, walls only, and furniture only.",
    materialsStyleA11yLabel: "Materials style",
    materialsStyleA11yHint: "Toggle between real materials and stylized colors.",
    materialsStyleValueStylized: "Stylized",
    materialsStyleValueReal: "Real",
    brandMarkA11yLabel: "UyDosh",
    onFloorObjectTint: Self.uiColorFromRgbHex6("795548")
  )
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

/// Full-screen 3D viewer for a local USDZ (object-only, no Quick Look AR/Object toggle).
final class RoomUsdzViewerViewController: UIViewController, UIGestureRecognizerDelegate {
  private let fileURL: URL
  private let strings: RoomViewerStrings
  private let listingId: Int
  private let publishMetricsIfMissing: Bool
  private weak var metricsMessenger: FlutterBinaryMessenger?
  /// Completes the Flutter `presentLocalFile` future when the viewer is dismissed (not when it opens).
  private let dismissFlutterResult: OnceFlutterResult
  private var didPublishFlutterMetrics = false
  private let sceneView = SCNView()
  private static let autoRotateActionKey = "uydosh.autoRotateModel"
  /// Wraps all USDZ geometry so we can spin the room without rotating the camera (a sibling under `rootNode`).
  private static let modelOrbitNodeName = "UydoshModelOrbit"
  private var isAutoRotating = true
  /// Orbit state (manual mode); camera stays a direct child of `rootNode`, not inside the model wrapper.
  private weak var framingCameraNode: SCNNode?
  private var orbitTarget = SCNVector3Zero
  private var orbitYaw: Float = 0
  private var orbitPitch: Float = 0
  private var orbitRadius: Float = 1
  private var orbitPanGesture: UIPanGestureRecognizer?
  private var orbitPinchGesture: UIPinchGestureRecognizer?
  private var introTapGesture: UITapGestureRecognizer?
  private var pinchBaseFov: CGFloat = 60
  private let hintContainer = UIView()
  private let hintStack = UIStackView()
  private let dimensionsTitleLabel = UILabel()
  private let dimensionsLineStack = UIStackView()
  private let dimensionsLine1Icon = UIImageView()
  private let dimensionsLine1Label = UILabel()
  private let dimensionsHeightIcon = UIImageView()
  private let dimensionsHeightLabel = UILabel()
  private let dimensionsLine2Icon = UIImageView()
  private let dimensionsLine2Label = UILabel()
  private let zoomControlsContainer = UIView()
  private let zoomControlsPanel = UIView()
  private let zoomStack = UIStackView()
  private let zoomInButton = UIButton(type: .system)
  private let zoomOutButton = UIButton(type: .system)
  /// App mark (PNG): bottom-trailing over the 3D viewport, loaded from the
  /// Flutter asset bundle so it stays in sync with the rest of the app.
  /// We swapped to the PNG (away from the SVG-via-CAShapeLayer renderer)
  /// and to the trailing edge so the zoom +/- controls can take the
  /// bottom-leading slot — easier to reach with the right thumb on
  /// portrait phones, and consistent with where the watermark lives on
  /// the saved photo.
  private let brandMarkView = UIImageView()
  private var loadedScene: SCNScene?
  private enum DisplayMode: Int {
    case fullRoom = 0
    /// Furniture removed, keep walls/structure.
    case wallsOnly = 1
    /// Walls/structure removed, keep furniture.
    case furnitureOnly = 2
  }

  private var displayMode: DisplayMode = .fullRoom
  private let modeControl = UISegmentedControl(items: ["", "", ""])
  private var useStylizedMaterials = true
  private var materialsBarButton: UIBarButtonItem?
  private var sceneWorldBounds: (min: SCNVector3, max: SCNVector3)?
  private var didCacheOriginalMaterials = false
  private var originalMaterialsByGeometry = [ObjectIdentifier: [SCNMaterial]]()
  /// Matches `zoomInTapped` / `zoomOutTapped` (FOV change per step).
  private static let zoomFovStepDegrees: CGFloat = 7.2
  /// Pill-shaped zoom bar; large enough to read softer than the old 14pt radius.
  private static let zoomControlsPanelCornerRadius: CGFloat = 28
  private static let zoomButtonSize: CGFloat = 38
  private static let zoomButtonCornerRadius: CGFloat = 19
  /// How many zoom-in steps to apply on open (model appears larger; same camera distance as padded fit).
  private static let initialZoomInSteps: Int = 2

  fileprivate init(
    fileURL: URL,
    strings: RoomViewerStrings,
    listingId: Int = 0,
    publishMetricsIfMissing: Bool = false,
    metricsMessenger: FlutterBinaryMessenger? = nil,
    dismissFlutterResult: OnceFlutterResult
  ) {
    self.fileURL = fileURL
    self.strings = strings
    self.listingId = listingId
    self.publishMetricsIfMissing = publishMetricsIfMissing
    self.metricsMessenger = metricsMessenger
    self.dismissFlutterResult = dismissFlutterResult
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
    setupModeControl()
    setupMaterialsToggle()
    navigationItem.rightBarButtonItems = [
      materialsBarButton,
      UIBarButtonItem(customView: modeControl),
    ].compactMap { $0 }

    sceneView.translatesAutoresizingMaskIntoConstraints = false
    sceneView.backgroundColor = .black
    // Start in "presentation" mode: auto-rotate until the user taps to take control.
    sceneView.allowsCameraControl = false
    sceneView.antialiasingMode = .multisampling4X
    sceneView.autoenablesDefaultLighting = true
    view.addSubview(sceneView)

    let tap = UITapGestureRecognizer(target: self, action: #selector(sceneTapped))
    tap.cancelsTouchesInView = false
    sceneView.addGestureRecognizer(tap)
    introTapGesture = tap

    setupZoomControls()

    hintContainer.translatesAutoresizingMaskIntoConstraints = false
    // Opaque panel only once dimensions are known (avoids an empty strip while labels are hidden).
    hintContainer.backgroundColor = .clear
    hintContainer.layer.cornerRadius = 12
    if #available(iOS 13.0, *) {
      hintContainer.layer.cornerCurve = .continuous
    }
    hintContainer.clipsToBounds = true
    hintContainer.isUserInteractionEnabled = false

    dimensionsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
    dimensionsTitleLabel.textAlignment = .center
    dimensionsTitleLabel.numberOfLines = 0
    dimensionsTitleLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
    dimensionsTitleLabel.adjustsFontForContentSizeCategory = true
    dimensionsTitleLabel.textColor = UIColor.white.withAlphaComponent(0.68)
    dimensionsTitleLabel.text = strings.dimensionsCaption
    dimensionsTitleLabel.isHidden = true

    let dimSymbolConfig = UIImage.SymbolConfiguration(pointSize: 13, weight: .medium)
    func configureDimensionIcon(_ iv: UIImageView, systemName: String) {
      iv.translatesAutoresizingMaskIntoConstraints = false
      iv.contentMode = .scaleAspectFit
      iv.tintColor = UIColor.white.withAlphaComponent(0.92)
      iv.image = UIImage(systemName: systemName, withConfiguration: dimSymbolConfig)
      iv.setContentHuggingPriority(.required, for: .horizontal)
      NSLayoutConstraint.activate([
        iv.widthAnchor.constraint(equalToConstant: 20),
        iv.heightAnchor.constraint(equalToConstant: 18),
      ])
    }
    configureDimensionIcon(dimensionsLine1Icon, systemName: "rectangle")
    configureDimensionIcon(dimensionsHeightIcon, systemName: "arrow.up.and.down")
    configureDimensionIcon(dimensionsLine2Icon, systemName: "rectangle.on.rectangle")

    let subHead = UIFont.preferredFont(forTextStyle: .subheadline)
    let valueFont: UIFont = {
      if let boldDesc = subHead.fontDescriptor.withSymbolicTraits(.traitBold) {
        return UIFont(descriptor: boldDesc, size: 0)
      }
      return subHead
    }()

    func configureDimensionValueLabel(_ label: UILabel) {
      label.translatesAutoresizingMaskIntoConstraints = false
      label.textAlignment = .natural
      label.numberOfLines = 0
      label.adjustsFontForContentSizeCategory = true
      label.textColor = UIColor.white.withAlphaComponent(0.98)
      label.font = valueFont
    }
    configureDimensionValueLabel(dimensionsLine1Label)
    configureDimensionValueLabel(dimensionsHeightLabel)
    configureDimensionValueLabel(dimensionsLine2Label)

    let row1 = UIStackView(arrangedSubviews: [dimensionsLine1Icon, dimensionsLine1Label])
    row1.axis = .horizontal
    row1.spacing = 8
    row1.alignment = .center
    row1.distribution = .fill
    let rowHeight = UIStackView(arrangedSubviews: [dimensionsHeightIcon, dimensionsHeightLabel])
    rowHeight.axis = .horizontal
    rowHeight.spacing = 8
    rowHeight.alignment = .center
    rowHeight.distribution = .fill
    let row2 = UIStackView(arrangedSubviews: [dimensionsLine2Icon, dimensionsLine2Label])
    row2.axis = .horizontal
    row2.spacing = 8
    row2.alignment = .center
    row2.distribution = .fill

    dimensionsLineStack.translatesAutoresizingMaskIntoConstraints = false
    dimensionsLineStack.axis = .vertical
    dimensionsLineStack.spacing = 6
    dimensionsLineStack.alignment = .center
    dimensionsLineStack.addArrangedSubview(row1)
    dimensionsLineStack.addArrangedSubview(rowHeight)
    dimensionsLineStack.addArrangedSubview(row2)
    dimensionsLineStack.isHidden = true
    dimensionsLineStack.isAccessibilityElement = true
    dimensionsLineStack.accessibilityTraits = .staticText

    hintStack.translatesAutoresizingMaskIntoConstraints = false
    hintStack.axis = .vertical
    hintStack.alignment = .center
    hintStack.spacing = 4
    hintStack.addArrangedSubview(dimensionsTitleLabel)
    hintStack.addArrangedSubview(dimensionsLineStack)

    hintContainer.addSubview(hintStack)
    view.addSubview(hintContainer)

    brandMarkView.translatesAutoresizingMaskIntoConstraints = false
    brandMarkView.accessibilityIgnoresInvertColors = true
    brandMarkView.isAccessibilityElement = true
    brandMarkView.accessibilityLabel = strings.brandMarkA11yLabel
    brandMarkView.contentMode = .scaleAspectFit
    brandMarkView.isUserInteractionEnabled = false
    // Soft drop shadow so the mark stays legible over varied 3D scenes
    // (mirrors the shadow the previous vector renderer applied).
    brandMarkView.layer.shadowColor = UIColor.black.cgColor
    brandMarkView.layer.shadowOpacity = 0.35
    brandMarkView.layer.shadowOffset = CGSize(width: 0, height: 1)
    brandMarkView.layer.shadowRadius = 5
    brandMarkView.layer.masksToBounds = false
    // Load the PNG from the Flutter asset bundle (same lookup pattern as
    // the RoomCaptureView overlay injected via Podfile).
    let brandMarkAssetKey = FlutterDartProject.lookupKey(
      forAsset: "assets/icon/components/brand_logo_transparent.png"
    )
    if let path = Bundle.main.path(forResource: brandMarkAssetKey, ofType: nil),
       let image = UIImage(contentsOfFile: path) {
      brandMarkView.image = image
    }
    view.addSubview(brandMarkView)

    // Make sure overlay controls remain tappable/draggable above SceneKit.
    view.bringSubviewToFront(zoomControlsContainer)

    NSLayoutConstraint.activate([
      sceneView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      sceneView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),

      hintStack.topAnchor.constraint(equalTo: hintContainer.topAnchor, constant: 10),
      hintStack.leadingAnchor.constraint(equalTo: hintContainer.leadingAnchor, constant: 14),
      hintStack.trailingAnchor.constraint(equalTo: hintContainer.trailingAnchor, constant: -14),
      hintStack.bottomAnchor.constraint(equalTo: hintContainer.bottomAnchor, constant: -10),

      hintContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      hintContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      hintContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),

      // Brand mark moved to bottom-trailing (was bottom-leading); zoom
      // controls take over the bottom-leading slot below.
      brandMarkView.trailingAnchor.constraint(equalTo: sceneView.trailingAnchor, constant: -12),
      brandMarkView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -22),
      brandMarkView.widthAnchor.constraint(equalToConstant: 62),
      brandMarkView.heightAnchor.constraint(equalToConstant: 62),

      zoomControlsContainer.leadingAnchor.constraint(equalTo: sceneView.leadingAnchor, constant: 12),
      zoomControlsContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -22),
    ])

    // Pan / pinch from launch so a drag or pinch ends intro auto-rotation (tap-only was too limiting).
    installManualOrbitGestures()
    sceneView.isMultipleTouchEnabled = true
    if let tap = introTapGesture, let pan = orbitPanGesture {
      tap.require(toFail: pan)
    }

    loadScene()
    playBrandMarkEntranceAnimation()
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    refreshZoomControlsNeumorphicShadowPaths()
    let stackWidth = hintStack.bounds.width
    guard stackWidth > 0 else { return }
    // Multiline labels need a max width when the stack uses centered alignment.
    dimensionsTitleLabel.preferredMaxLayoutWidth = stackWidth
    let lineLabelMaxWidth = stackWidth - 20 - 8  // icon width + row spacing
    dimensionsLine1Label.preferredMaxLayoutWidth = lineLabelMaxWidth
    dimensionsHeightLabel.preferredMaxLayoutWidth = lineLabelMaxWidth
    dimensionsLine2Label.preferredMaxLayoutWidth = lineLabelMaxWidth
  }

  /// Fade + slight drop entrance for the brand mark. Mirrors the feel of
  /// the previous CAShapeLayer-based renderer so the viewer's opening
  /// beat doesn't change visually after the PNG swap.
  private func playBrandMarkEntranceAnimation() {
    brandMarkView.alpha = 0
    brandMarkView.transform = CGAffineTransform(translationX: 0, y: -6)
    UIView.animate(
      withDuration: 0.32,
      delay: 0.05,
      usingSpringWithDamping: 0.78,
      initialSpringVelocity: 0,
      options: [.curveEaseOut],
      animations: {
        self.brandMarkView.alpha = 1
        self.brandMarkView.transform = .identity
      }
    )
  }

  private func setupZoomControls() {
    zoomControlsContainer.translatesAutoresizingMaskIntoConstraints = false
    zoomControlsContainer.isUserInteractionEnabled = true
    zoomControlsContainer.backgroundColor = .clear
    zoomControlsContainer.clipsToBounds = false
    zoomControlsContainer.layer.masksToBounds = false
    zoomControlsContainer.layer.shadowColor = UIColor.black.cgColor
    zoomControlsContainer.layer.shadowOpacity = 0.52
    zoomControlsContainer.layer.shadowOffset = CGSize(width: 5, height: 7)
    zoomControlsContainer.layer.shadowRadius = 14

    zoomControlsPanel.translatesAutoresizingMaskIntoConstraints = false
    zoomControlsPanel.isUserInteractionEnabled = true
    zoomControlsPanel.backgroundColor = UIColor(red: 0.17, green: 0.17, blue: 0.19, alpha: 1)
    zoomControlsPanel.layer.cornerRadius = Self.zoomControlsPanelCornerRadius
    if #available(iOS 13.0, *) {
      zoomControlsPanel.layer.cornerCurve = .continuous
    }
    zoomControlsPanel.clipsToBounds = true
    zoomControlsPanel.layer.borderWidth = 1
    zoomControlsPanel.layer.borderColor = UIColor.white.withAlphaComponent(0.07).cgColor

    zoomControlsContainer.addSubview(zoomControlsPanel)
    NSLayoutConstraint.activate([
      zoomControlsPanel.topAnchor.constraint(equalTo: zoomControlsContainer.topAnchor),
      zoomControlsPanel.leadingAnchor.constraint(equalTo: zoomControlsContainer.leadingAnchor),
      zoomControlsPanel.trailingAnchor.constraint(equalTo: zoomControlsContainer.trailingAnchor),
      zoomControlsPanel.bottomAnchor.constraint(equalTo: zoomControlsContainer.bottomAnchor),
    ])

    view.addSubview(zoomControlsContainer)

    zoomStack.translatesAutoresizingMaskIntoConstraints = false
    zoomStack.axis = .horizontal
    zoomStack.alignment = .center
    zoomStack.spacing = 12

    let iconConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
    zoomInButton.setImage(UIImage(systemName: "plus.magnifyingglass", withConfiguration: iconConfig), for: .normal)
    zoomOutButton.setImage(UIImage(systemName: "minus.magnifyingglass", withConfiguration: iconConfig), for: .normal)

    let buttonTint = UIColor.white.withAlphaComponent(0.92)
    for b in [zoomInButton, zoomOutButton] {
      b.translatesAutoresizingMaskIntoConstraints = false
      b.tintColor = buttonTint
      b.backgroundColor = UIColor(red: 0.22, green: 0.22, blue: 0.26, alpha: 1)
      b.layer.cornerRadius = Self.zoomButtonCornerRadius
      if #available(iOS 13.0, *) {
        b.layer.cornerCurve = .continuous
      }
      b.clipsToBounds = false
      b.layer.masksToBounds = false
      b.layer.shadowColor = UIColor.black.cgColor
      b.layer.shadowOpacity = 0.4
      b.layer.shadowOffset = CGSize(width: 2, height: 3)
      b.layer.shadowRadius = 4
      b.layer.borderWidth = 0.5
      b.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
      NSLayoutConstraint.activate([
        b.heightAnchor.constraint(equalToConstant: Self.zoomButtonSize),
        b.widthAnchor.constraint(equalToConstant: Self.zoomButtonSize),
      ])
    }

    zoomInButton.accessibilityLabel = strings.zoomInA11yLabel
    zoomOutButton.accessibilityLabel = strings.zoomOutA11yLabel
    zoomInButton.addTarget(self, action: #selector(zoomInTapped), for: .touchUpInside)
    zoomOutButton.addTarget(self, action: #selector(zoomOutTapped), for: .touchUpInside)

    zoomStack.addArrangedSubview(zoomInButton)
    zoomStack.addArrangedSubview(zoomOutButton)
    zoomControlsPanel.addSubview(zoomStack)

    NSLayoutConstraint.activate([
      zoomStack.topAnchor.constraint(equalTo: zoomControlsPanel.topAnchor, constant: 12),
      zoomStack.leadingAnchor.constraint(equalTo: zoomControlsPanel.leadingAnchor, constant: 12),
      zoomStack.trailingAnchor.constraint(equalTo: zoomControlsPanel.trailingAnchor, constant: -12),
      zoomStack.bottomAnchor.constraint(equalTo: zoomControlsPanel.bottomAnchor, constant: -12),
    ])
  }

  private func refreshZoomControlsNeumorphicShadowPaths() {
    let panelR = Self.zoomControlsPanelCornerRadius
    let outer = zoomControlsContainer.bounds
    guard outer.width > 1, outer.height > 1 else { return }
    zoomControlsContainer.layer.shadowPath =
      UIBezierPath(roundedRect: outer, cornerRadius: panelR).cgPath

    let br = Self.zoomButtonCornerRadius
    for b in [zoomInButton, zoomOutButton] {
      let bb = b.bounds
      guard bb.width > 1, bb.height > 1 else { continue }
      b.layer.shadowPath = UIBezierPath(roundedRect: bb, cornerRadius: br).cgPath
    }
  }

  private func setZoom(fovDegrees: CGFloat, animated: Bool) {
    guard let cam = sceneView.pointOfView?.camera else { return }
    let next = max(28, min(82, fovDegrees))
    if animated {
      SCNTransaction.begin()
      SCNTransaction.animationDuration = 0.12
      cam.fieldOfView = next
      SCNTransaction.commit()
    } else {
      cam.fieldOfView = next
    }
  }

  @objc private func zoomInTapped() {
    guard let cam = sceneView.pointOfView?.camera else { return }
    setZoom(fovDegrees: cam.fieldOfView - Self.zoomFovStepDegrees, animated: true)
  }

  @objc private func zoomOutTapped() {
    guard let cam = sceneView.pointOfView?.camera else { return }
    setZoom(fovDegrees: cam.fieldOfView + Self.zoomFovStepDegrees, animated: true)
  }

  private func setupModeControl() {
    modeControl.translatesAutoresizingMaskIntoConstraints = false
    modeControl.isMomentary = false
    modeControl.selectedSegmentIndex = DisplayMode.fullRoom.rawValue
    modeControl.apportionsSegmentWidthsByContent = true

    let fullIcon = UIImage(systemName: "house.fill")
    let wallsIcon = UIImage(systemName: "rectangle.split.3x1.fill")
      ?? UIImage(systemName: "square.split.2x2.fill")
    let furnitureIcon = UIImage(systemName: "bed.double.fill")
      ?? UIImage(systemName: "shippingbox.fill")
      ?? UIImage(systemName: "cube.box.fill")

    if let fullIcon = fullIcon {
      modeControl.setImage(fullIcon, forSegmentAt: DisplayMode.fullRoom.rawValue)
    } else {
      modeControl.setTitle("All", forSegmentAt: DisplayMode.fullRoom.rawValue)
    }
    if let wallsIcon = wallsIcon {
      modeControl.setImage(wallsIcon, forSegmentAt: DisplayMode.wallsOnly.rawValue)
    } else {
      modeControl.setTitle("Walls", forSegmentAt: DisplayMode.wallsOnly.rawValue)
    }
    if let furnitureIcon = furnitureIcon {
      modeControl.setImage(furnitureIcon, forSegmentAt: DisplayMode.furnitureOnly.rawValue)
    } else {
      modeControl.setTitle("Items", forSegmentAt: DisplayMode.furnitureOnly.rawValue)
    }

    modeControl.setWidth(38, forSegmentAt: DisplayMode.fullRoom.rawValue)
    modeControl.setWidth(38, forSegmentAt: DisplayMode.wallsOnly.rawValue)
    modeControl.setWidth(38, forSegmentAt: DisplayMode.furnitureOnly.rawValue)

    modeControl.addTarget(self, action: #selector(modeChanged), for: .valueChanged)

    modeControl.isAccessibilityElement = true
    modeControl.accessibilityLabel = strings.viewModeA11yLabel
    modeControl.accessibilityHint = strings.viewModeA11yHint
  }

  private func setupMaterialsToggle() {
    let btn = UIBarButtonItem(
      image: UIImage(systemName: "paintbrush.fill"),
      style: .plain,
      target: self,
      action: #selector(toggleMaterialsStyle)
    )
    btn.accessibilityLabel = strings.materialsStyleA11yLabel
    btn.accessibilityHint = strings.materialsStyleA11yHint
    materialsBarButton = btn
    updateMaterialsButtonAppearance()
  }

  private func updateMaterialsButtonAppearance() {
    // Stylized: paintbrush, Real: photo
    let name = useStylizedMaterials ? "paintbrush.fill" : "photo.fill.on.rectangle.fill"
    materialsBarButton?.image = UIImage(systemName: name)
    materialsBarButton?.accessibilityValue = useStylizedMaterials
      ? strings.materialsStyleValueStylized
      : strings.materialsStyleValueReal
  }

  // (Removed: `UydoshVectorBrandMarkView` and its `SVGPathParser` helper
  // used to render the brand mark from inline SVG paths via CAShapeLayer.
  // The viewer now loads `assets/icon/components/brand_logo_transparent.png`
  // from the Flutter asset bundle so the mark stays in lockstep with the
  // rest of the app's brand surfaces.)

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

  private func restoreOriginalMaterials() {
    guard let root = loadedScene?.rootNode else { return }
    cacheOriginalMaterialsIfNeeded()
    SCNTransaction.begin()
    SCNTransaction.animationDuration = 0
    func visit(_ node: SCNNode) {
      if let geo = node.geometry {
        let id = ObjectIdentifier(geo)
        if let originals = originalMaterialsByGeometry[id] {
          geo.materials = originals.map { $0.copy() as! SCNMaterial }
        }
      }
      for c in node.childNodes { visit(c) }
    }
    visit(root)
    SCNTransaction.commit()
  }

  /// Roughness for stylized wall materials (PBR). Higher = more diffuse, less plastic shine.
  private static let stylizedWallRoughness: CGFloat = 0.86

  /// Applies PBR + matte roughness so stylized walls do not read as perfectly smooth plastic.
  private func applyStylizedWallMaterial(_ material: SCNMaterial, diffuseTint: UIColor) {
    material.lightingModel = .physicallyBased
    material.diffuse.contents = diffuseTint
    material.metalness.contents = NSNumber(value: 0.0)
    material.roughness.contents = NSNumber(value: Double(Self.stylizedWallRoughness))
  }

  /// Stylized palette (fixed tints for USDZ room scans):
  /// - Walls: Soft Sand `#E8DFCF`
  /// - Floor: Walnut Wood `#7A5C4F`
  /// - Furniture: Muted Teal `#4F7D8A`
  private func applyFloorAndFurnitureTint() {
    guard let root = loadedScene?.rootNode, let sceneBounds = sceneWorldBounds else { return }
    cacheOriginalMaterialsIfNeeded()
    let floorTint = UIColor(red: 122 / 255, green: 92 / 255, blue: 79 / 255, alpha: 1) // #7A5C4F
    let furnitureTint = UIColor(red: 79 / 255, green: 125 / 255, blue: 138 / 255, alpha: 1) // #4F7D8A
    let wallTint = UIColor(red: 232 / 255, green: 223 / 255, blue: 207 / 255, alpha: 1) // #E8DFCF
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

      // Restore originals first; then selectively retint per surface class.
      geo.materials = originals.map { $0.copy() as! SCNMaterial }
      if let b = worldBounds(of: node), isLikelyFloorSlab(b, sceneBounds: sceneBounds) {
        geo.materials = originals.map { orig in
          let m = orig.copy() as! SCNMaterial
          m.diffuse.contents = floorTint
          return m
        }
      } else if isOnFloorObject(node, sceneBounds: sceneBounds) {
        geo.materials = originals.map { orig in
          let m = orig.copy() as! SCNMaterial
          m.diffuse.contents = furnitureTint
          return m
        }
      } else if isWallSurface(node) {
        geo.materials = originals.map { orig in
          let m = orig.copy() as! SCNMaterial
          applyStylizedWallMaterial(m, diffuseTint: wallTint)
          return m
        }
      }
      for c in node.childNodes {
        visit(c)
      }
    }
    visit(root)
    SCNTransaction.commit()
  }

  private func applyMaterialsStyle() {
    guard loadedScene != nil else { return }
    if useStylizedMaterials {
      applyFloorAndFurnitureTint()
    } else {
      restoreOriginalMaterials()
    }
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

  /// Name-based wall detector (RoomPlan exports meshes named like `Wall0`, `Wall1`, ...).
  /// Intentionally excludes ceiling/doors/windows/openings so the tint only hits solid walls.
  private func isWallSurface(_ node: SCNNode) -> Bool {
    if node.name == "UydoshFramingCamera" { return false }
    let name = (node.name ?? "").lowercased()
    if name.isEmpty { return false }
    if name.contains("floor") || name.contains("ground") { return false }
    if name.contains("ceiling") { return false }
    if name.contains("door") || name.contains("window") || name.contains("opening") { return false }
    return name.contains("wall")
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

  private func applyDisplayMode(_ mode: DisplayMode) {
    guard let root = loadedScene?.rootNode else { return }

    SCNTransaction.begin()
    SCNTransaction.animationDuration = 0

    func visit(_ node: SCNNode) {
      if node.geometry != nil {
        switch mode {
        case .fullRoom:
          node.isHidden = false
        case .wallsOnly:
          if node.name == "UydoshFramingCamera" {
            node.isHidden = false
          } else if let sceneBounds = sceneWorldBounds, isOnFloorObject(node, sceneBounds: sceneBounds) {
            node.isHidden = true
          } else {
            node.isHidden = false
          }
        case .furnitureOnly:
          if node.name == "UydoshFramingCamera" {
            node.isHidden = false
          } else {
            node.isHidden = shouldHideWallLikeSurface(node)
          }
        }
      }
      for child in node.childNodes {
        visit(child)
      }
    }

    visit(root)
    SCNTransaction.commit()

    if mode == .furnitureOnly {
      // If we cannot find any wall-like meshes by name, don’t pretend mode worked.
      var anyHidden = false
      func checkHidden(_ node: SCNNode) {
        if node.geometry != nil, node.isHidden {
          anyHidden = true
          return
        }
        guard !anyHidden else { return }
        for c in node.childNodes { checkHidden(c) }
      }
      checkHidden(root)
      if !anyHidden {
        // Revert and explain.
        displayMode = .fullRoom
        modeControl.selectedSegmentIndex = DisplayMode.fullRoom.rawValue
        setAllGeometryVisible(true)
        let alert = UIAlertController(
          title: nil,
          message: strings.floorOnlyUnavailableMessage,
          preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: strings.alertOk, style: .default))
        present(alert, animated: true)
      }
    }
  }

  @objc private func modeChanged() {
    guard loadedScene != nil else { return }
    let idx = modeControl.selectedSegmentIndex
    let next = DisplayMode(rawValue: idx) ?? .fullRoom
    displayMode = next
    applyDisplayMode(next)
  }

  @objc private func toggleMaterialsStyle() {
    guard loadedScene != nil else { return }
    useStylizedMaterials.toggle()
    updateMaterialsButtonAppearance()
    applyMaterialsStyle()
  }

  /// RoomPlan / SceneKit: meters, Y-up. Uses horizontal spans (X, Z) as floor footprint and Y as height.
  /// Floor “area” is the axis-aligned footprint (long × short); room shapes are often non-rectangular.
  private func updateDimensionsDisplay(dx: Float, dy: Float, dz: Float) {
    let floorLong = max(dx, dz)
    let floorShort = min(dx, dz)
    let height = dy
    let floorArea = Double(floorLong) * Double(floorShort)
    func fmt(_ v: Float) -> String {
      String(format: "%.1f", v)
    }
    func fmtArea(_ v: Double) -> String {
      String(format: "%.1f", v)
    }
    var line1 = strings.dimensionsLine1Template
    line1 = line1.replacingOccurrences(of: "{floorLong}", with: fmt(floorLong))
    line1 = line1.replacingOccurrences(of: "{floorShort}", with: fmt(floorShort))
    var lineH = strings.dimensionsHeightTemplate
    lineH = lineH.replacingOccurrences(of: "{height}", with: fmt(height))
    var line2 = strings.dimensionsLine2Template
    line2 = line2.replacingOccurrences(of: "{floorArea}", with: fmtArea(floorArea))
    dimensionsLine1Label.text = line1
    dimensionsHeightLabel.text = lineH
    dimensionsLine2Label.text = line2
    dimensionsLineStack.accessibilityLabel = "\(line1). \(lineH). \(line2)"
    dimensionsTitleLabel.isHidden = false
    dimensionsLineStack.isHidden = false
    hintContainer.backgroundColor = UIColor.black.withAlphaComponent(0.52)
    hintContainer.isUserInteractionEnabled = true
    publishMetricsToFlutterIfNeeded(dx: dx, dy: dy, dz: dz)
  }

  /// Owner backfill: push bounds to Flutter once so the API can persist metrics for legacy scans.
  private func publishMetricsToFlutterIfNeeded(dx: Float, dy: Float, dz: Float) {
    guard publishMetricsIfMissing, listingId > 0, !didPublishFlutterMetrics,
      let messenger = metricsMessenger
    else { return }
    didPublishFlutterMetrics = true
    let floorLong = Double(max(dx, dz))
    let floorShort = Double(min(dx, dz))
    let height = Double(dy)
    let floorArea = floorLong * floorShort
    let channel = FlutterMethodChannel(
      name: "uydosh/room_scan_metrics_sink",
      binaryMessenger: messenger
    )
    channel.invokeMethod(
      "onComputedMetrics",
      arguments: [
        "listingId": listingId,
        "floor_long_m": floorLong,
        "floor_short_m": floorShort,
        "height_m": height,
        "floor_area_m2": floorArea,
      ],
      result: { _ in }
    )
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
    let initialFov =
      vfovDegrees - Self.zoomFovStepDegrees * CGFloat(Self.initialZoomInSteps)
    setZoom(fovDegrees: initialFov, animated: false)

    view.defaultCameraController.target = centerWorld

    framingCameraNode = cameraNode
    orbitTarget = centerWorld
    let wp = cameraNode.worldPosition
    let cdx = wp.x - centerWorld.x
    let cdy = wp.y - centerWorld.y
    let cdz = wp.z - centerWorld.z
    orbitRadius = sqrt(cdx * cdx + cdy * cdy + cdz * cdz)
    if orbitRadius > 1e-4 {
      orbitPitch = asin(min(1, max(-1, cdy / orbitRadius)))
      orbitYaw = atan2(cdx, cdz)
    }

    cacheOriginalMaterialsIfNeeded()
    applyMaterialsStyle()
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
        self.displayMode = DisplayMode(rawValue: self.modeControl.selectedSegmentIndex) ?? .fullRoom
        self.applyDisplayMode(self.displayMode)
        self.startIntroAutoRotationIfNeeded()
      } catch {
        self.presentLoadError(error)
      }
    }
  }

  /// Reparents every child of `rootNode` except the framing camera under a wrapper so spin actions do not rotate the camera.
  private func ensureModelOrbitWrapper() -> SCNNode? {
    guard let scene = loadedScene else { return nil }
    let root = scene.rootNode
    if let existing = root.childNode(withName: Self.modelOrbitNodeName, recursively: false) {
      return existing
    }
    let wrap = SCNNode()
    wrap.name = Self.modelOrbitNodeName
    let toReparent = root.childNodes.filter { $0.name != "UydoshFramingCamera" }
    guard !toReparent.isEmpty else { return nil }
    for child in toReparent {
      child.removeFromParentNode()
      wrap.addChildNode(child)
    }
    root.addChildNode(wrap)
    return wrap
  }

  private func removeAutoRotateAnimation() {
    guard let scene = loadedScene else { return }
    scene.rootNode.childNode(withName: Self.modelOrbitNodeName, recursively: false)?
      .removeAction(forKey: Self.autoRotateActionKey)
    scene.rootNode.removeAction(forKey: Self.autoRotateActionKey)
  }

  private func startIntroAutoRotationIfNeeded() {
    guard isAutoRotating, let orbitNode = ensureModelOrbitWrapper() else { return }
    // Y-up rooms: spin around **world Y** (turntable in the floor plane). Negative angle ≈ clockwise from above.
    let secondsPerTurn: TimeInterval = 8.0
    let spin = SCNAction.rotate(
      by: -CGFloat.pi * 2,
      around: SCNVector3(0, 1, 0),
      duration: secondsPerTurn
    )
    let action = SCNAction.repeatForever(spin)
    orbitNode.runAction(action, forKey: Self.autoRotateActionKey)
  }

  private func installManualOrbitGestures() {
    guard orbitPanGesture == nil else { return }
    let pan = UIPanGestureRecognizer(target: self, action: #selector(orbitPan(_:)))
    pan.maximumNumberOfTouches = 1
    pan.delegate = self
    sceneView.addGestureRecognizer(pan)
    orbitPanGesture = pan

    let pinch = UIPinchGestureRecognizer(target: self, action: #selector(orbitPinch(_:)))
    pinch.delegate = self
    sceneView.addGestureRecognizer(pinch)
    orbitPinchGesture = pinch
  }

  private func removeManualOrbitGestures() {
    if let g = orbitPanGesture {
      sceneView.removeGestureRecognizer(g)
      orbitPanGesture = nil
    }
    if let g = orbitPinchGesture {
      sceneView.removeGestureRecognizer(g)
      orbitPinchGesture = nil
    }
  }

  private func updateCameraFromOrbit() {
    guard let camNode = framingCameraNode else { return }
    let T = orbitTarget
    let r = orbitRadius
    let horizontal = r * cos(orbitPitch)
    let x = T.x + horizontal * sin(orbitYaw)
    let y = T.y + r * sin(orbitPitch)
    let z = T.z + horizontal * cos(orbitYaw)
    camNode.worldPosition = SCNVector3(x, y, z)
    camNode.look(at: T, up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))
  }

  @objc private func orbitPan(_ gr: UIPanGestureRecognizer) {
    switch gr.state {
    case .began, .changed, .ended:
      break
    default:
      return
    }
    if isAutoRotating {
      removeAutoRotateAnimation()
      isAutoRotating = false
      updateCameraFromOrbit()
    }
    guard framingCameraNode != nil else { return }
    let t = gr.translation(in: sceneView)
    gr.setTranslation(.zero, in: sceneView)
    // Signs chosen so horizontal/vertical drags match typical “orbit the model” (inverted vs raw deltas).
    let sens: Float = 0.012
    orbitYaw -= Float(t.x) * sens
    orbitPitch += Float(t.y) * sens
    let maxPitch = Float.pi / 2 - 0.12
    let minPitch = -Float.pi / 2 + 0.12
    orbitPitch = min(max(orbitPitch, minPitch), maxPitch)
    updateCameraFromOrbit()
  }

  @objc private func orbitPinch(_ gr: UIPinchGestureRecognizer) {
    if isAutoRotating {
      removeAutoRotateAnimation()
      isAutoRotating = false
      updateCameraFromOrbit()
    }
    guard let cam = framingCameraNode?.camera else { return }
    switch gr.state {
    case .began:
      pinchBaseFov = cam.fieldOfView
    case .changed:
      let next = pinchBaseFov / CGFloat(gr.scale)
      setZoom(fovDegrees: next, animated: false)
    case .ended, .cancelled, .failed:
      pinchBaseFov = cam.fieldOfView
    default:
      break
    }
  }

  func gestureRecognizer(
    _: UIGestureRecognizer,
    shouldRecognizeSimultaneouslyWith _: UIGestureRecognizer
  ) -> Bool {
    true
  }

  @objc private func sceneTapped() {
    guard isAutoRotating else { return }
    removeAutoRotateAnimation()
    isAutoRotating = false
    updateCameraFromOrbit()
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
    removeAutoRotateAnimation()
    removeManualOrbitGestures()
    framingCameraNode = nil
    didCacheOriginalMaterials = false
    originalMaterialsByGeometry.removeAll(keepingCapacity: false)
    sceneWorldBounds = nil
    displayMode = .fullRoom
    modeControl.selectedSegmentIndex = DisplayMode.fullRoom.rawValue
    useStylizedMaterials = true
    updateMaterialsButtonAppearance()
    sceneView.scene = nil
    loadedScene = nil
    let once = dismissFlutterResult
    dismiss(animated: true) {
      once.send(true)
    }
  }

  deinit {
    sceneView.scene = nil
  }
}

enum RoomUsdzViewerPresenter {
  static func present(
    filePath: String,
    strings: [String: String],
    messenger: FlutterBinaryMessenger?,
    listingId: Int,
    publishMetricsIfMissing: Bool,
    result: @escaping FlutterResult
  ) {
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
    let viewer = RoomUsdzViewerViewController(
      fileURL: url,
      strings: resolved,
      listingId: listingId,
      publishMetricsIfMissing: publishMetricsIfMissing,
      metricsMessenger: messenger,
      dismissFlutterResult: once
    )
    let nav = UINavigationController(rootViewController: viewer)
    nav.modalPresentationStyle = .fullScreen
    nav.navigationBar.prefersLargeTitles = false

    host.present(nav, animated: true)
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
