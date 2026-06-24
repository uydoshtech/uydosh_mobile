import "package:flutter/material.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_avatar.dart";

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
    final glyphColor = (!isCurrentUser && isBlueTheme)
        ? primary
        : Theme.of(context).colorScheme.onSurface;

    return UyDoshAvatar(
      avatarUrl: avatarUrl,
      initials: hasInitials ? initials : null,
      size: UyDoshAvatarSize.small,
      customSize: diameter,
      backgroundColor: base,
      backgroundGradient: ThreeDSurfaceStyle.surfaceGradient(context, base),
      foregroundColor: glyphColor,
      boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
      fontWeight: FontWeight.w800,
    );
  }
}
