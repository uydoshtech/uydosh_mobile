import CoreGraphics
import UIKit

/// Telegram mini-app blueprint palette (`FP_COLORS` in listing-detail-floorplan.js).
enum FloorPlanStyle {
  static let wall = UIColor(red: 31 / 255, green: 58 / 255, blue: 84 / 255, alpha: 1)
  static let gridMinor = UIColor(red: 237 / 255, green: 243 / 255, blue: 250 / 255, alpha: 1)
  static let gridMajor = UIColor(red: 216 / 255, green: 228 / 255, blue: 241 / 255, alpha: 1)
  static let furnitureFill = UIColor(red: 242 / 255, green: 166 / 255, blue: 90 / 255, alpha: 0.35)
  static let furnitureStroke = UIColor(red: 217 / 255, green: 145 / 255, blue: 63 / 255, alpha: 1)
  static let windowFill = UIColor(red: 207 / 255, green: 228 / 255, blue: 247 / 255, alpha: 1)
  static let dim = UIColor(red: 43 / 255, green: 98 / 255, blue: 168 / 255, alpha: 1)
  static let dimStroke = UIColor(red: 59 / 255, green: 120 / 255, blue: 194 / 255, alpha: 1)
  /// Fallback opening thickness when wall thickness is unavailable (meters).
  static let openingThicknessMeters: CGFloat = 0.12
  static let gridMinorSpacingMeters: CGFloat = 0.2
  static let gridMajorSpacingMeters: CGFloat = 1.0
  static let gridPaddingMeters: CGFloat = 1.5
}

/// Blueprint-style drawing helpers for floor plan elements.
enum FloorPlanWallRenderer {
  /// Filled wall rectangles (true thickness), matching the Telegram SVG blueprint.
  static func draw(
    walls: [FloorPlanWall],
    in context: CGContext,
    transform: FloorPlanViewTransform,
    fillColor: UIColor
  ) {
    context.saveGState()
    context.setFillColor(fillColor.cgColor)
    for wall in walls {
      guard let path = orientedBandPath(
        start: wall.start,
        end: wall.end,
        thicknessMeters: max(wall.thickness, 0.04),
        transform: transform
      ) else { continue }
      context.addPath(path)
      context.fillPath()
    }
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
      context.setLineWidth(1.4)
      context.setLineJoin(.round)
      context.setLineCap(.round)
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
    wallColor: UIColor,
    planCenter: FloorPlanPoint2D,
    wallThicknessMeters: CGFloat
  ) {
    let thickness = max(wallThicknessMeters, FloorPlanStyle.openingThicknessMeters)
    for opening in openings {
      drawGenericOpening(
        opening,
        in: context,
        transform: transform,
        color: wallColor,
        thicknessMeters: thickness
      )
    }
    for door in doors {
      drawDoor(
        door,
        in: context,
        transform: transform,
        color: wallColor,
        planCenter: planCenter,
        thicknessMeters: thickness
      )
    }
    for window in windows {
      drawWindow(
        window,
        in: context,
        transform: transform,
        wallColor: wallColor,
        thicknessMeters: thickness
      )
    }
  }

  /// White wall cutout + dashed swing arc + door leaf (Telegram `fpDoorEl`).
  private static func drawDoor(
    _ door: FloorPlanOpening,
    in context: CGContext,
    transform: FloorPlanViewTransform,
    color: UIColor,
    planCenter: FloorPlanPoint2D,
    thicknessMeters: CGFloat
  ) {
    let gapThickness = max(thicknessMeters * 1.4, 0.14)
    if let gap = orientedBandPath(
      start: door.start,
      end: door.end,
      thicknessMeters: gapThickness,
      transform: transform
    ) {
      context.saveGState()
      context.setFillColor(UIColor.white.cgColor)
      context.addPath(gap)
      context.fillPath()
      context.restoreGState()
    }

    let start = transform.planToScreen(door.start)
    let end = transform.planToScreen(door.end)
    let dx = end.x - start.x
    let dy = end.y - start.y
    let len = hypot(dx, dy)
    guard len > 4 else { return }

    let dirX = dx / len
    let dirY = dy / len
    var normX = -dirY
    var normY = dirX
    let mid = CGPoint(x: (start.x + end.x) * 0.5, y: (start.y + end.y) * 0.5)
    let centerScreen = transform.planToScreen(planCenter)
    let toCenterX = centerScreen.x - mid.x
    let toCenterY = centerScreen.y - mid.y
    if normX * toCenterX + normY * toCenterY < 0 {
      normX = -normX
      normY = -normY
    }

    // Hinge at `start`, leaf swings from `end` jamb toward the room.
    let hinge = start
    let jamb = end
    let leaf = CGPoint(x: hinge.x + normX * len, y: hinge.y + normY * len)
    let sweepClockwise = (dirX * normY - dirY * normX) < 0
    let startAngle = atan2(jamb.y - hinge.y, jamb.x - hinge.x)
    let endAngle = atan2(leaf.y - hinge.y, leaf.x - hinge.x)

    context.saveGState()
    context.setStrokeColor(color.cgColor)
    context.setLineWidth(1)
    context.setLineDash(phase: 0, lengths: [max(3, len * 0.08), max(3, len * 0.08)])
    context.addArc(
      center: hinge,
      radius: len,
      startAngle: startAngle,
      endAngle: endAngle,
      clockwise: sweepClockwise
    )
    context.strokePath()

    context.setLineDash(phase: 0, lengths: [])
    context.setLineWidth(1.6)
    context.move(to: hinge)
    context.addLine(to: leaf)
    context.strokePath()
    context.restoreGState()
  }

