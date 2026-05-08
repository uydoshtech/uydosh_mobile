import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/state/profile_completion_state.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// Diameter of the circular avatar in app bar actions (neighbors use 28px).
/// The bell uses the same slot + padding → ~40px face; a full-bleed photo
/// reads larger, so this stays smaller than that (~32px) for visual balance.
const double kAppBarAvatarContentSize = 32;

/// Person outline or the current user's cached avatar for app bar slots.
///
/// The widget keeps a stable subtree across rebuilds: the fallback
/// `person_outline` glyph is only painted while the avatar image is unknown,
/// missing, or actively decoding for the first time. Once the image is in
/// Flutter's [ImageCache] (warmed via [precacheCurrentUserAvatar] right after
/// the profile loads), subsequent rebuilds resolve the frame synchronously and
/// the glyph never blinks back in — fixing the "default icon, then PNG" flash
/// most visible on the Home tab during cold start.
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
            child: Image(
              image: CachedNetworkImageProvider(
                resolved,
                maxWidth: px,
                maxHeight: px,
              ),
              width: iconSize,
              height: iconSize,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (wasSynchronouslyLoaded || frame != null) {
                  return child;
                }
                return fallback;
              },
              errorBuilder: (context, error, stackTrace) => fallback,
            ),
          ),
        );
      },
    );
  }
}

/// Warm Flutter's [ImageCache] with the current user's avatar so the app bar
/// can paint it on the first frame after the profile arrives, without falling
/// back through the placeholder glyph.
///
/// Safe to call multiple times — [precacheImage] dedupes against the cache.
void precacheCurrentUserAvatar(BuildContext context, String? rawAvatarUrl) {
  final resolved = resolveAvatarUrl(rawAvatarUrl);
  if (resolved == null) return;
  final dpr = MediaQuery.maybeOf(context)?.devicePixelRatio ?? 1.0;
  // Cover the largest size we render in the app bar (40 logical px when the
  // user has an avatar — see `main_navigation.dart`).
  const maxLogical = 40.0;
  final px = (maxLogical * dpr).round();
  final provider = CachedNetworkImageProvider(
    resolved,
    maxWidth: px,
    maxHeight: px,
  );
  precacheImage(provider, context, onError: (_, __) {});
}
