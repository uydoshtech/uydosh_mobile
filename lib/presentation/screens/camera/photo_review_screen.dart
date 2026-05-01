import "dart:io";

import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

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
    return Stack(
      fit: StackFit.expand,
      children: [
        PhotoReviewWithLogo(path: path),
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
        child: Stack(
          fit: StackFit.expand,
          children: [
            image,
            Positioned(
              right: 12,
              bottom: 12,
              child: IgnorePointer(
                child: Image.asset(
                  "assets/icon/components/brand_logo_transparent.png",
                  width: 56,
                  height: 56,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ],
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
    final base = widget.primary
        ? BlueThemeColors.primary
        : const Color(0xFF1F2630);
    const fg = Colors.white;

    final shadows = _pressed
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
          transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: ThreeDSurfaceStyle.surfaceGradient(context, base),
            boxShadow: shadows,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.10),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: fg, size: 20),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  color: fg,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
