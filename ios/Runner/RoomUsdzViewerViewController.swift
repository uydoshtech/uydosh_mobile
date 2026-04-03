import Flutter
import SceneKit
import UIKit

/// Strings resolved in Flutter ([AppStrings] by language) and passed through the method channel.
struct RoomViewerStrings {
  let title: String
  let dimensionsCaption: String
  let dimensionsLineTemplate: String
  let gestureHint: String
  let loadErrorTitle: String
  let alertOk: String
  let floorOnlyButtonTitle: String
  let fullRoomButtonTitle: String
  let floorOnlyUnavailableMessage: String
  /// RGB hex `RRGGBB` from [AppColors.floorObject3dTint] (Material brown).
  let onFloorObjectTint: UIColor

  init(
    title: String,
    dimensionsCaption: String,
    dimensionsLineTemplate: String,
    gestureHint: String,
    loadErrorTitle: String,
    alertOk: String,
    floorOnlyButtonTitle: String,
    fullRoomButtonTitle: String,
    floorOnlyUnavailableMessage: String,
    onFloorObjectTint: UIColor
  ) {
    self.title = title
    self.dimensionsCaption = dimensionsCaption
    self.dimensionsLineTemplate = dimensionsLineTemplate
    self.gestureHint = gestureHint
    self.loadErrorTitle = loadErrorTitle
    self.alertOk = alertOk
    self.floorOnlyButtonTitle = floorOnlyButtonTitle
    self.fullRoomButtonTitle = fullRoomButtonTitle
    self.floorOnlyUnavailableMessage = floorOnlyUnavailableMessage
    self.onFloorObjectTint = onFloorObjectTint
  }

  init?(dict: [String: String]) {
    guard let title = dict["title"],
      let dimensionsCaption = dict["dimensionsCaption"],
      let dimensionsLineTemplate = dict["dimensionsLineTemplate"],
      let gestureHint = dict["gestureHint"],
      let loadErrorTitle = dict["loadErrorTitle"],
      let alertOk = dict["alertOk"]
    else { return nil }
    self.init(
      title: title,
      dimensionsCaption: dimensionsCaption,
      dimensionsLineTemplate: dimensionsLineTemplate,
      gestureHint: gestureHint,
      loadErrorTitle: loadErrorTitle,
      alertOk: alertOk,
      floorOnlyButtonTitle: dict["floorOnlyButton"] ?? "Hide walls",
      fullRoomButtonTitle: dict["fullRoomButton"] ?? "Full room",
      floorOnlyUnavailableMessage: dict["floorOnlyUnavailable"]
        ?? "No wall meshes were found by name in this file.",
      onFloorObjectTint: Self.uiColorFromRgbHex6(dict["onFloorTintRgb"] ?? "795548")
    )
  }

  /// `RRGGBB` (e.g. Material brown `795548`).
  private static func uiColorFromRgbHex6(_ hex: String) -> UIColor {
    var h = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    if h.hasPrefix("#") { h.removeFirst() }
    guard h.count == 6, let v = UInt32(h, radix: 16) else {
      return UIColor(red: 121 / 255, green: 85 / 255, blue: 72 / 255, alpha: 1)
    }
    let r = CGFloat((v >> 16) & 0xFF) / 255
    let g = CGFloat((v >> 8) & 0xFF) / 255
    let b = CGFloat(v & 0xFF) / 255
    return UIColor(red: r, green: g, blue: b, alpha: 1)
  }

  static let englishFallback = RoomViewerStrings(
    title: "3D",
    dimensionsCaption: "Approximate dimensions (full scan bounds)",
    dimensionsLineTemplate: "{floorLong} × {floorShort} m floor · {height} m high",
    gestureHint:
      "Drag with one finger to look around the model.\n"
      + "Pinch with two fingers to zoom in or out.",
    loadErrorTitle: "Could not load 3D model",
    alertOk: "OK",
    floorOnlyButtonTitle: "Hide walls",
    fullRoomButtonTitle: "Full room",
    floorOnlyUnavailableMessage:
      "No wall meshes were found by name in this file.",
    onFloorObjectTint: Self.uiColorFromRgbHex6("795548")
  )
}

/// Full-screen 3D viewer for a local USDZ (object-only, no Quick Look AR/Object toggle).
final class RoomUsdzViewerViewController: UIViewController {
  private let fileURL: URL
  private let strings: RoomViewerStrings
  private let sceneView = SCNView()
  private let hintContainer = UIView()
  private let hintStack = UIStackView()
  private let dimensionsTitleLabel = UILabel()
  private let dimensionsValueLabel = UILabel()
  private let hintLabel = UILabel()
  /// App mark (vector): U letter + roof + chimney over the 3D viewport.
  private let brandMarkView = UydoshVectorBrandMarkView()
  private var loadedScene: SCNScene?
  private enum DisplayMode: Int {
    case fullRoom = 0
    /// Furniture removed, keep walls/structure.
    case wallsOnly = 1
    /// Walls/structure removed, keep furniture.
    case furnitureOnly = 2
  }

  private var displayMode: DisplayMode = .fullRoom
  private let modeControl = UISegmentedControl(items: ["", "", ""])
  private var sceneWorldBounds: (min: SCNVector3, max: SCNVector3)?
  private var didCacheOriginalMaterials = false
  private var originalMaterialsByGeometry = [ObjectIdentifier: [SCNMaterial]]()

