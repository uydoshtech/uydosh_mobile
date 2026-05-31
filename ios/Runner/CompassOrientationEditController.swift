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

/// Manages inline north-orientation panel on the viewer canvas (no modal sheet).
final class CompassOrientationEditController: CompassOrientationAdjustPanelDelegate {
  private let strings: CompassOrientationEditStrings
  private let panel: CompassOrientationAdjustPanel
  private weak var hostView: UIView?
  private weak var presenter: UIViewController?
  private var onPreview: ((Double) -> Void)?
  private var onCommit: ((Double) -> Void)?
  private var onReset: (() -> Void)?
  private var committedCorrection: Double = 0
  private var panelTopConstraint: NSLayoutConstraint?
  var onVisibilityChanged: (() -> Void)?

  var isExpanded: Bool {
    panel.superview != nil && !panel.isHidden
  }

  var panelView: UIView { panel }

  init(strings: CompassOrientationEditStrings) {
    self.strings = strings
    panel = CompassOrientationAdjustPanel(strings: strings)
    panel.delegate = self
  }

  /// Mount once under the viewer root view; visibility toggled with [showPanel] / [hidePanel].
  func installIfNeeded(in hostView: UIView) {
    guard panel.superview == nil else { return }
    self.hostView = hostView
    panel.translatesAutoresizingMaskIntoConstraints = false
    panel.alpha = 0
    hostView.addSubview(panel)
    let top = panel.topAnchor.constraint(equalTo: hostView.safeAreaLayoutGuide.topAnchor, constant: 8)
    panelTopConstraint = top
    NSLayoutConstraint.activate([
      top,
      panel.leadingAnchor.constraint(equalTo: hostView.safeAreaLayoutGuide.leadingAnchor, constant: 16),
      panel.trailingAnchor.constraint(equalTo: hostView.safeAreaLayoutGuide.trailingAnchor, constant: -16),
    ])
  }

  func updateTopAnchor(_ anchor: NSLayoutYAxisAnchor, constant: CGFloat) {
    guard panel.superview != nil else { return }
    panelTopConstraint?.isActive = false
    let top = panel.topAnchor.constraint(equalTo: anchor, constant: constant)
    panelTopConstraint = top
    top.isActive = true
  }

  func showPanel(
    topAnchor: NSLayoutYAxisAnchor,
    topConstant: CGFloat,
    presenter: UIViewController,
    currentCorrection: Double,
    onPreview: @escaping (Double) -> Void,
    onCommit: @escaping (Double) -> Void,
    onReset: @escaping () -> Void
  ) {
    guard let hostView else { return }
    self.presenter = presenter
    self.onPreview = onPreview
    self.onCommit = onCommit
    self.onReset = onReset
    committedCorrection = currentCorrection
    updateTopAnchor(topAnchor, constant: topConstant)

    panel.beginSession(committedCorrection: currentCorrection)
    panel.isHidden = false
    hostView.bringSubviewToFront(panel)
    UIView.animate(withDuration: 0.22, delay: 0, options: [.curveEaseOut]) {
      self.panel.alpha = 1
    }
    onVisibilityChanged?()
  }

  func hidePanel(revertPreview: Bool) {
    guard !panel.isHidden else { return }
    if revertPreview {
      onPreview?(committedCorrection)
    }
    UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseIn]) {
      self.panel.alpha = 0
    } completion: { _ in
      self.panel.isHidden = true
      self.onVisibilityChanged?()
    }
  }

  func togglePanel(
    in hostView: UIView,
    topAnchor: NSLayoutYAxisAnchor,
    topConstant: CGFloat,
    presenter: UIViewController,
    currentCorrection: Double,
    onPreview: @escaping (Double) -> Void,
    onCommit: @escaping (Double) -> Void,
    onReset: @escaping () -> Void
  ) {
    installIfNeeded(in: hostView)
    if isExpanded {
      hidePanel(revertPreview: true)
      return
    }
    showPanel(
      topAnchor: topAnchor,
      topConstant: topConstant,
      presenter: presenter,
      currentCorrection: currentCorrection,
      onPreview: onPreview,
      onCommit: onCommit,
      onReset: onReset
    )
  }

  func showConfirmation(from presenter: UIViewController) {
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
      UIView.animate(withDuration: 0.25, delay: 1.0, options: [], animations: {
        toast.alpha = 0
      }) { _ in
        toast.removeFromSuperview()
      }
    }
  }

  func northPanel(_ panel: CompassOrientationAdjustPanel, didPreviewCorrection degrees: Double) {
    onPreview?(degrees)
  }

  func northPanelDidApply(_ panel: CompassOrientationAdjustPanel, correction degrees: Double) {
    committedCorrection = degrees
    onCommit?(degrees)
    hidePanel(revertPreview: false)
    if let presenter {
      showConfirmation(from: presenter)
    }
  }

  func northPanelDidReset(_ panel: CompassOrientationAdjustPanel) {
    committedCorrection = 0
    onReset?()
    if let presenter {
      showConfirmation(from: presenter)
    }
  }

  func northPanelDidDismiss(_ panel: CompassOrientationAdjustPanel, revertPreview: Bool) {
    hidePanel(revertPreview: revertPreview)
  }
}
