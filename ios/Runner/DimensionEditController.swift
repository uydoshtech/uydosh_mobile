import UIKit

struct DimensionEditDialogStrings {
  let title: String
  let currentLabel: String
  let newValuePlaceholder: String
  let cancel: String
  let apply: String
  let updatedConfirmation: String
  let largeChangeTitle: String
  let largeChangeMessage: String
  let invalidInputTitle: String
  let invalidInputMessage: String
  let confirmLargeChange: String

  static let englishFallback = DimensionEditDialogStrings(
    title: "Edit dimension",
    currentLabel: "Current",
    newValuePlaceholder: "New value (m)",
    cancel: "Cancel",
    apply: "Apply",
    updatedConfirmation: "Dimension updated",
    largeChangeTitle: "Large change",
    largeChangeMessage: "New value differs significantly from the scanned measurement. Apply correction?",
    invalidInputTitle: "Invalid value",
    invalidInputMessage: "Enter a number between 0.5 and 100 meters.",
    confirmLargeChange: "Apply"
  )

  init(
    title: String,
    currentLabel: String,
    newValuePlaceholder: String,
    cancel: String,
    apply: String,
    updatedConfirmation: String,
    largeChangeTitle: String,
    largeChangeMessage: String,
    invalidInputTitle: String,
    invalidInputMessage: String,
    confirmLargeChange: String
  ) {
    self.title = title
    self.currentLabel = currentLabel
    self.newValuePlaceholder = newValuePlaceholder
    self.cancel = cancel
    self.apply = apply
    self.updatedConfirmation = updatedConfirmation
    self.largeChangeTitle = largeChangeTitle
    self.largeChangeMessage = largeChangeMessage
    self.invalidInputTitle = invalidInputTitle
    self.invalidInputMessage = invalidInputMessage
    self.confirmLargeChange = confirmLargeChange
  }

  init?(dict: [String: String]) {
    self.init(
      title: dict["floorPlanEditDimensionTitle"] ?? "Edit dimension",
      currentLabel: dict["floorPlanEditDimensionCurrent"] ?? "Current",
      newValuePlaceholder: dict["floorPlanEditDimensionNewValue"] ?? "New value (m)",
      cancel: dict["floorPlanEditDimensionCancel"] ?? "Cancel",
      apply: dict["floorPlanEditDimensionApply"] ?? "Apply",
      updatedConfirmation: dict["floorPlanEditDimensionUpdated"] ?? "Dimension updated",
      largeChangeTitle: dict["floorPlanEditDimensionLargeChangeTitle"] ?? "Large change",
      largeChangeMessage: dict["floorPlanEditDimensionLargeChangeMessage"]
        ?? "New value differs significantly from the scanned measurement. Apply correction?",
      invalidInputTitle: dict["floorPlanEditDimensionInvalidTitle"] ?? "Invalid value",
      invalidInputMessage: dict["floorPlanEditDimensionInvalidMessage"]
        ?? "Enter a number between 0.5 and 100 meters.",
      confirmLargeChange: dict["floorPlanEditDimensionConfirmLargeChange"] ?? "Apply"
    )
  }
}

/// Handles tap on editable dimension labels and presents the edit dialog.
final class DimensionEditController {
  private let stateManager: FloorPlanStateManager
  private let strings: DimensionEditDialogStrings

  init(stateManager: FloorPlanStateManager, strings: DimensionEditDialogStrings) {
    self.stateManager = stateManager
    self.strings = strings
  }

  func presentEdit(
    for dimensionId: UUID,
    from presenter: UIViewController,
    onApplied: @escaping () -> Void
  ) {
    guard let annotation = stateManager.annotation(for: dimensionId),
      annotation.editable
    else { return }

    let alert = UIAlertController(title: strings.title, message: nil, preferredStyle: .alert)
    alert.addTextField { field in
      field.keyboardType = .decimalPad
      field.placeholder = self.strings.newValuePlaceholder
      field.text = String(format: "%.2f", annotation.measuredValueMeters)
    }
    alert.message = "\(strings.currentLabel): \(annotation.label)"

    alert.addAction(UIAlertAction(title: strings.cancel, style: .cancel))
    alert.addAction(
      UIAlertAction(title: strings.apply, style: .default) { [weak self, weak presenter] _ in
        guard let self else { return }
        let text = alert.textFields?.first?.text ?? ""
        switch FloorPlanResizeService.validateInput(text, currentValue: annotation.measuredValueMeters) {
        case .failure:
          self.presentInvalidInput(from: presenter)
        case .success(let validation):
          if validation.requiresLargeChangeConfirmation {
            self.confirmLargeChange(
              value: validation.valueMeters,
              annotation: annotation,
              from: presenter,
              onApplied: onApplied
            )
          } else {
            self.apply(value: validation.valueMeters, annotation: annotation, from: presenter, onApplied: onApplied)
          }
        }
      }
    )
    presenter.present(alert, animated: true)
  }

  private func confirmLargeChange(
    value: Double,
    annotation: EditableDimensionAnnotation,
    from presenter: UIViewController?,
    onApplied: @escaping () -> Void
  ) {
    let alert = UIAlertController(
      title: strings.largeChangeTitle,
      message: strings.largeChangeMessage,
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: strings.cancel, style: .cancel))
    alert.addAction(
      UIAlertAction(title: strings.confirmLargeChange, style: .default) { [weak self, weak presenter] _ in
        self?.apply(value: value, annotation: annotation, from: presenter, onApplied: onApplied)
      }
    )
    presenter?.present(alert, animated: true)
  }

  private func presentInvalidInput(from presenter: UIViewController?) {
    let alert = UIAlertController(
      title: strings.invalidInputTitle,
      message: strings.invalidInputMessage,
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: strings.cancel, style: .default))
    presenter?.present(alert, animated: true)
  }

  private func apply(
    value: Double,
    annotation: EditableDimensionAnnotation,
    from presenter: UIViewController?,
    onApplied: @escaping () -> Void
  ) {
    stateManager.applyDimensionEdit(annotation: annotation, newValueMeters: value)
    onApplied()
    showConfirmation(from: presenter)
  }

  private func showConfirmation(from presenter: UIViewController?) {
    guard let presenter else { return }
    let toast = UILabel()
    toast.text = strings.updatedConfirmation
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
      toast.widthAnchor.constraint(greaterThanOrEqualToConstant: 180),
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
