import UIKit

/// Compact analog clock for the 3D viewport, sitting beside the compass rose.
///
/// Rather than cram 24 hours onto one dial (which forces unfamiliar `0` / `18` numerals), this
/// reads as an ordinary 12-hour clock face — `12` at top, `3` / `6` / `9` at the cardinals — so the
/// hand position is instantly legible. The full day is covered by two "versions" of the same face:
/// an **AM** half (after midnight, 00:00→12:00) and a **PM** half (after noon, 12:00→24:00), with
/// the current half called out by an `AM` / `PM` badge under the dial.
///
/// The gold arc marks the slice of the daylight window (dawn → dusk) that falls in the current half,
/// and the hand ends in an arrowhead (gold by day, cool blue by night) so the time reads at a glance.
/// A sun ☀ (daylight) or moon ☾ (night) glyph sits at the hub, swapping with the current period.
final class SunClockOverlayView: UIView {
  /// Current simulated time as minutes since local midnight (0...1440). Drives the hand.
  var minuteOfDay: Double = 12 * 60 {
    didSet { setNeedsDisplay() }
  }

  /// Sunrise / sunset of the simulated day, in minutes since midnight — bounds of the gold arc.
  private var sunriseMinute: Double = 6 * 60
  private var sunsetMinute: Double = 20 * 60

  /// Whether the current simulated time falls inside the daylight window. Drives the day/night
  /// skin (sun ↔ moon glyph, warm ↔ cool hand) so the dial reads as "day" or "night" at a glance.
  private var isDaytime: Bool {
    minuteOfDay >= sunriseMinute && minuteOfDay <= sunsetMinute
  }

  /// Which "version" of the dial we're showing: the AM half (after midnight) or the PM half
  /// (after noon). Selects the badge text and clips the daylight arc to the visible half-day.
  private var isAM: Bool { minuteOfDay < 720 }

  /// Accent tint for the current period — warm gold by day, cool blue by night. Shared by the
  /// hand and the AM/PM badge so the skin reads as a single piece.
  private var accentColor: UIColor {
    isDaytime
      ? UIColor(red: 1, green: 0.85, blue: 0.45, alpha: 1)
      : UIColor(red: 0.7, green: 0.78, blue: 0.95, alpha: 1)
  }

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

    // Sun (day) / moon (night) glyph at the hub — drawn last so it caps the hand shaft.
    drawCenterGlyph(ctx, center: center)

