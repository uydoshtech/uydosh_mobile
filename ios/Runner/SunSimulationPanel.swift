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
  let today: String
  let now: String
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
    today: String,
    now: String,
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
    self.today = today
    self.now = now
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
      today: dict["sunToday"] ?? "Today",
      now: dict["sunNow"] ?? "Now",
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
    today: "Today",
    now: "Now",
    azimuthFormat: "Az %d°",
    elevationFormat: "El %d°"
  )
}

protocol SunSimulationPanelDelegate: AnyObject {
  func sunPanel(_ panel: SunSimulationPanel, didChangeAzimuth degrees: Float)
  func sunPanel(_ panel: SunSimulationPanel, didChangeElevation degrees: Float)
  func sunPanel(_ panel: SunSimulationPanel, didChangeIntensity value: CGFloat)
  func sunPanel(_ panel: SunSimulationPanel, didSelectPreset preset: SunPositionMath.TimePreset)
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

  // "Today" solar mode: animate the real sun path for the property's location & today's date.
  private let todayButton = UIButton(type: .system)
  private let solarContainer = UIStackView()
  private let solarInfoLabel = UILabel()
  private let timeSlider = UISlider()
  private let nowButton = UIButton(type: .system)
  private let playButton = UIButton(type: .system)
  private var solarMode = false
  private var isPlaying = false
  private var animationTimer: Timer?
  private var sunriseMinute: Double = 6 * 60
  private var sunsetMinute: Double = 20 * 60

  /// Property location (defaults to central Tashkent — the app's market).
  var siteLatitude = SolarPosition.tashkentLatitude
  var siteLongitude = SolarPosition.tashkentLongitude
  var siteTimeZone = SolarPosition.tashkentTimeZone

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
    stack.spacing = 8
    stack.alignment = .fill
    addSubview(stack)

    stack.addArrangedSubview(makeSliderRow(
      title: strings.azimuthLabel,
      slider: azimuthSlider,
      valueLabel: azimuthValueLabel,
      min: 0,
      max: 360,
      value: SunPositionMath.TimePreset.noon.azimuthDeg,
      action: #selector(azimuthChanged)
    ))
    stack.addArrangedSubview(makeSliderRow(
      title: strings.elevationLabel,
      slider: elevationSlider,
      valueLabel: elevationValueLabel,
      min: 0,
      max: 90,
      value: SunPositionMath.TimePreset.noon.elevationDeg,
      action: #selector(elevationChanged)
    ))
    stack.addArrangedSubview(makeSliderRow(
      title: strings.intensityLabel,
      slider: intensitySlider,
      valueLabel: nil,
      min: 400,
      max: 2600,
      value: 1400,
      action: #selector(intensityChanged)
    ))

    presetStack.axis = .horizontal
    presetStack.spacing = 8
    presetStack.distribution = .fillEqually
    presetStack.addArrangedSubview(presetButton(strings.morning, preset: .morning))
    presetStack.addArrangedSubview(presetButton(strings.noon, preset: .noon))
    presetStack.addArrangedSubview(presetButton(strings.evening, preset: .evening))
    stack.addArrangedSubview(presetStack)

