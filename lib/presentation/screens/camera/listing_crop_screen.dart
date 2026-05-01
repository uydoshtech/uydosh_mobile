import "dart:io";
import "dart:math" as math;
import "dart:typed_data";

import "package:crop_your_image/crop_your_image.dart";
import "package:flutter/material.dart";
import "package:flutter_svg/flutter_svg.dart";
import "package:image/image.dart" as img;
import "package:path_provider/path_provider.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/presentation/widgets/common/glass_bottom_sheet_surface.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";

/// UyDosh-styled listing photo crop screen.
///
/// Replaces the native [ImageCropper] flow (TOCropViewController on iOS, uCrop
/// on Android) with a Flutter-rendered crop UI so we can:
///   - apply UyDosh palette + 3D pill buttons consistently with the rest of
///     the listing-creation flow,
///   - overlay the UyDosh brand mark at the bottom-right of the visible crop
///     rect, mirroring where [WatermarkService] will bake the watermark.
///
/// Returns the cropped JPEG file path via [Navigator.pop], or `null` if the
/// user cancels. On any rotation/cropping failure we surface a toast and pop
/// with `null` so the caller falls back to the original (uncropped) photo.
class ListingCropScreen extends StatefulWidget {
  const ListingCropScreen({
    required this.sourcePath,
    super.key,
    this.lockedAspectRatio,
    this.maxOutputDimension = 1600,
    this.jpegQuality = 85,
  });

  final String sourcePath;
  final double? lockedAspectRatio;

  /// Cap on the longer side of the cropped JPEG (matches the previous
  /// [ImageCropper] config so subsequent watermarking + upload stays light).
  final int maxOutputDimension;

  /// JPEG quality of the encoded crop result (0-100).
  final int jpegQuality;

  @override
  State<ListingCropScreen> createState() => _ListingCropScreenState();
}

enum _AspectChoice {
  free,
  ratio1x1,
  ratio4x3,
  ratio16x9,
  ratio3x2,
}

extension on _AspectChoice {
  /// `null` when the user wants free-form cropping.
  double? get value {
    switch (this) {
      case _AspectChoice.free:
        return null;
      case _AspectChoice.ratio1x1:
        return 1.0;
      case _AspectChoice.ratio4x3:
        return 4 / 3;
      case _AspectChoice.ratio16x9:
        return 16 / 9;
      case _AspectChoice.ratio3x2:
        return 3 / 2;
    }
  }

  String get label {
    switch (this) {
      case _AspectChoice.free:
        return L10n.get("crop_aspect_free");
      case _AspectChoice.ratio1x1:
        return "1:1";
      case _AspectChoice.ratio4x3:
        return "4:3";
      case _AspectChoice.ratio16x9:
        return "16:9";
      case _AspectChoice.ratio3x2:
        return "3:2";
    }
  }
}

class _ListingCropScreenState extends State<ListingCropScreen> {
  final CropController _controller = CropController();
  Uint8List? _imageBytes;
  String? _loadError;
  bool _busy = false;
  _AspectChoice _aspect = _AspectChoice.free;

  @override
  void initState() {
    super.initState();
    if (widget.lockedAspectRatio != null) {
      // Pick the closest preset to the locked ratio so the picker reflects
      // the actual constraint (prevents user confusion when the chosen
      // option appears different from the rect they're cropping).
      _aspect = _closestPresetTo(widget.lockedAspectRatio!);
    }
    _loadImage();
  }

  /// Build the initial crop rect inside the viewport. Free-aspect mode
  /// covers the whole viewport (which equals the visible photo after the
  /// package's scale-to-cover); locked aspects centre an aspect-correct
  /// rect that touches the viewport on its tight axis.
  static Rect _initialCropRect(Rect viewportRect, double? aspectRatio) {
    if (aspectRatio == null) {
      return viewportRect;
    }
    final vw = viewportRect.width;
    final vh = viewportRect.height;
    final viewportAr = vw / vh;
    final double rectW;
    final double rectH;
    if (aspectRatio > viewportAr) {
      rectW = vw;
      rectH = vw / aspectRatio;
    } else {
      rectH = vh;
      rectW = vh * aspectRatio;
    }
    return Rect.fromLTWH(
      viewportRect.left + (vw - rectW) / 2,
      viewportRect.top + (vh - rectH) / 2,
      rectW,
      rectH,
    );
  }

