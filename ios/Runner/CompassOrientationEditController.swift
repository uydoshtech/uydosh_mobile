import UIKit

struct CompassOrientationEditStrings {
  let title: String
  let message: String
  let cancel: String
  let apply: String
  let reset: String
  let updated: String
  let degreesFormat: String

  static let englishFallback = CompassOrientationEditStrings(
    title: "Adjust north",
    message: "Rotate if the compass does not match reality. Range ±180°.",
    cancel: "Cancel",
    apply: "Apply",
    reset: "Reset to scan",
    updated: "North orientation updated",
    degreesFormat: "%+.0f°"
  )

  init(
    title: String,
    message: String,
    cancel: String,
    apply: String,
    reset: String,
    updated: String,
    degreesFormat: String
  ) {
    self.title = title
    self.message = message
    self.cancel = cancel
    self.apply = apply
    self.reset = reset
    self.updated = updated
    self.degreesFormat = degreesFormat
  }

  init?(dict: [String: String]) {
    guard let title = dict["floorPlanAdjustNorthTitle"] else { return nil }
    self.init(
      title: title,
      message: dict["floorPlanAdjustNorthMessage"]
        ?? "Rotate if the compass does not match reality. Range ±180°.",
      cancel: dict["floorPlanEditDimensionCancel"] ?? "Cancel",
      apply: dict["floorPlanEditDimensionApply"] ?? "Apply",
      reset: dict["floorPlanAdjustNorthReset"] ?? "Reset to scan",
      updated: dict["floorPlanAdjustNorthUpdated"] ?? "North orientation updated",
      degreesFormat: dict["floorPlanAdjustNorthDegreesFormat"] ?? "%+.0f°"
    )
  }
}

/// Presents a slider to manually correct floor-plan compass north.
final class CompassOrientationEditController {
  private let strings: CompassOrientationEditStrings
  private var previewCorrection: Double = 0
  private var committedCorrection: Double = 0

  init(strings: CompassOrientationEditStrings) {
    self.strings = strings
  }

  func present(
    from presenter: UIViewController,
    currentCorrection: Double,
    onPreview: @escaping (Double) -> Void,
    onCommit: @escaping (Double) -> Void,
    onReset: @escaping () -> Void
  ) {
    committedCorrection = currentCorrection
    previewCorrection = currentCorrection

    let sheet = CompassOrientationAdjustViewController(
      strings: strings,
      initialCorrection: currentCorrection
    )
    sheet.onPreview = { [weak self] value in
      self?.previewCorrection = value
      onPreview(value)
    }
    sheet.onApply = { [weak self] value in
      self?.committedCorrection = value
      onCommit(value)
      self?.showConfirmation(from: presenter)
    }
    sheet.onReset = {
      onReset()
      self.showConfirmation(from: presenter)
    }
    sheet.onCancel = {
      onPreview(self.committedCorrection)
    }

    if let popover = sheet.popoverPresentationController {
      popover.sourceView = presenter.view
      popover.sourceRect = CGRect(
        x: presenter.view.bounds.maxX - 72,
        y: presenter.view.safeAreaInsets.top + 8,
        width: 1,
        height: 1
      )
    }
    presenter.present(sheet, animated: true)
  }

  private func showConfirmation(from presenter: UIViewController) {
    let toast = UILabel()
    toast.text = strings.updated
    toast.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
    toast.textColor = .white
    toast.backgroundColor = UIColor(white: 0.12, alpha: 0.92)
    toast.textAlignment = .center
    toast.layer.cornerRadius = 14
    toast.clipsToBounds = true
    toast.alpha = 0
    toast.translatesAutoresizingMaskIntoConstraints = false
    presenter.view.addSubview(toast)
    NSLayoutConstraint.activate([
      toast.centerXAnchor.constraint(equalTo: presenter.view.centerXAnchor),
      toast.topAnchor.constraint(equalTo: presenter.view.safeAreaLayoutGuide.topAnchor, constant: 56),
      toast.heightAnchor.constraint(equalToConstant: 34),
      toast.widthAnchor.constraint(greaterThanOrEqualToConstant: 200),
    ])
    toast.layoutIfNeeded()
    toast.bounds = toast.bounds.insetBy(dx: -16, dy: 0)
    UIView.animate(withDuration: 0.2, animations: {
      toast.alpha = 1
    }) { _ in
      UIView.animate(withDuration: 0.25, delay: 1.2, options: [], animations: {
        toast.alpha = 0
      }) { _ in
        toast.removeFromSuperview()
      }
    }
  }
}

