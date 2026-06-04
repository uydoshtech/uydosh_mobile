import UIKit

/// Floor Plan tab container: blueprint canvas plus minimal controls.
final class FloorPlanTab: UIView {
  let canvas = FloorPlanCanvas()

  /// Same compass rose component used on the 3D scene view, reused here for a consistent look.
  let orientationCompass = SunCompassOverlayView()

  private let controlsPanel = UIView()
  private let controlsStack = UIStackView()
  private let dimensionsButton = UIButton(type: .system)
  private let unitLabel = UILabel()

  private var strings: FloorPlanTabStrings
  var onAdjustNorthTapped: (() -> Void)?

  init(strings: FloorPlanTabStrings) {
    self.strings = strings
    super.init(frame: .zero)
    setupViews()
  }

  required init?(coder: NSCoder) {
    self.strings = .englishFallback
    super.init(coder: coder)
    setupViews()
  }

  func configure(model: FloorPlanModel) {
    canvas.configure(sourceModel: model, autoAlignEnabled: false)
    updateCompassOrientation(model)
  }

  func setDisplayModel(_ model: FloorPlanModel) {
    canvas.setDisplayModel(model)
    updateCompassOrientation(model)
  }

  /// Forwards the current sun azimuth so the floor-plan rose matches the 3D scene's compass.
  func updateSunAzimuth(_ azimuthDeg: Float) {
    orientationCompass.azimuthDeg = azimuthDeg
  }

  /// Points the compass rose at the plan's north. Plan coordinates map to screen with a single Y
  /// flip and no rotation, so the screen-space north angle is the negated plan-space north angle.
  private func updateCompassOrientation(_ model: FloorPlanModel) {
    let northPlanAngle = model.orientationTrueNorthPlanAngleRad
      ?? (model.orientationEastPlanAngleRad + .pi / 2)
    orientationCompass.usesTrueNorth = model.orientationUsesTrueNorth
    orientationCompass.northScreenAngleRad = -northPlanAngle
  }

  func updateStrings(_ strings: FloorPlanTabStrings) {
    self.strings = strings
    applyControlLabels()
  }

  /// The compass rose doubles as the north-adjust control: it only accepts taps (and shows the gold
  /// editable ring) when north editing is available.
  func setNorthAdjustEnabled(_ enabled: Bool) {
    orientationCompass.acceptsOrientationTaps = enabled
    orientationCompass.isOrientationEditable = enabled
  }

  private func setupViews() {
    translatesAutoresizingMaskIntoConstraints = false
    backgroundColor = .white

    canvas.translatesAutoresizingMaskIntoConstraints = false
    // The 2D plan now uses the shared SunCompassOverlayView rose instead of the canvas-drawn compass.
    canvas.showOrientationOverlay = false
    addSubview(canvas)

    orientationCompass.translatesAutoresizingMaskIntoConstraints = false
    orientationCompass.accessibilityLabel = strings.adjustNorth
    orientationCompass.addTarget(self, action: #selector(compassTapped), for: .touchUpInside)
    addSubview(orientationCompass)

    controlsPanel.translatesAutoresizingMaskIntoConstraints = false
    controlsPanel.backgroundColor = UIColor(red: 0.17, green: 0.17, blue: 0.19, alpha: 1)
    controlsPanel.layer.cornerRadius = 22
    if #available(iOS 13.0, *) {
      controlsPanel.layer.cornerCurve = .continuous
    }
    controlsPanel.layer.borderWidth = 1
    controlsPanel.layer.borderColor = UIColor.white.withAlphaComponent(0.07).cgColor
    addSubview(controlsPanel)

    controlsStack.translatesAutoresizingMaskIntoConstraints = false
    controlsStack.axis = .horizontal
    controlsStack.spacing = 8
    controlsStack.alignment = .center
    controlsStack.distribution = .fillProportionally
    controlsPanel.addSubview(controlsStack)

    configureControlButton(dimensionsButton, symbol: "ruler", action: #selector(dimensionsTapped))
    controlsStack.addArrangedSubview(dimensionsButton)

    unitLabel.translatesAutoresizingMaskIntoConstraints = false
    unitLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 11, weight: .medium)
    unitLabel.textColor = UIColor.white.withAlphaComponent(0.62)
    unitLabel.text = strings.unitMeters
    controlsPanel.addSubview(unitLabel)

    NSLayoutConstraint.activate([
      canvas.topAnchor.constraint(equalTo: topAnchor),
      canvas.leadingAnchor.constraint(equalTo: leadingAnchor),
      canvas.trailingAnchor.constraint(equalTo: trailingAnchor),
      canvas.bottomAnchor.constraint(equalTo: bottomAnchor),

      // Top-right corner, matching the analog clock's vertical position on the 3D view.
      orientationCompass.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 2),
      orientationCompass.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),

      controlsPanel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
      controlsPanel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -12),
      controlsPanel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 2),

      controlsStack.topAnchor.constraint(equalTo: controlsPanel.topAnchor, constant: 10),
      controlsStack.leadingAnchor.constraint(equalTo: controlsPanel.leadingAnchor, constant: 12),
      controlsStack.trailingAnchor.constraint(equalTo: controlsPanel.trailingAnchor, constant: -12),
      controlsStack.bottomAnchor.constraint(equalTo: controlsPanel.bottomAnchor, constant: -10),

      unitLabel.topAnchor.constraint(equalTo: controlsPanel.topAnchor, constant: 4),
      unitLabel.trailingAnchor.constraint(equalTo: controlsPanel.trailingAnchor, constant: -10),
    ])

    applyControlLabels()
    updateToggleStates()
  }

  private func configureControlButton(_ button: UIButton, symbol: String, action: Selector) {
    button.translatesAutoresizingMaskIntoConstraints = false
    let cfg = UIImage.SymbolConfiguration(pointSize: 15, weight: .semibold)
    button.setImage(UIImage(systemName: symbol, withConfiguration: cfg), for: .normal)
    button.tintColor = UIColor.white.withAlphaComponent(0.92)
    button.backgroundColor = UIColor(red: 0.22, green: 0.22, blue: 0.26, alpha: 1)
    button.layer.cornerRadius = 18
    if #available(iOS 13.0, *) {
      button.layer.cornerCurve = .continuous
    }
    button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 10)
    button.addTarget(self, action: action, for: .touchUpInside)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
    button.titleLabel?.lineBreakMode = .byTruncatingTail
  }

  private func applyControlLabels() {
    dimensionsButton.accessibilityLabel = strings.dimensionsOverall
    orientationCompass.accessibilityLabel = strings.adjustNorth
    unitLabel.text = strings.unitMeters
    updateToggleStates()
  }

  private func updateToggleStates() {
    let dimTitle: String
    switch canvas.dimensionMode {
    case .overall: dimTitle = strings.dimensionsOverall
    case .wallSegments: dimTitle = strings.dimensionsWalls
    case .hidden: dimTitle = strings.dimensionsHide
    }
    dimensionsButton.setTitle(dimTitle, for: .normal)
  }

  @objc private func compassTapped() {
    onAdjustNorthTapped?()
  }

  /// Modes the dimensions button cycles through. "Общие" (overall) is intentionally excluded.
  private static let selectableDimensionModes: [FloorPlanDimensionMode] = [.hidden, .wallSegments]

  @objc private func dimensionsTapped() {
    let modes = FloorPlanTab.selectableDimensionModes
    let currentIndex = modes.firstIndex(of: canvas.dimensionMode) ?? 0
    canvas.dimensionMode = modes[(currentIndex + 1) % modes.count]
    updateToggleStates()
  }
}

