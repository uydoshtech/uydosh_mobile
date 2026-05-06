import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/base/utils/string_utils.dart";

/// Circular avatar chip with optional ring stroke (clips image to oval).
///
/// Same treatment as gig request tiles and collapsed chat-group headers:
/// relative avatar URLs resolved via [resolveAvatarUrl], initials / person
/// fallback, thin border [ringColor] so the photo reads as a button-sized
/// disk on dark surfaces.
class GigParticipantAvatarBadge extends StatelessWidget {
  const GigParticipantAvatarBadge({
    required this.avatarUrl,
    required this.displayName,
    required this.ringColor,
    super.key,
    this.size = 40,
  });

  static const double defaultSize = 40;

  final String? avatarUrl;
  final String? displayName;
  final Color ringColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final url = resolveAvatarUrl(avatarUrl);
    final cacheExtent = (size * MediaQuery.devicePixelRatioOf(context)).round();

    Widget fallback() {
      final initials = StringUtils.extractInitials(displayName ?? "");
      return Container(
        color: scheme.primaryContainer,
        alignment: Alignment.center,
        child: initials.isNotEmpty
            ? Text(
                initials,
                style: TextStyle(
                  color: scheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.35,
                ),
              )
            : Icon(
                Icons.person,
                size: size * 0.5,
                color: scheme.onPrimaryContainer,
              ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipOval(
              child: url != null
                  ? CachedNetworkImage(
                      imageUrl: url,
                      fit: BoxFit.cover,
                      memCacheWidth: cacheExtent,
                      memCacheHeight: cacheExtent,
                      placeholder: (_, __) => fallback(),
                      errorWidget: (_, __, ___) => fallback(),
                    )
                  : fallback(),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ringColor, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
