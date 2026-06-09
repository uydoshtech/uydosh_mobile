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
      let fill = object.isOutsideBounds
        ? UIColor.systemOrange.withAlphaComponent(0.30)
        : fillColor
      let stroke = object.isOutsideBounds
        ? UIColor.systemOrange
        : strokeColor
      context.setFillColor(fill.cgColor)
      context.setStrokeColor(stroke.cgColor)
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
  struct LabelHitRegion {
    var dimensionId: UUID
    var rect: CGRect
    var editKind: DimensionEditKind
  }

  static func draw(
    lines: [DimensionLine],
    in context: CGContext,
    transform: FloorPlanViewTransform,
    color: UIColor,
    highlightedDimensionId: UUID? = nil
  ) -> [LabelHitRegion] {
    var hits: [LabelHitRegion] = []
    for line in lines {
      if let hit = draw(
        line,
        in: context,
        transform: transform,
        color: color,
        highlightedDimensionId: highlightedDimensionId
      ) {
        hits.append(hit)
      }
    }
    return hits
  }

  private static func draw(
    _ line: DimensionLine,
    in context: CGContext,
    transform: FloorPlanViewTransform,
    color: UIColor,
    highlightedDimensionId: UUID?
  ) -> LabelHitRegion? {
    let start = transform.planToScreen(line.start)
    let end = transform.planToScreen(line.end)
    let dx = end.x - start.x
    let dy = end.y - start.y
    let len = hypot(dx, dy)
    guard len > 2 else { return nil }

    let isHighlighted = line.id == highlightedDimensionId
    let strokeColor = line.isEditable
      ? (isHighlighted ? UIColor.systemBlue : color)
      : color
    let dirX = dx / len
    let dirY = dy / len
    let perpX = -dirY
    let perpY = dirX
    let tick = max(4, transform.scale * 0.035)
    let lineWidth = max(0.65, transform.scale * 0.007)
    let witnessWidth = max(0.5, transform.scale * 0.005)

    context.saveGState()
    context.setStrokeColor(strokeColor.cgColor)
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
    let textColor = line.isEditable ? UIColor.systemBlue : strokeColor
    let attrs: [NSAttributedString.Key: Any] = [
      .font: UIFont.monospacedDigitSystemFont(ofSize: fontSize, weight: line.isEditable ? .semibold : .regular),
      .foregroundColor: textColor,
    ]
    let text = line.label as NSString
    let size = text.size(withAttributes: attrs)
    let labelGap = max(6, transform.scale * 0.05)
    let mid = CGPoint(
      x: (start.x + end.x) * 0.5 + perpX * labelGap,
      y: (start.y + end.y) * 0.5 + perpY * labelGap
    )
    let textOrigin = CGPoint(x: mid.x - size.width * 0.5, y: mid.y - size.height * 0.5)
    let padH: CGFloat = line.isEditable ? 8 : 4
    let padV: CGFloat = 3
    let bgRect = CGRect(
      x: textOrigin.x - padH,
      y: textOrigin.y - padV,
      width: size.width + padH * 2,
      height: size.height + padV * 2
    )
    let bgFill = line.isEditable
      ? UIColor.systemBlue.withAlphaComponent(isHighlighted ? 0.18 : 0.10)
      : UIColor(white: 1, alpha: 0.92)
    context.setFillColor(bgFill.cgColor)
    context.fill(bgRect)
    context.setStrokeColor((line.isEditable ? UIColor.systemBlue : strokeColor).withAlphaComponent(0.35).cgColor)
    context.setLineWidth(line.isEditable ? 1 : 0.5)
    context.stroke(bgRect)
    text.draw(at: textOrigin, withAttributes: attrs)

    if line.isEditable, let icon = UIImage(systemName: "pencil")?.withTintColor(
      UIColor.systemBlue.withAlphaComponent(0.85),
      renderingMode: .alwaysOriginal
    ) {
      let iconSide = min(11, bgRect.height - 2)
      icon.draw(in: CGRect(
        x: bgRect.maxX - iconSide - 2,
        y: bgRect.midY - iconSide * 0.5,
        width: iconSide,
        height: iconSide
      ))
    }

    context.restoreGState()

    guard line.isEditable, let editKind = line.editKind else { return nil }
    return LabelHitRegion(dimensionId: line.id, rect: bgRect.insetBy(dx: -6, dy: -6), editKind: editKind)
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

/// Draws a fixed compass rose showing scan/world axes on the 2D floor plan canvas.
enum FloorPlanOrientationOverlayRenderer {
  private static let radius: CGFloat = 24
  private static let cornerInset: CGFloat = 14

  static func draw(
    in context: CGContext,
    canvasSize: CGSize,
    model: FloorPlanModel,
    transform: FloorPlanViewTransform
  ) {
    let northPlanAngle = northPlanAngle(for: model)
    let screenNorth = screenAngle(
      forPlanAngle: northPlanAngle,
      pivot: model.planCenter,
      transform: transform
    )

    let center = CGPoint(
      x: canvasSize.width - cornerInset - radius,
      y: cornerInset + radius
    )

    let fill = UIColor.white.withAlphaComponent(0.92)
    let stroke = UIColor(red: 0.28, green: 0.34, blue: 0.42, alpha: 0.35)
    let labelColor = UIColor(red: 0.35, green: 0.41, blue: 0.48, alpha: 0.95)
    let northColor = UIColor(red: 0.78, green: 0.22, blue: 0.24, alpha: 1)

    context.setFillColor(fill.cgColor)
    context.setStrokeColor(stroke.cgColor)
    context.setLineWidth(1)
    context.addEllipse(in: CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2))
    context.drawPath(using: .fillStroke)

    context.setStrokeColor(stroke.cgColor)
    context.setLineWidth(0.75)
    context.move(to: point(onCircle: center, angle: screenNorth, inset: 6))
    context.addLine(to: point(onCircle: center, angle: screenNorth + .pi, inset: 10))
    context.move(to: point(onCircle: center, angle: screenNorth + .pi / 2, inset: 6))
    context.addLine(to: point(onCircle: center, angle: screenNorth - .pi / 2, inset: 6))
    context.strokePath()

    if model.orientationUsesTrueNorth {
      let tip = point(onCircle: center, angle: screenNorth, inset: 4)
      let left = point(onCircle: center, angle: screenNorth, inset: 13, lateral: -4.5)
      let right = point(onCircle: center, angle: screenNorth, inset: 13, lateral: 4.5)
      context.setFillColor(northColor.cgColor)
      context.move(to: tip)
      context.addLine(to: left)
      context.addLine(to: right)
      context.closePath()
      context.fillPath()

      drawLabel("N", at: point(onCircle: center, angle: screenNorth, inset: 2), color: northColor)
      drawLabel("E", at: point(onCircle: center, angle: screenNorth + .pi / 2, inset: 3), color: labelColor)
      drawLabel("S", at: point(onCircle: center, angle: screenNorth + .pi, inset: 2), color: labelColor)
      drawLabel("W", at: point(onCircle: center, angle: screenNorth - .pi / 2, inset: 3), color: labelColor)
      let caption: String
      if model.orientationHasGeographicNorth {
        caption = model.orientationNorthIsAdjusted ? "True N · adj" : "True N"
      } else {
        caption = model.orientationNorthIsAdjusted ? "Scan N · adj" : "Scan N"
      }
      drawCaption(caption, near: center, emphasized: model.orientationHasGeographicNorth)
    }
  }

  private static func northPlanAngle(for model: FloorPlanModel) -> CGFloat {
    if let trueNorth = model.orientationTrueNorthPlanAngleRad {
      return trueNorth
    }
    return model.orientationEastPlanAngleRad + .pi / 2
  }

  private static func screenAngle(
    forPlanAngle planAngle: CGFloat,
    pivot: FloorPlanPoint2D,
    transform: FloorPlanViewTransform
  ) -> CGFloat {
    let origin = transform.planToScreen(pivot)
    let probe = transform.planToScreen(
      FloorPlanPoint2D(
        x: pivot.x + cos(planAngle) * 0.05,
        y: pivot.y + sin(planAngle) * 0.05
      )
    )
    return atan2(probe.y - origin.y, probe.x - origin.x)
  }

  private static func point(
    onCircle center: CGPoint,
    angle: CGFloat,
    inset: CGFloat,
    lateral: CGFloat = 0
  ) -> CGPoint {
    let radial = radius - inset
    let nx = cos(angle)
    let ny = sin(angle)
    return CGPoint(
      x: center.x + nx * radial - ny * lateral,
      y: center.y + ny * radial + nx * lateral
    )
  }

  private static func drawLabel(_ text: String, at center: CGPoint, color: UIColor) {
    let font = UIFont.systemFont(ofSize: 10, weight: .bold)
    let attrs: [NSAttributedString.Key: Any] = [
      .font: font,
      .foregroundColor: color,
    ]
    let size = (text as NSString).size(withAttributes: attrs)
    let rect = CGRect(
      x: center.x - size.width * 0.5,
      y: center.y - size.height * 0.5,
      width: size.width,
      height: size.height
    )
    (text as NSString).draw(in: rect, withAttributes: attrs)
  }

  private static func drawScanAxesCaption(near center: CGPoint) {
    drawCaption("Not compass", near: center, emphasized: false)
  }

  private static func drawCaption(_ text: String, near center: CGPoint, emphasized: Bool) {
    let font = UIFont.systemFont(ofSize: emphasized ? 8 : 7, weight: .semibold)
    let color = emphasized
      ? UIColor(red: 0.35, green: 0.41, blue: 0.48, alpha: 0.9)
      : UIColor(red: 0.78, green: 0.22, blue: 0.24, alpha: 0.85)
    let attrs: [NSAttributedString.Key: Any] = [
      .font: font,
      .foregroundColor: color,
    ]
    let size = (text as NSString).size(withAttributes: attrs)
    let rect = CGRect(
      x: center.x - size.width * 0.5,
      y: center.y + radius + 2,
      width: size.width,
      height: size.height
    )
    (text as NSString).draw(in: rect, withAttributes: attrs)
  }
}