    setupSolarControls()
    stack.addArrangedSubview(todayButton)
    stack.addArrangedSubview(solarContainer)

    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
      stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
      stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
      stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
    ])
  }

  private func setupSolarControls() {
    todayButton.setTitle(strings.today, for: .normal)
    todayButton.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
    todayButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
    todayButton.layer.cornerRadius = 10
    if #available(iOS 13.0, *) {
      todayButton.layer.cornerCurve = .continuous
    }
    todayButton.addTarget(self, action: #selector(todayTapped), for: .touchUpInside)
    updateTodayButtonAppearance()

    solarContainer.axis = .vertical
    solarContainer.spacing = 6
    solarContainer.isHidden = true

    solarInfoLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .semibold)
    solarInfoLabel.textColor = UIColor(red: 1, green: 0.85, blue: 0.5, alpha: 1)
    solarInfoLabel.textAlignment = .center

    timeSlider.minimumValue = Float(sunriseMinute)
    timeSlider.maximumValue = Float(sunsetMinute)
    timeSlider.value = Float((sunriseMinute + sunsetMinute) / 2)
    timeSlider.tintColor = UIColor(red: 1, green: 0.78, blue: 0.35, alpha: 1)
    timeSlider.addTarget(self, action: #selector(timeScrubbed), for: .valueChanged)
    timeSlider.addTarget(self, action: #selector(timeScrubBegan), for: .touchDown)

    configureSolarIconButton(nowButton, systemName: "location.fill", title: strings.now)
    nowButton.addTarget(self, action: #selector(nowTapped), for: .touchUpInside)

    configureSolarIconButton(playButton, systemName: "play.fill", title: nil)
    playButton.addTarget(self, action: #selector(playTapped), for: .touchUpInside)

    let controlsRow = UIStackView(arrangedSubviews: [nowButton, timeSlider, playButton])
    controlsRow.axis = .horizontal
    controlsRow.spacing = 8
    controlsRow.alignment = .center

    solarContainer.addArrangedSubview(solarInfoLabel)
    solarContainer.addArrangedSubview(controlsRow)
  }

  private func configureSolarIconButton(_ button: UIButton, systemName: String, title: String?) {
    let cfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
    button.setImage(UIImage(systemName: systemName, withConfiguration: cfg), for: .normal)
    if let title {
      button.setTitle(" " + title, for: .normal)
      button.titleLabel?.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
    }
    button.tintColor = UIColor.white.withAlphaComponent(0.92)
    button.setTitleColor(UIColor.white.withAlphaComponent(0.92), for: .normal)
    button.backgroundColor = UIColor(red: 0.22, green: 0.22, blue: 0.26, alpha: 1)
    button.layer.cornerRadius = 8
    if #available(iOS 13.0, *) {
      button.layer.cornerCurve = .continuous
    }
    button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 9, bottom: 6, right: 9)
    button.setContentHuggingPriority(.required, for: .horizontal)
    button.setContentCompressionResistancePriority(.required, for: .horizontal)
  }

  private func makeSliderRow(
    title: String,
    slider: UISlider,
    valueLabel: UILabel?,
    min: Float,
    max: Float,
    value: Float,
    action: Selector
  ) -> UIStackView {
    let titleLabel = UILabel()
    titleLabel.font = UIFont.systemFont(ofSize: 11, weight: .semibold)
    titleLabel.textColor = UIColor.white.withAlphaComponent(0.75)
    titleLabel.text = title

    slider.minimumValue = min
    slider.maximumValue = max
    slider.value = value
    slider.addTarget(self, action: action, for: .valueChanged)
    slider.tintColor = UIColor(red: 1, green: 0.78, blue: 0.35, alpha: 1)

    let row = UIStackView()
    row.axis = .vertical
    row.spacing = 4

    let header = UIStackView(arrangedSubviews: [titleLabel])
    if let valueLabel {
      valueLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 11, weight: .medium)
      valueLabel.textColor = UIColor.white.withAlphaComponent(0.9)
      valueLabel.textAlignment = .right
      valueLabel.setContentHuggingPriority(.required, for: .horizontal)
      header.addArrangedSubview(valueLabel)
      if title.contains("Azimuth") || title == strings.azimuthLabel {
        valueLabel.text = String(format: strings.azimuthFormat, Int(value.rounded()))
      } else if title == strings.elevationLabel {
        valueLabel.text = String(format: strings.elevationFormat, Int(value.rounded()))
      }
    }
    header.axis = .horizontal
    header.distribution = .equalSpacing

    row.addArrangedSubview(header)
    row.addArrangedSubview(slider)
    return row
  }

  private func presetButton(_ title: String, preset: SunPositionMath.TimePreset) -> UIButton {
    let b = UIButton(type: .system)
    b.setTitle(title, for: .normal)
    b.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .semibold)
    b.setTitleColor(UIColor.white.withAlphaComponent(0.92), for: .normal)
    b.backgroundColor = UIColor(red: 0.22, green: 0.22, blue: 0.26, alpha: 1)
    b.layer.cornerRadius = 10
    if #available(iOS 13.0, *) {
      b.layer.cornerCurve = .continuous
    }
    b.contentEdgeInsets = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
    b.tag = presetTag(preset)
    b.addTarget(self, action: #selector(presetTapped(_:)), for: .touchUpInside)
    return b
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
    exitSolarMode()
    delegate?.sunPanel(self, didChangeAzimuth: v)
  }

  @objc private func elevationChanged() {
    let v = elevationSlider.value
    elevationValueLabel.text = String(format: strings.elevationFormat, Int(v.rounded()))
    guard !suppressCallbacks else { return }
    exitSolarMode()
    delegate?.sunPanel(self, didChangeElevation: v)
  }

  @objc private func intensityChanged() {
    guard !suppressCallbacks else { return }
    delegate?.sunPanel(self, didChangeIntensity: CGFloat(intensitySlider.value))
  }

  @objc private func presetTapped(_ sender: UIButton) {
    guard let preset = presetFromTag(sender.tag) else { return }
    exitSolarMode()
    setAzimuth(preset.azimuthDeg, notify: false)
    setElevation(preset.elevationDeg, notify: false)
    delegate?.sunPanel(self, didSelectPreset: preset)
  }

  // MARK: - Today (real solar path) mode

  @objc private func todayTapped() {
    if solarMode {
      exitSolarMode()
    } else {
      enterSolarMode()
    }
  }

  private func enterSolarMode() {
    solarMode = true
    recomputeDaylight()
    timeSlider.minimumValue = Float(sunriseMinute)
    timeSlider.maximumValue = Float(sunsetMinute)
    let start = clampToDaylight(currentMinuteOfDay())
    timeSlider.value = Float(start)
    solarContainer.isHidden = false
    updateTodayButtonAppearance()
    applySolar(atMinute: start)
  }

  private func exitSolarMode() {
    guard solarMode else { return }
    stopPlayback()
    solarMode = false
    solarContainer.isHidden = true
    updateTodayButtonAppearance()
  }

  @objc private func nowTapped() {
    recomputeDaylight()
    timeSlider.minimumValue = Float(sunriseMinute)
    timeSlider.maximumValue = Float(sunsetMinute)
    let minute = clampToDaylight(currentMinuteOfDay())
    timeSlider.value = Float(minute)
    applySolar(atMinute: minute)
  }

  @objc private func timeScrubBegan() {
    stopPlayback()
  }

  @objc private func timeScrubbed() {
    applySolar(atMinute: Double(timeSlider.value))
  }

  @objc private func playTapped() {
    if isPlaying {
      stopPlayback()
    } else {
      startPlayback()
    }
  }

  private func startPlayback() {
    isPlaying = true
    updatePlayButtonAppearance()
    // Sweep the full daylight span in ~14s, looping back to sunrise at the end.
    let span = max(1, sunsetMinute - sunriseMinute)
    let stepPerTick = span / (14.0 / 0.05)
    let timer = Timer(timeInterval: 0.05, repeats: true) { [weak self] _ in
      guard let self else { return }
      var next = Double(self.timeSlider.value) + stepPerTick
      if next >= self.sunsetMinute { next = self.sunriseMinute }
      self.timeSlider.value = Float(next)
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
    let azimuth = Float(pos.azimuthDeg)
    let elevation = Float(max(0, pos.elevationDeg))

    setAzimuth(azimuth, notify: false)
    setElevation(elevation, notify: false)
    solarInfoLabel.text = String(
      format: "%@ · %@ · %@",
      formatTime(minute: minute),
      String(format: strings.azimuthFormat, Int(pos.azimuthDeg.rounded())),
      String(format: strings.elevationFormat, Int(max(0, pos.elevationDeg).rounded()))
    )
    delegate?.sunPanel(self, didChangeAzimuth: azimuth)
    delegate?.sunPanel(self, didChangeElevation: elevation)
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

  private func formatTime(minute: Double) -> String {
    let total = Int(minute.rounded())
    return String(format: "%02d:%02d", (total / 60) % 24, total % 60)
  }

  private func updateTodayButtonAppearance() {
    if solarMode {
      todayButton.backgroundColor = UIColor(red: 0.36, green: 0.28, blue: 0.18, alpha: 1)
      todayButton.setTitleColor(UIColor(red: 1, green: 0.9, blue: 0.7, alpha: 1), for: .normal)
    } else {
      todayButton.backgroundColor = UIColor(red: 0.22, green: 0.22, blue: 0.26, alpha: 1)
      todayButton.setTitleColor(UIColor.white.withAlphaComponent(0.92), for: .normal)
    }
  }

  private func updatePlayButtonAppearance() {
    let cfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
    let name = isPlaying ? "pause.fill" : "play.fill"
    playButton.setImage(UIImage(systemName: name, withConfiguration: cfg), for: .normal)
  }
}