  /// Light-blue band + center mullion (Telegram `fpWindowEl`).
  private static func drawWindow(
    _ window: FloorPlanOpening,
    in context: CGContext,
    transform: FloorPlanViewTransform,
    wallColor: UIColor,
    thicknessMeters: CGFloat
  ) {
    let thick = max(thicknessMeters, 0.1)
    guard let band = orientedBandPath(
      start: window.start,
      end: window.end,
      thicknessMeters: thick,
      transform: transform
    ) else { return }

    context.saveGState()
    context.setFillColor(FloorPlanStyle.windowFill.cgColor)
    context.setStrokeColor(wallColor.cgColor)
    context.setLineWidth(1)
    context.addPath(band)
    context.drawPath(using: .fillStroke)

    let start = transform.planToScreen(window.start)
    let end = transform.planToScreen(window.end)
    context.move(to: start)
    context.addLine(to: end)
    context.strokePath()
    context.restoreGState()
  }

  /// White cutout + dashed connector (Telegram opening pass-through).
  private static func drawGenericOpening(
    _ opening: FloorPlanOpening,
    in context: CGContext,
    transform: FloorPlanViewTransform,
    color: UIColor,
    thicknessMeters: CGFloat
  ) {
    let gapThickness = max(thicknessMeters * 1.4, 0.14)
    if let gap = orientedBandPath(
      start: opening.start,
      end: opening.end,
      thicknessMeters: gapThickness,
      transform: transform
    ) {
      context.saveGState()
      context.setFillColor(UIColor.white.cgColor)
      context.addPath(gap)
      context.fillPath()
      context.restoreGState()
    }

    let start = transform.planToScreen(opening.start)
    let end = transform.planToScreen(opening.end)
    context.saveGState()
    context.setStrokeColor(color.cgColor)
    context.setLineWidth(1)
    context.setLineDash(phase: 0, lengths: [5, 5])
    context.move(to: start)
    context.addLine(to: end)
    context.strokePath()
    context.restoreGState()
  }
}

