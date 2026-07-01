import "dart:io";

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";

/// Medium-sized centered preview for a single uploaded photo.
///
/// Used by the create/edit-listing photo grid so a user can tap any tile to
/// inspect the photo without leaving the form. Supports both already-uploaded
/// remote photos (use [PhotoPreviewDialog.network]) and freshly-picked local
/// files that haven't been uploaded yet (use [PhotoPreviewDialog.file]).
///
/// When [onMakePrimary] is provided (edit/create reorder mode) and the photo
/// isn't already primary, a "Make primary" action is rendered at the bottom of
/// the image. Tapping it invokes the callback and closes the dialog.
class PhotoPreviewDialog extends StatelessWidget {
  const PhotoPreviewDialog._({
    required this.imageProvider,
    this.onMakePrimary,
    this.isPrimary = false,
  });

  factory PhotoPreviewDialog.network(
    String url, {
    VoidCallback? onMakePrimary,
    bool isPrimary = false,
  }) {
    return PhotoPreviewDialog._(
      imageProvider: CachedNetworkImageProvider(url),
      onMakePrimary: onMakePrimary,
      isPrimary: isPrimary,
    );
  }

  factory PhotoPreviewDialog.file(
    File file, {
    VoidCallback? onMakePrimary,
    bool isPrimary = false,
  }) {
    return PhotoPreviewDialog._(
      imageProvider: FileImage(file),
      onMakePrimary: onMakePrimary,
      isPrimary: isPrimary,
    );
  }

  final ImageProvider imageProvider;

  /// Optional "make this photo primary" action. When non-null and the photo is
  /// not already primary, a button is shown at the bottom of the image.
  final VoidCallback? onMakePrimary;

  /// Whether this photo is already the primary one (hides the action so we
  /// don't offer a no-op).
  final bool isPrimary;

  static Future<void> show(
    BuildContext context, {
    required ImageProvider image,
    VoidCallback? onMakePrimary,
    bool isPrimary = false,
  }) {
    final isLightTheme = ThemeState().isLightTheme;
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: isLightTheme ? 0.35 : 0.72),
      builder: (_) => PhotoPreviewDialog._(
        imageProvider: image,
        onMakePrimary: onMakePrimary,
        isPrimary: isPrimary,
      ),
    );
  }

  static Future<void> showNetwork(
    BuildContext context,
    String url, {
    VoidCallback? onMakePrimary,
    bool isPrimary = false,
  }) {
    return show(
      context,
      image: CachedNetworkImageProvider(url),
      onMakePrimary: onMakePrimary,
      isPrimary: isPrimary,
    );
  }

  static Future<void> showFile(
    BuildContext context,
    File file, {
    VoidCallback? onMakePrimary,
    bool isPrimary = false,
  }) {
    return show(
      context,
      image: FileImage(file),
      onMakePrimary: onMakePrimary,
      isPrimary: isPrimary,
    );
  }

  Color _surfaceColor(BuildContext context) {
    if (ThemeState().isLightTheme) {
      return Theme.of(context).colorScheme.surface;
    }
    return const Color(0xFF0B1220);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // Keep it firmly in "popup" territory — leaves a clear gap of background
    // around the image so it doesn't read as a full-screen viewer.
    final maxWidth = media.size.width * 0.7;
    final maxHeight = media.size.height * 0.5;
    final showMakePrimary = onMakePrimary != null && !isPrimary;
    final surfaceColor = _surfaceColor(context);
    final errorIconColor = Theme.of(context)
        .colorScheme
        .onSurfaceVariant
        .withValues(alpha: 0.5);

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ColoredBox(
                color: surfaceColor,
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 4,
                  child: Image(
                    image: imageProvider,
                    fit: BoxFit.contain,
                    width: maxWidth,
                    height: maxHeight,
                    errorBuilder: (context, error, stackTrace) {
                      return SizedBox(
                        width: maxWidth,
                        height: maxHeight,
                        child: Center(
                          child: ThemeIcon(
                            Icons.broken_image,
                            color: errorIconColor,
                            size: 48,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            Positioned(
              top: -10,
              right: -10,
              child: ThreeDAppBarIconButton(
                iconData: Icons.close,
                onPressed: () => Navigator.of(context).pop(),
                semanticsLabel:
                    MaterialLocalizations.of(context).closeButtonTooltip,
                borderRadius: const BorderRadius.all(Radius.circular(999)),
                iconSize: 18,
                contentSlotSize: 20,
                padding: const EdgeInsets.all(4),
                neumorphicSoftUi: ThemeState().isLightTheme,
              ),
            ),
            if (showMakePrimary)
              Positioned(
                left: 0,
                right: 0,
                bottom: 12,
                child: Center(
                  child: GhostButtonFactory.iconText(
                    onPressed: () {
                      onMakePrimary!();
                      Navigator.of(context).pop();
                    },
                    icon: Icons.star,
                    text: L10n.get("make_photo_primary"),
                    iconSize: 18,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
