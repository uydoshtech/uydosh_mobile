import UIKit

struct SunSimulationStrings {
  let toggleA11yLabel: String
  let toggleA11yHint: String
  let azimuthLabel: String
  let elevationLabel: String
  let intensityLabel: String
  let morning: String
  let noon: String
  let evening: String
  let azimuthFormat: String
  let elevationFormat: String

  init(
    toggleA11yLabel: String,
    toggleA11yHint: String,
    azimuthLabel: String,
    elevationLabel: String,
    intensityLabel: String,
    morning: String,
    noon: String,
    evening: String,
    azimuthFormat: String,
    elevationFormat: String
  ) {
    self.toggleA11yLabel = toggleA11yLabel
    self.toggleA11yHint = toggleA11yHint
    self.azimuthLabel = azimuthLabel
    self.elevationLabel = elevationLabel
    self.intensityLabel = intensityLabel
    self.morning = morning
    self.noon = noon
    self.evening = evening
    self.azimuthFormat = azimuthFormat
    self.elevationFormat = elevationFormat
  }

  init?(dict: [String: String]) {
    self.init(
      toggleA11yLabel: dict["sunToggleLabel"] ?? "Sunlight",
      toggleA11yHint: dict["sunToggleHint"] ?? "Show or hide sun simulation controls",
      azimuthLabel: dict["sunAzimuthLabel"] ?? "Azimuth",
      elevationLabel: dict["sunElevationLabel"] ?? "Elevation",
      intensityLabel: dict["sunIntensityLabel"] ?? "Intensity",
      morning: dict["sunPresetMorning"] ?? "Morning",
      noon: dict["sunPresetNoon"] ?? "Noon",
      evening: dict["sunPresetEvening"] ?? "Evening",
      azimuthFormat: dict["sunAzimuthFormat"] ?? "Az %d°",
      elevationFormat: dict["sunElevationFormat"] ?? "El %d°"
    )
  }

  static let englishFallback = SunSimulationStrings(
    toggleA11yLabel: "Sunlight",
    toggleA11yHint: "Show or hide sun simulation controls",
    azimuthLabel: "Azimuth",
    elevationLabel: "Elevation",
    intensityLabel: "Intensity",
    morning: "Morning",
    noon: "Noon",
    evening: "Evening",
    azimuthFormat: "Az %d°",
    elevationFormat: "El %d°"
  )
}

protocol SunSimulationPanelDelegate: AnyObject {
  func sunPanel(_ panel: SunSimulationPanel, didChangeAzimuth degrees: Float)
  func sunPanel(_ panel: SunSimulationPanel, didChangeElevation degrees: Float)
  /// Fired by the timeline (scrub/play/"now") with the real solar position, where `trueElevation`
  /// may dip below 0° at night. Lets the host drive the night sky (dark backdrop, moon, stars)
  /// that the clamped `didChangeElevation` path would otherwise hide. Geometric lighting elevation
  /// is still clamped to the horizon by the host.
  func sunPanel(_ panel: SunSimulationPanel, didAnimateToAzimuth azimuth: Float, trueElevation: Float)
  func sunPanel(_ panel: SunSimulationPanel, didChangeIntensity value: CGFloat)
  func sunPanel(_ panel: SunSimulationPanel, didSelectPreset preset: SunPositionMath.TimePreset)
  /// The user grabbed the timeline / play / now controls. The host should end any externally
  /// driven animation (e.g. the intro cinematic) so it doesn't double-drive the sun.
  func sunPanelDidTakeManualControl(_ panel: SunSimulationPanel)
  /// Fired whenever the simulated time-of-day changes (scrub, play, "now", or a preset), so the
  /// host can drive the analog clock overlay. Minutes are since local midnight.
  func sunPanel(
    _ panel: SunSimulationPanel,
    didChangeTimeMinute minute: Double,
    sunriseMinute: Double,
    sunsetMinute: Double
  )
}

/// Collapsible sunlight controls (sliders + time-of-day presets).
final class SunSimulationPanel: UIView {
  weak var delegate: SunSimulationPanelDelegate?

