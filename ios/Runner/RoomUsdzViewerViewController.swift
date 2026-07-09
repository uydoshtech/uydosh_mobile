import Flutter
import QuartzCore
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
  let floorPlan: FloorPlanTabStrings
  let compassOrientation: CompassOrientationEditStrings
  let sunSimulation: SunSimulationStrings

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
    onFloorObjectTint: UIColor,
    floorPlan: FloorPlanTabStrings,
    compassOrientation: CompassOrientationEditStrings,
    sunSimulation: SunSimulationStrings
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
    self.floorPlan = floorPlan
    self.compassOrientation = compassOrientation
    self.sunSimulation = sunSimulation
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
      viewModeA11yHint: dict["viewModeHint"] ?? "Switch between full room, floor with furniture, and floor only.",
      materialsStyleA11yLabel: dict["materialsStyleLabel"] ?? "Materials style",
      materialsStyleA11yHint: dict["materialsStyleHint"] ?? "Toggle between real materials and stylized colors.",
      materialsStyleValueStylized: dict["materialsStylizedValue"] ?? "Stylized",
      materialsStyleValueReal: dict["materialsRealValue"] ?? "Real",
      brandMarkA11yLabel: dict["brandMarkA11yLabel"] ?? "UyDosh",
      onFloorObjectTint: Self.uiColorFromRgbHex6(dict["onFloorTintRgb"] ?? "795548"),
      floorPlan: FloorPlanTabStrings(dict: dict) ?? .englishFallback,
      compassOrientation: CompassOrientationEditStrings(dict: dict) ?? .englishFallback,
      sunSimulation: SunSimulationStrings(dict: dict) ?? .englishFallback
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
    viewModeA11yHint: "Switch between full room, floor with furniture, and floor only.",
    materialsStyleA11yLabel: "Materials style",
    materialsStyleA11yHint: "Toggle between real materials and stylized colors.",
    materialsStyleValueStylized: "Stylized",
    materialsStyleValueReal: "Real",
    brandMarkA11yLabel: "UyDosh",
    onFloorObjectTint: Self.uiColorFromRgbHex6("795548"),
    floorPlan: .englishFallback,
    compassOrientation: .englishFallback,
    sunSimulation: .englishFallback
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
  private let worldPlusXTrueBearingDeg: Double?
  private let isListingOwner: Bool
  private var committedNorthCorrectionDeg: Double
  private weak var metricsMessenger: FlutterBinaryMessenger?
  /// Completes the Flutter `presentLocalFile` future when the viewer is dismissed (not when it opens).
  private let dismissFlutterResult: OnceFlutterResult
  private var didPublishFlutterMetrics = false
  private let sceneView = SCNView()
  private static let autoRotateSecondsPerTurn: TimeInterval = 8.0
  private var isAutoRotating = true
  private var autoRotateDisplayLink: CADisplayLink?
  private var autoRotateLastTimestamp: CFTimeInterval = 0
  /// While the model auto-rotates with the sun enabled, loop the real sun through a full day so the
  /// sky cycles dusk → night → dawn → day → dusk. Local minutes of day [0, 1440); starts at dusk.
  private static let sunCycleSeconds: TimeInterval = 88.0
  private static let sunCycleStartMinute: Double = 18 * 60
  private var sunSweepMinute: Double = sunCycleStartMinute
  /// True solar elevation last applied by the sweep; drives the night fast-forward so the cycle
  /// speeds through darkness and slows back to normal across twilight. Updated each `applySunSweep`.
  private var sunSweepElevationDeg: Double = 0
  /// Cached so the per-frame sweep doesn't allocate a Calendar every tick.
  private lazy var sunSweepCalendar: Calendar = {
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = SolarPosition.tashkentTimeZone
    return cal
  }()
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
  private let zoomSlider = UISlider()
  private let zoomMinIcon = UIImageView()
  private let zoomMaxIcon = UIImageView()
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
    /// Walls/structure removed, keep floor + furniture.
    case floorAndFurniture = 1
    /// Furniture removed too — floor only.
    case floorOnly = 2
  }

  private var displayMode: DisplayMode = .fullRoom
  /// Single cycling button (was a 3-segment control): tap advances
  /// full room → floor + furniture → floor only → full room, swapping its icon.
  private let modeButton = UIButton(type: .system)
  private let useStylizedMaterials = true
  /// Bottom-centered “glassy” bar: view mode picker (matches zoom panel styling).
  private let modeMaterialsToolbarContainer = UIView()
  private let modeMaterialsToolbarPanel = UIView()
  private let modeMaterialsStack = UIStackView()
  private var sceneWorldBounds: (min: SCNVector3, max: SCNVector3)?
  private var footprintMetrics: RoomScanMetricsResult?
  private var isOrthographicPlanView = false
  private var savedPerspectiveOrbitYaw: Float = 0
  private var savedPerspectiveOrbitPitch: Float = 0
  private var savedPerspectiveOrbitRadius: Float = 1
  private var savedPerspectiveFov: CGFloat = 60
  private var planOrthographicScale: CGFloat = 1
  private var pinchBaseOrthoScale: CGFloat = 1
  private weak var debugOverlayNode: SCNNode?
  private var didCacheOriginalMaterials = false
  private var originalMaterialsByGeometry = [ObjectIdentifier: [SCNMaterial]]()
  /// Initial zoom-in steps on open are expressed as a FOV delta from the padded fit.
  private static let zoomFovStepDegrees: CGFloat = 7.2
  /// Zoom slider maps its 0…1 range onto this perspective field-of-view window
  /// (smaller FOV = more zoomed in). Mirrors the clamp inside `setZoom`.
  private static let zoomFovMinDegrees: CGFloat = 28
  private static let zoomFovMaxDegrees: CGFloat = 82
  /// Orthographic plan view maps the same slider onto this scale window (log-spaced;
  /// smaller scale = more zoomed in). Mirrors the clamp inside `orbitPinch`.
  private static let zoomOrthoScaleMin: CGFloat = 0.5
  private static let zoomOrthoScaleMax: CGFloat = 80
  /// Pill-shaped zoom bar; large enough to read softer than the old 14pt radius.
  private static let zoomControlsPanelCornerRadius: CGFloat = 28
  private static let zoomButtonSize: CGFloat = 38
  private static let zoomButtonCornerRadius: CGFloat = 19
  /// Matches zoom +/- row and segmented + materials row so both bottom pills share one height.
  private static let bottomToolbarPanelInset: CGFloat = 12
  /// How many zoom-in steps to apply on open (model appears larger; same camera distance as padded fit).
  private static let initialZoomInSteps: Int = 2
  /// Manual orbit: translation (points) → angle delta, per `changed` callback.
  private static let orbitPanSensitivity: Float = 0.012
  /// `velocity` (points/s) → angular velocity (rad/s); tuned for natural coast-down vs [orbitPanSensitivity].
  private static let orbitVelocityScale: Float = 0.00011
  /// Exponential damping of angular velocity (higher = stops sooner).
  private static let orbitDecelDampingPerSec: Float = 3.8
  private static let orbitDecelStopThreshold: Float = 0.001

  private var orbitDecelDisplayLink: CADisplayLink?
  private var orbitDecelLastTimestamp: CFTimeInterval = 0
  private var orbitYawVel: Float = 0
  private var orbitPitchVel: Float = 0

  private enum ViewerTab: Int {
    case threeD = 0
    case floorPlan = 1
  }

  private var viewerTab: ViewerTab = .threeD
  private let viewerTabContainer = UIView()
  private let viewerTabSelection = UIView()
  private var viewerTabItems: [(button: UIButton, icon: UIImageView, label: UILabel)] = []
  private var floorPlanTabView: FloorPlanTab?
  private var floorPlanStateManager = FloorPlanStateManager()
  private var dimensionEditController: DimensionEditController?
  private let northOrientationPanel: CompassOrientationAdjustPanel
  private var northPanelTopConstraint: NSLayoutConstraint?
  private var northPanelCommittedCorrection: Double = 0
  private var isNorthPanelExpanded: Bool { !northOrientationPanel.isHidden }
  private var dimensionEditStrings: DimensionEditDialogStrings = .englishFallback
  private let sunSimulationController = SunSimulationController()
  private let sunToggleButton = UIButton(type: .system)
  private let sunSimulationPanel: SunSimulationPanel
  private let sunCompassOverlay = SunCompassOverlayView()
  private let sunClockOverlay = SunClockOverlayView()
  /// Sun timeline starts expanded so the day/night control is visible as soon as the scene opens.
  private var isSunPanelExpanded = true

  fileprivate init(
    fileURL: URL,
    strings: RoomViewerStrings,
    listingId: Int = 0,
    publishMetricsIfMissing: Bool = false,
    worldPlusXTrueBearingDeg: Double? = nil,
    northCorrectionDeg: Double = 0,
    isListingOwner: Bool = false,
    metricsMessenger: FlutterBinaryMessenger? = nil,
    dismissFlutterResult: OnceFlutterResult
  ) {
    self.fileURL = fileURL
    self.strings = strings
    self.listingId = listingId
    self.publishMetricsIfMissing = publishMetricsIfMissing
    self.worldPlusXTrueBearingDeg = worldPlusXTrueBearingDeg
    self.isListingOwner = isListingOwner
    self.committedNorthCorrectionDeg = northCorrectionDeg
    self.metricsMessenger = metricsMessenger
    self.dismissFlutterResult = dismissFlutterResult
    sunSimulationPanel = SunSimulationPanel(strings: strings.sunSimulation)
    northOrientationPanel = CompassOrientationAdjustPanel(strings: strings.compassOrientation)
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = RoomSceneAppearance.skyBackgroundColor

    navigationItem.leftBarButtonItem = nil
    navigationItem.rightBarButtonItem = makeCloseBarButtonItem()
    setupModeControl()
    setupViewerTabControl()

    sceneView.translatesAutoresizingMaskIntoConstraints = false
    sceneView.backgroundColor = RoomSceneAppearance.skyBackgroundColor
    // Start in "presentation" mode: camera auto-orbits the model center until the user interacts.
    sceneView.allowsCameraControl = false
    sceneView.antialiasingMode = .multisampling4X
    sceneView.autoenablesDefaultLighting = false
    view.addSubview(sceneView)

    let floorPlanTab = FloorPlanTab(strings: strings.floorPlan)
    floorPlanTab.translatesAutoresizingMaskIntoConstraints = false
    floorPlanTab.isHidden = true
    floorPlanTab.isUserInteractionEnabled = false
    floorPlanTab.canvas.delegate = self
    view.addSubview(floorPlanTab)
    floorPlanTabView = floorPlanTab
    floorPlanStateManager.objectLabels = strings.floorPlan.objectLabels

    dimensionEditStrings = strings.floorPlan.dimensionEditDialogStrings
    dimensionEditController = DimensionEditController(
      stateManager: floorPlanStateManager,
      strings: dimensionEditStrings
    )
    floorPlanStateManager.onDisplayModelUpdated = { [weak self] displayModel in
      guard let self else { return }
      self.floorPlanTabView?.setDisplayModel(displayModel)
      self.floorPlanTabView?.updateSunAzimuth(self.sunSimulationController.azimuthDeg)
    }
    floorPlanStateManager.onRequires3DRegeneration = { [weak self] editableModel in
      self?.regenerateSceneFromEditableModel(editableModel)
    }
    floorPlanTab.onAdjustNorthTapped = { [weak self] in
      self?.toggleNorthCorrectionPanel()
    }
    updateNorthAdjustButtonVisibility()

    let tap = UITapGestureRecognizer(target: self, action: #selector(sceneTapped))
    tap.cancelsTouchesInView = false
    sceneView.addGestureRecognizer(tap)
    introTapGesture = tap

    setupZoomControls()
    setupSunControls()

    hintContainer.translatesAutoresizingMaskIntoConstraints = false
    // Opaque panel only once dimensions are known (avoids an empty strip while labels are hidden).
    hintContainer.backgroundColor = .clear
    hintContainer.layer.cornerRadius = 12
    if #available(iOS 13.0, *) {
      hintContainer.layer.cornerCurve = .continuous
    }
    hintContainer.clipsToBounds = true
    hintContainer.isUserInteractionEnabled = false

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
    // Leading-align every row to the widest line; `.center` offset each row
    // horizontally by half its slack, so icons/labels zig-zagged across rows.
    dimensionsLineStack.alignment = .fill
    dimensionsLineStack.addArrangedSubview(row1)
    dimensionsLineStack.addArrangedSubview(rowHeight)
    dimensionsLineStack.addArrangedSubview(row2)
    dimensionsLineStack.isHidden = true
    dimensionsLineStack.isAccessibilityElement = true
    dimensionsLineStack.accessibilityTraits = .staticText

    hintStack.translatesAutoresizingMaskIntoConstraints = false
    hintStack.axis = .vertical
    hintStack.alignment = .leading
    hintStack.spacing = 4
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

    setupModeMaterialsToolbar()

    // Keep interactive overlays above SceneKit and the full-screen plan tab (3D mode).
    bringInteractiveOverlaysToFront()

    let modeMaterialsToolbarPlacement: [NSLayoutConstraint] = {
      let modeCenterX = modeMaterialsToolbarContainer.centerXAnchor.constraint(
        equalTo: view.safeAreaLayoutGuide.centerXAnchor
      )
      modeCenterX.priority = UILayoutPriority(750)
      return [
        modeCenterX,
        modeMaterialsToolbarContainer.leadingAnchor.constraint(
          greaterThanOrEqualTo: zoomControlsContainer.trailingAnchor,
          constant: 8
        ),
        modeMaterialsToolbarContainer.trailingAnchor.constraint(
          lessThanOrEqualTo: brandMarkView.leadingAnchor,
          constant: -8
        ),
        modeMaterialsToolbarContainer.bottomAnchor.constraint(
          equalTo: view.safeAreaLayoutGuide.bottomAnchor,
          constant: -22
        ),
      ]
    }()

    NSLayoutConstraint.activate(
      [
        northOrientationPanel.leadingAnchor.constraint(
          equalTo: view.safeAreaLayoutGuide.leadingAnchor,
          constant: 16
        ),
        northOrientationPanel.trailingAnchor.constraint(
          equalTo: view.safeAreaLayoutGuide.trailingAnchor,
          constant: -16
        ),

        sceneView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
        sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        sceneView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),

        floorPlanTab.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
        floorPlanTab.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        floorPlanTab.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        floorPlanTab.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),

        hintStack.topAnchor.constraint(equalTo: hintContainer.topAnchor, constant: 8),
        hintStack.leadingAnchor.constraint(equalTo: hintContainer.leadingAnchor, constant: 14),
        hintStack.trailingAnchor.constraint(equalTo: hintContainer.trailingAnchor, constant: -14),
        hintStack.bottomAnchor.constraint(equalTo: hintContainer.bottomAnchor, constant: -8),

        hintContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
        hintContainer.trailingAnchor.constraint(equalTo: hintStack.trailingAnchor, constant: 14),
        hintContainer.trailingAnchor.constraint(
          lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor,
          constant: -16
        ),
        hintContainer.widthAnchor.constraint(
          lessThanOrEqualTo: view.safeAreaLayoutGuide.widthAnchor,
          constant: -32
        ),
        hintContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 2),

        sunCompassOverlay.topAnchor.constraint(equalTo: hintContainer.topAnchor),
        sunCompassOverlay.heightAnchor.constraint(equalToConstant: 88),
        sunCompassOverlay.widthAnchor.constraint(equalToConstant: 88),
        sunCompassOverlay.leadingAnchor.constraint(equalTo: hintContainer.trailingAnchor, constant: 6),

        // Analog day-clock sits to the right of the compass rose.
        sunClockOverlay.topAnchor.constraint(equalTo: sunCompassOverlay.topAnchor),
        sunClockOverlay.heightAnchor.constraint(equalToConstant: 88),
        sunClockOverlay.widthAnchor.constraint(equalToConstant: 88),
        sunClockOverlay.leadingAnchor.constraint(equalTo: sunCompassOverlay.trailingAnchor, constant: 6),
        sunClockOverlay.trailingAnchor.constraint(
          lessThanOrEqualTo: view.safeAreaLayoutGuide.trailingAnchor,
          constant: -16
        ),

        // Brand mark moved to bottom-trailing (was bottom-leading); zoom
        // controls take over the bottom-leading slot below.
        brandMarkView.trailingAnchor.constraint(equalTo: sceneView.trailingAnchor, constant: -12),
        brandMarkView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -22),
        brandMarkView.widthAnchor.constraint(equalToConstant: 62),
        brandMarkView.heightAnchor.constraint(equalToConstant: 62),

        zoomControlsContainer.leadingAnchor.constraint(equalTo: sceneView.leadingAnchor, constant: 12),
        zoomControlsContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -22),

        sunSimulationPanel.leadingAnchor.constraint(equalTo: sceneView.leadingAnchor, constant: 12),
        // Stretch across the viewport so the 24-hour timeline has room to breathe.
        sunSimulationPanel.trailingAnchor.constraint(equalTo: sceneView.trailingAnchor, constant: -12),
        sunSimulationPanel.bottomAnchor.constraint(
          equalTo: modeMaterialsToolbarContainer.topAnchor,
          constant: -10
        ),
      ]
        + modeMaterialsToolbarPlacement
    )
    updateNorthPanelTopAnchor()

    // Pan / pinch from launch so a drag or pinch ends intro auto-rotation (tap-only was too limiting).
    installManualOrbitGestures()
    sceneView.isMultipleTouchEnabled = true
    if let tap = introTapGesture, let pan = orbitPanGesture {
      tap.require(toFail: pan)
    }

    loadScene()
    playBrandMarkEntranceAnimation()
  }

  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    // CADisplayLink retains its target, so it must be invalidated here — otherwise dismissing via
    // swipe or host teardown (anything other than the in-app close button) leaks the controller.
    removeAutoRotateAnimation()
    stopOrbitDeceleration()
    isAutoRotating = false
  }

  override func viewDidLayoutSubviews() {
    super.viewDidLayoutSubviews()
    updateViewerTabSelection(animated: false)
    if isNorthPanelExpanded {
      updateNorthPanelTopAnchor()
    }
    if viewerTab == .threeD || isNorthPanelExpanded {
      bringInteractiveOverlaysToFront()
    }
    refreshZoomControlsNeumorphicShadowPaths()
    refreshModeMaterialsToolbarShadowPaths()
    // Cap line width so large content sizes / long values wrap instead of stretching the panel.
    let panelMaxWidth = max(0, view.bounds.width - 32 - 28)
    let stackWidth = hintStack.bounds.width
    let lineWrapWidth: CGFloat
    if stackWidth > 0 {
      lineWrapWidth = min(stackWidth - 20 - 8, panelMaxWidth - 20 - 8)
    } else {
      lineWrapWidth = panelMaxWidth - 20 - 8
    }
    guard lineWrapWidth > 0 else { return }
    dimensionsLine1Label.preferredMaxLayoutWidth = lineWrapWidth
    dimensionsHeightLabel.preferredMaxLayoutWidth = lineWrapWidth
    dimensionsLine2Label.preferredMaxLayoutWidth = lineWrapWidth
    if isOrthographicPlanView {
      applyTopDownPlanCamera(animated: false)
    }
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
    zoomStack.spacing = 10

    let iconConfig = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
    let iconTint = UIColor.white.withAlphaComponent(0.7)
    zoomMinIcon.image = UIImage(systemName: "minus.magnifyingglass", withConfiguration: iconConfig)
    zoomMaxIcon.image = UIImage(systemName: "plus.magnifyingglass", withConfiguration: iconConfig)
    for icon in [zoomMinIcon, zoomMaxIcon] {
      icon.translatesAutoresizingMaskIntoConstraints = false
      icon.tintColor = iconTint
      icon.contentMode = .scaleAspectFit
      icon.setContentHuggingPriority(.required, for: .horizontal)
      icon.setContentCompressionResistancePriority(.required, for: .horizontal)
    }

    // Slider value 0 = fully zoomed out, 1 = fully zoomed in (handle moves right to enlarge).
    zoomSlider.translatesAutoresizingMaskIntoConstraints = false
    zoomSlider.minimumValue = 0
    zoomSlider.maximumValue = 1
    zoomSlider.value = 0.5
    zoomSlider.isContinuous = true
    zoomSlider.minimumTrackTintColor = UIColor.white.withAlphaComponent(0.92)
    zoomSlider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.22)
    zoomSlider.thumbTintColor = .white
    zoomSlider.accessibilityLabel = strings.zoomInA11yLabel
    zoomSlider.addTarget(self, action: #selector(zoomSliderChanged(_:)), for: .valueChanged)

    zoomStack.addArrangedSubview(zoomMinIcon)
    zoomStack.addArrangedSubview(zoomSlider)
    zoomStack.addArrangedSubview(zoomMaxIcon)
    zoomControlsPanel.addSubview(zoomStack)

    NSLayoutConstraint.activate([
      zoomStack.topAnchor.constraint(equalTo: zoomControlsPanel.topAnchor, constant: Self.bottomToolbarPanelInset),
      zoomStack.leadingAnchor.constraint(equalTo: zoomControlsPanel.leadingAnchor, constant: Self.bottomToolbarPanelInset),
      zoomStack.trailingAnchor.constraint(equalTo: zoomControlsPanel.trailingAnchor, constant: -Self.bottomToolbarPanelInset),
      zoomStack.bottomAnchor.constraint(equalTo: zoomControlsPanel.bottomAnchor, constant: -Self.bottomToolbarPanelInset),
      zoomStack.heightAnchor.constraint(equalToConstant: Self.zoomButtonSize),
      zoomSlider.widthAnchor.constraint(equalToConstant: 150),
    ])
  }

  private func setupSunControls() {
    let sunStrings = strings.sunSimulation
    let iconCfg = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
    sunToggleButton.translatesAutoresizingMaskIntoConstraints = false
    sunToggleButton.setPreferredSymbolConfiguration(iconCfg, forImageIn: .normal)
    sunToggleButton.setImage(UIImage(systemName: "sun.max.fill"), for: .normal)
    sunToggleButton.tintColor = UIColor(red: 1, green: 0.82, blue: 0.35, alpha: 1)
    sunToggleButton.backgroundColor = UIColor(red: 0.22, green: 0.22, blue: 0.26, alpha: 1)
    sunToggleButton.layer.cornerRadius = Self.zoomButtonCornerRadius
    if #available(iOS 13.0, *) {
      sunToggleButton.layer.cornerCurve = .continuous
    }
    sunToggleButton.accessibilityLabel = sunStrings.toggleA11yLabel
    sunToggleButton.accessibilityHint = sunStrings.toggleA11yHint
    sunToggleButton.addTarget(self, action: #selector(sunToggleTapped), for: .touchUpInside)
    NSLayoutConstraint.activate([
      sunToggleButton.heightAnchor.constraint(equalToConstant: Self.zoomButtonSize),
      sunToggleButton.widthAnchor.constraint(equalToConstant: Self.zoomButtonSize),
    ])

    sunSimulationPanel.delegate = self
    sunSimulationPanel.translatesAutoresizingMaskIntoConstraints = false
    // Expanded by default (only collapsed when the user switches to the 2D plan tab).
    sunSimulationPanel.isHidden = !isSunPanelExpanded
    view.addSubview(sunSimulationPanel)
    updateSunToggleAppearance()

    sunSimulationController.onSunPositionChanged = { [weak self] azimuth, elevation in
      self?.updateSceneSkyBackground(azimuthDeg: azimuth, elevationDeg: elevation)
    }

    sunCompassOverlay.translatesAutoresizingMaskIntoConstraints = false
    sunCompassOverlay.usesTrueNorth = worldPlusXTrueBearingDeg != nil
    sunCompassOverlay.isAccessibilityElement = true
    sunCompassOverlay.accessibilityLabel = strings.compassOrientation.title
    sunCompassOverlay.addTarget(self, action: #selector(compassOverlayTapped), for: .touchUpInside)
    view.addSubview(sunCompassOverlay)

    sunClockOverlay.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(sunClockOverlay)
    // Prime the clock with the timeline's current (real-now) time so it reads correctly before
    // the sun is ever animated.
    sunClockOverlay.update(
      minuteOfDay: sunSimulationPanel.currentTimelineMinute,
      sunriseMinute: sunSimulationPanel.daylightSunriseMinute,
      sunsetMinute: sunSimulationPanel.daylightSunsetMinute
    )

    northOrientationPanel.translatesAutoresizingMaskIntoConstraints = false
    northOrientationPanel.isHidden = true
    northOrientationPanel.delegate = self
    view.addSubview(northOrientationPanel)

    refreshSunCompassLabels()
    updateNorthAdjustButtonVisibility()
  }

  @objc private func compassOverlayTapped() {
    guard sunCompassOverlay.acceptsOrientationTaps else { return }
    toggleNorthCorrectionPanel()
  }

  @objc private func sunToggleTapped() {
    isSunPanelExpanded.toggle()
    sunSimulationPanel.isHidden = !isSunPanelExpanded
    if isSunPanelExpanded, loadedScene != nil, sunSimulationController.isEnabled == false {
      attachSunSimulationIfNeeded()
    }
    // If the opening cinematic is still running, show it as playing right away rather than waiting
    // for the next sweep frame to flip the button.
    if isSunPanelExpanded {
      sunSimulationPanel.setExternalPlayback(active: isAutoRotating)
    }
    updateSunToggleAppearance()
  }

  private func updateSunToggleAppearance() {
    let active = isSunPanelExpanded
    sunToggleButton.layer.borderWidth = active ? 1.5 : 0.5
    sunToggleButton.layer.borderColor = (
      active
        ? UIColor(red: 1, green: 0.78, blue: 0.35, alpha: 0.9)
        : UIColor.white.withAlphaComponent(0.1)
    ).cgColor
  }

  private func attachSunSimulationIfNeeded() {
    guard let scene = loadedScene, let bounds = sceneWorldBounds else { return }
    let bearing = resolvedScanBearingDeg()
    let eastRad = floorPlanStateManager.editableModel?.worldEastPlanAngleRad ?? 0
    sunSimulationController.attach(
      to: scene,
      roomCenter: orbitTarget,
      sceneBounds: bounds,
      worldEastPlanAngleRad: eastRad,
      scanWorldPlusXBearingDeg: bearing,
      northCorrectionDeg: floorPlanStateManager.northCorrectionDeg
    )
    sunSimulationPanel.setAzimuth(sunSimulationController.azimuthDeg)
    sunSimulationPanel.setElevation(sunSimulationController.elevationDeg)
    sunSimulationPanel.setIntensity(sunSimulationController.lightIntensity)
    refreshSunCompassLabels()
    sceneView.autoenablesDefaultLighting = false
    updateSceneSkyBackground(
      azimuthDeg: sunSimulationController.azimuthDeg,
      elevationDeg: sunSimulationController.elevationDeg
    )
  }

  private func updateSceneSkyBackground(azimuthDeg: Float, elevationDeg: Float) {
    let color = RoomSceneAppearance.skyBackgroundColor(
      azimuthDeg: azimuthDeg,
      elevationDeg: elevationDeg
    )
    sceneView.backgroundColor = color
    view.backgroundColor = color
  }

  private func resolvedScanBearingDeg() -> Double? {
    worldPlusXTrueBearingDeg
      ?? RoomScanOrientationCapture.readSidecar(forUsdzPath: fileURL.path)
  }

  private func refreshSunOrientationContext() {
    let bearing = resolvedScanBearingDeg()
    let eastRad = floorPlanStateManager.editableModel?.worldEastPlanAngleRad ?? 0
    sunCompassOverlay.usesTrueNorth = bearing != nil
    sunSimulationController.setOrientationContext(
      worldEastPlanAngleRad: eastRad,
      scanWorldPlusXBearingDeg: bearing,
      northCorrectionDeg: floorPlanStateManager.northCorrectionDeg
    )
    refreshSunCompassLabels()
  }

  private func refreshSunCompassLabels() {
    let northAngle = computeNorthScreenAngleRad()
    sunCompassOverlay.update(
      azimuthDeg: sunSimulationController.azimuthDeg,
      elevationDeg: sunSimulationController.elevationDeg,
      azimuthFormat: strings.sunSimulation.azimuthFormat,
      elevationFormat: strings.sunSimulation.elevationFormat,
      northScreenAngleRad: northAngle
    )
    floorPlanTabView?.updateSunAzimuth(sunSimulationController.azimuthDeg)
  }

  private func resolvedTrueNorthPlanAngleRad() -> Double {
    if let model = floorPlanStateManager.editableModel,
      let trueNorth = model.trueNorthPlanAngleRad
    {
      return trueNorth
    }
    let eastRad = floorPlanStateManager.editableModel?.worldEastPlanAngleRad ?? 0
    return FloorPlanNorthOrientation.trueNorthPlanAngleRad(
      worldEastPlanAngleRad: eastRad,
      scanBearing: resolvedScanBearingDeg(),
      correctionDeg: floorPlanStateManager.northCorrectionDeg
    )
  }

  private func computeNorthScreenAngleRad() -> CGFloat? {
    guard viewerTab == .threeD, !isOrthographicPlanView else { return nil }
    // `projectPoint` asserts ("scene failed. Null argument") once the scene is torn down, so never
    // call it after dismissal has nil'd it out.
    guard sceneView.scene != nil else { return nil }
    return CompassScreenProjection.northScreenAngleRad(
      sceneView: sceneView,
      roomCenter: orbitTarget,
      trueNorthPlanAngleRad: resolvedTrueNorthPlanAngleRad()
    )
  }

  private func refreshZoomControlsNeumorphicShadowPaths() {
    let panelR = Self.zoomControlsPanelCornerRadius
    let outer = zoomControlsContainer.bounds
    guard outer.width > 1, outer.height > 1 else { return }
    zoomControlsContainer.layer.shadowPath =
      UIBezierPath(roundedRect: outer, cornerRadius: panelR).cgPath
  }

  private func setZoom(fovDegrees: CGFloat, animated: Bool) {
    guard let cam = sceneView.pointOfView?.camera else { return }
    if isOrthographicPlanView {
      let next = max(0.5, planOrthographicScale * (60 / max(28, min(82, fovDegrees))))
      planOrthographicScale = next
      if animated {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.12
        cam.orthographicScale = Double(next)
        SCNTransaction.commit()
      } else {
        cam.orthographicScale = Double(next)
      }
      return
    }
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

  @objc private func zoomSliderChanged(_ slider: UISlider) {
    endIntroCinematic(reflectOnPanel: true)
    applyZoomFraction(CGFloat(slider.value), animated: false)
  }

  /// Maps a 0…1 fraction (0 = zoomed out, 1 = zoomed in) onto the live camera.
  private func applyZoomFraction(_ fraction: CGFloat, animated: Bool) {
    guard let cam = sceneView.pointOfView?.camera else { return }
    let t = max(0, min(1, fraction))
    if isOrthographicPlanView {
      let lnMax = log(Self.zoomOrthoScaleMax)
      let lnMin = log(Self.zoomOrthoScaleMin)
      let scale = exp(lnMax + t * (lnMin - lnMax))
      planOrthographicScale = scale
      pinchBaseOrthoScale = scale
      if animated {
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.12
        cam.orthographicScale = Double(scale)
        SCNTransaction.commit()
      } else {
        cam.orthographicScale = Double(scale)
      }
      return
    }
    let fov = Self.zoomFovMaxDegrees - t * (Self.zoomFovMaxDegrees - Self.zoomFovMinDegrees)
    pinchBaseFov = fov
    setZoom(fovDegrees: fov, animated: animated)
  }

  /// Reflects the camera's current zoom back onto the slider handle (after pinch,
  /// initial framing, or a projection change) without retriggering `valueChanged`.
  private func syncZoomSliderToCamera() {
    guard let cam = sceneView.pointOfView?.camera else { return }
    let t: CGFloat
    if isOrthographicPlanView {
      let lnMax = log(Self.zoomOrthoScaleMax)
      let lnMin = log(Self.zoomOrthoScaleMin)
      let clamped = max(Self.zoomOrthoScaleMin, min(Self.zoomOrthoScaleMax, CGFloat(cam.orthographicScale)))
      t = (log(clamped) - lnMax) / (lnMin - lnMax)
    } else {
      let fov = max(Self.zoomFovMinDegrees, min(Self.zoomFovMaxDegrees, cam.fieldOfView))
      t = (Self.zoomFovMaxDegrees - fov) / (Self.zoomFovMaxDegrees - Self.zoomFovMinDegrees)
    }
    zoomSlider.setValue(Float(max(0, min(1, t))), animated: false)
  }

  // Custom pill switch (instead of UISegmentedControl). A UISegmentedControl
  // hosted in the nav-bar titleView drops baked icon+label images on some iOS
  // versions/themes, so we draw a sliding-thumb switch with plain views.
  private func setupViewerTabControl() {
    viewerTabContainer.translatesAutoresizingMaskIntoConstraints = false
    viewerTabContainer.backgroundColor = UIColor(red: 0.14, green: 0.14, blue: 0.16, alpha: 1)
    viewerTabContainer.layer.cornerRadius = 16
    viewerTabContainer.clipsToBounds = true
    if #available(iOS 13.0, *) {
      viewerTabContainer.layer.cornerCurve = .continuous
      viewerTabContainer.overrideUserInterfaceStyle = .dark
    }

    viewerTabSelection.backgroundColor = UIColor(red: 0.33, green: 0.33, blue: 0.36, alpha: 1)
    viewerTabSelection.layer.cornerRadius = 13
    viewerTabSelection.isUserInteractionEnabled = false
    if #available(iOS 13.0, *) {
      viewerTabSelection.layer.cornerCurve = .continuous
    }
    viewerTabContainer.addSubview(viewerTabSelection)

    let iconCfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold)
    func symbol(_ names: [String]) -> UIImage? {
      for name in names {
        if let image = UIImage(systemName: name, withConfiguration: iconCfg) {
          return image.withRenderingMode(.alwaysTemplate)
        }
      }
      return nil
    }
    let threeDIcon = symbol(["rotate.3d", "cube.transparent", "cube.fill", "cube"])
    let planIcon = symbol(["map.fill", "square.split.bottomrightquarter.fill", "square.grid.2x2.fill"])

    let configs: [(icon: UIImage?, title: String, tag: Int)] = [
      (threeDIcon, strings.floorPlan.tab3DView, ViewerTab.threeD.rawValue),
      (planIcon, strings.floorPlan.tabFloorPlan, ViewerTab.floorPlan.rawValue),
    ]

    let stack = UIStackView()
    stack.axis = .horizontal
    stack.distribution = .fillEqually
    stack.translatesAutoresizingMaskIntoConstraints = false

    for config in configs {
      let item = makeViewerTabButton(icon: config.icon, title: config.title)
      item.button.tag = config.tag
      item.button.addTarget(self, action: #selector(viewerTabButtonTapped(_:)), for: .touchUpInside)
      stack.addArrangedSubview(item.button)
      viewerTabItems.append(item)
    }

    viewerTabContainer.addSubview(stack)
    NSLayoutConstraint.activate([
      viewerTabContainer.heightAnchor.constraint(equalToConstant: 36),
      viewerTabContainer.widthAnchor.constraint(equalToConstant: 176),
      stack.topAnchor.constraint(equalTo: viewerTabContainer.topAnchor),
      stack.bottomAnchor.constraint(equalTo: viewerTabContainer.bottomAnchor),
      stack.leadingAnchor.constraint(equalTo: viewerTabContainer.leadingAnchor),
      stack.trailingAnchor.constraint(equalTo: viewerTabContainer.trailingAnchor),
    ])

    viewerTabContainer.accessibilityLabel = "\(strings.floorPlan.tab3DView), \(strings.floorPlan.tabFloorPlan)"

    navigationItem.titleView = viewerTabContainer
    viewerTabContainer.frame = CGRect(x: 0, y: 0, width: 176, height: 36)
    viewerTabContainer.layoutIfNeeded()
    updateViewerTabSelection(animated: false)
    updateViewerTabAccessibility()
  }

  private func makeViewerTabButton(
    icon: UIImage?,
    title: String
  ) -> (button: UIButton, icon: UIImageView, label: UILabel) {
    let button = UIButton(type: .custom)
    button.backgroundColor = .clear

    let iconView = UIImageView(image: icon)
    iconView.contentMode = .scaleAspectFit
    iconView.setContentHuggingPriority(.required, for: .horizontal)

    let label = UILabel()
    label.text = title
    label.font = .systemFont(ofSize: 13, weight: .semibold)

    let row = UIStackView(arrangedSubviews: [iconView, label])
    row.axis = .horizontal
    row.spacing = 5
    row.alignment = .center
    row.isUserInteractionEnabled = false
    row.translatesAutoresizingMaskIntoConstraints = false
    button.addSubview(row)

    NSLayoutConstraint.activate([
      row.centerXAnchor.constraint(equalTo: button.centerXAnchor),
      row.centerYAnchor.constraint(equalTo: button.centerYAnchor),
      iconView.widthAnchor.constraint(equalToConstant: 15),
      iconView.heightAnchor.constraint(equalToConstant: 15),
    ])

    return (button, iconView, label)
  }

  /// Slides the selection thumb behind the active tab and updates icon/label emphasis.
  private func updateViewerTabSelection(animated: Bool) {
    guard viewerTab.rawValue < viewerTabItems.count else { return }
    for (index, item) in viewerTabItems.enumerated() {
      let selected = index == viewerTab.rawValue
      let alpha: CGFloat = selected ? 0.95 : 0.5
      item.icon.tintColor = UIColor.white.withAlphaComponent(alpha)
      item.label.textColor = UIColor.white.withAlphaComponent(alpha)
    }
    viewerTabContainer.layoutIfNeeded()
    let targetFrame = viewerTabItems[viewerTab.rawValue].button.frame.insetBy(dx: 3, dy: 3)
    guard !targetFrame.isNull, targetFrame.width > 0 else { return }
    let apply = { self.viewerTabSelection.frame = targetFrame }
    if animated {
      UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseInOut], animations: apply)
    } else {
      apply()
    }
  }

  @objc private func viewerTabButtonTapped(_ sender: UIButton) {
    let next = ViewerTab(rawValue: sender.tag) ?? .threeD
    guard next != viewerTab else { return }
    viewerTab = next
    updateViewerTabSelection(animated: true)
    updateViewerTabAccessibility()
    applyViewerTab(next, animated: true)
  }

  private func updateViewerTabAccessibility() {
    viewerTabContainer.accessibilityValue = viewerTab == .threeD
      ? strings.floorPlan.tab3DView
      : strings.floorPlan.tabFloorPlan
  }

  private func applyViewerTab(_ tab: ViewerTab, animated: Bool) {
    let show3D = tab == .threeD
    let updates = {
      self.sceneView.isHidden = !show3D
      self.floorPlanTabView?.isHidden = show3D
      self.floorPlanTabView?.isUserInteractionEnabled = !show3D
      self.zoomControlsContainer.isHidden = !show3D
      self.modeMaterialsToolbarContainer.isHidden = !show3D
      self.brandMarkView.isHidden = !show3D
      self.hintContainer.isHidden = !show3D || self.dimensionsLineStack.isHidden
      self.sunToggleButton.isHidden = !show3D
      self.sunCompassOverlay.isHidden = !show3D
      self.sunClockOverlay.isHidden = !show3D
      if !show3D {
        self.sunSimulationPanel.isHidden = true
      } else {
        self.sunSimulationPanel.isHidden = !self.isSunPanelExpanded
      }
    }
    if animated {
      UIView.transition(with: view, duration: 0.2, options: .transitionCrossDissolve, animations: updates)
    } else {
      updates()
    }
    if show3D {
      bringInteractiveOverlaysToFront()
    } else if let floorPlanTabView {
      view.bringSubviewToFront(floorPlanTabView)
      if isNorthPanelExpanded {
        updateNorthPanelTopAnchor()
        view.bringSubviewToFront(northOrientationPanel)
      }
    }
    if tab == .threeD {
      startIntroAutoRotationIfNeeded()
    } else {
      removeAutoRotateAnimation()
      isAutoRotating = false
    }
    updateNorthAdjustButtonVisibility()
  }

  /// Keeps tappable HUD controls above the full-screen floor-plan layer in 3D mode.
  private func bringInteractiveOverlaysToFront() {
    view.bringSubviewToFront(zoomControlsContainer)
    view.bringSubviewToFront(modeMaterialsToolbarContainer)
    view.bringSubviewToFront(sunSimulationPanel)
    view.bringSubviewToFront(sunCompassOverlay)
    view.bringSubviewToFront(sunClockOverlay)
    if !northOrientationPanel.isHidden {
      view.bringSubviewToFront(northOrientationPanel)
    }
  }

  private func setupModeControl() {
    modeButton.translatesAutoresizingMaskIntoConstraints = false
    modeButton.tintColor = UIColor.white.withAlphaComponent(0.92)
    modeButton.backgroundColor = UIColor(red: 0.22, green: 0.22, blue: 0.26, alpha: 1)
    modeButton.layer.cornerRadius = Self.zoomButtonCornerRadius
    if #available(iOS 13.0, *) {
      modeButton.layer.cornerCurve = .continuous
    }

    modeButton.addTarget(self, action: #selector(modeButtonTapped), for: .touchUpInside)

    modeButton.isAccessibilityElement = true
    modeButton.accessibilityLabel = strings.viewModeA11yLabel
    modeButton.accessibilityHint = strings.viewModeA11yHint

    NSLayoutConstraint.activate([
      modeButton.heightAnchor.constraint(equalToConstant: Self.zoomButtonSize),
      modeButton.widthAnchor.constraint(equalToConstant: Self.zoomButtonSize),
    ])

    updateModeButtonAppearance()
  }

  private func modeIcon(for mode: DisplayMode) -> UIImage? {
    let cfg = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
    switch mode {
    case .fullRoom:
      return UIImage(systemName: "house.fill", withConfiguration: cfg)
    case .floorAndFurniture:
      return UIImage(systemName: "bed.double.fill", withConfiguration: cfg)
        ?? UIImage(systemName: "shippingbox.fill", withConfiguration: cfg)
        ?? UIImage(systemName: "cube.box.fill", withConfiguration: cfg)
    case .floorOnly:
      return UIImage(systemName: "rectangle.fill", withConfiguration: cfg)
        ?? UIImage(systemName: "square.fill", withConfiguration: cfg)
    }
  }

  private func nextDisplayMode(after mode: DisplayMode) -> DisplayMode {
    switch mode {
    case .fullRoom: return .floorAndFurniture
    case .floorAndFurniture: return .floorOnly
    case .floorOnly: return .fullRoom
    }
  }

  /// Reflects `displayMode` onto the cycling button's icon and VoiceOver value.
  private func updateModeButtonAppearance() {
    modeButton.setImage(modeIcon(for: displayMode), for: .normal)
    switch displayMode {
    case .fullRoom:
      modeButton.accessibilityValue = "Full room"
    case .floorAndFurniture:
      modeButton.accessibilityValue = "Floor and furniture"
    case .floorOnly:
      modeButton.accessibilityValue = "Floor only"
    }
  }

  private func setupModeMaterialsToolbar() {
    modeMaterialsToolbarContainer.translatesAutoresizingMaskIntoConstraints = false
    modeMaterialsToolbarContainer.isUserInteractionEnabled = true
    modeMaterialsToolbarContainer.backgroundColor = .clear
    modeMaterialsToolbarContainer.clipsToBounds = false
    modeMaterialsToolbarContainer.layer.masksToBounds = false
    modeMaterialsToolbarContainer.layer.shadowColor = UIColor.black.cgColor
    modeMaterialsToolbarContainer.layer.shadowOpacity = 0.52
    modeMaterialsToolbarContainer.layer.shadowOffset = CGSize(width: 5, height: 7)
    modeMaterialsToolbarContainer.layer.shadowRadius = 14

    modeMaterialsToolbarPanel.translatesAutoresizingMaskIntoConstraints = false
    modeMaterialsToolbarPanel.isUserInteractionEnabled = true
    modeMaterialsToolbarPanel.backgroundColor = UIColor(red: 0.17, green: 0.17, blue: 0.19, alpha: 1)
    modeMaterialsToolbarPanel.layer.cornerRadius = Self.zoomControlsPanelCornerRadius
    if #available(iOS 13.0, *) {
      modeMaterialsToolbarPanel.layer.cornerCurve = .continuous
    }
    modeMaterialsToolbarPanel.clipsToBounds = true
    modeMaterialsToolbarPanel.layer.borderWidth = 1
    modeMaterialsToolbarPanel.layer.borderColor = UIColor.white.withAlphaComponent(0.07).cgColor

    modeMaterialsToolbarContainer.addSubview(modeMaterialsToolbarPanel)
    NSLayoutConstraint.activate([
      modeMaterialsToolbarPanel.topAnchor.constraint(equalTo: modeMaterialsToolbarContainer.topAnchor),
      modeMaterialsToolbarPanel.leadingAnchor.constraint(equalTo: modeMaterialsToolbarContainer.leadingAnchor),
      modeMaterialsToolbarPanel.trailingAnchor.constraint(equalTo: modeMaterialsToolbarContainer.trailingAnchor),
      modeMaterialsToolbarPanel.bottomAnchor.constraint(equalTo: modeMaterialsToolbarContainer.bottomAnchor),
    ])

    modeMaterialsStack.translatesAutoresizingMaskIntoConstraints = false
    modeMaterialsStack.axis = .horizontal
    modeMaterialsStack.alignment = .center
    modeMaterialsStack.spacing = 12

    modeMaterialsStack.addArrangedSubview(sunToggleButton)
    modeMaterialsStack.addArrangedSubview(modeButton)
    modeMaterialsToolbarPanel.addSubview(modeMaterialsStack)

    NSLayoutConstraint.activate([
      modeMaterialsStack.topAnchor.constraint(
        equalTo: modeMaterialsToolbarPanel.topAnchor,
        constant: Self.bottomToolbarPanelInset
      ),
      modeMaterialsStack.leadingAnchor.constraint(
        equalTo: modeMaterialsToolbarPanel.leadingAnchor,
        constant: Self.bottomToolbarPanelInset
      ),
      modeMaterialsStack.trailingAnchor.constraint(
        equalTo: modeMaterialsToolbarPanel.trailingAnchor,
        constant: -Self.bottomToolbarPanelInset
      ),
      modeMaterialsStack.bottomAnchor.constraint(
        equalTo: modeMaterialsToolbarPanel.bottomAnchor,
        constant: -Self.bottomToolbarPanelInset
      ),
    ])

    view.addSubview(modeMaterialsToolbarContainer)
  }

  private func refreshModeMaterialsToolbarShadowPaths() {
    let panelR = Self.zoomControlsPanelCornerRadius
    let outer = modeMaterialsToolbarContainer.bounds
    guard outer.width > 1, outer.height > 1 else { return }
    modeMaterialsToolbarContainer.layer.shadowPath =
      UIBezierPath(roundedRect: outer, cornerRadius: panelR).cgPath
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

  /// World-space angle (radians, in X/Z) of the longest wall in the loaded scan. Used to align the
  /// floor tile grid to the walls. Derived from the wall nodes' world transforms because the scan
  /// geometry lives in the original (possibly rotated) world space, unlike the aligned editable model.
  private func dominantWallAngleInScene() -> Float {
    guard let root = loadedScene?.rootNode else { return 0 }
    var bestWeight: Float = -1
    var bestAngle: Float = 0
    func visit(_ node: SCNNode) {
      if node.geometry != nil, isWallSurface(node) {
        let bb = node.boundingBox
        let extentX = bb.max.x - bb.min.x
        let extentZ = bb.max.z - bb.min.z
        // The wall's length runs along whichever horizontal local axis is longer.
        let axis: simd_float4 = extentX >= extentZ ? simd_float4(1, 0, 0, 0) : simd_float4(0, 0, 1, 0)
        let dir = node.simdWorldTransform * axis
        let horizontal = simd_length(simd_float2(dir.x, dir.z))
        if horizontal > 1e-4 {
          let weight = max(extentX, extentZ)
          if weight > bestWeight {
            bestWeight = weight
            bestAngle = atan2(dir.z, dir.x)
          }
        }
      }
      for c in node.childNodes { visit(c) }
    }
    visit(root)
    return bestAngle
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

  /// Furniture that does not rest on the floor plane — most notably hanging/upper kitchen
  /// cabinets and wall shelves — fails `isOnFloorObject`, and because its node name does not
  /// contain "wall" it is not caught by `isWallSurface` either, so it would otherwise keep the
  /// raw white/gray scan material. RoomPlan still names these meshes by category (`Cabinet*`,
  /// `Storage*`, ...), so detect furniture by name and give it the same stylized material as its
  /// floor-standing counterpart. Structural surfaces and large wall-like slabs are excluded so
  /// real walls/ceilings/doors are never mistaken for furniture.
  private func nonFloorFurnitureType(
    _ node: SCNNode,
    sceneBounds: (min: SCNVector3, max: SCNVector3)
  ) -> EditableObjectType? {
    if shouldHideWallLikeSurface(node) || isWallSurface(node) { return nil }
    let name = (node.name ?? "").lowercased()
    if name.contains("floor") || name.contains("ground") || name.contains("ceiling") { return nil }
    if let b = worldBounds(of: node) {
      let sceneH = max(sceneBounds.max.y - sceneBounds.min.y, 0.12)
      if isLikelyFloorSlab(b, sceneBounds: sceneBounds) { return nil }
      if isLikelyVerticalWallSlab(b, sceneHeight: sceneH) { return nil }
    }
    switch EditableObjectType.from(nodeName: node.name ?? "") {
    case .cabinet, .storage, .table, .appliance, .fixture, .sofa, .bed, .chair:
      return EditableObjectType.from(nodeName: node.name ?? "")
    case .television, .unknown:
      return nil
    }
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

  /// Applies the shared tileable red-brick texture to a scan wall surface using world-space
  /// triplanar projection rotated about Y by `wallAngleRadians` (see
  /// `SurfaceShaders.triplanarRotated`), so brick shows correctly on meshes without proper UV
  /// coordinates while its lines run parallel to the walls (matching the floor tile alignment)
  /// instead of looking skewed against the world axes in the top-down view.
  private func applyBrickWallMaterial(_ material: SCNMaterial, wallAngleRadians: Float) {
    material.lightingModel = .physicallyBased
    material.metalness.contents = NSNumber(value: 0.0)
    material.roughness.contents = NSNumber(value: 0.95)
    material.diffuse.contents = BrickTexture.shared
    material.diffuse.wrapS = .repeat
    material.diffuse.wrapT = .repeat
    material.ambient.contents = UIColor(white: 0.5, alpha: 1)
    material.shaderModifiers = [.surface: SurfaceShaders.triplanarRotated]
    material.setValue(NSNumber(value: Float(BrickTexture.tileMeters)), forKey: "triTileMeters")
    material.setValue(NSNumber(value: wallAngleRadians), forKey: "triRotation")
  }

  /// Applies the stylized look to a USDZ room scan: brick exterior walls, dark wood-tile floor,
  /// per-category furniture materials, and a glossy-black material for televisions.
  private func applyFloorAndFurnitureTint() {
    guard let root = loadedScene?.rootNode, let sceneBounds = sceneWorldBounds else { return }
    cacheOriginalMaterialsIfNeeded()
    let floorAngle = dominantWallAngleInScene()
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
      // Televisions are often wall-mounted, so they may not pass the floor-object test.
      // Detect them by name first so they always get the glossy-black screen material.
      if EditableObjectType.from(nodeName: node.name ?? "") == .television {
        geo.materials = originals.map { _ in FurnitureMaterials.material(for: .television) }
      } else if let b = worldBounds(of: node), isLikelyFloorSlab(b, sceneBounds: sceneBounds) {
        geo.materials = originals.map { _ in FurnitureMaterials.floor(wallAngleRadians: floorAngle) }
      } else if isOnFloorObject(node, sceneBounds: sceneBounds) {
        let type = EditableObjectType.from(nodeName: node.name ?? "")
        geo.materials = originals.map { _ in
          FurnitureMaterials.material(for: type, rotationRadians: floorAngle)
        }
      } else if let type = nonFloorFurnitureType(node, sceneBounds: sceneBounds) {
        geo.materials = originals.map { _ in
          FurnitureMaterials.material(for: type, rotationRadians: floorAngle)
        }
      } else if isWallSurface(node) {
        geo.materials = originals.map { orig in
          let m = orig.copy() as! SCNMaterial
          applyBrickWallMaterial(m, wallAngleRadians: floorAngle)
          return m
        }
      } else if !shouldHideWallLikeSurface(node),
        !(node.name ?? "").lowercased().contains("floor"),
        !(node.name ?? "").lowercased().contains("ground"),
        !(worldBounds(of: node).map { isLikelyFloorSlab($0, sceneBounds: sceneBounds) } ?? false)
      {
        // Fallback for an interior mesh that matched none of the classes above — typically a
        // RoomPlan bounding box for a counter/appliance whose node name doesn't map to a known
        // category. It sits above the floor (fails the floor-object test) and its name resolves to
        // `.unknown` (so `nonFloorFurnitureType` returns nil), so without this it keeps the raw
        // white/cream scan material. Give it a textured wood furniture material so nothing renders
        // untextured. Structural surfaces (walls/ceiling/doors/windows/floor) are excluded above.
        let inferred = EditableObjectType.from(nodeName: node.name ?? "")
        let type: EditableObjectType = inferred == .unknown ? .storage : inferred
        geo.materials = originals.map { _ in
          FurnitureMaterials.material(for: type, rotationRadians: floorAngle)
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
    if let editable = floorPlanStateManager.editableModel,
      editable.metadata.isEdited,
      let scene = loadedScene
    {
      Scene3DRegenerationService.regenerate(
        in: scene,
        model: editable,
        stylizedMaterials: useStylizedMaterials
      )
    }
    if floorPlanStateManager.editableModel?.metadata.isEdited != true,
      let scene = loadedScene
    {
      ScanCeilingService.updateMaterials(in: scene, stylizedMaterials: useStylizedMaterials)
    }
    sunSimulationController.refreshShadowCasters()
  }

  private func applyScanCeilingIfNeeded() {
    guard let scene = loadedScene else { return }
    if floorPlanStateManager.editableModel?.metadata.isEdited == true {
      ScanCeilingService.remove(from: scene)
      return
    }
    ScanCeilingService.apply(to: scene, stylizedMaterials: useStylizedMaterials)
    sunSimulationController.refreshShadowCasters()
  }

  /// Uses mesh node names from RoomPlan-style USDZ. Furniture stays visible unless its name matches these.
  private func shouldHideWallLikeSurface(_ node: SCNNode) -> Bool {
    if node.name == "UydoshFramingCamera" { return false }
    let name = (node.name ?? "").lowercased()
    if name == ScanCeilingService.ceilingNodeName.lowercased() { return true }
    if name == "uydoshgeneratedceiling" { return true }
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
        case .floorAndFurniture:
          if node.name == "UydoshFramingCamera" {
            node.isHidden = false
          } else {
            node.isHidden = shouldHideWallLikeSurface(node)
          }
        case .floorOnly:
          if node.name == "UydoshFramingCamera" {
            node.isHidden = false
          } else if shouldHideWallLikeSurface(node) {
            node.isHidden = true
          } else if let sceneBounds = sceneWorldBounds, isOnFloorObject(node, sceneBounds: sceneBounds) {
            node.isHidden = true
          } else {
            node.isHidden = false
          }
        }
      }
      for child in node.childNodes {
        visit(child)
      }
    }

    visit(root)
    SCNTransaction.commit()

    if mode == .floorAndFurniture || mode == .floorOnly {
      // Both modes hinge on being able to find wall-like meshes by name — if we can't,
      // don't pretend the mode worked (floorOnly could still "work" by only hiding
      // furniture, which isn't what its icon/label promise).
      var anyWallHidden = false
      func checkWallHidden(_ node: SCNNode) {
        if node.geometry != nil, shouldHideWallLikeSurface(node), node.isHidden {
          anyWallHidden = true
          return
        }
        guard !anyWallHidden else { return }
        for c in node.childNodes { checkWallHidden(c) }
      }
      checkWallHidden(root)
      if !anyWallHidden {
        // Revert and explain.
        displayMode = .fullRoom
        updateModeButtonAppearance()
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
    updateCameraForDisplayMode()
    sunSimulationController.refreshShadowCasters()
  }

  @objc private func modeButtonTapped() {
    guard loadedScene != nil else { return }
    let next = nextDisplayMode(after: displayMode)
    displayMode = next
    updateModeButtonAppearance()
    applyDisplayMode(next)
  }

  /// RoomPlan / SceneKit: meters, Y-up. Footprint from floor polygon; height from full scene.
  private func updateDimensionsDisplay(_ metrics: RoomScanMetricsResult) {
    let floorLong = Float(metrics.floorLongM)
    let floorShort = Float(metrics.floorShortM)
    let height = Float(metrics.heightM)
    let floorArea = metrics.floorAreaM2
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
    dimensionsLineStack.isHidden = false
    hintContainer.backgroundColor = UIColor.black.withAlphaComponent(0.52)
    hintContainer.isUserInteractionEnabled = true
    if isNorthPanelExpanded {
      updateNorthPanelTopAnchor()
    }
    publishMetricsToFlutterIfNeeded(metrics: metrics)
    #if DEBUG
    logFootprintDebug(metrics)
    #endif
  }

  /// Owner backfill: push bounds to Flutter once so the API can persist metrics for legacy scans.
  private func publishMetricsToFlutterIfNeeded(metrics: RoomScanMetricsResult) {
    guard publishMetricsIfMissing, listingId > 0, !didPublishFlutterMetrics,
      let messenger = metricsMessenger
    else { return }
    didPublishFlutterMetrics = true
    let channel = FlutterMethodChannel(
      name: "uydosh/room_scan_metrics_sink",
      binaryMessenger: messenger
    )
    channel.invokeMethod(
      "onComputedMetrics",
      arguments: [
        "listingId": listingId,
        "floor_long_m": metrics.floorLongM,
        "floor_short_m": metrics.floorShortM,
        "height_m": metrics.heightM,
        "floor_area_m2": metrics.floorAreaM2,
      ],
      result: { _ in }
    )
  }

  /// Owner: persist manual north correction to Flutter/backend.
  private func publishNorthCorrectionToFlutter(correctionDeg: Double?) {
    guard isListingOwner, listingId > 0, let messenger = metricsMessenger else { return }
    let channel = FlutterMethodChannel(
      name: "uydosh/room_scan_north_correction_sink",
      binaryMessenger: messenger
    )
    var args: [String: Any] = ["listingId": listingId]
    if let correctionDeg {
      args["north_correction_deg"] = correctionDeg
    } else {
      args["north_correction_deg"] = NSNull()
    }
    channel.invokeMethod("onNorthCorrectionChanged", arguments: args, result: { _ in })
  }

  private func updateNorthAdjustButtonVisibility() {
    let canEdit = isListingOwner && listingId > 0
    let canEditOn3D = canEdit && viewerTab == .threeD
    floorPlanTabView?.setNorthAdjustEnabled(canEdit)
    sunCompassOverlay.isOrientationEditable = canEditOn3D
    sunCompassOverlay.acceptsOrientationTaps = canEditOn3D
    sunCompassOverlay.accessibilityHint = canEdit
      ? strings.compassOrientation.message
      : nil
    updateNorthPanelAppearance()
  }

  private func updateNorthPanelAppearance() {
    let active = isNorthPanelExpanded
    sunCompassOverlay.layer.borderWidth = active ? 1.5 : 1
    sunCompassOverlay.layer.borderColor = (
      active
        ? UIColor(red: 1, green: 0.78, blue: 0.35, alpha: 0.85).cgColor
        : UIColor.white.withAlphaComponent(0.12).cgColor
    )
    floorPlanTabView?.setNorthAdjustActive(active)
  }

  private func northPanelCallbacks() -> (
    onPreview: (Double) -> Void,
    onCommit: (Double) -> Void,
    onReset: () -> Void
  ) {
    (
      onPreview: { [weak self] value in
        self?.floorPlanStateManager.previewNorthCorrection(value)
        self?.refreshSunOrientationContext()
      },
      onCommit: { [weak self] value in
        guard let self else { return }
        self.committedNorthCorrectionDeg = value
        self.floorPlanStateManager.applyNorthCorrection(value)
        self.publishNorthCorrectionToFlutter(correctionDeg: value)
        self.refreshSunOrientationContext()
      },
      onReset: { [weak self] in
        guard let self else { return }
        self.committedNorthCorrectionDeg = 0
        self.floorPlanStateManager.resetNorthCorrection()
        self.publishNorthCorrectionToFlutter(correctionDeg: nil)
        self.refreshSunOrientationContext()
      }
    )
  }

  private func updateNorthPanelTopAnchor() {
    northPanelTopConstraint?.isActive = false
    let anchor: NSLayoutYAxisAnchor
    switch viewerTab {
    case .threeD where !sunCompassOverlay.isHidden:
      anchor = sunCompassOverlay.bottomAnchor
    case .floorPlan:
      anchor = floorPlanTabView?.orientationCompass.bottomAnchor
        ?? view.safeAreaLayoutGuide.topAnchor
    case .threeD:
      anchor = view.safeAreaLayoutGuide.topAnchor
    }
    let top = northOrientationPanel.topAnchor.constraint(equalTo: anchor, constant: 8)
    northPanelTopConstraint = top
    top.isActive = true
  }

  private func showNorthCorrectionPanel() {
    guard isListingOwner else { return }
    northPanelCommittedCorrection = floorPlanStateManager.northCorrectionDeg
    updateNorthPanelTopAnchor()
    northOrientationPanel.beginSession(committedCorrection: northPanelCommittedCorrection)
    northOrientationPanel.isHidden = false
    northOrientationPanel.alpha = 1
    view.layoutIfNeeded()
    bringInteractiveOverlaysToFront()
    updateNorthPanelAppearance()
  }

  private func hideNorthCorrectionPanel(revertPreview: Bool) {
    guard !northOrientationPanel.isHidden else { return }
    if revertPreview {
      northPanelCallbacks().onPreview(northPanelCommittedCorrection)
    }
    northOrientationPanel.isHidden = true
    updateNorthPanelAppearance()
  }

  private func toggleNorthCorrectionPanel() {
    guard isListingOwner else { return }
    if isNorthPanelExpanded {
      hideNorthCorrectionPanel(revertPreview: true)
    } else {
      showNorthCorrectionPanel()
    }
  }

  private func showNorthCorrectionConfirmationToast() {
    let toast = UILabel()
    toast.text = strings.compassOrientation.updated
    toast.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
    toast.textColor = .white
    toast.backgroundColor = UIColor(white: 0.12, alpha: 0.92)
    toast.textAlignment = .center
    toast.layer.cornerRadius = 14
    toast.clipsToBounds = true
    toast.alpha = 0
    toast.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(toast)
    NSLayoutConstraint.activate([
      toast.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      toast.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 56),
      toast.heightAnchor.constraint(equalToConstant: 34),
      toast.widthAnchor.constraint(greaterThanOrEqualToConstant: 200),
    ])
    toast.layoutIfNeeded()
    toast.bounds = toast.bounds.insetBy(dx: -16, dy: 0)
    UIView.animate(withDuration: 0.2, animations: {
      toast.alpha = 1
    }) { _ in
      UIView.animate(withDuration: 0.25, delay: 1.0, options: [], animations: {
        toast.alpha = 0
      }) { _ in
        toast.removeFromSuperview()
      }
    }
  }

  /// Places the camera so the whole model fits the viewport (avoids default “inside the mesh” zoom).
  private func frameCamera(for scene: SCNScene, in view: SCNView) {
    guard let bounds = RoomScanMetricsComputer.unionWorldBounds(of: scene.rootNode),
      let metrics = RoomScanMetricsComputer.metrics(for: scene)
    else { return }

    let minB = bounds.min
    let maxB = bounds.max
    let dx = maxB.x - minB.x
    let dy = maxB.y - minB.y
    let dz = maxB.z - minB.z
    guard dx > 1e-6 || dy > 1e-6 || dz > 1e-6 else { return }

    sceneWorldBounds = (minB, maxB)
    footprintMetrics = metrics
    updateDimensionsDisplay(metrics)
    updateDebugFootprintOverlay(in: scene)

    let centerWorld = SCNVector3(
      (metrics.minX + metrics.maxX) * 0.5,
      (minB.y + maxB.y) * 0.5,
      (metrics.minZ + metrics.maxZ) * 0.5
    )

    // Half diagonal of the axis-aligned box; enclosing sphere radius for a conservative fit.
    let halfDiagonal =
      0.5 * sqrt(dx * dx + dy * dy + dz * dz)
    guard halfDiagonal > 1e-4 else { return }

    let cameraNode = SCNNode()
    cameraNode.name = "UydoshFramingCamera"
    let cam = SCNCamera()
    cam.usesOrthographicProjection = false
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
    syncZoomSliderToCamera()

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
    savedPerspectiveOrbitYaw = orbitYaw
    savedPerspectiveOrbitPitch = orbitPitch
    savedPerspectiveOrbitRadius = orbitRadius
    savedPerspectiveFov = initialFov
    isOrthographicPlanView = false

    cacheOriginalMaterialsIfNeeded()
    applyMaterialsStyle()
    updateCameraForDisplayMode()
  }

  private func updateCameraForDisplayMode() {
    // Legacy orthographic plan view is no longer used for furniture-only mode.
    if isOrthographicPlanView {
      restorePerspectiveCamera(animated: true)
    }
    guard displayMode == .floorAndFurniture || displayMode == .floorOnly else { return }
    removeAutoRotateAnimation()
    isAutoRotating = false
    if isSunPanelExpanded {
      sunSimulationController.setEnabled(true)
    }
    sunCompassOverlay.isHidden = false
    sunClockOverlay.isHidden = false
    updateCameraFromOrbit()
  }

  /// Orthographic top-down camera aligned to the floor footprint so on-screen aspect matches dimensions.
  private func applyTopDownPlanCamera(animated: Bool) {
    guard let metrics = footprintMetrics,
      let camNode = framingCameraNode,
      let cam = camNode.camera,
      let sceneBounds = sceneWorldBounds
    else { return }

    if !isOrthographicPlanView {
      savedPerspectiveOrbitYaw = orbitYaw
      savedPerspectiveOrbitPitch = orbitPitch
      savedPerspectiveOrbitRadius = orbitRadius
      savedPerspectiveFov = cam.fieldOfView
    }

    removeAutoRotateAnimation()
    isAutoRotating = false

    let dx = metrics.maxX - metrics.minX
    let dz = metrics.maxZ - metrics.minZ
    let centerWorld = SCNVector3(
      (metrics.minX + metrics.maxX) * 0.5,
      (sceneBounds.min.y + sceneBounds.max.y) * 0.5,
      (metrics.minZ + metrics.maxZ) * 0.5
    )
    orbitTarget = centerWorld

    let w = max(sceneView.bounds.width, 1)
    let h = max(sceneView.bounds.height, 1)
    let aspect = w / h
    let padding: CGFloat = 1.12
    let floorLong = CGFloat(metrics.floorLongM)
    let floorShort = CGFloat(metrics.floorShortM)
    let halfHeight = max(floorShort * 0.5, floorLong * 0.5 / aspect) * padding
    planOrthographicScale = halfHeight

    let cameraHeight = max(dx, dz) * 2.5 + max(sceneBounds.max.y - sceneBounds.min.y, 0.5)

    let apply = {
      cam.usesOrthographicProjection = true
      cam.orthographicScale = Double(self.planOrthographicScale)
      cam.fieldOfView = 60
      camNode.position = SCNVector3(
        centerWorld.x,
        sceneBounds.max.y + cameraHeight,
        centerWorld.z
      )
      // Pitch −90° looks straight down; yaw aligns long footprint edge with screen horizontal.
      camNode.eulerAngles = SCNVector3(-Float.pi / 2, metrics.footprintYaw, 0)
      self.isOrthographicPlanView = true
      self.sunSimulationController.setEnabled(false)
      self.sunCompassOverlay.isHidden = true
      self.sunClockOverlay.isHidden = true
    }

    if animated {
      SCNTransaction.begin()
      SCNTransaction.animationDuration = 0.28
      apply()
      SCNTransaction.commit()
    } else {
      apply()
    }
    syncZoomSliderToCamera()
  }

  private func restorePerspectiveCamera(animated: Bool) {
    guard isOrthographicPlanView,
      let camNode = framingCameraNode,
      let cam = camNode.camera
    else { return }

    orbitYaw = savedPerspectiveOrbitYaw
    orbitPitch = savedPerspectiveOrbitPitch
    orbitRadius = savedPerspectiveOrbitRadius

    let apply = {
      cam.usesOrthographicProjection = false
      cam.fieldOfView = self.savedPerspectiveFov
      self.updateCameraFromOrbit()
      self.isOrthographicPlanView = false
      if self.isSunPanelExpanded {
        self.sunSimulationController.setEnabled(true)
      }
      self.sunCompassOverlay.isHidden = false
      self.sunClockOverlay.isHidden = false
    }

    if animated {
      SCNTransaction.begin()
      SCNTransaction.animationDuration = 0.28
      apply()
      SCNTransaction.commit()
    } else {
      apply()
    }
    syncZoomSliderToCamera()
  }

  #if DEBUG
  private func logFootprintDebug(_ metrics: RoomScanMetricsResult) {
    let aabbDx = metrics.maxX - metrics.minX
    let aabbDz = metrics.maxZ - metrics.minZ
    let viewAspect = sceneView.bounds.width / max(sceneView.bounds.height, 1)
    NSLog(
      """
      [RoomScanMetrics] source=\(metrics.footprintSource) verts=\(metrics.polygonVertexCount)
      footprint long×short=\(String(format: "%.2f", metrics.floorLongM))×\(String(format: "%.2f", metrics.floorShortM)) m area=\(String(format: "%.1f", metrics.floorAreaM2)) m²
      AABB X[\(metrics.minX), \(metrics.maxX)] Z[\(metrics.minZ), \(metrics.maxZ)] dx=\(aabbDx) dz=\(aabbDz)
      footprintYaw=\(metrics.footprintYaw) viewportAspect=\(viewAspect)
      """
    )
  }

  private func updateDebugFootprintOverlay(in scene: SCNScene) {
    debugOverlayNode?.removeFromParentNode()
    guard let metrics = footprintMetrics,
      let sceneBounds = sceneWorldBounds
    else { return }

    let overlay = SCNNode()
    overlay.name = "UydoshFootprintDebug"

    let y = sceneBounds.min.y + 0.03
    let corners: [SCNVector3] = [
      SCNVector3(metrics.minX, y, metrics.minZ),
      SCNVector3(metrics.maxX, y, metrics.minZ),
      SCNVector3(metrics.maxX, y, metrics.maxZ),
      SCNVector3(metrics.minX, y, metrics.maxZ),
    ]

    func addEdge(from a: SCNVector3, to b: SCNVector3) {
      let dx = b.x - a.x
      let dy = b.y - a.y
      let dz = b.z - a.z
      let length = sqrt(dx * dx + dy * dy + dz * dz)
      guard length > 1e-4 else { return }
      let cyl = SCNCylinder(radius: 0.015, height: CGFloat(length))
      cyl.firstMaterial?.diffuse.contents = UIColor.systemGreen.withAlphaComponent(0.9)
      cyl.firstMaterial?.lightingModel = .constant
      let node = SCNNode(geometry: cyl)
      node.position = SCNVector3(
        (a.x + b.x) * 0.5,
        (a.y + b.y) * 0.5,
        (a.z + b.z) * 0.5
      )
      node.look(at: b, up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 1, 0))
      overlay.addChildNode(node)
    }

    for i in 0..<corners.count {
      addEdge(from: corners[i], to: corners[(i + 1) % corners.count])
    }

    for c in corners {
      let sphere = SCNSphere(radius: 0.06)
      sphere.firstMaterial?.diffuse.contents = UIColor.systemYellow
      sphere.firstMaterial?.lightingModel = .constant
      let node = SCNNode(geometry: sphere)
      node.position = c
      overlay.addChildNode(node)
    }

    scene.rootNode.addChildNode(overlay)
    debugOverlayNode = overlay
  }
  #else
  private func updateDebugFootprintOverlay(in _: SCNScene) {}
  #endif

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
        if let metrics = self.footprintMetrics {
          let bearing = self.worldPlusXTrueBearingDeg
            ?? RoomScanOrientationCapture.readSidecar(forUsdzPath: self.fileURL.path)
          self.floorPlanStateManager.importScan(
            scene: scene,
            metrics: metrics,
            sourceScanId: self.fileURL.lastPathComponent,
            worldPlusXTrueBearingDeg: bearing,
            northCorrectionDeg: self.committedNorthCorrectionDeg
          )
          self.updateNorthAdjustButtonVisibility()
        }
        self.updateModeButtonAppearance()
        self.applyDisplayMode(self.displayMode)
        self.applyScanCeilingIfNeeded()
        self.attachSunSimulationIfNeeded()
        self.startIntroAutoRotationIfNeeded()
        // Seed the sun/sky at the sweep's starting moment so the scene opens directly at dusk
        // (the rig attaches at noon) — avoids a one-frame lighting jump before the first tick.
        if self.sunSimulationController.isEnabled {
          self.applySunSweep(minute: self.sunSweepMinute)
        }
      } catch {
        self.presentLoadError(error)
      }
    }
  }

  private func removeAutoRotateAnimation() {
    autoRotateDisplayLink?.invalidate()
    autoRotateDisplayLink = nil
    autoRotateLastTimestamp = 0
  }

  /// Stops the opening cinematic (camera spin + sun sweep). Pass `reflectOnPanel: true` when the
  /// stop wasn't triggered by the panel itself, so the play/pause button returns to its idle state.
  private func endIntroCinematic(reflectOnPanel: Bool) {
    guard isAutoRotating else { return }
    removeAutoRotateAnimation()
    isAutoRotating = false
    updateCameraFromOrbit()
    if reflectOnPanel {
      sunSimulationPanel.setExternalPlayback(active: false)
    }
  }

  private func startIntroAutoRotationIfNeeded() {
    guard isAutoRotating, framingCameraNode != nil else { return }
    removeAutoRotateAnimation()
    sunSweepMinute = Self.sunCycleStartMinute
    // Orbit the camera around the model center (same pivot as manual pan), not world origin.
    let link = CADisplayLink(target: self, selector: #selector(tickAutoRotate(_:)))
    if #available(iOS 15.0, *) {
      link.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 120, preferred: 60)
    }
    link.add(to: .main, forMode: .common)
    autoRotateDisplayLink = link
  }

  @objc private func tickAutoRotate(_ link: CADisplayLink) {
    guard isAutoRotating, framingCameraNode != nil else {
      removeAutoRotateAnimation()
      return
    }
    let now = link.targetTimestamp
    let dt: Float
    if autoRotateLastTimestamp > 0 {
      dt = Float(now - autoRotateLastTimestamp)
    } else {
      dt = Float(max(link.duration, 1.0 / 120.0))
    }
    autoRotateLastTimestamp = now
    guard dt > 0, dt < 0.25 else { return }

    // Match the old intro spin direction: clockwise from above (negative yaw).
    let yawSpeed = Float(-2 * Double.pi / Self.autoRotateSecondsPerTurn)
    orbitYaw += yawSpeed * dt
    updateCameraFromOrbit()

    // Loop the real sun through a full day (dusk → dawn → dusk) so the sky cycles while spinning.
    if sunSimulationController.isEnabled {
      let minutesPerSecond = 1440.0 / Self.sunCycleSeconds
      // Fast-forward the night (eased across twilight) so the cycle lingers on daylight.
      let speedScale = SolarPosition.nightPlaybackSpeedScale(elevationDeg: sunSweepElevationDeg)
      sunSweepMinute += Double(dt) * minutesPerSecond * speedScale
      if sunSweepMinute >= 1440 { sunSweepMinute -= 1440 }
      applySunSweep(minute: sunSweepMinute)
    }
  }

  /// Drives the sun rig to the real solar position for today at `minute` (local), and keeps the
  /// compass + sun panel in sync. Used by the rotate-with-sun cinematic.
  private func applySunSweep(minute: Double) {
    let date = sunSweepCalendar.startOfDay(for: Date()).addingTimeInterval(minute * 60)
    let pos = SolarPosition.position(
      latitude: SolarPosition.tashkentLatitude,
      longitude: SolarPosition.tashkentLongitude,
      date: date,
      timeZone: SolarPosition.tashkentTimeZone
    )
    sunSweepElevationDeg = pos.elevationDeg
    let azimuth = Float(pos.azimuthDeg)
    let trueElevation = Float(pos.elevationDeg)
    let lightElevation = max(0, trueElevation)
    sunSimulationController.setSunAngles(
      azimuthDeg: azimuth,
      elevationDeg: lightElevation,
      trueElevationDeg: trueElevation
    )
    // Only refresh the (hidden during the intro spin) panel sliders when actually visible.
    if !sunSimulationPanel.isHidden {
      sunSimulationPanel.setAzimuth(azimuth)
      sunSimulationPanel.setElevation(lightElevation)
      // Mirror the running cinematic on the panel so the play/pause button + timeline track it,
      // instead of the user pressing play and spawning a second (flickering) animator.
      if isAutoRotating {
        sunSimulationPanel.setExternalPlayback(active: true)
        sunSimulationPanel.syncTimeline(toMinute: minute)
      }
    }
    // Sky uses the real (possibly below-horizon) elevation so night reads as night, not dusk.
    updateSceneSkyBackground(azimuthDeg: azimuth, elevationDeg: trueElevation)
    refreshSunCompassLabels()
    sunClockOverlay.update(
      minuteOfDay: minute,
      sunriseMinute: sunSimulationPanel.daylightSunriseMinute,
      sunsetMinute: sunSimulationPanel.daylightSunsetMinute
    )
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
    refreshSunCompassLabels()
  }

  private func stopOrbitDeceleration() {
    orbitDecelDisplayLink?.invalidate()
    orbitDecelDisplayLink = nil
    orbitDecelLastTimestamp = 0
    orbitYawVel = 0
    orbitPitchVel = 0
  }

  private func beginOrbitDecelerationIfWorthwhile(panVelocity v: CGPoint) {
    let vx = Float(v.x)
    let vy = Float(v.y)
    let scale = Self.orbitVelocityScale
    let yawV = -vx * scale
    let pitchV = vy * scale
    let speed = hypotf(yawV, pitchV)
    guard speed > Self.orbitDecelStopThreshold * 2.5 else { return }
    orbitDecelDisplayLink?.invalidate()
    orbitYawVel = yawV
    orbitPitchVel = pitchV
    orbitDecelLastTimestamp = 0
    let link = CADisplayLink(target: self, selector: #selector(tickOrbitDeceleration(_:)))
    if #available(iOS 15.0, *) {
      link.preferredFrameRateRange = CAFrameRateRange(minimum: 30, maximum: 120, preferred: 60)
    }
    link.add(to: .main, forMode: .common)
    orbitDecelDisplayLink = link
  }

  @objc private func tickOrbitDeceleration(_ link: CADisplayLink) {
    guard framingCameraNode != nil else {
      stopOrbitDeceleration()
      return
    }
    let now = link.targetTimestamp
    let dt: Float
    if orbitDecelLastTimestamp > 0 {
      dt = Float(now - orbitDecelLastTimestamp)
    } else {
      dt = Float(max(link.duration, 1.0 / 120.0))
    }
    orbitDecelLastTimestamp = now
    guard dt > 0, dt < 0.25 else { return }

    orbitYaw += orbitYawVel * dt
    orbitPitch += orbitPitchVel * dt

    let maxPitch = Float.pi / 2 - 0.12
    let minPitch = -Float.pi / 2 + 0.12
    if orbitPitch <= minPitch {
      orbitPitch = minPitch
      orbitPitchVel = min(0, orbitPitchVel)
    } else if orbitPitch >= maxPitch {
      orbitPitch = maxPitch
      orbitPitchVel = max(0, orbitPitchVel)
    }

    let decay = exp(-Self.orbitDecelDampingPerSec * dt)
    orbitYawVel *= decay
    orbitPitchVel *= decay

    updateCameraFromOrbit()

    if hypotf(orbitYawVel, orbitPitchVel) < Self.orbitDecelStopThreshold {
      stopOrbitDeceleration()
    }
  }

  @objc private func orbitPan(_ gr: UIPanGestureRecognizer) {
    if isOrthographicPlanView { return }
    switch gr.state {
    case .began:
      stopOrbitDeceleration()
    case .cancelled, .failed:
      stopOrbitDeceleration()
      return
    case .changed, .ended:
      break
    default:
      return
    }
    endIntroCinematic(reflectOnPanel: true)
    guard framingCameraNode != nil else { return }

    let t = gr.translation(in: sceneView)
    gr.setTranslation(.zero, in: sceneView)
    let sens = Self.orbitPanSensitivity
    orbitYaw -= Float(t.x) * sens
    orbitPitch += Float(t.y) * sens
    let maxPitch = Float.pi / 2 - 0.12
    let minPitch = -Float.pi / 2 + 0.12
    orbitPitch = min(max(orbitPitch, minPitch), maxPitch)
    updateCameraFromOrbit()

    if gr.state == .ended {
      beginOrbitDecelerationIfWorthwhile(panVelocity: gr.velocity(in: sceneView))
    }
  }

  @objc private func orbitPinch(_ gr: UIPinchGestureRecognizer) {
    endIntroCinematic(reflectOnPanel: true)
    if gr.state == .began {
      stopOrbitDeceleration()
    }
    guard let cam = framingCameraNode?.camera else { return }
    if isOrthographicPlanView {
      switch gr.state {
      case .began:
        pinchBaseOrthoScale = planOrthographicScale
      case .changed:
        planOrthographicScale = max(0.5, min(80, pinchBaseOrthoScale / CGFloat(gr.scale)))
        cam.orthographicScale = Double(planOrthographicScale)
        syncZoomSliderToCamera()
      case .ended, .cancelled, .failed:
        pinchBaseOrthoScale = planOrthographicScale
      default:
        break
      }
      return
    }
    switch gr.state {
    case .began:
      pinchBaseFov = cam.fieldOfView
    case .changed:
      let next = pinchBaseFov / CGFloat(gr.scale)
      setZoom(fovDegrees: next, animated: false)
      syncZoomSliderToCamera()
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
    endIntroCinematic(reflectOnPanel: true)
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

  /// Compact circular close button styled to match the floating viewer chrome
  /// (replaces the oversized default `.close` system bar item).
  private func makeCloseBarButtonItem() -> UIBarButtonItem {
    let diameter: CGFloat = 30
    let button = UIButton(type: .system)
    button.frame = CGRect(x: 0, y: 0, width: diameter, height: diameter)
    button.backgroundColor = UIColor.black.withAlphaComponent(0.35)
    button.layer.cornerRadius = diameter / 2
    button.tintColor = UIColor.white.withAlphaComponent(0.92)
    if #available(iOS 13.0, *) {
      let cfg = UIImage.SymbolConfiguration(pointSize: 13, weight: .bold)
      button.setImage(UIImage(systemName: "xmark", withConfiguration: cfg), for: .normal)
    } else {
      button.setTitle("\u{2715}", for: .normal)
      button.titleLabel?.font = .systemFont(ofSize: 15, weight: .bold)
    }
    button.accessibilityLabel = "Close"
    button.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    button.widthAnchor.constraint(equalToConstant: diameter).isActive = true
    button.heightAnchor.constraint(equalToConstant: diameter).isActive = true
    return UIBarButtonItem(customView: button)
  }

  @objc private func closeTapped() {
    dismissViewer()
  }

  private func dismissViewer() {
    stopOrbitDeceleration()
    removeAutoRotateAnimation()
    removeManualOrbitGestures()
    framingCameraNode = nil
    didCacheOriginalMaterials = false
    originalMaterialsByGeometry.removeAll(keepingCapacity: false)
    sceneWorldBounds = nil
    footprintMetrics = nil
    floorPlanStateManager.clear()
    floorPlanTabView?.canvas.clearModel()
    viewerTab = .threeD
    updateViewerTabSelection(animated: false)
    updateViewerTabAccessibility()
    isOrthographicPlanView = false
    debugOverlayNode = nil
    displayMode = .fullRoom
    updateModeButtonAppearance()
    // Hiding the panel stops its playback timer (see `isHidden` didSet) — otherwise a tick can fire
    // mid-dismiss and call `projectPoint` on the now-nil scene, asserting on the main thread.
    sunSimulationPanel.isHidden = true
    sunSimulationController.detach()
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
    worldPlusXTrueBearingDeg: Double? = nil,
    northCorrectionDeg: Double = 0,
    isListingOwner: Bool = false,
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
      worldPlusXTrueBearingDeg: worldPlusXTrueBearingDeg,
      northCorrectionDeg: northCorrectionDeg,
      isListingOwner: isListingOwner,
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

extension RoomUsdzViewerViewController: FloorPlanCanvasDelegate {
  func floorPlanCanvas(_ canvas: FloorPlanCanvas, didTapEditableDimension dimensionId: UUID) {
    guard let controller = dimensionEditController else { return }
    controller.presentEdit(for: dimensionId, from: self) { [weak self] in
      self?.floorPlanTabView?.canvas.clearHighlight()
    }
  }

  func floorPlanCanvasPresenterViewController(_ canvas: FloorPlanCanvas) -> UIViewController? {
    self
  }

  private func regenerateSceneFromEditableModel(_ model: EditableFloorPlanModel) {
    guard let scene = loadedScene else { return }
    ScanCeilingService.remove(from: scene)
    Scene3DRegenerationService.regenerate(
      in: scene,
      model: model,
      stylizedMaterials: useStylizedMaterials
    )
    if viewerTab == .threeD {
      applyDisplayMode(displayMode)
    }
    sunSimulationController.refreshShadowCasters()
  }
}

extension RoomUsdzViewerViewController: CompassOrientationAdjustPanelDelegate {
  func northPanel(_ panel: CompassOrientationAdjustPanel, didPreviewCorrection degrees: Double) {
    northPanelCallbacks().onPreview(degrees)
  }

  func northPanelDidApply(_ panel: CompassOrientationAdjustPanel, correction degrees: Double) {
    northPanelCommittedCorrection = degrees
    northPanelCallbacks().onCommit(degrees)
    hideNorthCorrectionPanel(revertPreview: false)
    showNorthCorrectionConfirmationToast()
  }

  func northPanelDidReset(_ panel: CompassOrientationAdjustPanel) {
    northPanelCommittedCorrection = 0
    northPanelCallbacks().onReset()
    showNorthCorrectionConfirmationToast()
  }

  func northPanelDidDismiss(_ panel: CompassOrientationAdjustPanel, revertPreview: Bool) {
    hideNorthCorrectionPanel(revertPreview: revertPreview)
  }
}

extension RoomUsdzViewerViewController: SunSimulationPanelDelegate {
  func sunPanel(_ panel: SunSimulationPanel, didChangeAzimuth degrees: Float) {
    sunSimulationController.setSunAzimuth(degrees: degrees)
    refreshSunCompassLabels()
  }

  func sunPanel(_ panel: SunSimulationPanel, didChangeElevation degrees: Float) {
    sunSimulationController.setSunElevation(degrees: degrees)
    refreshSunCompassLabels()
  }

  func sunPanel(_ panel: SunSimulationPanel, didAnimateToAzimuth azimuth: Float, trueElevation: Float) {
    // Keep the geometric sun on/above the horizon, but feed the real elevation as the mood driver
    // so dusk/night (dark sky, fading orb, moon + stars) renders exactly like the intro sweep.
    sunSimulationController.setSunAngles(
      azimuthDeg: azimuth,
      elevationDeg: max(0, trueElevation),
      trueElevationDeg: trueElevation
    )
    updateSceneSkyBackground(azimuthDeg: azimuth, elevationDeg: trueElevation)
    refreshSunCompassLabels()
  }

  func sunPanel(_ panel: SunSimulationPanel, didChangeIntensity value: CGFloat) {
    sunSimulationController.setLightIntensity(value)
  }

  func sunPanel(_ panel: SunSimulationPanel, didSelectPreset preset: SunPositionMath.TimePreset) {
    endIntroCinematic(reflectOnPanel: false)
    sunSimulationController.applyPreset(preset)
    panel.setAzimuth(sunSimulationController.azimuthDeg)
    panel.setElevation(sunSimulationController.elevationDeg)
    refreshSunCompassLabels()
  }

  func sunPanelDidTakeManualControl(_ panel: SunSimulationPanel) {
    // The panel itself updates its play/pause button on manual control, so don't override it here.
    endIntroCinematic(reflectOnPanel: false)
  }

  func sunPanel(
    _ panel: SunSimulationPanel,
    didChangeTimeMinute minute: Double,
    sunriseMinute: Double,
    sunsetMinute: Double
  ) {
    sunClockOverlay.update(
      minuteOfDay: minute,
      sunriseMinute: sunriseMinute,
      sunsetMinute: sunsetMinute
    )
  }
}
