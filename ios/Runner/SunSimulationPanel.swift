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

    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: topAnchor, constant: 12),
      stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
      stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -12),
      stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
    ])
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
    delegate?.sunPanel(self, didChangeAzimuth: v)
  }

  @objc private func elevationChanged() {
    let v = elevationSlider.value
    elevationValueLabel.text = String(format: strings.elevationFormat, Int(v.rounded()))
    guard !suppressCallbacks else { return }
    delegate?.sunPanel(self, didChangeElevation: v)
  }

  @objc private func intensityChanged() {
    guard !suppressCallbacks else { return }
    delegate?.sunPanel(self, didChangeIntensity: CGFloat(intensitySlider.value))
  }

  @objc private func presetTapped(_ sender: UIButton) {
    guard let preset = presetFromTag(sender.tag) else { return }
    setAzimuth(preset.azimuthDeg, notify: false)
    setElevation(preset.elevationDeg, notify: false)
    delegate?.sunPanel(self, didSelectPreset: preset)
  }
}
