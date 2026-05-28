import CoreGraphics
import UIKit

/// Blueprint-style drawing helpers for floor plan elements.
enum FloorPlanWallRenderer {
  static func draw(
    walls: [FloorPlanWall],
    in context: CGContext,
    transform: FloorPlanViewTransform,
    strokeColor: UIColor,
    lineWidth: CGFloat
  ) {
    context.saveGState()
    context.setStrokeColor(strokeColor.cgColor)
    context.setLineWidth(lineWidth)
    context.setLineCap(.square)
    context.setLineJoin(.miter)

    for wall in walls {
      let start = transform.planToScreen(wall.start)
      let end = transform.planToScreen(wall.end)
      let dx = end.x - start.x
      let dy = end.y - start.y
      let len = hypot(dx, dy)
      guard len > 0.5 else { continue }
      let extra = CGFloat(wall.thickness) * transform.scale * 0.5
      let nx = dx / len * extra
      let ny = dy / len * extra
      context.move(to: CGPoint(x: start.x - nx, y: start.y - ny))
      context.addLine(to: CGPoint(x: end.x + nx, y: end.y + ny))
    }
    context.strokePath()
    context.restoreGState()
  }
}

enum FloorPlanObjectRenderer {
  static func draw(
    objects: [FloorPlanObject],
    in context: CGContext,
    transform: FloorPlanViewTransform,
    fillColor: UIColor,
    strokeColor: UIColor,
    showLabels: Bool
  ) {
    for object in objects {
      guard object.corners.count >= 3 else { continue }
      let screenCorners = object.corners.map { transform.planToScreen($0) }
      guard screenCorners.count >= 3 else { continue }

      context.saveGState()
      context.setFillColor(fillColor.cgColor)
      context.setStrokeColor(strokeColor.cgColor)
      context.setLineWidth(max(1, transform.scale * 0.015))
      context.move(to: screenCorners[0])
      for point in screenCorners.dropFirst() {
        context.addLine(to: point)
      }
      context.closePath()
      context.drawPath(using: .fillStroke)
      context.restoreGState()

      let center = transform.planToScreen(object.center)
      let avgSpan = object.corners.enumerated().dropFirst().map { idx, corner in
        hypot(corner.x - object.corners[idx - 1].x, corner.y - object.corners[idx - 1].y)
      }.reduce(0, +) / CGFloat(max(object.corners.count - 1, 1))
      let labelSpan = avgSpan * transform.scale

      if showLabels, labelSpan > 22 {
        let fontSize = min(11, max(8, transform.scale * 0.08))
        let attrs: [NSAttributedString.Key: Any] = [
          .font: UIFont.systemFont(ofSize: fontSize, weight: .medium),
          .foregroundColor: strokeColor.withAlphaComponent(0.85),
        ]
        let text = object.label as NSString
        let size = text.size(withAttributes: attrs)
        let origin = CGPoint(x: center.x - size.width * 0.5, y: center.y - size.height * 0.5)
        text.draw(at: origin, withAttributes: attrs)
      }
    }
  }
}

enum FloorPlanOpeningRenderer {
  static func draw(
    doors: [FloorPlanOpening],
    windows: [FloorPlanOpening],
    openings: [FloorPlanOpening],
    in context: CGContext,
    transform: FloorPlanViewTransform,
    wallColor: UIColor
  ) {
    for door in doors {
      drawDoor(door, in: context, transform: transform, color: wallColor)
    }
    for window in windows {
      drawWindow(window, in: context, transform: transform)
    }
    for opening in openings {
      drawGenericOpening(opening, in: context, transform: transform, color: wallColor)
    }
  }

  private static func drawDoor(
    _ door: FloorPlanOpening,
    in context: CGContext,
    transform: FloorPlanViewTransform,
    color: UIColor
  ) {
    let start = transform.planToScreen(door.start)
    let end = transform.planToScreen(door.end)
    context.saveGState()
    context.setStrokeColor(UIColor.systemBlue.withAlphaComponent(0.85).cgColor)
    context.setLineWidth(max(2.5, transform.scale * 0.03))
    context.setLineCap(.butt)
    context.move(to: start)
    context.addLine(to: end)
    context.strokePath()

    let dx = end.x - start.x
    let dy = end.y - start.y
    let len = hypot(dx, dy)
    guard len > 4 else {
      context.restoreGState()
      return
    }
    let radius = len * 0.85
    let angle = atan2(dy, dx)
    context.setStrokeColor(color.withAlphaComponent(0.55).cgColor)
    context.setLineWidth(max(1, transform.scale * 0.012))
    context.addArc(
      center: start,
      radius: radius,
      startAngle: angle,
      endAngle: angle + .pi / 2,
      clockwise: false
    )
    context.strokePath()
    context.restoreGState()
  }

