import UIKit

/// Compact 24-hour analog clock for the 3D viewport, sitting beside the compass rose.
///
/// Noon sits at the top of the dial and midnight at the bottom, so the single hand makes one
/// revolution per simulated day. The gold arc marks the daylight window (dawn → dusk); the hand
/// ends in an arrowhead (gold by day, cool blue by night) so the current time reads at a glance.
/// The 12 / 3 / 6 / 9 numerals are drawn at the cardinal positions as a familiar clock reference.
final class SunClockOverlayView: UIView {
  /// Current simulated time as minutes since local midnight (0...1440). Drives the hand.
  var minuteOfDay: Double = 12 * 60 {
    didSet { setNeedsDisplay() }
  }

  /// Sunrise / sunset of the simulated day, in minutes since midnight — bounds of the gold arc.
  private var sunriseMinute: Double = 6 * 60
  private var sunsetMinute: Double = 20 * 60

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    setup()
  }

  /// Single entry point used by the host: current time plus the day's daylight bounds.
  func update(minuteOfDay minute: Double, sunriseMinute sunrise: Double, sunsetMinute sunset: Double) {
    sunriseMinute = sunrise
    sunsetMinute = sunset
    minuteOfDay = minute.truncatingRemainder(dividingBy: 1440)
    if minuteOfDay < 0 { minuteOfDay += 1440 }
    accessibilityValue = Self.timeString(forMinute: minuteOfDay)
    setNeedsDisplay()
  }

  private func setup() {
    isOpaque = false
    isUserInteractionEnabled = false
    // Match the compass rose panel styling so the two HUD widgets read as a pair.
    backgroundColor = UIColor(red: 0.12, green: 0.14, blue: 0.18, alpha: 0.72)
    layer.cornerRadius = 14
    if #available(iOS 13.0, *) {
      layer.cornerCurve = .continuous
    }
    layer.borderWidth = 1
    layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
    clipsToBounds = true

    isAccessibilityElement = true
    accessibilityLabel = "Time of day"
    accessibilityTraits = .updatesFrequently

    NSLayoutConstraint.activate([
      widthAnchor.constraint(equalToConstant: 88),
      heightAnchor.constraint(equalToConstant: 88),
    ])
  }

  override func draw(_ rect: CGRect) {
    guard let ctx = UIGraphicsGetCurrentContext() else { return }
    let center = CGPoint(x: rect.midX, y: rect.midY)
    let radius: CGFloat = 30

    // Faint full ring (the night portion of the day).
    ctx.setStrokeColor(UIColor.white.withAlphaComponent(0.14).cgColor)
    ctx.setLineWidth(2)
    ctx.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
    ctx.strokePath()

    drawDaylightArc(ctx, center: center, radius: radius)
    drawHourTicks(ctx, center: center, radius: radius)
    drawHourNumerals(center: center, radius: radius)
    drawHand(ctx, center: center, radius: radius)

    // Center hub.
    ctx.setFillColor(UIColor.white.withAlphaComponent(0.9).cgColor)
    ctx.addEllipse(in: CGRect(x: center.x - 2.5, y: center.y - 2.5, width: 5, height: 5))
    ctx.fillPath()
  }

  // MARK: - Drawing helpers

  private func drawDaylightArc(_ ctx: CGContext, center: CGPoint, radius: CGFloat) {
    guard sunsetMinute > sunriseMinute else { return }
    let gold = UIColor(red: 1, green: 0.78, blue: 0.35, alpha: 0.9)
    ctx.setStrokeColor(gold.cgColor)
    ctx.setLineWidth(2.5)
    ctx.setLineCap(.round)

    let steps = 48
    let span = sunsetMinute - sunriseMinute
    for i in 0...steps {
      let m = sunriseMinute + span * Double(i) / Double(steps)
      let p = point(onDial: center, radius: radius, minute: m)
      if i == 0 {
        ctx.move(to: p)
      } else {
        ctx.addLine(to: p)
      }
    }
    ctx.strokePath()

    // Dawn / dusk end caps.
    let dot: CGFloat = 2.6
    for m in [sunriseMinute, sunsetMinute] {
      let p = point(onDial: center, radius: radius, minute: m)
      ctx.setFillColor(gold.cgColor)
      ctx.addEllipse(in: CGRect(x: p.x - dot, y: p.y - dot, width: dot * 2, height: dot * 2))
      ctx.fillPath()
    }
  }

  private func drawHourTicks(_ ctx: CGContext, center: CGPoint, radius: CGFloat) {
    for hour in 0..<24 {
      let isMajor = hour % 6 == 0
      let inner = radius - (isMajor ? 6 : 3)
      let p1 = point(onDial: center, radius: radius - 1.5, minute: Double(hour) * 60)
      let p2 = point(onDial: center, radius: inner, minute: Double(hour) * 60)
      ctx.setStrokeColor(UIColor.white.withAlphaComponent(isMajor ? 0.55 : 0.28).cgColor)
      ctx.setLineWidth(isMajor ? 1.5 : 1)
      ctx.move(to: p1)
      ctx.addLine(to: p2)
      ctx.strokePath()
    }
  }

  /// Draws the 12 / 3 / 6 / 9 numerals at the top / right / bottom / left of the dial.
  private func drawHourNumerals(center: CGPoint, radius: CGFloat) {
    let labelRadius = radius - 11
    let labels: [(String, CGPoint)] = [
      ("12", CGPoint(x: center.x, y: center.y - labelRadius)),
      ("3", CGPoint(x: center.x + labelRadius, y: center.y)),
      ("6", CGPoint(x: center.x, y: center.y + labelRadius)),
      ("9", CGPoint(x: center.x - labelRadius, y: center.y)),
    ]
    let attrs: [NSAttributedString.Key: Any] = [
      .font: UIFont.systemFont(ofSize: 9, weight: .semibold),
      .foregroundColor: UIColor.white.withAlphaComponent(0.6),
    ]
    for (text, anchor) in labels {
      let string = NSAttributedString(string: text, attributes: attrs)
      let size = string.size()
      string.draw(at: CGPoint(x: anchor.x - size.width / 2, y: anchor.y - size.height / 2))
    }
  }

  private func drawHand(_ ctx: CGContext, center: CGPoint, radius: CGFloat) {
    let isDaytime = minuteOfDay >= sunriseMinute && minuteOfDay <= sunsetMinute
    let handColor = isDaytime
      ? UIColor(red: 1, green: 0.85, blue: 0.45, alpha: 1)
      : UIColor(red: 0.7, green: 0.78, blue: 0.95, alpha: 1)

    // Unit vectors along the hand (outward) and perpendicular to it, for the arrowhead.
    let angle = dialAngle(forMinute: minuteOfDay)
    let dir = CGVector(dx: sin(angle), dy: -cos(angle))
    let perp = CGVector(dx: cos(angle), dy: sin(angle))

    let tipRadius = radius - 6
    let tip = CGPoint(x: center.x + tipRadius * dir.dx, y: center.y + tipRadius * dir.dy)

    let arrowLength: CGFloat = 8
    let arrowHalfWidth: CGFloat = 4.5
    let base = CGPoint(x: tip.x - arrowLength * dir.dx, y: tip.y - arrowLength * dir.dy)

    // Shaft stops at the arrowhead base so the two don't overlap awkwardly.
    ctx.setStrokeColor(handColor.withAlphaComponent(0.95).cgColor)
    ctx.setLineWidth(2.5)
    ctx.setLineCap(.round)
    ctx.move(to: center)
    ctx.addLine(to: base)
    ctx.strokePath()

    // Arrowhead.
    let left = CGPoint(x: base.x + arrowHalfWidth * perp.dx, y: base.y + arrowHalfWidth * perp.dy)
    let right = CGPoint(x: base.x - arrowHalfWidth * perp.dx, y: base.y - arrowHalfWidth * perp.dy)
    ctx.setFillColor(handColor.cgColor)
    ctx.move(to: tip)
    ctx.addLine(to: left)
    ctx.addLine(to: right)
    ctx.closePath()
    ctx.fillPath()
  }

  /// Maps a minute-of-day to a point on the dial: noon at top, midnight at bottom, clockwise.
  private func point(onDial center: CGPoint, radius: CGFloat, minute: Double) -> CGPoint {
    let angle = dialAngle(forMinute: minute)
    return CGPoint(
      x: center.x + radius * sin(angle),
      y: center.y - radius * cos(angle)
    )
  }

  /// Dial angle (radians, clockwise from the top) for a minute-of-day; noon → top, midnight → bottom.
  private func dialAngle(forMinute minute: Double) -> CGFloat {
    CGFloat(minute / 1440 * 2 * .pi + .pi)
  }

  private static func timeString(forMinute minute: Double) -> String {
    let total = Int(minute.rounded())
    let h = (total / 60) % 24
    let m = total % 60
    return String(format: "%02d:%02d", h, m)
  }
}