struct FloorPlanTabStrings {
  let tab3DView: String
  let tabFloorPlan: String
  let resetView: String
  let dimensionsOverall: String
  let dimensionsWalls: String
  let dimensionsHide: String
  let showObjects: String
  let hideObjects: String
  let showGrid: String
  let hideGrid: String
  let autoAlignOn: String
  let autoAlignOff: String
  let adjustNorth: String
  let unitMeters: String
  let editDimensionTitle: String
  let editDimensionCurrent: String
  let editDimensionNewValue: String
  let editDimensionCancel: String
  let editDimensionApply: String
  let editDimensionUpdated: String
  let editDimensionLargeChangeTitle: String
  let editDimensionLargeChangeMessage: String
  let editDimensionInvalidTitle: String
  let editDimensionInvalidMessage: String
  let editDimensionConfirmLargeChange: String

  var dimensionEditDialogStrings: DimensionEditDialogStrings {
    DimensionEditDialogStrings(
      title: editDimensionTitle,
      currentLabel: editDimensionCurrent,
      newValuePlaceholder: editDimensionNewValue,
      cancel: editDimensionCancel,
      apply: editDimensionApply,
      updatedConfirmation: editDimensionUpdated,
      largeChangeTitle: editDimensionLargeChangeTitle,
      largeChangeMessage: editDimensionLargeChangeMessage,
      invalidInputTitle: editDimensionInvalidTitle,
      invalidInputMessage: editDimensionInvalidMessage,
      confirmLargeChange: editDimensionConfirmLargeChange
    )
  }

