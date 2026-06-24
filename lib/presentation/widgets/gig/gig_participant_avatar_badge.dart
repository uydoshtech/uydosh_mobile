import "package:flutter/material.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_avatar.dart";

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

    return UyDoshAvatar(
      avatarUrl: avatarUrl,
      displayName: displayName,
      customSize: size,
      backgroundColor: scheme.primaryContainer,
      foregroundColor: scheme.onPrimaryContainer,
      borderColor: ringColor,
      borderWidth: 1.5,
    );
  }
}
