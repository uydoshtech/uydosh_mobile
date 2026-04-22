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
        final fallback = SizedBox.square(
          dimension: iconSize,
          child: Center(
            child: ThemeIcon(
              Icons.person_outline,
              color: iconColor,
              size: iconSize,
            ),
          ),
        );
        if (resolved == null) {
          return fallback;
        }
        final dpr = MediaQuery.of(context).devicePixelRatio;
        final px = (iconSize * dpr).round();
        return SizedBox.square(
          dimension: iconSize,
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: resolved,
              width: iconSize,
              height: iconSize,
              fit: BoxFit.cover,
              memCacheWidth: px,
              memCacheHeight: px,
              placeholder: (context, url) => fallback,
              errorWidget: (context, url, error) => fallback,
            ),
          ),
        );
      },
    );
  }
}