  private static func drawWindow(
    _ window: FloorPlanOpening,
    in context: CGContext,
    transform: FloorPlanViewTransform
  ) {
    let start = transform.planToScreen(window.start)
    let end = transform.planToScreen(window.end)
    context.saveGState()
    context.setStrokeColor(UIColor.systemTeal.withAlphaComponent(0.9).cgColor)
    context.setLineWidth(max(1.5, transform.scale * 0.018))
    context.setLineCap(.butt)
    context.move(to: start)
    context.addLine(to: end)
    context.strokePath()

    let dx = end.x - start.x
    let dy = end.y - start.y
    let len = hypot(dx, dy)
    guard len > 2 else {
      context.restoreGState()
      return
    }
    let nx = -dy / len * 2
    let ny = dx / len * 2
    context.move(to: CGPoint(x: start.x + nx, y: start.y + ny))
    context.addLine(to: CGPoint(x: end.x + nx, y: end.y + ny))
    context.strokePath()
    context.restoreGState()
  }

  private static func drawGenericOpening(
    _ opening: FloorPlanOpening,
    in context: CGContext,
    transform: FloorPlanViewTransform,
    color: UIColor
  ) {
    let start = transform.planToScreen(opening.start)
    let end = transform.planToScreen(opening.end)
    context.saveGState()
    context.setStrokeColor(color.withAlphaComponent(0.45).cgColor)
    context.setLineWidth(max(2, transform.scale * 0.02))
    context.setLineDash(phase: 0, lengths: [4, 3])
    context.move(to: start)
    context.addLine(to: end)
    context.strokePath()
    context.restoreGState()
  }
}

enum DimensionLineRenderer {
  static func draw(
    lines: [DimensionLine],
    in context: CGContext,
    transform: FloorPlanViewTransform,
    color: UIColor
  ) {
    for line in lines {
      draw(line, in: context, transform: transform, color: color)
    }
  }

  private static func draw(
    _ line: DimensionLine,
    in context: CGContext,
    transform: FloorPlanViewTransform,
    color: UIColor
  ) {
    let start = transform.planToScreen(line.start)
    let end = transform.planToScreen(line.end)
    let dx = end.x - start.x
    let dy = end.y - start.y
    let len = hypot(dx, dy)
    guard len > 2 else { return }

    let dirX = dx / len
    let dirY = dy / len
    let perpX = -dirY
    let perpY = dirX
    let tick = max(4, transform.scale * 0.035)
    let lineWidth = max(0.65, transform.scale * 0.007)
    let witnessWidth = max(0.5, transform.scale * 0.005)

    context.saveGState()
    context.setStrokeColor(color.cgColor)
    context.setLineCap(.butt)
    context.setLineJoin(.miter)

    if let witnessStart = line.witnessStart, let witnessEnd = line.witnessEnd {
      let wStart = transform.planToScreen(witnessStart)
      let wEnd = transform.planToScreen(witnessEnd)
      context.setLineWidth(witnessWidth)
      context.setLineDash(phase: 0, lengths: [])
      context.move(to: wStart)
      context.addLine(to: start)
      context.move(to: wEnd)
      context.addLine(to: end)
      context.strokePath()
    }

    context.setLineWidth(lineWidth)
    context.setLineDash(phase: 0, lengths: [])
    context.move(to: start)
    context.addLine(to: end)
    context.strokePath()

    func drawArchitecturalTick(at point: CGPoint) {
      let half = tick * 0.5
      let slashX = (dirX + perpX) * half
      let slashY = (dirY + perpY) * half
      context.move(to: CGPoint(x: point.x - slashX, y: point.y - slashY))
      context.addLine(to: CGPoint(x: point.x + slashX, y: point.y + slashY))
      context.strokePath()
    }
    drawArchitecturalTick(at: start)
    drawArchitecturalTick(at: end)

    let fontSize = max(9, min(12, transform.scale * 0.085))
    let attrs: [NSAttributedString.Key: Any] = [
      .font: UIFont.monospacedDigitSystemFont(ofSize: fontSize, weight: .regular),
      .foregroundColor: color,
    ]
    let text = line.label as NSString
    let size = text.size(withAttributes: attrs)
    let labelGap = max(6, transform.scale * 0.05)
    let mid = CGPoint(
      x: (start.x + end.x) * 0.5 + perpX * labelGap,
      y: (start.y + end.y) * 0.5 + perpY * labelGap
    )
    let textOrigin = CGPoint(x: mid.x - size.width * 0.5, y: mid.y - size.height * 0.5)
    let padH: CGFloat = 4
    let padV: CGFloat = 2
    let bgRect = CGRect(
      x: textOrigin.x - padH,
      y: textOrigin.y - padV,
      width: size.width + padH * 2,
      height: size.height + padV * 2
    )
    context.setFillColor(UIColor(white: 1, alpha: 0.92).cgColor)
    context.fill(bgRect)
    context.setStrokeColor(color.withAlphaComponent(0.25).cgColor)
    context.setLineWidth(0.5)
    context.stroke(bgRect)
    text.draw(at: textOrigin, withAttributes: attrs)
    context.restoreGState()
  }
}

