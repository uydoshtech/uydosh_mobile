import "package:flutter/material.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

/// Reusable chat avatar with initials or person icon.
/// Used in user messaging (chat) and support chat screens.
class ChatAvatar extends StatelessWidget {
  const ChatAvatar({
    required this.isCurrentUser,
    this.initials,
    super.key,
  });

  /// Whether this is the current user's avatar (black bg) vs other user (white bg).
  final bool isCurrentUser;

  /// User initials to display (e.g. "AM"). If null or empty, shows person icon.
  final String? initials;

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
    final glyphColor =
        (!isCurrentUser && isBlueTheme) ? primary : Theme.of(context).colorScheme.onSurface;

    return SizedBox(
      width: diameter,
      height: diameter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: ThreeDSurfaceStyle.surfaceGradient(context, base),
          boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
        child: ClipOval(
          child: Center(
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
          ),
        ),
      ),
    );
  }
}
