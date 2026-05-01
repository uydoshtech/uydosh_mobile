import "dart:io";
import "dart:math" as math;
import "dart:ui" show ImageFilter;

import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/watermark_service.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";

/// Result returned by [PhotoReviewScreen] via [Navigator.pop]:
///   - the original [path] when the user accepts the photo,
///   - `null` when the user wants to retake / cancel.
typedef PhotoReviewResult = String?;

/// Full-screen Flutter review of a freshly captured photo.
///
/// Used in two places:
///   1. Inside [CustomCameraScreen] (via [PhotoReviewBody] embedded in its
///      own Scaffold so it shares the camera's chrome / lifecycle).
///   2. Wrapping captures from `image_picker` when the in-app custom
///      camera is disabled — without this, iOS would surface
///      `UIImagePickerController`'s untheable native preview screen and the
///      flow would feel like it left the UyDosh app mid-action.
///
/// In both cases we render the photo at its real aspect ratio and pin the
/// UyDosh brand mark to the **bottom-right** of the photo (not the screen)
/// so the preview matches where [WatermarkService] will bake the watermark.
class PhotoReviewScreen extends StatelessWidget {
  const PhotoReviewScreen({required this.path, super.key});

  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: false,
        bottom: false,
        child: PhotoReviewBody(
          path: path,
          onRetake: () => Navigator.of(context).pop<PhotoReviewResult>(null),
          onUsePhoto: () =>
              Navigator.of(context).pop<PhotoReviewResult>(path),
        ),
      ),
    );
  }
}

/// Re-usable body that renders the captured photo with the UyDosh brand
/// overlay and the Retake / Use-photo controls. Extracted so the embedded
/// review stage of `CustomCameraScreen` can render exactly the same UI
/// without nesting another `Scaffold`.
class PhotoReviewBody extends StatelessWidget {
  const PhotoReviewBody({
    required this.path,
    required this.onRetake,
    required this.onUsePhoto,
    super.key,
  });

  final String path;
  final VoidCallback onRetake;
  final VoidCallback onUsePhoto;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    // Reserve enough room for the bottom action bar (top padding 16 +
    // ~48 button height + 20 bottom padding ≈ 84) plus the home-bar safe
    // area, so the photo (and its bottom-right logo overlay) finish
    // above the Retake / Use-photo buttons instead of sitting behind
    // them and getting clipped.
    final bottomBarReserve = bottomInset + 96;
    return Stack(
      fit: StackFit.expand,
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: bottomBarReserve),
          child: PhotoReviewWithLogo(path: path),
        ),
        _PhotoReviewBottomBar(onRetake: onRetake, onUsePhoto: onUsePhoto),
      ],
    );
  }
}

/// Renders the photo at its real aspect ratio with the UyDosh brand mark
/// pinned to the **bottom-right** corner of the visible photo bounds.
class PhotoReviewWithLogo extends StatefulWidget {
  const PhotoReviewWithLogo({required this.path, super.key});

  final String path;

  @override
  State<PhotoReviewWithLogo> createState() => _PhotoReviewWithLogoState();
}

class _PhotoReviewWithLogoState extends State<PhotoReviewWithLogo> {
  Size? _imageSize;
  ImageStream? _stream;
  ImageStreamListener? _listener;

  @override
  void initState() {
    super.initState();
    _resolveSize();
  }