  private let strings: SunSimulationStrings
  private let stack = UIStackView()
  private let azimuthSlider = UISlider()
  private let elevationSlider = UISlider()
  private let intensitySlider = UISlider()
  private let azimuthValueLabel = UILabel()
  private let elevationValueLabel = UILabel()
  private let presetStack = UIStackView()
  private var suppressCallbacks = false

  // Solar timeline: drives the real sun path for the property's location & today's date.
  private let solarContainer = UIStackView()
  private let timeSlider = UISlider()
  private let timeLabelsRow = UIStackView()
  private let playButton = UIButton(type: .system)
  private var isPlaying = false
  private var animationTimer: Timer?
  private var sunriseMinute: Double = 6 * 60
  private var sunsetMinute: Double = 20 * 60
  /// True solar elevation last applied to the scene; drives the night fast-forward during playback
  /// so the timeline races through darkness and eases back to normal across twilight. Starts high
  /// (daytime → normal speed) until the first `applySolar` populates it.
  private var lastSolarElevationDeg: Double = 90

  /// Minutes in a full day — the timeline spans 00:00…24:00 regardless of the daylight window.
  private static let dayMinutes: Double = 24 * 60

  /// Property location (defaults to central Tashkent — the app's market).
  var siteLatitude = SolarPosition.tashkentLatitude
  var siteLongitude = SolarPosition.tashkentLongitude
  var siteTimeZone = SolarPosition.tashkentTimeZone

  /// Daylight bounds of the currently primed day (minutes since midnight), for the clock arc.
  var daylightSunriseMinute: Double { sunriseMinute }
  var daylightSunsetMinute: Double { sunsetMinute }
  /// The time-of-day the timeline currently points at (minutes since midnight).
  var currentTimelineMinute: Double { Double(timeSlider.value) }

  init(strings: SunSimulationStrings) {
    self.strings = strings
    super.init(frame: .zero)
    setup()
  }

  required init?(coder: NSCoder) {
    self.strings = .englishFallback
    super.init(coder: coder)
    setup()
  }

  deinit {
    animationTimer?.invalidate()
  }

  override var isHidden: Bool {
    didSet {
      if isHidden { stopPlayback() }
    }
  }

  func setAzimuth(_ degrees: Float, notify: Bool = false) {
    suppressCallbacks = !notify
    azimuthSlider.value = degrees
    azimuthValueLabel.text = String(format: strings.azimuthFormat, Int(degrees.rounded()))
    suppressCallbacks = false
  }

  func setElevation(_ degrees: Float, notify: Bool = false) {
    suppressCallbacks = !notify
    elevationSlider.value = degrees
    elevationValueLabel.text = String(format: strings.elevationFormat, Int(degrees.rounded()))
    suppressCallbacks = false
  }

  func setIntensity(_ value: CGFloat, notify: Bool = false) {
    suppressCallbacks = !notify
    intensitySlider.value = Float(value)
    suppressCallbacks = false
  }

  /// Reflects an externally-driven animation (e.g. the intro cinematic) on the play/pause button
  /// WITHOUT starting the panel's own playback timer — keeping the two animators from overlapping.
  func setExternalPlayback(active: Bool) {
    if active {
      animationTimer?.invalidate()
      animationTimer = nil
    }
    guard isPlaying != active else { return }
    isPlaying = active
    updatePlayButtonAppearance()
  }

  /// Moves the timeline thumb to mirror an externally-driven sun sweep. The timeline spans the
  /// full 24-hour day, so clamp only to the slider's range (not the daylight window) — otherwise
  /// the thumb stalls at sunset and restarts at sunrise instead of sweeping midnight → midnight.
  func syncTimeline(toMinute minute: Double) {
    let clamped = min(SunSimulationPanel.dayMinutes, max(0, minute))
    timeSlider.value = Float(clamped)
  }

  private func setup() {
    translatesAutoresizingMaskIntoConstraints = false
    backgroundColor = UIColor(red: 0.17, green: 0.17, blue: 0.19, alpha: 0.94)
    layer.cornerRadius = 16
    if #available(iOS 13.0, *) {
      layer.cornerCurve = .continuous
    }
    layer.borderWidth = 1
    layer.borderColor = UIColor.white.withAlphaComponent(0.08).cgColor
    clipsToBounds = true
    isHidden = true

    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .vertical
    stack.spacing = 5
    stack.alignment = .fill
    addSubview(stack)