  init(fileURL: URL, strings: RoomViewerStrings) {
    self.fileURL = fileURL
    self.strings = strings
    super.init(nibName: nil, bundle: nil)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black
    title = strings.title

    navigationItem.leftBarButtonItem = UIBarButtonItem(
      barButtonSystemItem: .close,
      target: self,
      action: #selector(closeTapped)
    )
    setupModeControl()
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: modeControl)

    sceneView.translatesAutoresizingMaskIntoConstraints = false
    sceneView.backgroundColor = .black
    sceneView.allowsCameraControl = true
    sceneView.antialiasingMode = .multisampling4X
    sceneView.autoenablesDefaultLighting = true
    view.addSubview(sceneView)

    hintContainer.translatesAutoresizingMaskIntoConstraints = false
    hintContainer.backgroundColor = UIColor.black.withAlphaComponent(0.52)
    hintContainer.layer.cornerRadius = 12
    if #available(iOS 13.0, *) {
      hintContainer.layer.cornerCurve = .continuous
    }
    hintContainer.clipsToBounds = true

    dimensionsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
    dimensionsTitleLabel.textAlignment = .center
    dimensionsTitleLabel.numberOfLines = 0
    dimensionsTitleLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
    dimensionsTitleLabel.adjustsFontForContentSizeCategory = true
    dimensionsTitleLabel.textColor = UIColor.white.withAlphaComponent(0.68)
    dimensionsTitleLabel.text = strings.dimensionsCaption
    dimensionsTitleLabel.isHidden = true

    dimensionsValueLabel.translatesAutoresizingMaskIntoConstraints = false
    dimensionsValueLabel.textAlignment = .center
    dimensionsValueLabel.numberOfLines = 0
    dimensionsValueLabel.adjustsFontForContentSizeCategory = true
    dimensionsValueLabel.textColor = UIColor.white.withAlphaComponent(0.98)
    let subHead = UIFont.preferredFont(forTextStyle: .subheadline)
    if let boldDesc = subHead.fontDescriptor.withSymbolicTraits(.traitBold) {
      dimensionsValueLabel.font = UIFont(descriptor: boldDesc, size: 0)
    } else {
      dimensionsValueLabel.font = subHead
    }
    dimensionsValueLabel.isHidden = true

    hintLabel.translatesAutoresizingMaskIntoConstraints = false
    hintLabel.numberOfLines = 0
    hintLabel.textAlignment = .center
    hintLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
    hintLabel.adjustsFontForContentSizeCategory = true
    hintLabel.textColor = UIColor.white.withAlphaComponent(0.95)
    hintLabel.text = strings.gestureHint

    hintStack.translatesAutoresizingMaskIntoConstraints = false
    hintStack.axis = .vertical
    hintStack.alignment = .fill
    hintStack.spacing = 4
    hintStack.addArrangedSubview(dimensionsTitleLabel)
    hintStack.addArrangedSubview(dimensionsValueLabel)
    hintStack.setCustomSpacing(12, after: dimensionsValueLabel)
    hintStack.addArrangedSubview(hintLabel)

    hintContainer.addSubview(hintStack)
    view.addSubview(hintContainer)

    brandMarkView.translatesAutoresizingMaskIntoConstraints = false
    brandMarkView.accessibilityIgnoresInvertColors = true
    brandMarkView.isAccessibilityElement = true
    brandMarkView.accessibilityLabel = "UiDosha"
    view.addSubview(brandMarkView)

    NSLayoutConstraint.activate([
      sceneView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      sceneView.bottomAnchor.constraint(equalTo: hintContainer.topAnchor, constant: -12),

      hintStack.topAnchor.constraint(equalTo: hintContainer.topAnchor, constant: 10),
      hintStack.leadingAnchor.constraint(equalTo: hintContainer.leadingAnchor, constant: 14),
      hintStack.trailingAnchor.constraint(equalTo: hintContainer.trailingAnchor, constant: -14),
      hintStack.bottomAnchor.constraint(equalTo: hintContainer.bottomAnchor, constant: -10),

      hintContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      hintContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      hintContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),

      brandMarkView.leadingAnchor.constraint(equalTo: sceneView.leadingAnchor, constant: 12),
      brandMarkView.topAnchor.constraint(equalTo: sceneView.topAnchor, constant: 10),
      brandMarkView.widthAnchor.constraint(equalToConstant: 62),
      brandMarkView.heightAnchor.constraint(equalToConstant: 62),
    ])

    loadScene()
    brandMarkView.playEntranceAnimation()
  }

  private func setupModeControl() {
    modeControl.translatesAutoresizingMaskIntoConstraints = false
    modeControl.isMomentary = false
    modeControl.selectedSegmentIndex = DisplayMode.fullRoom.rawValue
    modeControl.apportionsSegmentWidthsByContent = true

    let fullIcon = UIImage(systemName: "house.fill")
    let wallsIcon = UIImage(systemName: "rectangle.split.3x1.fill")
      ?? UIImage(systemName: "square.split.2x2.fill")
    let furnitureIcon = UIImage(systemName: "bed.double.fill")
      ?? UIImage(systemName: "shippingbox.fill")
      ?? UIImage(systemName: "cube.box.fill")

    if let fullIcon = fullIcon {
      modeControl.setImage(fullIcon, forSegmentAt: DisplayMode.fullRoom.rawValue)
    } else {
      modeControl.setTitle("All", forSegmentAt: DisplayMode.fullRoom.rawValue)
    }
    if let wallsIcon = wallsIcon {
      modeControl.setImage(wallsIcon, forSegmentAt: DisplayMode.wallsOnly.rawValue)
    } else {
      modeControl.setTitle("Walls", forSegmentAt: DisplayMode.wallsOnly.rawValue)
    }
    if let furnitureIcon = furnitureIcon {
      modeControl.setImage(furnitureIcon, forSegmentAt: DisplayMode.furnitureOnly.rawValue)
    } else {
      modeControl.setTitle("Items", forSegmentAt: DisplayMode.furnitureOnly.rawValue)
    }

    modeControl.setWidth(38, forSegmentAt: DisplayMode.fullRoom.rawValue)
    modeControl.setWidth(38, forSegmentAt: DisplayMode.wallsOnly.rawValue)
    modeControl.setWidth(38, forSegmentAt: DisplayMode.furnitureOnly.rawValue)

    modeControl.addTarget(self, action: #selector(modeChanged), for: .valueChanged)

    modeControl.isAccessibilityElement = true
    modeControl.accessibilityLabel = "3D view mode"
    modeControl.accessibilityHint = "Switch between full room, walls only, and furniture only."
  }

/// Minimal vector version of the UiDosha mark (U + roof + chimney) rendered as shape layers.
/// Uses the same paths as Flutter SVG assets:
/// - `assets/icon/components/u_letter.svg`
/// - `assets/icon/components/red_roof.svg`
/// - `assets/icon/components/chimney.svg`
private final class UydoshVectorBrandMarkView: UIView {
  private let uLayer = CAShapeLayer()
  private let roofLayer = CAShapeLayer()
  private let chimneyLayer = CAShapeLayer()

  private static let viewBoxSize = CGSize(width: 11711.83, height: 11607.21)

  // Extracted from SVGs (single-path icons).
  private static let uPathD =
    "M5051.79 4188.4l0 3927.65c0,955.99 282.12,1580.83 1381.98,1474.33 603.53,-58.44 1203.73,-456.43 1203.73,-1474.33l0 -3923.09c233.65,150.03 484.36,282.24 751.71,395.19l0 3764.99c0,1423.17 -1102.8,2090.19 -2305.89,2103.4 -1574.75,17.29 -2510.72,-571.96 -2510.72,-2103.4l0 -3218.05c520.61,-224.71 1036,-539.84 1479.19,-946.69z"
  private static let roofPathD =
    "M1720.3 3580c2285.09,-242.21 3270.04,-1249.1 4293.14,-2890.67 788.08,1783.39 1854.5,3164.87 4240.52,3457.89l0 492.09c-2033.27,-162.86 -3482.17,-1155.31 -4254.17,-2636.81 -833.77,1771.85 -2942.62,2639.21 -4279.49,2636.81l0 -1059.31z"
  private static let chimneyPathD =
    "M7658.7 1621.07l0 939.82c-168.92,-85.46 -325.93,-189.35 -471.58,-311.75l0 -628.07 471.58,0z"

  override init(frame: CGRect) {
    super.init(frame: frame)
    isUserInteractionEnabled = false
    backgroundColor = .clear

    // Soft shadow for readability over bright scans.
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOpacity = 0.35
    layer.shadowOffset = CGSize(width: 0, height: 1)
    layer.shadowRadius = 5
    layer.masksToBounds = false

    uLayer.fillColor = UIColor.white.cgColor
    roofLayer.fillColor = UIColor.red.cgColor
    chimneyLayer.fillColor = UIColor.red.cgColor

    // Start slightly faded so animation reads well.
    uLayer.opacity = 0
    roofLayer.opacity = 0
    chimneyLayer.opacity = 0

    layer.addSublayer(uLayer)
    layer.addSublayer(roofLayer)
    layer.addSublayer(chimneyLayer)

    // Initial paths (will be scaled in `layoutSubviews`).
    uLayer.path = SVGPathParser.parsePath(d: Self.uPathD)?.cgPath
    roofLayer.path = SVGPathParser.parsePath(d: Self.roofPathD)?.cgPath
    chimneyLayer.path = SVGPathParser.parsePath(d: Self.chimneyPathD)?.cgPath
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let vb = Self.viewBoxSize
    guard vb.width > 0, vb.height > 0, bounds.width > 0, bounds.height > 0 else { return }

    // Uniform scale to fit, with centered letterboxing.
    let sx = bounds.width / vb.width
    let sy = bounds.height / vb.height
    let s = min(sx, sy)
    let tx = (bounds.width - vb.width * s) / 2
    let ty = (bounds.height - vb.height * s) / 2

    var t = CGAffineTransform.identity
    t = t.translatedBy(x: tx, y: ty)
    t = t.scaledBy(x: s, y: s)

    // SVG coordinates are Y-down (UIKit is Y-down too), so no flip needed.
    uLayer.setAffineTransform(t)
    roofLayer.setAffineTransform(t)
    chimneyLayer.setAffineTransform(t)

    uLayer.frame = bounds
    roofLayer.frame = bounds
    chimneyLayer.frame = bounds
  }

  func playEntranceAnimation() {
    // Avoid restarting if already visible.
    if uLayer.opacity > 0.01 { return }

    let fade = CABasicAnimation(keyPath: "opacity")
    fade.fromValue = 0
    fade.toValue = 1
    fade.duration = 0.28
    fade.timingFunction = CAMediaTimingFunction(name: .easeOut)
    fade.fillMode = .forwards
    fade.isRemovedOnCompletion = false

    let drop = CASpringAnimation(keyPath: "transform.translation.y")
    drop.fromValue = -6
    drop.toValue = 0
    drop.damping = 14
    drop.stiffness = 240
    drop.mass = 1
    drop.initialVelocity = 0
    drop.duration = drop.settlingDuration
    drop.fillMode = .forwards
    drop.isRemovedOnCompletion = false

    CATransaction.begin()
    CATransaction.setDisableActions(true)
    uLayer.opacity = 1
    roofLayer.opacity = 1
    chimneyLayer.opacity = 1
    CATransaction.commit()

    uLayer.add(fade, forKey: "u.fade")

    // Roof/chimney: fade + slight drop (reads like “roof landing”).
    let roofGroup = CAAnimationGroup()
    roofGroup.animations = [fade, drop]
    roofGroup.duration = max(fade.duration, drop.duration)
    roofGroup.beginTime = CACurrentMediaTime() + 0.05
    roofGroup.fillMode = .forwards
    roofGroup.isRemovedOnCompletion = false

    roofLayer.add(roofGroup, forKey: "roof.in")
    chimneyLayer.add(roofGroup, forKey: "chimney.in")
  }
}

/// Tiny subset SVG path parser: supports `M/m`, `L/l`, `C/c`, `Z/z`.
/// Enough for the UiDosha mark paths (single shape per file).
private enum SVGPathParser {
  static func parsePath(d: String) -> UIBezierPath? {
    let path = UIBezierPath()
    var lexer = Lexer(d)

    var current = CGPoint.zero
    var start = CGPoint.zero
    var lastCommand: Character?

    while true {
      lexer.skipSeparators()
      guard !lexer.isAtEnd else { break }

      let cmd: Character
      if let c = lexer.peekCommand() {
        cmd = c
        _ = lexer.consumeChar()
        lastCommand = cmd
      } else if let lc = lastCommand {
        // Implicit command repetition.
        cmd = lc
      } else {
        return nil
      }

      switch cmd {
      case "M", "m":
        guard let x = lexer.readNumber(), let y = lexer.readNumber() else { return nil }
        let p = CGPoint(x: x, y: y)
        current = (cmd == "m") ? CGPoint(x: current.x + p.x, y: current.y + p.y) : p
        path.move(to: current)
        start = current
        // Subsequent pairs are treated as implicit "L/l".
        while true {
          let save = lexer.index
          if let nx = lexer.readNumber(), let ny = lexer.readNumber() {
            let np = CGPoint(x: nx, y: ny)
            current = (cmd == "m") ? CGPoint(x: current.x + np.x, y: current.y + np.y) : np
            path.addLine(to: current)
          } else {
            lexer.index = save
            break
          }
        }
      case "L", "l":
        while true {
          let save = lexer.index
          guard let x = lexer.readNumber(), let y = lexer.readNumber() else {
            lexer.index = save
            break
          }
          let p = CGPoint(x: x, y: y)
          current = (cmd == "l") ? CGPoint(x: current.x + p.x, y: current.y + p.y) : p
          path.addLine(to: current)
        }
      case "C", "c":
        while true {
          let save = lexer.index
          guard
            let x1 = lexer.readNumber(), let y1 = lexer.readNumber(),
            let x2 = lexer.readNumber(), let y2 = lexer.readNumber(),
            let x = lexer.readNumber(), let y = lexer.readNumber()
          else {
            lexer.index = save
            break
          }
          let p1 = CGPoint(x: x1, y: y1)
          let p2 = CGPoint(x: x2, y: y2)
          let p = CGPoint(x: x, y: y)
          if cmd == "c" {
            path.addCurve(
              to: CGPoint(x: current.x + p.x, y: current.y + p.y),
              controlPoint1: CGPoint(x: current.x + p1.x, y: current.y + p1.y),
              controlPoint2: CGPoint(x: current.x + p2.x, y: current.y + p2.y)
            )
            current = CGPoint(x: current.x + p.x, y: current.y + p.y)
          } else {
            path.addCurve(to: p, controlPoint1: p1, controlPoint2: p2)
            current = p
          }
        }
      case "Z", "z":
        path.close()
        current = start
      default:
        // Not needed for our brand mark; fail closed so issues are visible in dev.
        return nil
      }
    }

    return path
  }

  private struct Lexer {
    let chars: [Character]
    var index: Int = 0

    init(_ s: String) { self.chars = Array(s) }

    var isAtEnd: Bool { index >= chars.count }

    func peek() -> Character? { isAtEnd ? nil : chars[index] }

    mutating func consumeChar() -> Character? {
      guard !isAtEnd else { return nil }
      let c = chars[index]
      index += 1
      return c
    }

    mutating func skipSeparators() {
      while let c = peek(), c == " " || c == "\n" || c == "\t" || c == "\r" || c == "," {
        index += 1
      }
    }

    func peekCommand() -> Character? {
      guard let c = peek() else { return nil }
      switch c {
      case "M", "m", "L", "l", "C", "c", "Z", "z": return c
      default: return nil
      }
    }

    mutating func readNumber() -> CGFloat? {
      skipSeparators()
      guard !isAtEnd else { return nil }

      var s = ""
      if let c = peek(), c == "+" || c == "-" {
        s.append(c)
        index += 1
      }

      var sawDigit = false
      while let c = peek(), c.isNumber {
        sawDigit = true
        s.append(c)
        index += 1
      }

      if let c = peek(), c == "." {
        s.append(c)
        index += 1
        while let c2 = peek(), c2.isNumber {
          sawDigit = true
          s.append(c2)
          index += 1
        }
      }

      // Optional exponent (rare here, but safe).
      if let c = peek(), c == "e" || c == "E" {
        s.append(c)
        index += 1
        if let sign = peek(), sign == "+" || sign == "-" {
          s.append(sign)
          index += 1
        }
        var expDigit = false
        while let cd = peek(), cd.isNumber {
          expDigit = true
          s.append(cd)
          index += 1
        }
        if !expDigit { return nil }
      }

      guard sawDigit, let v = Double(s) else { return nil }
      return CGFloat(v)
    }
  }
}

  /// World-space union of all geometry bounding boxes (root’s own `boundingBox` ignores children).
  private func unionWorldBounds(of root: SCNNode) -> (min: SCNVector3, max: SCNVector3)? {
    var minV = SCNVector3(
      Float.greatestFiniteMagnitude,
      Float.greatestFiniteMagnitude,
      Float.greatestFiniteMagnitude
    )
    var maxV = SCNVector3(
      -Float.greatestFiniteMagnitude,
      -Float.greatestFiniteMagnitude,
      -Float.greatestFiniteMagnitude
    )
    var any = false

    func visit(_ node: SCNNode) {
      if node.geometry != nil {
        let box = node.boundingBox
        let corners: [SCNVector3] = [
          SCNVector3(box.min.x, box.min.y, box.min.z),
          SCNVector3(box.max.x, box.min.y, box.min.z),
          SCNVector3(box.min.x, box.max.y, box.min.z),
          SCNVector3(box.max.x, box.max.y, box.min.z),
          SCNVector3(box.min.x, box.min.y, box.max.z),
          SCNVector3(box.max.x, box.min.y, box.max.z),
          SCNVector3(box.min.x, box.max.y, box.max.z),
          SCNVector3(box.max.x, box.max.y, box.max.z),
        ]
        for c in corners {
          let w = node.convertPosition(c, to: nil)
          minV.x = Swift.min(minV.x, w.x)
          minV.y = Swift.min(minV.y, w.y)
          minV.z = Swift.min(minV.z, w.z)
          maxV.x = Swift.max(maxV.x, w.x)
          maxV.y = Swift.max(maxV.y, w.y)
          maxV.z = Swift.max(maxV.z, w.z)
          any = true
        }
      }
      for child in node.childNodes {
        visit(child)
      }
    }

    visit(root)
    guard any else { return nil }
    return (minV, maxV)
  }

  private func worldBounds(of node: SCNNode) -> (min: SCNVector3, max: SCNVector3)? {
    guard node.geometry != nil else { return nil }
    let box = node.boundingBox
    let corners: [SCNVector3] = [
      SCNVector3(box.min.x, box.min.y, box.min.z),
      SCNVector3(box.max.x, box.min.y, box.min.z),
      SCNVector3(box.min.x, box.max.y, box.min.z),
      SCNVector3(box.max.x, box.max.y, box.min.z),
      SCNVector3(box.min.x, box.min.y, box.max.z),
      SCNVector3(box.max.x, box.min.y, box.max.z),
      SCNVector3(box.min.x, box.max.y, box.max.z),
      SCNVector3(box.max.x, box.max.y, box.max.z),
    ]
    var minV = SCNVector3(
      Float.greatestFiniteMagnitude,
      Float.greatestFiniteMagnitude,
      Float.greatestFiniteMagnitude
    )
    var maxV = SCNVector3(
      -Float.greatestFiniteMagnitude,
      -Float.greatestFiniteMagnitude,
      -Float.greatestFiniteMagnitude
    )
    for c in corners {
      let w = node.convertPosition(c, to: nil)
      minV.x = Swift.min(minV.x, w.x)
      minV.y = Swift.min(minV.y, w.y)
      minV.z = Swift.min(minV.z, w.z)
      maxV.x = Swift.max(maxV.x, w.x)
      maxV.y = Swift.max(maxV.y, w.y)
      maxV.z = Swift.max(maxV.z, w.z)
    }
    return (minV, maxV)
  }

  private func isLikelyFloorSlab(
    _ b: (min: SCNVector3, max: SCNVector3),
    sceneBounds: (min: SCNVector3, max: SCNVector3)
  ) -> Bool {
    let dx = b.max.x - b.min.x
    let dy = b.max.y - b.min.y
    let dz = b.max.z - b.min.z
    let foot = max(dx, dz)
    guard foot > 0.06 else { return false }
    guard dy < max(0.05, 0.12 * foot) else { return false }
    let sceneH = max(sceneBounds.max.y - sceneBounds.min.y, 0.12)
    return b.min.y <= sceneBounds.min.y + 0.14 * sceneH + 0.04
  }

  private func isLikelyVerticalWallSlab(
    _ b: (min: SCNVector3, max: SCNVector3),
    sceneHeight: Float
  ) -> Bool {
    let dx = b.max.x - b.min.x
    let dy = b.max.y - b.min.y
    let dz = b.max.z - b.min.z
    let hMax = max(dx, dz)
    let hMin = min(dx, dz)
    guard dy > 0.18 else { return false }
    guard dy > 0.28 * max(hMax, 0.08) else { return false }
    guard hMin < 0.26 * hMax else { return false }
    return dy > 0.22 * max(sceneHeight, 0.2)
  }

  /// Anything that sits on the floor plane: not the floor mesh itself, not walls/doors/ceiling by name or shape.
  private func isOnFloorObject(_ node: SCNNode, sceneBounds: (min: SCNVector3, max: SCNVector3)) -> Bool {
    if node.name == "UydoshFramingCamera" { return false }
    if shouldHideWallLikeSurface(node) { return false }
    let name = (node.name ?? "").lowercased()
    if name.contains("ceiling") { return false }
    if name.contains("floor") || name.contains("ground") { return false }
    guard let b = worldBounds(of: node) else { return false }
    let sceneMinY = sceneBounds.min.y
    let sceneH = max(sceneBounds.max.y - sceneBounds.min.y, 0.12)
    if isLikelyFloorSlab(b, sceneBounds: sceneBounds) { return false }
    if isLikelyVerticalWallSlab(b, sceneHeight: sceneH) { return false }
    let bottomY = b.min.y
    guard bottomY >= sceneMinY - 0.08, bottomY <= sceneMinY + 0.22 * sceneH + 0.06 else { return false }
    let dy = b.max.y - b.min.y
    guard dy > 0.025 else { return false }
    return true
  }

  private func cacheOriginalMaterialsIfNeeded() {
    guard !didCacheOriginalMaterials, let root = loadedScene?.rootNode else { return }
    func visit(_ node: SCNNode) {
      if let geo = node.geometry {
        let id = ObjectIdentifier(geo)
        if originalMaterialsByGeometry[id] == nil {
          originalMaterialsByGeometry[id] = geo.materials.map { mat in
            mat.copy() as! SCNMaterial
          }
        }
      }
      for child in node.childNodes {
        visit(child)
      }
    }
    visit(root)
    didCacheOriginalMaterials = true
  }

  private func darkerColor(from color: UIColor, factor: CGFloat) -> UIColor {
    // factor < 1 => darker
    var r: CGFloat = 0
    var g: CGFloat = 0
    var b: CGFloat = 0
    var a: CGFloat = 0
    if color.getRed(&r, green: &g, blue: &b, alpha: &a) {
      return UIColor(
        red: max(0, min(1, r * factor)),
        green: max(0, min(1, g * factor)),
        blue: max(0, min(1, b * factor)),
        alpha: a
      )
    }
    return color
  }

  /// Makes the floor slightly darker than walls (keeps walls/furniture close to original).
  private func applyFloorAndFurnitureTint() {
    guard let root = loadedScene?.rootNode, let sceneBounds = sceneWorldBounds else { return }
    cacheOriginalMaterialsIfNeeded()
    let floorTint = darkerColor(from: strings.onFloorObjectTint, factor: 0.78)
    // Muted blue-teal that plays well with warm wood + cool light walls.
    // (RGB: 0x2F6F7A)
    let furnitureTint = UIColor(red: 47 / 255, green: 111 / 255, blue: 122 / 255, alpha: 1)
    SCNTransaction.begin()
    SCNTransaction.animationDuration = 0
    func visit(_ node: SCNNode) {
      guard let geo = node.geometry else {
        for c in node.childNodes { visit(c) }
        return
      }
      let id = ObjectIdentifier(geo)
      guard let originals = originalMaterialsByGeometry[id] else {
        for c in node.childNodes { visit(c) }
        return
      }

      // Restore originals first; then selectively tint floor slabs darker.
      geo.materials = originals.map { $0.copy() as! SCNMaterial }
      if let b = worldBounds(of: node), isLikelyFloorSlab(b, sceneBounds: sceneBounds) {
        geo.materials = originals.map { orig in
          let m = orig.copy() as! SCNMaterial
          m.diffuse.contents = floorTint
          return m
        }
      } else if isOnFloorObject(node, sceneBounds: sceneBounds) {
        geo.materials = originals.map { orig in
          let m = orig.copy() as! SCNMaterial
          m.diffuse.contents = furnitureTint
          return m
        }
      }
      for c in node.childNodes {
        visit(c)
      }
    }
    visit(root)
    SCNTransaction.commit()
  }

  /// Uses mesh node names from RoomPlan-style USDZ. Furniture stays visible unless its name matches these.
  private func shouldHideWallLikeSurface(_ node: SCNNode) -> Bool {
    if node.name == "UydoshFramingCamera" { return false }
    let name = (node.name ?? "").lowercased()
    if name.contains("floor") || name.contains("ground") { return false }
    if name.contains("wall") || name.contains("ceiling") { return true }
    if name.contains("door") || name.contains("window") || name.contains("opening") { return true }
    return false
  }

  private func setAllGeometryVisible(_ visible: Bool) {
    guard let root = loadedScene?.rootNode else { return }
    SCNTransaction.begin()
    SCNTransaction.animationDuration = 0
    func visit(_ node: SCNNode) {
      if node.geometry != nil {
        node.isHidden = !visible
      }
      for child in node.childNodes {
        visit(child)
      }
    }
    visit(root)
    SCNTransaction.commit()
  }

  private func applyWallsHiddenMode(_ hideWalls: Bool) {
    guard let root = loadedScene?.rootNode else { return }
    SCNTransaction.begin()
    SCNTransaction.animationDuration = 0
    func visit(_ node: SCNNode) {
      if node.geometry != nil {
        if hideWalls {
          node.isHidden = shouldHideWallLikeSurface(node)
        } else {
          node.isHidden = false
        }
      }
      for child in node.childNodes {
        visit(child)
      }
    }
    visit(root)
    SCNTransaction.commit()
  }

  private func applyDisplayMode(_ mode: DisplayMode) {
    guard let root = loadedScene?.rootNode else { return }

    SCNTransaction.begin()
    SCNTransaction.animationDuration = 0

    func visit(_ node: SCNNode) {
      if node.geometry != nil {
        switch mode {
        case .fullRoom:
          node.isHidden = false
        case .wallsOnly:
          if node.name == "UydoshFramingCamera" {
            node.isHidden = false
          } else if let sceneBounds = sceneWorldBounds, isOnFloorObject(node, sceneBounds: sceneBounds) {
            node.isHidden = true
          } else {
            node.isHidden = false
          }
        case .furnitureOnly:
          if node.name == "UydoshFramingCamera" {
            node.isHidden = false
          } else {
            node.isHidden = shouldHideWallLikeSurface(node)
          }
        }
      }
      for child in node.childNodes {
        visit(child)
      }
    }

    visit(root)
    SCNTransaction.commit()

    if mode == .furnitureOnly {
      // If we cannot find any wall-like meshes by name, don’t pretend mode worked.
      var anyHidden = false
      func checkHidden(_ node: SCNNode) {
        if node.geometry != nil, node.isHidden {
          anyHidden = true
          return
        }
        guard !anyHidden else { return }
        for c in node.childNodes { checkHidden(c) }
      }
      checkHidden(root)
      if !anyHidden {
        // Revert and explain.
        displayMode = .fullRoom
        modeControl.selectedSegmentIndex = DisplayMode.fullRoom.rawValue
        setAllGeometryVisible(true)
        let alert = UIAlertController(
          title: nil,
          message: strings.floorOnlyUnavailableMessage,
          preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: strings.alertOk, style: .default))
        present(alert, animated: true)
      }
    }
  }

  @objc private func modeChanged() {
    guard loadedScene != nil else { return }
    let idx = modeControl.selectedSegmentIndex
    let next = DisplayMode(rawValue: idx) ?? .fullRoom
    displayMode = next
    applyDisplayMode(next)
  }

  /// RoomPlan / SceneKit: meters, Y-up. Uses horizontal spans (X, Z) as floor footprint and Y as height.
  private func updateDimensionsDisplay(dx: Float, dy: Float, dz: Float) {
    let floorLong = max(dx, dz)
    let floorShort = min(dx, dz)
    let height = dy
    func fmt(_ v: Float) -> String {
      String(format: "%.1f", v)
    }
    var line = strings.dimensionsLineTemplate
    line = line.replacingOccurrences(of: "{floorLong}", with: fmt(floorLong))
    line = line.replacingOccurrences(of: "{floorShort}", with: fmt(floorShort))
    line = line.replacingOccurrences(of: "{height}", with: fmt(height))
    dimensionsValueLabel.text = line
    dimensionsTitleLabel.isHidden = false
    dimensionsValueLabel.isHidden = false
  }

  /// Places the camera so the whole model fits the viewport (avoids default “inside the mesh” zoom).
  private func frameCamera(for scene: SCNScene, in view: SCNView) {
    guard let bounds = unionWorldBounds(of: scene.rootNode) else { return }

    let minB = bounds.min
    let maxB = bounds.max
    let dx = maxB.x - minB.x
    let dy = maxB.y - minB.y
    let dz = maxB.z - minB.z
    guard dx > 1e-6 || dy > 1e-6 || dz > 1e-6 else { return }

    sceneWorldBounds = (minB, maxB)
    updateDimensionsDisplay(dx: dx, dy: dy, dz: dz)

    let centerWorld = SCNVector3(
      (minB.x + maxB.x) * 0.5,
      (minB.y + maxB.y) * 0.5,
      (minB.z + maxB.z) * 0.5
    )

    // Half diagonal of the axis-aligned box; enclosing sphere radius for a conservative fit.
    let halfDiagonal =
      0.5 * sqrt(dx * dx + dy * dy + dz * dz)
    guard halfDiagonal > 1e-4 else { return }

    let cameraNode = SCNNode()
    cameraNode.name = "UydoshFramingCamera"
    let cam = SCNCamera()
    cameraNode.camera = cam

    let vfovDegrees: CGFloat = 60
    cam.fieldOfView = vfovDegrees
    let vfov = vfovDegrees * .pi / 180
    // Portrait phones are tall: horizontal FOV is narrower than vertical. Framing using only
    // vertical FOV leaves the model cropped on the sides (still “too close” for room scans).
    let w = max(view.bounds.width, 1)
    let h = max(view.bounds.height, 1)
    let aspect = w / h
    let tanHalfV = tan(vfov / 2)
    let tanHalfH = aspect * tanHalfV
    let tanHalfLimit = min(tanHalfV, tanHalfH)
    let padding: CGFloat = 1.38
    let distance = CGFloat(halfDiagonal) / tanHalfLimit * padding

    // Slightly elevated “corner” view reads well for room scans.
    let vx: Float = 0.55
    let vy: Float = 0.38
    let vz: Float = 0.75
    let len = sqrt(vx * vx + vy * vy + vz * vz)
    let ox = vx / len * Float(distance)
    let oy = vy / len * Float(distance)
    let oz = vz / len * Float(distance)

    let worldCam = SCNVector3(
      centerWorld.x + ox,
      centerWorld.y + oy,
      centerWorld.z + oz
    )

    cam.zNear = Double(max(0.001, CGFloat(halfDiagonal) * 0.0005))
    cam.zFar = Double(max(100, CGFloat(halfDiagonal) * 50))

    let root = scene.rootNode
    cameraNode.position = root.convertPosition(worldCam, from: nil)
    cameraNode.look(at: centerWorld, up: SCNVector3(0, 1, 0), localFront: SCNVector3(0, 0, -1))

    root.addChildNode(cameraNode)
    view.pointOfView = cameraNode

    view.defaultCameraController.target = centerWorld

    cacheOriginalMaterialsIfNeeded()
    applyFloorAndFurnitureTint()
  }

  private func loadScene() {
    // Load on the main thread: SceneKit + SCNView expect scene graph work on main; background
    // loading has caused rare runtime issues with Metal/SceneKit state.
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      do {
        let scene = try SCNScene(url: self.fileURL, options: nil)
        self.loadedScene = scene
        self.sceneView.scene = scene
        self.frameCamera(for: scene, in: self.sceneView)
        self.displayMode = DisplayMode(rawValue: self.modeControl.selectedSegmentIndex) ?? .fullRoom
        self.applyDisplayMode(self.displayMode)
      } catch {
        self.presentLoadError(error)
      }
    }
  }

  private func presentLoadError(_ error: Error) {
    let alert = UIAlertController(
      title: strings.loadErrorTitle,
      message: error.localizedDescription,
      preferredStyle: .alert
    )
    alert.addAction(UIAlertAction(title: strings.alertOk, style: .default) { [weak self] _ in
      self?.dismissViewer()
    })
    present(alert, animated: true)
  }

  @objc private func closeTapped() {
    dismissViewer()
  }

  private func dismissViewer() {
    didCacheOriginalMaterials = false
    originalMaterialsByGeometry.removeAll(keepingCapacity: false)
    sceneWorldBounds = nil
    displayMode = .fullRoom
    modeControl.selectedSegmentIndex = DisplayMode.fullRoom.rawValue
    sceneView.scene = nil
    loadedScene = nil
    dismiss(animated: true)
  }

  deinit {
    sceneView.scene = nil
  }
}

