import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";

/// Loads a circular (or caller-clipped) avatar bitmap using [Image] +
/// [CachedNetworkImageProvider], matching [AppBarProfileIcon]: DPR-sized
/// decode caps, [gaplessPlayback], and a stable [fallback] until the first
/// frame decodes (avoids placeholder flicker versus raw [CachedNetworkImage]).
class NetworkAvatarImage extends StatelessWidget {
  const NetworkAvatarImage({
    required this.imageUrl,
    required this.size,
    required this.fallback,
    super.key,
  });

  final String imageUrl;
  final double size;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final px = (size * dpr).round();
    return Image(
      image: CachedNetworkImageProvider(
        imageUrl,
        maxWidth: px,
        maxHeight: px,
      ),
      width: size,
      height: size,
      fit: BoxFit.cover,
      gaplessPlayback: true,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) {
          return child;
        }
        return fallback;
      },
      errorBuilder: (context, error, stackTrace) => fallback,
    );
  }
}