    // AM / PM badge in the bottom margin tells which half-day version of the face we're on.
    drawMeridiemBadge(center: center, radius: radius)
  }

  // MARK: - Drawing helpers

  /// Draws the portion of the daylight window (dawn → dusk) that falls inside the half-day the dial
  /// is currently showing. Clipping to one half keeps the arc contiguous on the 12-hour face: in the
  /// AM version it's the morning light, in the PM version the afternoon/evening light.
  private func drawDaylightArc(_ ctx: CGContext, center: CGPoint, radius: CGFloat) {
    guard sunsetMinute > sunriseMinute else { return }
    // Intersect the daylight window with the visible half-day [halfStart, halfStart + 720].
    let halfStart: Double = isAM ? 0 : 720
    let halfEnd = halfStart + 720
    let arcStart = max(sunriseMinute, halfStart)
    let arcEnd = min(sunsetMinute, halfEnd)
    guard arcEnd > arcStart else { return }

    let gold = UIColor(red: 1, green: 0.78, blue: 0.35, alpha: 0.9)
    ctx.setStrokeColor(gold.cgColor)
    ctx.setLineWidth(2.5)
    ctx.setLineCap(.round)

    let steps = 48
    let span = arcEnd - arcStart
    for i in 0...steps {
      let m = arcStart + span * Double(i) / Double(steps)
      let p = point(onDial: center, radius: radius, minute: m)
      if i == 0 {
        ctx.move(to: p)
      } else {
        ctx.addLine(to: p)
      }
    }
    ctx.strokePath()

    // Dawn / dusk end caps — only mark the ones that actually land in this half-day.
    let dot: CGFloat = 2.6
    for m in [sunriseMinute, sunsetMinute] where m >= halfStart && m <= halfEnd {
      let p = point(onDial: center, radius: radius, minute: m)
      ctx.setFillColor(gold.cgColor)
      ctx.addEllipse(in: CGRect(x: p.x - dot, y: p.y - dot, width: dot * 2, height: dot * 2))
      ctx.fillPath()
    }
  }

  private func drawHourTicks(_ ctx: CGContext, center: CGPoint, radius: CGFloat) {
    // 12 ticks for the 12-hour face, with a longer mark at the 12 / 3 / 6 / 9 cardinals.
    for hour in 0..<12 {
      let isMajor = hour % 3 == 0
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

  /// Draws the familiar 12-hour cardinals — 12 / 3 / 6 / 9 at top / right / bottom / left — so the
  /// hand reads like any everyday clock. The AM/PM badge disambiguates which half-day this is.
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
    let handColor = accentColor

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

  /// Hub glyph: a radiant sun while the hand is in daylight, a crescent moon at night.
  private func drawCenterGlyph(_ ctx: CGContext, center: CGPoint) {
    if isDaytime {
      drawSun(ctx, center: center)
    } else {
      drawMoon(ctx, center: center)
    }
  }

  private func drawSun(_ ctx: CGContext, center: CGPoint) {
    let gold = UIColor(red: 1, green: 0.85, blue: 0.45, alpha: 1)

    let core: CGFloat = 3.4
    ctx.setFillColor(gold.cgColor)
    ctx.addEllipse(in: CGRect(x: center.x - core, y: center.y - core, width: core * 2, height: core * 2))
    ctx.fillPath()

    ctx.setStrokeColor(gold.cgColor)
    ctx.setLineWidth(1.2)
    ctx.setLineCap(.round)
    let inner: CGFloat = 4.8
    let outer: CGFloat = 6.8
    for i in 0..<8 {
      let a = CGFloat(i) * .pi / 4
      let d = CGVector(dx: cos(a), dy: sin(a))
      ctx.move(to: CGPoint(x: center.x + inner * d.dx, y: center.y + inner * d.dy))
      ctx.addLine(to: CGPoint(x: center.x + outer * d.dx, y: center.y + outer * d.dy))
    }
    ctx.strokePath()
  }

  private func drawMoon(_ ctx: CGContext, center: CGPoint) {
    let lit = UIColor(red: 0.82, green: 0.87, blue: 1, alpha: 1)
    // Opaque panel tone used to carve the crescent's shadow (matches the widget background).
    let shadow = UIColor(red: 0.12, green: 0.14, blue: 0.18, alpha: 1)

    let r: CGFloat = 6
    ctx.setFillColor(lit.cgColor)
    ctx.addEllipse(in: CGRect(x: center.x - r, y: center.y - r, width: r * 2, height: r * 2))
    ctx.fillPath()

    // Offset disc nudged up-right so the crescent opens toward the lower-left.
    let sr: CGFloat = 5
    let off = CGPoint(x: center.x + 2.4, y: center.y - 1.5)
    ctx.setFillColor(shadow.cgColor)
    ctx.addEllipse(in: CGRect(x: off.x - sr, y: off.y - sr, width: sr * 2, height: sr * 2))
    ctx.fillPath()
  }

  /// `AM` (after midnight) or `PM` (after noon) badge, drawn in the margin below the dial so it
  /// never collides with the numerals or the hand. Tinted with the period accent for quick reading.
  private func drawMeridiemBadge(center: CGPoint, radius: CGFloat) {
    let text = isAM ? "AM" : "PM"
    let attrs: [NSAttributedString.Key: Any] = [
      .font: UIFont.systemFont(ofSize: 9, weight: .bold),
      .foregroundColor: accentColor.withAlphaComponent(0.9),
      .kern: 0.5,
    ]
    let string = NSAttributedString(string: text, attributes: attrs)
    let size = string.size()
    let anchor = CGPoint(x: center.x, y: center.y + radius + 8)
    string.draw(at: CGPoint(x: anchor.x - size.width / 2, y: anchor.y - size.height / 2))
  }

  /// Maps a minute-of-day to a point on the 12-hour dial: 12 at top, 6 at bottom, clockwise.
  private func point(onDial center: CGPoint, radius: CGFloat, minute: Double) -> CGPoint {
    let angle = dialAngle(forMinute: minute)
    return CGPoint(
      x: center.x + radius * sin(angle),
      y: center.y - radius * cos(angle)
    )
  }

  /// Dial angle (radians, clockwise from the top) for a minute-of-day. The hand makes one full
  /// revolution every 12 hours like a normal clock, so 00:00 and 12:00 both land at the top — the
  /// AM/PM badge tells the two halves apart.
  private func dialAngle(forMinute minute: Double) -> CGFloat {
    let twelveHour = minute.truncatingRemainder(dividingBy: 720)
    return CGFloat(twelveHour / 720 * 2 * .pi)
  }

  private static func timeString(forMinute minute: Double) -> String {
    let total = Int(minute.rounded())
    let h = (total / 60) % 24
    let m = total % 60
    return String(format: "%02d:%02d", h, m)
  }
}
