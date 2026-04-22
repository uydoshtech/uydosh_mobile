import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/state/profile_completion_state.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// Person outline or the current user's cached avatar for app bar slots.
class AppBarProfileIcon extends StatelessWidget {
  const AppBarProfileIcon({
    required this.iconSize,
    required this.iconColor,
    super.key,
  });

  final double iconSize;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ProfileCompletionState(),
      builder: (context, child) {
        final resolved = resolveAvatarUrl(
          ProfileCompletionState().cachedAvatarUrl,
        );
        if (resolved == null) {
          return ThemeIcon(
            Icons.person_outline,
            color: iconColor,
            size: iconSize,
          );
        }
        final dpr = MediaQuery.of(context).devicePixelRatio;
        final px = (iconSize * dpr).round();
        return ClipOval(
          child: CachedNetworkImage(
            imageUrl: resolved,
            width: iconSize,
            height: iconSize,
            fit: BoxFit.cover,
            memCacheWidth: px,
            memCacheHeight: px,
            placeholder:
                (context, url) => ThemeIcon(
                  Icons.person_outline,
                  color: iconColor,
                  size: iconSize,
                ),
            errorWidget:
                (context, url, error) => ThemeIcon(
                  Icons.person_outline,
                  color: iconColor,
                  size: iconSize,
                ),
          ),
        );
      },
    );
  }
}