/// Oriented rectangle along a plan segment, converted to screen space.
private func orientedBandPath(
  start: FloorPlanPoint2D,
  end: FloorPlanPoint2D,
  thicknessMeters: CGFloat,
  transform: FloorPlanViewTransform
) -> CGPath? {
  let dx = end.x - start.x
  let dy = end.y - start.y
  let len = hypot(dx, dy)
  guard len > 1e-4 else { return nil }
  let ux = dx / len
  let uy = dy / len
  let nx = -uy
  let ny = ux
  let half = thicknessMeters * 0.5
  let corners = [
    FloorPlanPoint2D(x: start.x + nx * half, y: start.y + ny * half),
    FloorPlanPoint2D(x: end.x + nx * half, y: end.y + ny * half),
    FloorPlanPoint2D(x: end.x - nx * half, y: end.y - ny * half),
    FloorPlanPoint2D(x: start.x - nx * half, y: start.y - ny * half),
  ].map { transform.planToScreen($0) }
  let path = CGMutablePath()
  path.move(to: corners[0])
  for point in corners.dropFirst() {
    path.addLine(to: point)
  }
  path.closeSubpath()
  return path
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
    let lineStroke = isHighlighted ? FloorPlanStyle.dim : color
    let dirX = dx / len
    let dirY = dy / len
    let perpX = -dirY
    let perpY = dirX
    let tick = max(4, transform.scale * 0.035)
    let lineWidth: CGFloat = 1.2
    let witnessWidth: CGFloat = 0.9

    context.saveGState()
    context.setStrokeColor(lineStroke.cgColor)
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

    // End ticks (Telegram overall-dim style: perpendicular caps).
    let tickHalf = tick * 0.55
    for point in [start, end] {
      context.move(to: CGPoint(x: point.x - perpX * tickHalf, y: point.y - perpY * tickHalf))
      context.addLine(to: CGPoint(x: point.x + perpX * tickHalf, y: point.y + perpY * tickHalf))
    }
    context.strokePath()

    let fontSize = max(9, min(12, transform.scale * 0.085))
    let attrs: [NSAttributedString.Key: Any] = [
      .font: UIFont.monospacedDigitSystemFont(ofSize: fontSize, weight: .bold),
      .foregroundColor: FloorPlanStyle.dim,
    ]
    let text = line.label as NSString
    let size = text.size(withAttributes: attrs)
    let labelGap = max(6, transform.scale * 0.05)
    let mid = CGPoint(
      x: (start.x + end.x) * 0.5 + perpX * labelGap,
      y: (start.y + end.y) * 0.5 + perpY * labelGap
    )
    let padH: CGFloat = line.isEditable ? 10 : 8
    let padV: CGFloat = 4
    let chipW = size.width + padH * 2 + (line.isEditable ? 12 : 0)
    let chipH = max(size.height + padV * 2, fontSize * 1.7)
    let bgRect = CGRect(
      x: mid.x - chipW * 0.5,
      y: mid.y - chipH * 0.5,
      width: chipW,
      height: chipH
    )
    let chipPath = UIBezierPath(roundedRect: bgRect, cornerRadius: chipH * 0.5)
    context.setFillColor(UIColor.white.cgColor)
    context.addPath(chipPath.cgPath)
    context.fillPath()
    context.setStrokeColor(
      (isHighlighted ? FloorPlanStyle.dim : FloorPlanStyle.dimStroke).cgColor
    )
    context.setLineWidth(isHighlighted ? 1.5 : 1)
    context.addPath(chipPath.cgPath)
    context.strokePath()

    let textOrigin = CGPoint(
      x: mid.x - size.width * 0.5 - (line.isEditable ? 5 : 0),
      y: mid.y - size.height * 0.5
    )
    text.draw(at: textOrigin, withAttributes: attrs)

    if line.isEditable, let icon = UIImage(systemName: "pencil")?.withTintColor(
      FloorPlanStyle.dim.withAlphaComponent(0.85),
      renderingMode: .alwaysOriginal
    ) {
      let iconSide = min(11, bgRect.height - 4)
      icon.draw(in: CGRect(
        x: bgRect.maxX - iconSide - 5,
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
  /// Graph paper: 0.2 m minor + 1 m major (Telegram blueprint).
  static func draw(
    in context: CGContext,
    bounds: FloorPlanBounds,
    transform: FloorPlanViewTransform,
    minorSpacingMeters: CGFloat = FloorPlanStyle.gridMinorSpacingMeters,
    majorSpacingMeters: CGFloat = FloorPlanStyle.gridMajorSpacingMeters,
    minorColor: UIColor = FloorPlanStyle.gridMinor,
    majorColor: UIColor = FloorPlanStyle.gridMajor
  ) {
    drawLines(
      in: context,
      bounds: bounds,
      transform: transform,
      spacingMeters: minorSpacingMeters,
      color: minorColor,
      lineWidth: 1
    )
    drawLines(
      in: context,
      bounds: bounds,
      transform: transform,
      spacingMeters: majorSpacingMeters,
      color: majorColor,
      lineWidth: 1
    )
  }

  private static func drawLines(
    in context: CGContext,
    bounds: FloorPlanBounds,
    transform: FloorPlanViewTransform,
    spacingMeters: CGFloat,
    color: UIColor,
    lineWidth: CGFloat
  ) {
    context.saveGState()
    context.setStrokeColor(color.cgColor)
    context.setLineWidth(lineWidth)

    let minX = floor(bounds.minX / spacingMeters) * spacingMeters
    let maxX = ceil(bounds.maxX / spacingMeters) * spacingMeters
    let minY = floor(bounds.minY / spacingMeters) * spacingMeters
    let maxY = ceil(bounds.maxY / spacingMeters) * spacingMeters

    var x = minX
    while x <= maxX + 1e-9 {
      let a = transform.planToScreen(FloorPlanPoint2D(x: x, y: minY))
      let b = transform.planToScreen(FloorPlanPoint2D(x: x, y: maxY))
      context.move(to: a)
      context.addLine(to: b)
      x += spacingMeters
    }
    var y = minY
    while y <= maxY + 1e-9 {
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
