import "dart:io";

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";

/// Medium-sized centered preview for a single uploaded photo.
///
/// Used by the create/edit-listing photo grid so a user can tap any tile to
/// inspect the photo without leaving the form. Supports both already-uploaded
/// remote photos (use [PhotoPreviewDialog.network]) and freshly-picked local
/// files that haven't been uploaded yet (use [PhotoPreviewDialog.file]).
class PhotoPreviewDialog extends StatelessWidget {
  const PhotoPreviewDialog._({required this.imageProvider});

  factory PhotoPreviewDialog.network(String url) {
    return PhotoPreviewDialog._(
      imageProvider: CachedNetworkImageProvider(url),
    );
  }

  factory PhotoPreviewDialog.file(File file) {
    return PhotoPreviewDialog._(imageProvider: FileImage(file));
  }

  final ImageProvider imageProvider;

  static Future<void> show(BuildContext context, {required ImageProvider image}) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (_) => PhotoPreviewDialog._(imageProvider: image),
    );
  }

  static Future<void> showNetwork(BuildContext context, String url) {
    return show(context, image: CachedNetworkImageProvider(url));
  }

  static Future<void> showFile(BuildContext context, File file) {
    return show(context, image: FileImage(file));
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // Keep it firmly in "popup" territory — leaves a clear gap of background
    // around the image so it doesn't read as a full-screen viewer.
    final maxWidth = media.size.width * 0.7;
    final maxHeight = media.size.height * 0.5;

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
                color: const Color(0xFF0B1220),
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
                        child: const Center(
                          child: ThemeIcon(
                            Icons.broken_image,
                            color: Colors.white54,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
