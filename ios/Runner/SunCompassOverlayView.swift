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

  /// When true, draws the gold editable ring (owner on 3D tab).
  var isOrientationEditable: Bool = false {
    didSet { setNeedsDisplay() }
  }

  /// When true, the compass accepts taps (separate from ring visuals).
  var acceptsOrientationTaps: Bool = false {
    didSet {
      isUserInteractionEnabled = acceptsOrientationTaps
      isEnabled = true
    }
  }

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
    setNeedsDisplay()
  }

  override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
    guard acceptsOrientationTaps else { return false }
    // Slightly larger target than the 88×88 widget — taps near the edge still open adjust.
    return bounds.insetBy(dx: -12, dy: -12).contains(point)
  }

  private func setup() {
    isOpaque = false
    isUserInteractionEnabled = false
    isEnabled = true
    backgroundColor = UIColor(red: 0.12, green: 0.14, blue: 0.18, alpha: 0.72)
    layer.cornerRadius = 14
    if #available(iOS 13.0, *) {
      layer.cornerCurve = .continuous
    }
    layer.borderWidth = 1
    layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
    clipsToBounds = true

    NSLayoutConstraint.activate([
      widthAnchor.constraint(equalToConstant: 88),
      heightAnchor.constraint(equalToConstant: 88),
    ])
  }

  override func draw(_ rect: CGRect) {
    guard let ctx = UIGraphicsGetCurrentContext() else { return }
    let center = CGPoint(x: rect.midX, y: rect.midY)
    let radius: CGFloat = 28

    ctx.setFillColor(UIColor.white.withAlphaComponent(0.08).cgColor)
    ctx.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
    ctx.fillPath()

    ctx.setStrokeColor(UIColor.white.withAlphaComponent(0.25).cgColor)
    ctx.setLineWidth( 0.75)
    ctx.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
    ctx.strokePath()

    let northRad = northScreenAngleRad ?? (-CGFloat.pi / 2)
    drawCardinal("N", angle: northRad, center: center, radius: radius, color: UIColor(red: 0.95, green: 0.45, blue: 0.4, alpha: 1))
    drawCardinal("E", angle: northRad + .pi / 2, center: center, radius: radius, color: UIColor.white.withAlphaComponent(0.85))
    drawCardinal("S", angle: northRad + .pi, center: center, radius: radius, color: UIColor.white.withAlphaComponent(0.75))
    drawCardinal("W", angle: northRad - .pi / 2, center: center, radius: radius, color: UIColor.white.withAlphaComponent(0.75))

    let sunRad = northRad + CGFloat(azimuthDeg) * .pi / 180
    let sunCoreRadius: CGFloat = 4.5

    // Arrow shaft + head grow outward from the sun glyph toward the sun's azimuth.
    let sunTip = point(onCircle: center, radius: radius - 4, angle: sunRad)
    let shaftStart = point(onCircle: center, radius: sunCoreRadius + 1.5, angle: sunRad)
    ctx.setStrokeColor(UIColor(red: 1, green: 0.85, blue: 0.3, alpha: 0.95).cgColor)
    ctx.setLineWidth(2)
    ctx.setLineCap(.round)
    ctx.move(to: shaftStart)
    ctx.addLine(to: sunTip)
    ctx.strokePath()

    let sunBaseL = point(onCircle: center, radius: radius - 11, angle: sunRad, lateral: -3.5)
    let sunBaseR = point(onCircle: center, radius: radius - 11, angle: sunRad, lateral: 3.5)
    ctx.setFillColor(UIColor(red: 1, green: 0.82, blue: 0.2, alpha: 1).cgColor)
    ctx.move(to: sunTip)
    ctx.addLine(to: sunBaseL)
    ctx.addLine(to: sunBaseR)
    ctx.closePath()
    ctx.fillPath()

    // Sun icon at the very center, drawn last so the arrow reads as emanating from it.
    drawSunGlyph(ctx, center: center, coreRadius: sunCoreRadius)

    if isOrientationEditable {
      ctx.setStrokeColor(UIColor(red: 1, green: 0.78, blue: 0.35, alpha: 0.55).cgColor)
      ctx.setLineWidth(1.25)
      ctx.addEllipse(in: CGRect(x: center.x - radius - 2, y: center.y - radius - 2, width: (radius + 2) * 2, height: (radius + 2) * 2))
      ctx.strokePath()
    }
  }

  /// Small yellow sun (core disk + short rays) for the center of the compass.
  private func drawSunGlyph(_ ctx: CGContext, center: CGPoint, coreRadius: CGFloat) {
    let yellow = UIColor(red: 1, green: 0.82, blue: 0.2, alpha: 1)

    ctx.setStrokeColor(yellow.withAlphaComponent(0.9).cgColor)
    ctx.setLineWidth(1)
    ctx.setLineCap(.round)
    let rayInner = coreRadius + 1.5
    let rayOuter = coreRadius + 3.5
    for i in 0..<8 {
      let a = CGFloat(i) * .pi / 4
      ctx.move(to: CGPoint(x: center.x + cos(a) * rayInner, y: center.y + sin(a) * rayInner))
      ctx.addLine(to: CGPoint(x: center.x + cos(a) * rayOuter, y: center.y + sin(a) * rayOuter))
    }
    ctx.strokePath()

    ctx.setFillColor(yellow.cgColor)
    ctx.addEllipse(
      in: CGRect(x: center.x - coreRadius, y: center.y - coreRadius, width: coreRadius * 2, height: coreRadius * 2)
    )
    ctx.fillPath()
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
