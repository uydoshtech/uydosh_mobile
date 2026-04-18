import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

/// Reusable chat avatar. Shows the user's profile picture when [avatarUrl] is
/// provided, otherwise falls back to initials, then to a person icon.
/// Used in user messaging (chat) and support chat screens.
class ChatAvatar extends StatelessWidget {
  const ChatAvatar({
    required this.isCurrentUser,
    this.initials,
    this.avatarUrl,
    super.key,
  });

  /// Whether this is the current user's avatar (black bg) vs other user (white bg).
  final bool isCurrentUser;

  /// User initials to display (e.g. "AM"). If null or empty, shows person icon.
  final String? initials;

  /// Raw avatar URL or relative backend path. When provided and resolvable,
  /// the avatar image is shown inside the circle instead of initials.
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final diameter = 32.0;
    final hasInitials = initials != null && initials!.trim().isNotEmpty;
    final resolvedAvatarUrl = resolveAvatarUrl(avatarUrl);
    final hasAvatar = resolvedAvatarUrl != null;
    final isBlueTheme = ThemeState().isBlueTheme;

    // Match the profile avatar's 3D chrome: gradient + neumorphic shadows.
    // Keep a subtle tint difference so "me" reads distinct.
    final surface = Theme.of(context).colorScheme.surface;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final primary = Theme.of(context).colorScheme.primary;

    // Blue theme: other person's avatar is white face with blue glyphs.
    final base = (!isCurrentUser && isBlueTheme)
        ? Colors.white
        : (isCurrentUser
              ? Color.lerp(surface, onSurface, 0.06)!
              : Color.lerp(surface, onSurface, 0.02)!);
    final glyphColor =
        (!isCurrentUser && isBlueTheme) ? primary : Theme.of(context).colorScheme.onSurface;

    return SizedBox(
      width: diameter,
      height: diameter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: hasAvatar
              ? null
              : ThreeDSurfaceStyle.surfaceGradient(context, base),
          color: hasAvatar ? base : null,
          boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        child: ClipOval(
          child: hasAvatar
              ? CachedNetworkImage(
                  imageUrl: resolvedAvatarUrl,
                  width: diameter,
                  height: diameter,
                  fit: BoxFit.cover,
                  memCacheWidth: (diameter * 2).round(),
                  memCacheHeight: (diameter * 2).round(),
                  placeholder: (context, url) =>
                      _buildFallback(context, glyphColor, hasInitials),
                  errorWidget: (context, url, error) =>
                      _buildFallback(context, glyphColor, hasInitials),
                )
              : _buildFallback(context, glyphColor, hasInitials),
        ),
      ),
    );
  }

  Widget _buildFallback(
    BuildContext context,
    Color glyphColor,
    bool hasInitials,
  ) {
    return Center(
      child: hasInitials
          ? Text(
              initials!.trim(),
              style: TextStyle(
                color: glyphColor,
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 0.3,
              ),
            )
          : ThemeIcon(Icons.person, size: 16, color: glyphColor),
    );
  }
}