private final class CompassOrientationAdjustViewController: UIViewController {
  var onPreview: ((Double) -> Void)?
  var onApply: ((Double) -> Void)?
  var onReset: (() -> Void)?
  var onCancel: (() -> Void)?

  private let strings: CompassOrientationEditStrings
  private let initialCorrection: Double
  private let slider = UISlider()
  private let valueLabel = UILabel()

  init(strings: CompassOrientationEditStrings, initialCorrection: Double) {
    self.strings = strings
    self.initialCorrection = initialCorrection
    super.init(nibName: nil, bundle: nil)
    modalPresentationStyle = .formSheet
    preferredContentSize = CGSize(width: 340, height: 220)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.systemBackground

    let titleLabel = UILabel()
    titleLabel.text = strings.title
    titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
    titleLabel.translatesAutoresizingMaskIntoConstraints = false

    let messageLabel = UILabel()
    messageLabel.text = strings.message
    messageLabel.font = UIFont.systemFont(ofSize: 13)
    messageLabel.textColor = UIColor.secondaryLabel
    messageLabel.numberOfLines = 0
    messageLabel.translatesAutoresizingMaskIntoConstraints = false

    valueLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 28, weight: .semibold)
    valueLabel.textAlignment = .center
    valueLabel.translatesAutoresizingMaskIntoConstraints = false
    updateValueLabel(initialCorrection)

    slider.minimumValue = -180
    slider.maximumValue = 180
    slider.value = Float(initialCorrection)
    slider.addTarget(self, action: #selector(sliderChanged), for: .valueChanged)
    slider.translatesAutoresizingMaskIntoConstraints = false

    let buttonRow = UIStackView()
    buttonRow.axis = .horizontal
    buttonRow.spacing = 8
    buttonRow.distribution = .fillEqually
    buttonRow.translatesAutoresizingMaskIntoConstraints = false

    let cancel = makeButton(strings.cancel, style: .secondary, action: #selector(cancelTapped))
    let reset = makeButton(strings.reset, style: .secondary, action: #selector(resetTapped))
    let apply = makeButton(strings.apply, style: .primary, action: #selector(applyTapped))
    buttonRow.addArrangedSubview(cancel)
    buttonRow.addArrangedSubview(reset)
    buttonRow.addArrangedSubview(apply)

    view.addSubview(titleLabel)
    view.addSubview(messageLabel)
    view.addSubview(valueLabel)
    view.addSubview(slider)
    view.addSubview(buttonRow)

    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
      titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

      messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 6),
      messageLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
      messageLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),

      valueLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
      valueLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

      slider.topAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 8),
      slider.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
      slider.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

      buttonRow.topAnchor.constraint(equalTo: slider.bottomAnchor, constant: 20),
      buttonRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      buttonRow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      buttonRow.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -12),
      buttonRow.heightAnchor.constraint(equalToConstant: 40),
    ])
  }

  @objc private func sliderChanged() {
    let stepped = (Double(slider.value) / 1.0).rounded() * 1.0
    slider.value = Float(stepped)
    updateValueLabel(stepped)
    onPreview?(stepped)
  }

  @objc private func cancelTapped() {
    dismiss(animated: true) { [weak self] in
      self?.onCancel?()
    }
  }

  @objc private func applyTapped() {
    let value = Double(slider.value).rounded()
    dismiss(animated: true) { [weak self] in
      self?.onApply?(value)
    }
  }

  @objc private func resetTapped() {
    slider.value = 0
    updateValueLabel(0)
    onPreview?(0)
    dismiss(animated: true) { [weak self] in
      self?.onReset?()
    }
  }

  private func updateValueLabel(_ value: Double) {
    valueLabel.text = String(format: strings.degreesFormat, value)
  }

  private func makeButton(_ title: String, style: ButtonStyle, action: Selector) -> UIButton {
    let button = UIButton(type: .system)
    button.setTitle(title, for: .normal)
    button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
    button.layer.cornerRadius = 10
    if #available(iOS 13.0, *) {
      button.layer.cornerCurve = .continuous
    }
    switch style {
    case .primary:
      button.backgroundColor = UIColor(red: 0.29, green: 0.23, blue: 0.18, alpha: 1)
      button.setTitleColor(.white, for: .normal)
    case .secondary:
      button.backgroundColor = UIColor.secondarySystemFill
      button.setTitleColor(.label, for: .normal)
    }
    button.addTarget(self, action: action, for: .touchUpInside)
    return button
  }

  private enum ButtonStyle {
    case primary
    case secondary
  }
}