enum FloorPlanBoundaryRenderer {
  static func draw(
    boundary: [FloorPlanPoint2D],
    in context: CGContext,
    transform: FloorPlanViewTransform,
    strokeColor: UIColor,
    lineWidth: CGFloat
  ) {
    guard boundary.count >= 2 else { return }
    context.saveGState()
    context.setStrokeColor(strokeColor.withAlphaComponent(0.35).cgColor)
    context.setLineWidth(lineWidth)
    context.setLineDash(phase: 0, lengths: [6, 4])
    let first = transform.planToScreen(boundary[0])
    context.move(to: first)
    for p in boundary.dropFirst() {
      context.addLine(to: transform.planToScreen(p))
    }
    context.closePath()
    context.strokePath()
    context.restoreGState()
  }
}

enum FloorPlanGridRenderer {
  static func draw(
    in context: CGContext,
    bounds: FloorPlanBounds,
    transform: FloorPlanViewTransform,
    spacingMeters: CGFloat = 1.0,
    color: UIColor
  ) {
    context.saveGState()
    context.setStrokeColor(color.cgColor)
    context.setLineWidth(0.5)

    let minX = floor(bounds.minX / spacingMeters) * spacingMeters
    let maxX = ceil(bounds.maxX / spacingMeters) * spacingMeters
    let minY = floor(bounds.minY / spacingMeters) * spacingMeters
    let maxY = ceil(bounds.maxY / spacingMeters) * spacingMeters

    var x = minX
    while x <= maxX {
      let a = transform.planToScreen(FloorPlanPoint2D(x: x, y: minY))
      let b = transform.planToScreen(FloorPlanPoint2D(x: x, y: maxY))
      context.move(to: a)
      context.addLine(to: b)
      x += spacingMeters
    }
    var y = minY
    while y <= maxY {
      let a = transform.planToScreen(FloorPlanPoint2D(x: minX, y: y))
      let b = transform.planToScreen(FloorPlanPoint2D(x: maxX, y: y))
      context.move(to: a)
      context.addLine(to: b)
      y += spacingMeters
    }
    context.strokePath()
    context.restoreGState()
  }
}

/// Maps plan coordinates (meters, X/−Z) to screen points using the same pivot and yaw
/// as `RoomUsdzViewerViewController.applyTopDownPlanCamera`.
struct FloorPlanViewTransform {
  var scale: CGFloat
  var centerOffset: CGPoint
  var rotation: CGFloat
  var pivot: FloorPlanPoint2D

  func planToScreen(_ point: FloorPlanPoint2D) -> CGPoint {
    let dx = point.x - pivot.x
    let dy = point.y - pivot.y
    let cosA = cos(rotation)
    let sinA = sin(rotation)
    let rx = dx * cosA - dy * sinA
    let ry = dx * sinA + dy * cosA
    return CGPoint(
      x: centerOffset.x + rx * scale,
      y: centerOffset.y - ry * scale
    )
  }

  static func fit(
    model: FloorPlanModel,
    in size: CGSize,
    padding: CGFloat = 48,
    userScale: CGFloat = 1,
    userPan: CGPoint = .zero
  ) -> FloorPlanViewTransform {
    let contentW = max(model.overallLength, model.bounds.width, 0.5)
    let contentH = max(model.overallWidth, model.bounds.height, 0.5)
    let availW = max(size.width - padding * 2, 1)
    let availH = max(size.height - padding * 2, 1)
    let baseScale = min(availW / contentW, availH / contentH)
    let scale = baseScale * userScale
    return FloorPlanViewTransform(
      scale: scale,
      centerOffset: CGPoint(
        x: size.width * 0.5 + userPan.x,
        y: size.height * 0.5 + userPan.y
      ),
      rotation: model.footprintYaw,
      pivot: model.planCenter
    )
  }
}