/// Temporary diagnostics overlay: projected wall endpoints, computed 2D bounding box and object
/// centers. Driven through the same `FloorPlanViewTransform` as every other layer so it reflects the
/// exact projection being rendered. Toggle via `FloorPlanDebug.isEnabled`.
enum FloorPlanDebugRenderer {
  static func draw(
    in context: CGContext,
    model: FloorPlanModel,
    transform: FloorPlanViewTransform
  ) {
    context.saveGState()

    let boundsCorners = [
      FloorPlanPoint2D(x: model.bounds.minX, y: model.bounds.minY),
      FloorPlanPoint2D(x: model.bounds.maxX, y: model.bounds.minY),
      FloorPlanPoint2D(x: model.bounds.maxX, y: model.bounds.maxY),
      FloorPlanPoint2D(x: model.bounds.minX, y: model.bounds.maxY),
    ].map { transform.planToScreen($0) }
    context.setStrokeColor(UIColor.systemPink.withAlphaComponent(0.9).cgColor)
    context.setLineWidth(1)
    context.setLineDash(phase: 0, lengths: [5, 4])
    context.move(to: boundsCorners[0])
    for corner in boundsCorners.dropFirst() { context.addLine(to: corner) }
    context.closePath()
    context.strokePath()
    context.setLineDash(phase: 0, lengths: [])

    context.setFillColor(UIColor.systemRed.cgColor)
    for wall in model.walls {
      for endpoint in [wall.start, wall.end] {
        let p = transform.planToScreen(endpoint)
        context.fillEllipse(in: CGRect(x: p.x - 3, y: p.y - 3, width: 6, height: 6))
      }
    }

    context.setFillColor(UIColor.systemGreen.cgColor)
    for object in model.objects {
      let p = transform.planToScreen(object.center)
      context.fillEllipse(in: CGRect(x: p.x - 2.5, y: p.y - 2.5, width: 5, height: 5))
    }

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
    // Mirror the 3D top-down orthographic framing (RoomUsdzViewerViewController.applyTopDownPlanCamera)
    // so the plan appears at the same scale as the 3D view from the top. After alignment the long
    // footprint edge is horizontal, so `overallLength` maps to width and `overallWidth` to height.
    // The 3D camera uses orthographicScale == halfHeight (meters), i.e. on-screen scale = viewH / (2*halfHeight).
    let aspect = max(size.width, 1) / max(size.height, 1)
    let footprintPadding: CGFloat = 1.12
    let floorLong = max(model.overallLength, 0.5)
    let floorShort = max(model.overallWidth, 0.5)
    let halfHeight = max(floorShort * 0.5, floorLong * 0.5 / aspect) * footprintPadding
    let baseScale = max(size.height, 1) / (2 * halfHeight)
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
