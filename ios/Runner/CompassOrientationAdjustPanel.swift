import UIKit

protocol CompassOrientationAdjustPanelDelegate: AnyObject {
  func northPanel(_ panel: CompassOrientationAdjustPanel, didPreviewCorrection degrees: Double)
  func northPanelDidApply(_ panel: CompassOrientationAdjustPanel, correction degrees: Double)
  func northPanelDidReset(_ panel: CompassOrientationAdjustPanel)
  func northPanelDidDismiss(_ panel: CompassOrientationAdjustPanel, revertPreview: Bool)
}

/// Inline north-orientation controls overlaid on the 3D canvas (no modal sheet).
final class CompassOrientationAdjustPanel: UIView {
  weak var delegate: CompassOrientationAdjustPanelDelegate?

  private let strings: CompassOrientationEditStrings
  private let stack = UIStackView()
  private let valueLabel = UILabel()
  private let slider = UISlider()
  private let doneButton = UIButton(type: .system)
  private let closeButton = UIButton(type: .system)
  private var suppressCallbacks = false
  private var sessionCommittedCorrection: Double = 0

  init(strings: CompassOrientationEditStrings) {
    self.strings = strings
    super.init(frame: .zero)
    setup()
  }

  required init?(coder: NSCoder) {
    self.strings = .englishFallback
    super.init(coder: coder)
    setup()
  }

  func beginSession(committedCorrection: Double) {
    sessionCommittedCorrection = committedCorrection
    setCorrection(committedCorrection, notify: false)
  }

  func setCorrection(_ degrees: Double, notify: Bool = false) {
    suppressCallbacks = !notify
    let stepped = (degrees / 1.0).rounded()
    slider.value = Float(stepped)
    valueLabel.text = String(format: strings.degreesFormat, stepped)
    suppressCallbacks = false
  }

  private func setup() {
    translatesAutoresizingMaskIntoConstraints = false
    backgroundColor = UIColor(red: 0.14, green: 0.15, blue: 0.19, alpha: 0.94)
    layer.cornerRadius = 16
    if #available(iOS 13.0, *) {
      layer.cornerCurve = .continuous
    }
    layer.borderWidth = 1
    layer.borderColor = UIColor(red: 1, green: 0.78, blue: 0.35, alpha: 0.28).cgColor
    clipsToBounds = true
    isHidden = true

    stack.translatesAutoresizingMaskIntoConstraints = false
    stack.axis = .vertical
    stack.spacing = 6
    stack.alignment = .fill
    addSubview(stack)

    let header = UIStackView()
    header.axis = .horizontal
    header.alignment = .center
    header.spacing = 8

    let titleStack = UIStackView()
    titleStack.axis = .vertical
    titleStack.spacing = 2
    titleStack.alignment = .leading

    let titleLabel = UILabel()
    titleLabel.text = strings.title
    titleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
    titleLabel.textColor = UIColor.white.withAlphaComponent(0.95)

    let messageLabel = UILabel()
    messageLabel.text = strings.message
    messageLabel.font = UIFont.systemFont(ofSize: 10, weight: .regular)
    messageLabel.textColor = UIColor.white.withAlphaComponent(0.58)
    messageLabel.numberOfLines = 2

    titleStack.addArrangedSubview(titleLabel)
    titleStack.addArrangedSubview(messageLabel)

    closeButton.translatesAutoresizingMaskIntoConstraints = false
    let closeCfg = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
    closeButton.setImage(UIImage(systemName: "xmark", withConfiguration: closeCfg), for: .normal)
    closeButton.tintColor = UIColor.white.withAlphaComponent(0.72)
    closeButton.backgroundColor = UIColor.white.withAlphaComponent(0.08)
    closeButton.layer.cornerRadius = 14
    if #available(iOS 13.0, *) {
      closeButton.layer.cornerCurve = .continuous
    }
    closeButton.accessibilityLabel = strings.cancel
    closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
    NSLayoutConstraint.activate([
      closeButton.widthAnchor.constraint(equalToConstant: 28),
      closeButton.heightAnchor.constraint(equalToConstant: 28),
    ])

    header.addArrangedSubview(titleStack)
    header.addArrangedSubview(UIView())
    header.addArrangedSubview(closeButton)

    valueLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 22, weight: .semibold)
    valueLabel.textColor = UIColor(red: 1, green: 0.82, blue: 0.45, alpha: 1)
    valueLabel.textAlignment = .center

    slider.minimumValue = -180
    slider.maximumValue = 180
    slider.tintColor = UIColor(red: 1, green: 0.78, blue: 0.35, alpha: 1)
    slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)

    let tickRow = UIStackView()
    tickRow.axis = .horizontal
    tickRow.distribution = .equalSpacing
    for tick in ["−180°", "0°", "+180°"] {
      let label = UILabel()
      label.text = tick
      label.font = UIFont.monospacedDigitSystemFont(ofSize: 9, weight: .medium)
      label.textColor = UIColor.white.withAlphaComponent(0.38)
      tickRow.addArrangedSubview(label)
    }

    configureActionButton(doneButton, title: strings.apply, primary: true)
    doneButton.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)

    let buttonRow = UIStackView(arrangedSubviews: [doneButton])
    buttonRow.axis = .horizontal
    buttonRow.spacing = 8
    buttonRow.distribution = .fill

    stack.addArrangedSubview(header)
    stack.addArrangedSubview(valueLabel)
    stack.addArrangedSubview(slider)
    stack.addArrangedSubview(tickRow)
    stack.addArrangedSubview(buttonRow)

    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: topAnchor, constant: 10),
      stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 14),
      stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -14),
      stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10),
      buttonRow.heightAnchor.constraint(equalToConstant: 34),
    ])
  }

  private func configureActionButton(_ button: UIButton, title: String, primary: Bool) {
    button.setTitle(title, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
    button.layer.cornerRadius = 10
    if #available(iOS 13.0, *) {
      button.layer.cornerCurve = .continuous
    }
    if primary {
      button.backgroundColor = UIColor(red: 0.36, green: 0.28, blue: 0.18, alpha: 1)
      button.setTitleColor(UIColor(red: 1, green: 0.9, blue: 0.7, alpha: 1), for: .normal)
    } else {
      button.backgroundColor = UIColor.white.withAlphaComponent(0.1)
      button.setTitleColor(UIColor.white.withAlphaComponent(0.88), for: .normal)
    }
  }

  @objc private func sliderChanged() {
    let stepped = (Double(slider.value) / 1.0).rounded()
    slider.value = Float(stepped)
    valueLabel.text = String(format: strings.degreesFormat, stepped)
    guard !suppressCallbacks else { return }
    delegate?.northPanel(self, didPreviewCorrection: stepped)
  }

  @objc private func closeTapped() {
    delegate?.northPanelDidDismiss(self, revertPreview: true)
  }

  @objc private func doneTapped() {
    let value = Double(slider.value).rounded()
    sessionCommittedCorrection = value
    delegate?.northPanelDidApply(self, correction: value)
  }
}
