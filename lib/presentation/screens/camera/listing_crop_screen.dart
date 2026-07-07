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
import "package:uy_dosh/base/services/watermark_service.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/presentation/widgets/common/glass_bottom_sheet_surface.dart";
import "package:uy_dosh/presentation/widgets/common/swipe_dismissible_sheet.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_logo_spinner.dart";

/// UyDosh-styled photo crop screen.
///
/// Originally introduced to replace the native `image_cropper` flow
/// (TOCropViewController on iOS, uCrop on Android) for **listing photos** so
/// we can theme the surface and overlay the UyDosh brand mark exactly where
/// [WatermarkService] will bake the watermark. Now also reused for the
/// **profile avatar** crop via [showBrandMark]/[circleCrop]/[titleL10nKey],
/// which let us drop the `image_cropper` dependency entirely.
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
    this.titleL10nKey = "crop_listing_photo",
    this.showBrandMark = true,
    this.circleCrop = false,
  });

  final String sourcePath;

  /// `width / height` ratio to lock the crop to. `null` lets the user freely
  /// adjust. Ignored — and forced to 1.0 — when [circleCrop] is true.
  final double? lockedAspectRatio;

  /// Cap on the longer side of the cropped JPEG (matches the previous
  /// `image_cropper` config so subsequent watermarking + upload stays light).
  final int maxOutputDimension;

  /// JPEG quality of the encoded crop result (0-100).
  final int jpegQuality;

  /// L10n key for the title rendered in the top bar.
  final String titleL10nKey;

  /// Whether to render the UyDosh brand mark inside the crop rect to preview
  /// where [WatermarkService] will bake it. Avatar callers pass `false`.
  final bool showBrandMark;

  /// When true, renders a circular crop UI (forces 1:1 aspect, hides the
  /// aspect picker, shows a circular mask). The encoded JPEG is still the
  /// square bounding box; circular display is the caller's responsibility.
  final bool circleCrop;

  @override
  State<ListingCropScreen> createState() => _ListingCropScreenState();
}

enum _AspectChoice {
  free,
  ratio1x1,
  ratio3x4,
  ratio4x3,
  ratio9x16,
  ratio16x9,
  ratio2x3,
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
      case _AspectChoice.ratio3x4:
        return 3 / 4;
      case _AspectChoice.ratio4x3:
        return 4 / 3;
      case _AspectChoice.ratio9x16:
        return 9 / 16;
      case _AspectChoice.ratio16x9:
        return 16 / 9;
      case _AspectChoice.ratio2x3:
        return 2 / 3;
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
      case _AspectChoice.ratio3x4:
        return "3:4";
      case _AspectChoice.ratio4x3:
        return "4:3";
      case _AspectChoice.ratio9x16:
        return "9:16";
      case _AspectChoice.ratio16x9:
        return "16:9";
      case _AspectChoice.ratio2x3:
        return "2:3";
      case _AspectChoice.ratio3x2:
        return "3:2";
    }
  }

  IconData get icon {
    switch (this) {
      case _AspectChoice.free:
        return Icons.crop_free;
      case _AspectChoice.ratio1x1:
        return Icons.crop_square;
      case _AspectChoice.ratio3x4:
      case _AspectChoice.ratio9x16:
      case _AspectChoice.ratio2x3:
        return Icons.stay_current_portrait;
      case _AspectChoice.ratio4x3:
      case _AspectChoice.ratio16x9:
      case _AspectChoice.ratio3x2:
        return Icons.stay_current_landscape;
    }
  }
}

class _ListingCropScreenState extends State<ListingCropScreen> {
  final CropController _controller = CropController();
  Uint8List? _imageBytes;
  String? _loadError;
  bool _busy = false;
  _AspectChoice _aspect = _AspectChoice.free;

  /// Effective lock: `circleCrop` always implies a 1:1 lock per the
  /// `crop_your_image` API (it forces aspect 1.0 internally when
  /// `withCircleUi` is true), so we mirror that here.
  double? get _effectiveLock =>
      widget.circleCrop ? 1.0 : widget.lockedAspectRatio;

  @override
  void initState() {
    super.initState();
    final lock = _effectiveLock;
    if (lock != null) {
      // Pick the closest preset to the locked ratio so the picker reflects
      // the actual constraint (prevents user confusion when the chosen
      // option appears different from the rect they're cropping).
      _aspect = _closestPresetTo(lock);
    }
    _loadImage();
  }