  static _AspectChoice _closestPresetTo(double target) {
    var best = _AspectChoice.free;
    var bestDelta = double.infinity;
    for (final c in _AspectChoice.values) {
      final v = c.value;
      if (v == null) continue;
      final delta = (v - target).abs();
      if (delta < bestDelta) {
        bestDelta = delta;
        best = c;
      }
    }
    return best;
  }

  Future<void> _loadImage() async {
    try {
      final bytes = await File(widget.sourcePath).readAsBytes();
      if (!mounted) return;
      setStateIfMounted(() => _imageBytes = bytes);
    } catch (e, st) {
      logger.e("ListingCropScreen: failed to read source image",
          error: e, stackTrace: st);
      setStateIfMounted(
          () => _loadError = L10n.get("error_picking_photo"));
    }
  }

  Future<void> _rotate({required bool clockwise}) async {
    final bytes = _imageBytes;
    if (bytes == null || _busy) return;
    HapticFeedbackUtils.impact();
    setState(() => _busy = true);
    try {
      // Decode → rotate ±90° → re-encode. We re-encode as JPEG (quality 92)
      // since the source is already lossy and a higher quality preserves
      // edges through the eventual final encode in [crop()].
      final rotated = await _rotateBytes(bytes, clockwise: clockwise);
      if (!mounted) return;
      setState(() => _imageBytes = rotated);
    } catch (e, st) {
      logger.e("ListingCropScreen: rotate failed", error: e, stackTrace: st);
      if (mounted) {
        ToastTheme.showError(context,
            message: L10n.get("error_picking_photo"));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  static Future<Uint8List> _rotateBytes(
    Uint8List bytes, {
    required bool clockwise,
  }) async {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      throw const FormatException("Unable to decode image for rotation");
    }
    final rotated =
        img.copyRotate(decoded, angle: clockwise ? 90 : -90);
    return Uint8List.fromList(img.encodeJpg(rotated, quality: 92));
  }

  void _selectAspect(_AspectChoice choice) {
    HapticFeedbackUtils.impact();
    setState(() => _aspect = choice);
    _controller.aspectRatio = choice.value;
  }

  void _undo() {
    if (_busy) return;
    HapticFeedbackUtils.impact();
    _controller.undo();
  }

  Future<void> _showAspectPicker() async {
    if (_busy || _imageBytes == null) return;
    HapticFeedbackUtils.impact();
    final selected = await showModalBottomSheet<_AspectChoice>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      isScrollControlled: true,
      builder: (sheetContext) {
        // The crop screen forces a black scaffold regardless of system theme,
        // so we override the picker's theme to dark. That way
        // [GlassBottomSheetSurface] picks the dark glass tint and the
        // [ListTile] text reads white-on-glass — matching the rest of the
        // crop UI instead of inheriting the app's current light/blue theme.
        // Use the brand's brighter blue as the accent so the selected row
        // actually pops on dark glass — `BlueThemeColors.primary` is the
        // navy background tone itself and reads as low-contrast here.
        const accent = BlueThemeColors.iconPrimary;
        final darkTheme = ThemeData.dark(useMaterial3: true).copyWith(
          colorScheme: ThemeData.dark(useMaterial3: true).colorScheme.copyWith(
                primary: accent,
                secondary: accent,
              ),
        );
        const radius = BorderRadius.vertical(top: Radius.circular(20));
        return Theme(
          data: darkTheme,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: GlassBottomSheetSurface(
              borderRadius: radius,
              child: Material(
                type: MaterialType.transparency,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 38,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.28),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              L10n.get("crop_aspect_ratio"),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),
                        ..._AspectChoice.values.map((choice) {
                          final isSelected = _aspect == choice;
                          return ListTile(
                            dense: true,
                            onTap: () =>
                                Navigator.of(sheetContext).pop(choice),
                            title: Text(
                              choice.label,
                              style: TextStyle(
                                color: isSelected ? accent : Colors.white,
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(Icons.check, color: accent)
                                : null,
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    if (selected != null && selected != _aspect) {
      _selectAspect(selected);
    }
  }

  void _confirmCrop() {
    if (_imageBytes == null || _busy) return;
    HapticFeedbackUtils.impact();
    setState(() => _busy = true);
    // [CropController.crop] returns immediately; the result is delivered
    // through the [Crop.onCropped] callback below.
    _controller.crop();
  }

  Future<void> _onCropped(CropResult result) async {
    switch (result) {
      case CropSuccess(:final croppedImage):
        try {
          final path = await _writeCroppedFile(croppedImage);
          if (!mounted) return;
          Navigator.of(context).pop(path);
          return;
        } catch (e, st) {
          logger.e("ListingCropScreen: failed to write cropped JPEG",
              error: e, stackTrace: st);
          if (mounted) {
            ToastTheme.showError(context,
                message: L10n.get("error_picking_photo"));
          }
        }
      case CropFailure(:final cause):
        logger.e("ListingCropScreen: crop callback reported failure",
            error: cause);
        if (mounted) {
          ToastTheme.showError(context,
              message: L10n.get("error_picking_photo"));
        }
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<String> _writeCroppedFile(Uint8List bytes) async {
    // Re-encode through the [image] package so we can (a) honor
    // [maxOutputDimension] and (b) emit JPEG at our chosen quality, matching
    // the cap the previous [ImageCropper] flow enforced.
    final decoded = img.decodeImage(bytes);
    Uint8List output;
    if (decoded == null) {
      output = bytes;
    } else {
      final longSide = decoded.width > decoded.height
          ? decoded.width
          : decoded.height;
      img.Image resized = decoded;
      if (longSide > widget.maxOutputDimension) {
        if (decoded.width >= decoded.height) {
          resized = img.copyResize(decoded, width: widget.maxOutputDimension);
        } else {
          resized = img.copyResize(decoded, height: widget.maxOutputDimension);
        }
      }
      output =
          Uint8List.fromList(img.encodeJpg(resized, quality: widget.jpegQuality));
    }
    final dir = await getTemporaryDirectory();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final file = File("${dir.path}/uydosh_crop_$stamp.jpg");
    await file.writeAsBytes(output, flush: true);
    return file.path;
  }

  void _cancel() {
    HapticFeedbackUtils.impact();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          top: false,
          bottom: false,
          child: Stack(
            fit: StackFit.expand,
            children: [
              _buildBody(),
              _buildTopBar(),
              _buildBottomBar(),
              if (_busy)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0x66000000),
                    child: Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final error = _loadError;
    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            error,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    final bytes = _imageBytes;
    if (bytes == null) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Padding(
      // Reserve room for the chrome (title bar ~64, bottom bar ~120) so the
      // crop rect doesn't sit under the buttons.
      padding: EdgeInsets.fromLTRB(
        16,
        topInset + 56,
        16,
        bottomInset + 120,
      ),
      child: Crop(
        image: bytes,
        controller: _controller,
        onCropped: _onCropped,
        aspectRatio: _aspect.value,
        baseColor: Colors.black,
        maskColor: Colors.black.withValues(alpha: 0.55),
        // Start the crop rect at the full visible photo so it lines up
        // with the image edges on entry. We can't use
        // [InitialRectBuilder.withSizeAndRatio(size: 1.0)] in free-aspect
        // mode because the package internally substitutes a 1.0 aspect
        // ratio when null is passed, which would force a centered square
        // (showing as a horizontal strip on tall photos).
        //
        // We also can't return the raw [imageRect] (the pre-scale
        // letterboxed bounds): with [interactive] true the package
        // immediately calls `_applyScale(scaleToCover)` which grows the
        // image to fill the viewport. The cropRect stays as-set, so
        // returning the original imageRect would leave the brackets
        // sitting inside a now-bigger photo. Returning the [viewportRect]
        // (and a viewport-fitted rect for locked aspects) means the crop
        // rect matches the post-scale visible image area exactly.
        initialRectBuilder: InitialRectBuilder.withBuilder(
          (viewportRect, imageRect) =>
              _initialCropRect(viewportRect, _aspect.value),
        ),
        radius: 0,
        interactive: true,
        cornerDotBuilder: (size, edge) =>
            _CornerMarker(size: size, edge: edge),
        progressIndicator: const CircularProgressIndicator(
          color: Colors.white,
        ),
        overlayBuilder: (context, rect) {
          // Anchor the brand mark to the bottom-right of the visible crop
          // rect so the user previews exactly where [WatermarkService]
          // will land the logo on the saved photo.
          //
          // Constrain the logo so it never spills outside the rect: when
          // the user shrinks the crop area, scale the logo down to fit
          // (with a fixed margin), and hide it entirely if the rect is
          // smaller than the minimum readable mark.
          const margin = 10.0;
          const desiredLogoSize = 56.0;
          const minLogoSize = 24.0;
          final maxLogoSize = math.max(
            0.0,
            math.min(rect.width, rect.height) - margin * 2,
          );
          if (maxLogoSize < minLogoSize) {
            return const SizedBox.shrink();
          }
          final logoSize = math.min(desiredLogoSize, maxLogoSize);
          // The package wraps this widget in `Positioned.fromRect(rect:
          // cropRect)`, so coordinates here are *local* to the crop rect
          // (top-left = 0,0, bottom-right = rect.size). Anchor with
          // `right`/`bottom` rather than recomputing absolute offsets,
          // otherwise the logo lands outside the local box and gets
          // clipped.
          return IgnorePointer(
            child: Stack(
              children: [
                Positioned(
                  right: margin,
                  bottom: margin,
                  width: logoSize,
                  height: logoSize,
                  child: Image.asset(
                    "assets/icon/components/brand_logo_transparent.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopBar() {
    final topPadding = MediaQuery.paddingOf(context).top;
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: topPadding + 12,
          left: 16,
          right: 16,
          bottom: 12,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: 0.55),
              Colors.transparent,
            ],
          ),
        ),
        child: Center(
          child: Text(
            L10n.get("crop_listing_photo"),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final canInteract = !_busy && _imageBytes != null && _loadError == null;
    final canPickAspect = canInteract && widget.lockedAspectRatio == null;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: 12,
          bottom: bottomPadding + 16,
          left: 12,
          right: 12,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.65),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _CircleControlButton(
              icon: Icons.close,
              onPressed: _busy ? null : _cancel,
              tooltip: L10n.get("crop_cancel"),
            ),
            Flexible(
              child: _ToolPill(
                children: [
                  _ToolIconButton(
                    icon: Icons.rotate_90_degrees_ccw_outlined,
                    onPressed:
                        canInteract ? () => _rotate(clockwise: false) : null,
                    tooltip: L10n.get("crop_rotate_left"),
                  ),
                  _ToolIconButton(
                    icon: Icons.refresh,
                    onPressed: canInteract ? _undo : null,
                    tooltip: L10n.get("crop_undo"),
                  ),
                  _ToolIconButton(
                    assetPath: "assets/icon/components/aspect_ratio.svg",
                    onPressed: canPickAspect ? _showAspectPicker : null,
                    tooltip: L10n.get("crop_aspect_ratio"),
                  ),
                  _ToolIconButton(
                    icon: Icons.rotate_90_degrees_cw_outlined,
                    onPressed:
                        canInteract ? () => _rotate(clockwise: true) : null,
                    tooltip: L10n.get("crop_rotate_right"),
                  ),
                ],
              ),
            ),
            _CircleControlButton(
              icon: Icons.check,
              onPressed: canInteract ? _confirmCrop : null,
              tooltip: L10n.get("crop_done"),
              primary: true,
            ),
          ],
        ),
      ),
    );
  }
}

/// Round 3D pill button used for the bookend cancel / done actions on the
/// bottom toolbar. The primary variant uses [BlueThemeColors.primary] (same
/// brand blue as the camera shutter / "use photo" button) so the affirmative
/// action stays consistent across the listing-creation flow.
class _CircleControlButton extends StatefulWidget {
  const _CircleControlButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.primary = false,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final bool primary;

  @override
  State<_CircleControlButton> createState() => _CircleControlButtonState();
}

class _CircleControlButtonState extends State<_CircleControlButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;
    final base = widget.primary
        ? BlueThemeColors.primary
        : const Color(0xFF1F2630);

    final shadows = _pressed || !enabled
        ? ThreeDSurfaceStyle.pressedShadows(context)
        : <BoxShadow>[
            if (widget.primary)
              ...ThreeDSurfaceStyle.floatingOrbHaloShadows(
                context,
                base,
                depthScale: 0.7,
              ),
            ...ThreeDSurfaceStyle.elevatedShadows(context),
          ];

    final button = Semantics(
      label: widget.tooltip,
      button: true,
      enabled: enabled,
      child: GestureDetector(
        onTap: enabled
            ? () {
                HapticFeedbackUtils.impact();
                widget.onPressed!();
              }
            : null,
        onTapDown:
            enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel:
            enabled ? () => setState(() => _pressed = false) : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: ThreeDSurfaceStyle.surfaceGradient(context, base),
            boxShadow: shadows,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),
          child: Opacity(
            opacity: enabled ? 1 : 0.55,
            child: Icon(widget.icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
    final t = widget.tooltip;
    if (t == null) return button;
    return Tooltip(message: t, child: button);
  }
}

/// Dark slate pill that groups the in-pill icon tools (rotate, undo, aspect).
class _ToolPill extends StatelessWidget {
  const _ToolPill({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    const base = Color(0xFF1F2630);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: ThreeDSurfaceStyle.surfaceGradient(context, base),
        boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

/// Borderless icon button rendered inside [_ToolPill]. Uses an [InkWell]
/// ripple over the pill background so the tools feel grouped together.
///
/// Accepts either a Material [IconData] or an SVG [assetPath] (tinted via
/// `currentColor` so the disabled state matches the rest of the toolbar).
/// Exactly one of [icon] / [assetPath] must be provided.
class _ToolIconButton extends StatelessWidget {
  const _ToolIconButton({
    required this.onPressed,
    this.icon,
    this.assetPath,
    this.tooltip,
  }) : assert(
          (icon != null) ^ (assetPath != null),
          "Provide exactly one of icon or assetPath",
        );

  final IconData? icon;
  final String? assetPath;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final tintColor = Colors.white.withValues(alpha: enabled ? 1 : 0.4);
    final iconWidget = icon != null
        ? Icon(icon, color: tintColor, size: 22)
        : Center(
            child: SvgPicture.asset(
              assetPath!,
              width: 22,
              height: 22,
              colorFilter: ColorFilter.mode(tintColor, BlendMode.srcIn),
            ),
          );
    final button = Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: enabled
            ? () {
                HapticFeedbackUtils.impact();
                onPressed!();
              }
            : null,
        child: SizedBox(
          width: 44,
          height: 44,
          child: iconWidget,
        ),
      ),
    );
    final t = tooltip;
    if (t == null) return button;
    return Tooltip(message: t, child: button);
  }
}

/// Small white square / L-bracket painted at each corner of the crop rect.
/// Replaces the round handle dots so the crop indicator feels like the
/// classic photo-cropper marker the user sketched. The bracket arms point
/// inward from each corner so the marker visually "grips" the rect.
class _CornerMarker extends StatelessWidget {
  const _CornerMarker({required this.size, required this.edge});

  final double size;
  final EdgeAlignment edge;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerMarkerPainter(edge: edge),
      ),
    );
  }
}

class _CornerMarkerPainter extends CustomPainter {
  _CornerMarkerPainter({required this.edge});

  final EdgeAlignment edge;

  @override
  void paint(Canvas canvas, Size size) {
    const arm = 14.0;
    const stroke = 3.0;
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // The dot widget is centered on the corner of the crop rect, so the
    // rect's actual corner sits at the centre of [size]. We draw two short
    // strokes from there pointing inward along the rect's edges.
    final cx = size.width / 2;
    final cy = size.height / 2;

    final dx = switch (edge) {
      EdgeAlignment.topLeft || EdgeAlignment.bottomLeft => 1.0,
      EdgeAlignment.topRight || EdgeAlignment.bottomRight => -1.0,
    };
    final dy = switch (edge) {
      EdgeAlignment.topLeft || EdgeAlignment.topRight => 1.0,
      EdgeAlignment.bottomLeft || EdgeAlignment.bottomRight => -1.0,
    };

    final corner = Offset(cx, cy);
    canvas.drawLine(corner, corner.translate(arm * dx, 0), paint);
    canvas.drawLine(corner, corner.translate(0, arm * dy), paint);
  }

  @override
  bool shouldRepaint(covariant _CornerMarkerPainter old) =>
      old.edge != edge;
}