/// Flutter `FlutterResult` must run at most once; duplicate replies can abort the engine connection.
private final class OnceFlutterResult {
  private var consumed = false
  private let result: FlutterResult

  init(_ result: @escaping FlutterResult) {
    self.result = result
  }

  func send(_ value: Any?) {
    guard !consumed else { return }
    consumed = true
    result(value)
  }
}

enum RoomUsdzViewerPresenter {
  static func present(filePath: String, strings: [String: String], result: @escaping FlutterResult) {
    let once = OnceFlutterResult(result)

    guard FileManager.default.fileExists(atPath: filePath) else {
      once.send(
        FlutterError(
          code: "missing_file",
          message: "USDZ not found",
          details: filePath
        )
      )
      return
    }
    let url = URL(fileURLWithPath: filePath)
    guard let host = topViewController() else {
      once.send(
        FlutterError(
          code: "no_vc",
          message: "Cannot present 3D viewer",
          details: nil
        )
      )
      return
    }

    let resolved = RoomViewerStrings(dict: strings) ?? RoomViewerStrings.englishFallback
    let viewer = RoomUsdzViewerViewController(fileURL: url, strings: resolved)
    let nav = UINavigationController(rootViewController: viewer)
    nav.modalPresentationStyle = .fullScreen
    nav.navigationBar.prefersLargeTitles = false

    host.present(nav, animated: true) {
      once.send(true)
    }
  }

  private static func topViewController() -> UIViewController? {
    for scene in UIApplication.shared.connectedScenes {
      guard let windowScene = scene as? UIWindowScene else { continue }
      let windows = windowScene.windows
      let root = windows.first(where: { $0.isKeyWindow })?.rootViewController
        ?? windows.first?.rootViewController
      if let root = root {
        return findTop(from: root)
      }
    }
    return nil
  }

  private static func findTop(from vc: UIViewController) -> UIViewController {
    if let presented = vc.presentedViewController {
      return findTop(from: presented)
    }
    if let nav = vc as? UINavigationController, let visible = nav.visibleViewController {
      return findTop(from: visible)
    }
    if let tab = vc as? UITabBarController, let selected = tab.selectedViewController {
      return findTop(from: selected)
    }
    return vc
  }
}