    // Azimuth / elevation sliders are kept as backing storage (updated via setAzimuth/
    // setElevation) but no longer shown — the timeline drives the sun instead.
    configureBackingSlider(azimuthSlider, min: 0, max: 360,
                           value: SunPositionMath.TimePreset.noon.azimuthDeg,
                           action: #selector(azimuthChanged))
    configureBackingSlider(elevationSlider, min: 0, max: 90,
                           value: SunPositionMath.TimePreset.noon.elevationDeg,
                           action: #selector(elevationChanged))

    presetStack.axis = .horizontal
    presetStack.spacing = 8
    presetStack.distribution = .fillEqually
    presetStack.addArrangedSubview(presetButton(strings.morning, preset: .morning))
    presetStack.addArrangedSubview(presetButton(strings.noon, preset: .noon))
    presetStack.addArrangedSubview(presetButton(strings.evening, preset: .evening))
    configurePlayButton()
    presetStack.addArrangedSubview(playButton)
    stack.addArrangedSubview(presetStack)

    setupSolarControls()
    stack.addArrangedSubview(solarContainer)

    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
      stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
      stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
      stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
    ])

    // The solar timeline spans the full 24-hour day; daylight bounds still drive the clock arc.
    recomputeDaylight()
    timeSlider.minimumValue = 0
    timeSlider.maximumValue = Float(SunSimulationPanel.dayMinutes)
    timeSlider.value = Float(currentMinuteOfDay())
    rebuildTimeRuler()
  }

  private func configureBackingSlider(
    _ slider: UISlider,
    min: Float,
    max: Float,
    value: Float,
    action: Selector
  ) {
    slider.minimumValue = min
    slider.maximumValue = max
    slider.value = value
    slider.addTarget(self, action: action, for: .valueChanged)
  }

  private func setupSolarControls() {
    solarContainer.axis = .vertical
    solarContainer.spacing = 6
    solarContainer.isHidden = false

    timeSlider.minimumValue = 0
    timeSlider.maximumValue = Float(SunSimulationPanel.dayMinutes)
    timeSlider.value = Float(SunSimulationPanel.dayMinutes / 2)
    timeSlider.tintColor = UIColor(red: 1, green: 0.78, blue: 0.35, alpha: 1)
    timeSlider.addTarget(self, action: #selector(timeScrubbed), for: .valueChanged)
    timeSlider.addTarget(self, action: #selector(timeScrubBegan), for: .touchDown)

    timeLabelsRow.axis = .horizontal
    timeLabelsRow.distribution = .equalSpacing
    timeLabelsRow.alignment = .fill

    solarContainer.addArrangedSubview(timeSlider)
    solarContainer.addArrangedSubview(timeLabelsRow)
  }

  /// Styles the play/pause control to match the time-of-day preset buttons so all four sit
  /// together on the same row.
  private func configurePlayButton() {
    let cfg = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
    playButton.setImage(UIImage(systemName: "play.fill", withConfiguration: cfg), for: .normal)
    // Warm amber fill (matching the timeline tint) with a dark icon so the play/pause control
    // reads as the primary action and visually ties to the timeline it drives.
    playButton.tintColor = UIColor(red: 0.12, green: 0.1, blue: 0.05, alpha: 1)
    playButton.backgroundColor = UIColor(red: 1, green: 0.78, blue: 0.35, alpha: 1)
    playButton.layer.cornerRadius = 10
    if #available(iOS 13.0, *) {
      playButton.layer.cornerCurve = .continuous
    }
    playButton.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)
  }

  private func presetButton(_ title: String, preset: SunPositionMath.TimePreset) -> UIButton {
    let b = UIButton(type: .system)
    let cfg = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
    b.setImage(UIImage(systemName: presetIconName(preset), withConfiguration: cfg), for: .normal)
    b.tintColor = UIColor.white.withAlphaComponent(0.92)
    b.accessibilityLabel = title
    b.backgroundColor = UIColor(red: 0.22, green: 0.22, blue: 0.26, alpha: 1)
    b.layer.cornerRadius = 10
    if #available(iOS 13.0, *) {
      b.layer.cornerCurve = .continuous
    }
    b.contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    b.tag = presetTag(preset)
    b.addTarget(self, action: #selector(presetTapped(_:)), for: .touchUpInside)
    return b
  }

  private func presetIconName(_ preset: SunPositionMath.TimePreset) -> String {
    switch preset {
    case .morning: return "sunrise.fill"
    case .noon: return "sun.max.fill"
    case .evening: return "sunset.fill"
    }
  }

  private func presetTag(_ preset: SunPositionMath.TimePreset) -> Int {
    switch preset {
    case .morning: return 0
    case .noon: return 1
    case .evening: return 2
    }
  }

  private func presetFromTag(_ tag: Int) -> SunPositionMath.TimePreset? {
    switch tag {
    case 0: return .morning
    case 1: return .noon
    case 2: return .evening
    default: return nil
    }
  }

  @objc private func azimuthChanged() {
    let v = azimuthSlider.value
    azimuthValueLabel.text = String(format: strings.azimuthFormat, Int(v.rounded()))
    guard !suppressCallbacks else { return }
    stopPlayback()
    delegate?.sunPanel(self, didChangeAzimuth: v)
  }

  @objc private func elevationChanged() {
    let v = elevationSlider.value
    elevationValueLabel.text = String(format: strings.elevationFormat, Int(v.rounded()))
    guard !suppressCallbacks else { return }
    stopPlayback()
    delegate?.sunPanel(self, didChangeElevation: v)
  }

  @objc private func intensityChanged() {
    guard !suppressCallbacks else { return }
    delegate?.sunPanel(self, didChangeIntensity: CGFloat(intensitySlider.value))
  }

  @objc private func presetTapped(_ sender: UIButton) {
    guard let preset = presetFromTag(sender.tag) else { return }
    stopPlayback()
    setAzimuth(preset.azimuthDeg, notify: false)
    setElevation(preset.elevationDeg, notify: false)
    delegate?.sunPanel(self, didSelectPreset: preset)
    // Presets bypass the solar timeline, so point the clock at a representative daylight time.
    let minute = representativeMinute(for: preset)
    timeSlider.value = Float(clampToDaylight(minute))
    emitTimeChanged(minute)
  }

  /// A clock-friendly time-of-day for each preset (morning / noon / evening) within daylight.
  private func representativeMinute(for preset: SunPositionMath.TimePreset) -> Double {
    let span = max(1, sunsetMinute - sunriseMinute)
    switch preset {
    case .morning: return sunriseMinute + span * 0.2
    case .noon: return sunriseMinute + span * 0.5
    case .evening: return sunsetMinute - span * 0.12
    }
  }

  // MARK: - Solar timeline controls

  @objc private func timeScrubBegan() {
    delegate?.sunPanelDidTakeManualControl(self)
    stopPlayback()
  }

  @objc private func timeScrubbed() {
    applySolar(atMinute: Double(timeSlider.value))
  }

  @objc private func playTapped() {
    // End any externally driven animation first so only one animator drives the sun.
    delegate?.sunPanelDidTakeManualControl(self)
    if isPlaying {
      stopPlayback()
    } else {
      startPlayback()
    }
  }

  private func startPlayback() {
    isPlaying = true
    updatePlayButtonAppearance()
    // Sweep the full daylight portion in ~28s; the night is fast-forwarded (eased across twilight)
    // so playback lingers on the interesting sunrise → shadow-sweep → sunset transitions.
    let stepPerTick = SunSimulationPanel.dayMinutes / (28.0 / 0.05)
    let timer = Timer(timeInterval: 0.05, repeats: true) { [weak self] _ in
      guard let self else { return }
      let speedScale = SolarPosition.nightPlaybackSpeedScale(elevationDeg: self.lastSolarElevationDeg)
      var next = Double(self.timeSlider.value) + stepPerTick * speedScale
      if next >= SunSimulationPanel.dayMinutes { next = 0 }
      self.timeSlider.value = Float(next)
      // applySolar refreshes lastSolarElevationDeg, scaling the next tick.
      self.applySolar(atMinute: next)
    }
    RunLoop.main.add(timer, forMode: .common)
    animationTimer = timer
  }

  private func stopPlayback() {
    animationTimer?.invalidate()
    animationTimer = nil
    isPlaying = false
    updatePlayButtonAppearance()
  }

  /// Computes the real sun azimuth/elevation for today at `minute` (local) and drives the scene.
  private func applySolar(atMinute minute: Double) {
    let date = dateToday(atMinute: minute)
    let pos = SolarPosition.position(
      latitude: siteLatitude,
      longitude: siteLongitude,
      date: date,
      timeZone: siteTimeZone
    )
    lastSolarElevationDeg = pos.elevationDeg
    let azimuth = Float(pos.azimuthDeg)
    let trueElevation = Float(pos.elevationDeg)
    let elevation = max(0, trueElevation)

    setAzimuth(azimuth, notify: false)
    setElevation(elevation, notify: false)
    // Pass the real (possibly below-horizon) elevation so the host can render the night sky;
    // it clamps the geometric lighting elevation to the horizon itself.
    delegate?.sunPanel(self, didAnimateToAzimuth: azimuth, trueElevation: trueElevation)
    emitTimeChanged(minute)
  }

  /// Notifies the host of the current simulated time-of-day so it can drive the analog clock.
  private func emitTimeChanged(_ minute: Double) {
    delegate?.sunPanel(
      self,
      didChangeTimeMinute: minute,
      sunriseMinute: sunriseMinute,
      sunsetMinute: sunsetMinute
    )
  }

  private func recomputeDaylight() {
    if let info = SolarPosition.daylight(
      latitude: siteLatitude,
      longitude: siteLongitude,
      date: Date(),
      timeZone: siteTimeZone
    ) {
      sunriseMinute = max(0, info.sunriseMinute)
      sunsetMinute = min(1439, info.sunsetMinute)
    }
    if sunsetMinute <= sunriseMinute {
      sunriseMinute = 6 * 60
      sunsetMinute = 20 * 60
    }
  }

  private func currentMinuteOfDay() -> Double {
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = siteTimeZone
    let c = cal.dateComponents([.hour, .minute], from: Date())
    return Double(c.hour ?? 12) * 60 + Double(c.minute ?? 0)
  }

  private func clampToDaylight(_ minute: Double) -> Double {
    min(sunsetMinute, max(sunriseMinute, minute))
  }

  private func dateToday(atMinute minute: Double) -> Date {
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = siteTimeZone
    let start = cal.startOfDay(for: Date())
    return start.addingTimeInterval(minute * 60)
  }

  private func updatePlayButtonAppearance() {
    let cfg = UIImage.SymbolConfiguration(pointSize: 17, weight: .semibold)
    let name = isPlaying ? "pause.fill" : "play.fill"
    playButton.setImage(UIImage(systemName: name, withConfiguration: cfg), for: .normal)
  }

  // MARK: - Hour-of-day ruler

  /// Rebuilds the row of hour labels under the timeline across the full 24-hour day
  /// (12 a.m. → 12 a.m.), spaced every few hours so they never crowd the panel.
  private func rebuildTimeRuler() {
    timeLabelsRow.arrangedSubviews.forEach {
      timeLabelsRow.removeArrangedSubview($0)
      $0.removeFromSuperview()
    }

    let step = 3
    var hour = 0
    while hour <= 24 {
      timeLabelsRow.addArrangedSubview(makeHourLabel(hour))
      hour += step
    }
  }

  private func makeHourLabel(_ hour: Int) -> UILabel {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 9, weight: .medium)
    label.textColor = UIColor.white.withAlphaComponent(0.5)
    label.textAlignment = .center
    label.text = formatHourLabel(hour)
    return label
  }

  private func formatHourLabel(_ hour24: Int) -> String {
    let normalized = ((hour24 % 24) + 24) % 24
    let suffix = normalized < 12 ? "a.m." : "p.m."
    var hour12 = normalized % 12
    if hour12 == 0 { hour12 = 12 }
    return "\(hour12) \(suffix)"
  }
}
