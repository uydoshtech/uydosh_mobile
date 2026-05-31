import UIKit

/// Compact compass showing N/E/S/W and current sun azimuth on the 3D viewport.
final class SunCompassOverlayView: UIControl {
  var azimuthDeg: Float = 0 {
    didSet { setNeedsDisplay() }
  }

  var usesTrueNorth: Bool = false {
    didSet { setNeedsDisplay() }
  }

  /// Screen-space angle (radians) where geographic north points; `nil` = N fixed at top of widget.
  var northScreenAngleRad: CGFloat? {
    didSet { setNeedsDisplay() }
  }

  /// When true, overlay accepts taps to open north-orientation correction (listing owner).
  var isOrientationEditable: Bool = false {
    didSet {
      isEnabled = isOrientationEditable
      isUserInteractionEnabled = true
      accessibilityTraits = isOrientationEditable ? [.button] : [.image]
      setNeedsDisplay()
    }
  }

  private let valuesLabel = UILabel()

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }

  func update(
    azimuthDeg: Float,
    elevationDeg: Float,
    azimuthFormat: String,
    elevationFormat: String,
    northScreenAngleRad: CGFloat? = nil
  ) {
    self.azimuthDeg = azimuthDeg
    self.northScreenAngleRad = northScreenAngleRad
    valuesLabel.text = String(
      format: "%@ · %@",
      String(format: azimuthFormat, Int(azimuthDeg.rounded())),
      String(format: elevationFormat, Int(elevationDeg.rounded()))
    )
    setNeedsDisplay()
  }

  private func setup() {
    isOpaque = false
    isUserInteractionEnabled = true
    backgroundColor = UIColor(red: 0.12, green: 0.14, blue: 0.18, alpha: 0.72)
    layer.cornerRadius = 14
    if #available(iOS 13.0, *) {
      layer.cornerCurve = .continuous
    }
    layer.borderWidth = 1
    layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
    clipsToBounds = true

    valuesLabel.translatesAutoresizingMaskIntoConstraints = false
    valuesLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 10, weight: .medium)
    valuesLabel.textColor = UIColor.white.withAlphaComponent(0.9)
    valuesLabel.textAlignment = .center
    valuesLabel.numberOfLines = 2
    addSubview(valuesLabel)

    NSLayoutConstraint.activate([
      widthAnchor.constraint(equalToConstant: 88),
      valuesLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 3),
      valuesLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -3),
      valuesLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -3),
    ])
  }

  override func draw(_ rect: CGRect) {
    guard let ctx = UIGraphicsGetCurrentContext() else { return }
    let center = CGPoint(x: rect.midX, y: rect.midY - 8)
    let radius: CGFloat = 28

    ctx.setFillColor(UIColor.white.withAlphaComponent(0.08).cgColor)
    ctx.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
    ctx.fillPath()

    ctx.setStrokeColor(UIColor.white.withAlphaComponent(0.25).cgColor)
    ctx.setLineWidth(0.75)
    ctx.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
    ctx.strokePath()

    // Rotate rose so N aligns with calibrated north projected onto the current 3D view.
    let northRad = northScreenAngleRad ?? (-CGFloat.pi / 2)
    drawCardinal("N", angle: northRad, center: center, radius: radius, color: UIColor(red: 0.95, green: 0.45, blue: 0.4, alpha: 1))
    drawCardinal("E", angle: northRad + .pi / 2, center: center, radius: radius, color: UIColor.white.withAlphaComponent(0.85))
    drawCardinal("S", angle: northRad + .pi, center: center, radius: radius, color: UIColor.white.withAlphaComponent(0.75))
    drawCardinal("W", angle: northRad - .pi / 2, center: center, radius: radius, color: UIColor.white.withAlphaComponent(0.75))

    let sunRad = northRad + CGFloat(azimuthDeg) * .pi / 180
    let sunTip = point(onCircle: center, radius: radius - 4, angle: sunRad)
    let sunBaseL = point(onCircle: center, radius: radius - 14, angle: sunRad, lateral: -3)
    let sunBaseR = point(onCircle: center, radius: radius - 14, angle: sunRad, lateral: 3)
    ctx.setFillColor(UIColor(red: 1, green: 0.82, blue: 0.2, alpha: 1).cgColor)
    ctx.move(to: sunTip)
    ctx.addLine(to: sunBaseL)
    ctx.addLine(to: sunBaseR)
    ctx.closePath()
    ctx.fillPath()

    ctx.setStrokeColor(UIColor(red: 1, green: 0.9, blue: 0.4, alpha: 0.5).cgColor)
    ctx.setLineWidth(1.5)
    ctx.move(to: center)
    ctx.addLine(to: sunTip)
    ctx.strokePath()

    if isOrientationEditable {
      ctx.setStrokeColor(UIColor(red: 1, green: 0.78, blue: 0.35, alpha: 0.55).cgColor)
      ctx.setLineWidth(1.25)
      ctx.addEllipse(in: CGRect(x: center.x - radius - 2, y: center.y - radius - 2, width: (radius + 2) * 2, height: (radius + 2) * 2))
      ctx.strokePath()
    }
  }

  private func drawCardinal(
    _ text: String,
    angle: CGFloat,
    center: CGPoint,
    radius: CGFloat,
    color: UIColor
  ) {
    let p = point(onCircle: center, radius: radius - 6, angle: angle)
    let font = UIFont.systemFont(ofSize: 9, weight: .bold)
    let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
    let size = (text as NSString).size(withAttributes: attrs)
    (text as NSString).draw(
      at: CGPoint(x: p.x - size.width * 0.5, y: p.y - size.height * 0.5),
      withAttributes: attrs
    )
  }

  private func point(onCircle center: CGPoint, radius: CGFloat, angle: CGFloat, lateral: CGFloat = 0) -> CGPoint {
    let nx = cos(angle)
    let ny = sin(angle)
    return CGPoint(
      x: center.x + nx * radius - ny * lateral,
      y: center.y + ny * radius + nx * lateral
    )
  }
}