  @override
  void didUpdateWidget(covariant PhotoReviewWithLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _imageSize = null;
      _resolveSize();
    }
  }

  @override
  void dispose() {
    _detachListener();
    super.dispose();
  }

  void _detachListener() {
    final stream = _stream;
    final listener = _listener;
    if (stream != null && listener != null) {
      stream.removeListener(listener);
    }
    _stream = null;
    _listener = null;
  }

  void _resolveSize() {
    _detachListener();
    final stream =
        FileImage(File(widget.path)).resolve(ImageConfiguration.empty);
    final listener = ImageStreamListener(
      (info, _) {
        if (!mounted) return;
        setState(() {
          _imageSize = Size(
            info.image.width.toDouble(),
            info.image.height.toDouble(),
          );
        });
      },
      onError: (_, __) {
        if (!mounted) return;
        // Fall back to a portrait-ish ratio so the layout stays sensible
        // even if we can't decode the file (broken capture). The image
        // widget itself will surface the real failure if needed.
        setState(() => _imageSize = const Size(3, 4));
      },
    );
    stream.addListener(listener);
    _stream = stream;
    _listener = listener;
  }

  @override
  Widget build(BuildContext context) {
    final size = _imageSize;
    final image = Image.file(
      File(widget.path),
      fit: size == null ? BoxFit.contain : BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );

    if (size == null) {
      return Center(child: image);
    }

    return Center(
      child: AspectRatio(
        aspectRatio: size.width / size.height,
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Compute the logo size + margin from the rendered photo box
            // so the preview matches what [WatermarkService] will bake on
            // the saved file (both pull from [WatermarkPlacement]).
            final shorter =
                math.min(constraints.maxWidth, constraints.maxHeight);
            final logoSize = shorter * WatermarkPlacement.sizeFraction;
            final margin = shorter * WatermarkPlacement.marginFraction;
            return Stack(
              fit: StackFit.expand,
              children: [
                image,
                Positioned(
                  right: margin,
                  bottom: margin,
                  width: logoSize,
                  height: logoSize,
                  child: IgnorePointer(
                    child: Image.asset(
                      "assets/icon/components/brand_logo_transparent.png",
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Bottom action bar with the Retake / Use-photo pills.
class _PhotoReviewBottomBar extends StatelessWidget {
  const _PhotoReviewBottomBar({
    required this.onRetake,
    required this.onUsePhoto,
  });

  final VoidCallback onRetake;
  final VoidCallback onUsePhoto;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.only(
          top: 16,
          bottom: bottomPadding + 20,
          left: 24,
          right: 24,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [
              Colors.black.withValues(alpha: 0.55),
              Colors.transparent,
            ],
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            UyDoshReviewPillButton(
              icon: Icons.refresh,
              label: L10n.get("retake"),
              onPressed: onRetake,
            ),
            UyDoshReviewPillButton(
              icon: Icons.check,
              label: L10n.get("use_photo"),
              onPressed: onUsePhoto,
              primary: true,
            ),
          ],
        ),
      ),
    );
  }
}

/// Brand-colored 3D pill button used by the review/crop screens. Public so
/// `CustomCameraScreen` can reuse it for its inline review controls and
/// keep the look identical across both entry points.
class UyDoshReviewPillButton extends StatefulWidget {
  const UyDoshReviewPillButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.primary = false,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool primary;

  @override
  State<UyDoshReviewPillButton> createState() =>
      _UyDoshReviewPillButtonState();
}

class _UyDoshReviewPillButtonState extends State<UyDoshReviewPillButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AnimationSettingsState(),
      builder: (context, _) {
        const fg = Colors.white;
        // Tinted glass: brand-blue wash for the affirmative button, neutral
        // dark wash for the secondary one. Translucent so the watermark on
        // the photo behind the bar stays visible (was solid + heavy 3D
        // shadows before, which obscured the bottom-right brand mark).
        final tint = widget.primary
            ? BlueThemeColors.primary.withValues(alpha: _pressed ? 0.55 : 0.42)
            : Colors.black.withValues(alpha: _pressed ? 0.42 : 0.30);

        final disableAnimations =
            MediaQuery.maybeOf(context)?.disableAnimations ?? false;
        final enableGlass =
            AnimationSettingsState().uiAnimationsEnabled && !disableAnimations;

        // Slimmer pill (vertical 14 → 9, horizontal 22 → 18) so the row of
        // controls takes less vertical real-estate over the photo.
        final padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 9);
        final radius = BorderRadius.circular(999);

        // Inner content (icon + label) — same composition as before, just
        // slightly smaller icon to balance the slimmer pill.
        final content = Padding(
          padding: padding,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: fg, size: 18),
              const SizedBox(width: 7),
              Text(
                widget.label,
                style: const TextStyle(
                  color: fg,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        );

        // Subtle top→bottom gradient + hairline border keeps the pill
        // legible without re-introducing an opaque fill.
        final glassDecoration = BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: widget.primary ? 0.16 : 0.10),
              tint,
            ],
            stops: const [0.0, 1.0],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
            width: 0.6,
          ),
        );

        // Soft halo so the pill still reads as elevated against busy photos
        // (previous design used heavy 3D shadows + an orb halo — too much
        // visual weight for a glass surface).
        final boxShadow = <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: _pressed ? 0.18 : 0.28),
            blurRadius: _pressed ? 8 : 14,
            spreadRadius: 0,
            offset: Offset(0, _pressed ? 1 : 4),
          ),
        ];

        return Semantics(
          label: widget.label,
          button: true,
          child: GestureDetector(
            onTap: () {
              HapticFeedbackUtils.impact();
              widget.onPressed();
            },
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) => setState(() => _pressed = false),
            onTapCancel: () => setState(() => _pressed = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(0, _pressed ? 1 : 0, 0),
              decoration: BoxDecoration(
                borderRadius: radius,
                boxShadow: boxShadow,
              ),
              child: ClipRRect(
                borderRadius: radius,
                child: enableGlass
                    ? BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                        child: DecoratedBox(
                          decoration: glassDecoration,
                          child: content,
                        ),
                      )
                    : DecoratedBox(
                        decoration: glassDecoration,
                        child: content,
                      ),
              ),
            ),
          ),
        );
      },
    );
  }
}