  /// Build the initial crop rect inside the visible photo. Free-aspect
  /// mode hugs the [imageRect] so the brackets match the photo edges on
  /// entry; locked aspects centre an aspect-correct rect that touches
  /// the photo on its tight axis.
  static Rect _initialCropRect(Rect imageRect, double? aspectRatio) {
    if (aspectRatio == null) {
      return imageRect;
    }
    final iw = imageRect.width;
    final ih = imageRect.height;
    final imageAr = iw / ih;
    final double rectW;
    final double rectH;
    if (aspectRatio > imageAr) {
      rectW = iw;
      rectH = iw / aspectRatio;
    } else {
      rectH = ih;
      rectW = ih * aspectRatio;
    }
    return Rect.fromLTWH(
      imageRect.left + (iw - rectW) / 2,
      imageRect.top + (ih - rectH) / 2,
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
    final selected = await showAppBottomSheet<_AspectChoice>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      useSafeArea: false,
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
            padding: const EdgeInsets.only(bottom: 12),
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
                            leading: Icon(
                              choice.icon,
                              color: isSelected ? accent : Colors.white,
                            ),
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
                      child: UydoshLogoSpinner(),
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
        child: UydoshLogoSpinner(),
      );
    }
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return Padding(
      // Reserve room for the chrome so the crop rect doesn't sit under the
      // title bar / bottom controls. Keep this tight so the photo viewport
      // is as large as possible (the overlays already use gradients).
      padding: EdgeInsets.fromLTRB(
        16,
        // Top bar is roughly: 12 (top pad) + ~20 (text) + 12 (bottom pad).
        topInset + 44,
        16,
        // Bottom bar is roughly: 12 (top pad) + 56 (pill/button height) + 16 (bottom pad).
        bottomInset + 92,
      ),
      child: Crop(
        image: bytes,
        controller: _controller,
        onCropped: _onCropped,
        aspectRatio: _aspect.value,
        withCircleUi: widget.circleCrop,
        baseColor: Colors.black,
        maskColor: Colors.black.withValues(alpha: 0.55),
        // Start the crop rect at the full visible photo so it lines up
        // with the image edges on entry. We can't use
        // [InitialRectBuilder.withSizeAndRatio(size: 1.0)] in free-aspect
        // mode because the package internally substitutes a 1.0 aspect
        // ratio when null is passed, which would force a centered square
        // (showing as a horizontal strip on tall photos).
        initialRectBuilder: InitialRectBuilder.withBuilder(
          (viewportRect, imageRect) =>
              _initialCropRect(imageRect, _aspect.value),
        ),
        radius: 0,
        // [interactive] true would let the user pinch-zoom the image,
        // but it also disables the "drag the crop rect to move it"
        // gesture inside the package (single-finger drag pans the image
        // instead). For a listing-photo cropper, being able to drag the
        // crop box around is more important than pinch-zoom, so we
        // mirror the previous [ImageCropper] UX and keep this off.
        interactive: false,
        cornerDotBuilder: (size, edge) =>
            _CornerMarker(size: size, edge: edge),
        progressIndicator: const UydoshLogoSpinner(),
        overlayBuilder: (context, rect) {
          // Anchor the brand mark to the bottom-right of the visible crop
          // rect with the same proportional size + margin that
          // [WatermarkService] bakes into the final photo (both pull from
          // [WatermarkPlacement]). That way what the user sees here is
          // exactly what they'll get on the saved file.
          //
          // If the crop rect gets too small to comfortably hold the mark,
          // hide it instead of letting it dominate the cropped frame.
          //
          // Suppressed entirely on avatar (and other non-listing) crops via
          // [showBrandMark]: the watermark service only stamps listing
          // photos, so previewing it on profile avatars would be misleading.
          if (!widget.showBrandMark) {
            return const SizedBox.shrink();
          }
          // Previously the logo size was derived purely from the crop rect.
          // As the user tightens the crop, the rect shrinks → the logo shrinks
          // and eventually gets hidden (felt like the watermark "disappears").
          //
          // In reality the baked watermark is sized against the *final output*
          // image dimensions (after we re-encode / resize), so we keep the UI
          // preview readable by clamping to a minimum size, only hiding if the
          // crop rect is genuinely too small to fit it.
          const minLogoSize = 28.0;
          const minMargin = 8.0;

          final shorter = math.min(rect.width, rect.height);
          final desiredLogo = shorter * WatermarkPlacement.sizeFraction;
          final desiredMargin = shorter * WatermarkPlacement.marginFraction;
          final margin = math.max(minMargin, desiredMargin);
          final available = shorter - 2 * margin;
          if (available <= 0) {
            return const SizedBox.shrink();
          }
          final logoSize = math.min(
            available,
            math.max(minLogoSize, desiredLogo),
          );
          // Still hide only if the crop rect can't reasonably contain the mark.
          if (logoSize < minLogoSize * 0.75) {
            return const SizedBox.shrink();
          }
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
            L10n.get(widget.titleL10nKey),
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
    final canPickAspect = canInteract && _effectiveLock == null;
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
