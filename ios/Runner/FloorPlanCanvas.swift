import UIKit

/// Interactive 2D blueprint canvas with zoom, pan, and layered rendering.
final class FloorPlanCanvas: UIView {
  var model: FloorPlanModel? {
    didSet { setNeedsDisplay() }
  }

  private var sourceModel: FloorPlanModel?

  var autoAlignEnabled = true {
    didSet {
      guard oldValue != autoAlignEnabled else { return }
      applyDisplayModel()
    }
  }

  var dimensionMode: FloorPlanDimensionMode = .overall {
    didSet { setNeedsDisplay() }
  }

  var showObjects = true {
    didSet { setNeedsDisplay() }
  }

  var showGrid = true {
    didSet { setNeedsDisplay() }
  }

  private var userScale: CGFloat = 1
  private var userPan = CGPoint.zero
  private var pinchBaseScale: CGFloat = 1
  private var panGesture: UIPanGestureRecognizer?
  private var pinchGesture: UIPinchGestureRecognizer?

  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    commonInit()
  }

  private func commonInit() {
    backgroundColor = UIColor(red: 0.95, green: 0.97, blue: 0.99, alpha: 1)
    isMultipleTouchEnabled = true
    contentMode = .redraw

    let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
    addGestureRecognizer(pan)
    panGesture = pan

    let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch(_:)))
    addGestureRecognizer(pinch)
    pinchGesture = pinch
  }

  func resetView(animated: Bool = true) {
    let apply = {
      self.userScale = 1
      self.userPan = .zero
      self.setNeedsDisplay()
    }
    if animated {
      UIView.animate(withDuration: 0.22, animations: apply)
    } else {
      apply()
    }
  }

  func configure(sourceModel: FloorPlanModel, autoAlignEnabled: Bool = true) {
    self.sourceModel = sourceModel
    self.autoAlignEnabled = autoAlignEnabled
    applyDisplayModel()
    resetView(animated: false)
  }

  func clearModel() {
    sourceModel = nil
    model = nil
  }

  private func applyDisplayModel() {
    guard let source = sourceModel else {
      model = nil
      return
    }
    model = autoAlignEnabled
      ? FloorPlanAlignmentService.alignToLongestWall(source)
      : source
  }

  @objc private func handlePan(_ gr: UIPanGestureRecognizer) {
    let t = gr.translation(in: self)
    gr.setTranslation(.zero, in: self)
    userPan.x += t.x
    userPan.y += t.y
    setNeedsDisplay()
  }

  @objc private func handlePinch(_ gr: UIPinchGestureRecognizer) {
    switch gr.state {
    case .began:
      pinchBaseScale = userScale
    case .changed:
      userScale = max(0.35, min(8, pinchBaseScale * gr.scale))
      setNeedsDisplay()
    case .ended, .cancelled, .failed:
      pinchBaseScale = userScale
    default:
      break
    }
  }

  override func draw(_ rect: CGRect) {
    guard let model = model, let ctx = UIGraphicsGetCurrentContext() else { return }

    let transform = FloorPlanViewTransform.fit(
      model: model,
      in: bounds.size,
      userScale: userScale,
      userPan: userPan
    )

    if showGrid {
      FloorPlanGridRenderer.draw(
        in: ctx,
        bounds: expandedBounds(model.bounds, padding: 0.8),
        transform: transform,
        color: UIColor(red: 0.72, green: 0.78, blue: 0.86, alpha: 0.55)
      )
    }

    if model.walls.isEmpty {
      FloorPlanBoundaryRenderer.draw(
        boundary: model.boundary,
        in: ctx,
        transform: transform,
        strokeColor: UIColor(red: 0.18, green: 0.24, blue: 0.34, alpha: 1),
        lineWidth: 1
      )
    }

    let wallColor = UIColor(red: 0.12, green: 0.16, blue: 0.24, alpha: 1)
    FloorPlanWallRenderer.draw(
      walls: model.walls,
      in: ctx,
      transform: transform,
      strokeColor: wallColor,
      lineWidth: max(3, transform.scale * 0.045)
    )

    FloorPlanOpeningRenderer.draw(
      doors: model.doors,
      windows: model.windows,
      openings: model.openings,
      in: ctx,
      transform: transform,
      wallColor: wallColor
    )

    if showObjects {
      FloorPlanObjectRenderer.draw(
        objects: model.objects,
        in: ctx,
        transform: transform,
        fillColor: UIColor(red: 0.78, green: 0.86, blue: 0.92, alpha: 0.75),
        strokeColor: UIColor(red: 0.22, green: 0.38, blue: 0.48, alpha: 1),
        showLabels: true
      )
    }

    let dimensionColor = UIColor(red: 0.28, green: 0.34, blue: 0.42, alpha: 0.95)
    switch dimensionMode {
    case .overall:
      DimensionLineRenderer.draw(
        lines: model.overallDimensions,
        in: ctx,
        transform: transform,
        color: dimensionColor
      )
    case .wallSegments:
      DimensionLineRenderer.draw(
        lines: model.wallSegmentDimensions,
        in: ctx,
        transform: transform,
        color: dimensionColor
      )
    case .hidden:
      break
    }
  }

  private func expandedBounds(_ bounds: FloorPlanBounds, padding: CGFloat) -> FloorPlanBounds {
    FloorPlanBounds(
      minX: bounds.minX - padding,
      maxX: bounds.maxX + padding,
      minY: bounds.minY - padding,
      maxY: bounds.maxY + padding
    )
  }
}