  init(
    tab3DView: String,
    tabFloorPlan: String,
    resetView: String,
    dimensionsOverall: String,
    dimensionsWalls: String,
    dimensionsHide: String,
    showObjects: String,
    hideObjects: String,
    showGrid: String,
    hideGrid: String,
    autoAlignOn: String,
    autoAlignOff: String,
    adjustNorth: String,
    unitMeters: String,
    editDimensionTitle: String,
    editDimensionCurrent: String,
    editDimensionNewValue: String,
    editDimensionCancel: String,
    editDimensionApply: String,
    editDimensionUpdated: String,
    editDimensionLargeChangeTitle: String,
    editDimensionLargeChangeMessage: String,
    editDimensionInvalidTitle: String,
    editDimensionInvalidMessage: String,
    editDimensionConfirmLargeChange: String
  ) {
    self.tab3DView = tab3DView
    self.tabFloorPlan = tabFloorPlan
    self.resetView = resetView
    self.dimensionsOverall = dimensionsOverall
    self.dimensionsWalls = dimensionsWalls
    self.dimensionsHide = dimensionsHide
    self.showObjects = showObjects
    self.hideObjects = hideObjects
    self.showGrid = showGrid
    self.hideGrid = hideGrid
    self.autoAlignOn = autoAlignOn
    self.autoAlignOff = autoAlignOff
    self.adjustNorth = adjustNorth
    self.unitMeters = unitMeters
    self.editDimensionTitle = editDimensionTitle
    self.editDimensionCurrent = editDimensionCurrent
    self.editDimensionNewValue = editDimensionNewValue
    self.editDimensionCancel = editDimensionCancel
    self.editDimensionApply = editDimensionApply
    self.editDimensionUpdated = editDimensionUpdated
    self.editDimensionLargeChangeTitle = editDimensionLargeChangeTitle
    self.editDimensionLargeChangeMessage = editDimensionLargeChangeMessage
    self.editDimensionInvalidTitle = editDimensionInvalidTitle
    self.editDimensionInvalidMessage = editDimensionInvalidMessage
    self.editDimensionConfirmLargeChange = editDimensionConfirmLargeChange
  }

  init?(dict: [String: String]) {
    guard let tab3D = dict["tab3DView"],
      let tabFloor = dict["tabFloorPlan"],
      let reset = dict["floorPlanReset"]
    else { return nil }
    self.init(
      tab3DView: tab3D,
      tabFloorPlan: tabFloor,
      resetView: reset,
      dimensionsOverall: dict["floorPlanDimensionsOverall"] ?? "Overall",
      dimensionsWalls: dict["floorPlanDimensionsWalls"] ?? "Wall dims",
      dimensionsHide: dict["floorPlanDimensionsHide"] ?? "Hide dims",
      showObjects: dict["floorPlanShowObjects"] ?? "Objects",
      hideObjects: dict["floorPlanHideObjects"] ?? "Hide objects",
      showGrid: dict["floorPlanShowGrid"] ?? "Grid",
      hideGrid: dict["floorPlanHideGrid"] ?? "Hide grid",
      autoAlignOn: dict["floorPlanAutoAlignOn"] ?? "Auto-align",
      autoAlignOff: dict["floorPlanAutoAlignOff"] ?? "Scan angle",
      adjustNorth: dict["floorPlanAdjustNorth"] ?? "North",
      unitMeters: dict["floorPlanUnitMeters"] ?? "m",
      editDimensionTitle: dict["floorPlanEditDimensionTitle"] ?? "Edit dimension",
      editDimensionCurrent: dict["floorPlanEditDimensionCurrent"] ?? "Current",
      editDimensionNewValue: dict["floorPlanEditDimensionNewValue"] ?? "New value (m)",
      editDimensionCancel: dict["floorPlanEditDimensionCancel"] ?? "Cancel",
      editDimensionApply: dict["floorPlanEditDimensionApply"] ?? "Apply",
      editDimensionUpdated: dict["floorPlanEditDimensionUpdated"] ?? "Dimension updated",
      editDimensionLargeChangeTitle: dict["floorPlanEditDimensionLargeChangeTitle"] ?? "Large change",
      editDimensionLargeChangeMessage: dict["floorPlanEditDimensionLargeChangeMessage"]
        ?? "New value differs significantly from the scanned measurement. Apply correction?",
      editDimensionInvalidTitle: dict["floorPlanEditDimensionInvalidTitle"] ?? "Invalid value",
      editDimensionInvalidMessage: dict["floorPlanEditDimensionInvalidMessage"]
        ?? "Enter a number between 0.5 and 100 meters.",
      editDimensionConfirmLargeChange: dict["floorPlanEditDimensionConfirmLargeChange"] ?? "Apply"
    )
  }

  static let englishFallback = FloorPlanTabStrings(
    tab3DView: "3D",
    tabFloorPlan: "2D",
    resetView: "Reset",
    dimensionsOverall: "Overall",
    dimensionsWalls: "Wall dims",
    dimensionsHide: "Hide dims",
    showObjects: "Objects",
    hideObjects: "Hide objects",
    showGrid: "Grid",
    hideGrid: "Hide grid",
    autoAlignOn: "Auto-align",
    autoAlignOff: "Scan angle",
    adjustNorth: "North",
    unitMeters: "meters",
    editDimensionTitle: "Edit dimension",
    editDimensionCurrent: "Current",
    editDimensionNewValue: "New value (m)",
    editDimensionCancel: "Cancel",
    editDimensionApply: "Apply",
    editDimensionUpdated: "Dimension updated",
    editDimensionLargeChangeTitle: "Large change",
    editDimensionLargeChangeMessage:
      "New value differs significantly from the scanned measurement. Apply correction?",
    editDimensionInvalidTitle: "Invalid value",
    editDimensionInvalidMessage: "Enter a number between 0.5 and 100 meters.",
    editDimensionConfirmLargeChange: "Apply"
  )
}
