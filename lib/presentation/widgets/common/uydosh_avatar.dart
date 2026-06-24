import "package:flutter/material.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/presentation/widgets/common/network_avatar_image.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

enum UyDoshAvatarSize {
  small(32),
  medium(40),
  large(48),
  xxl(100);

  const UyDoshAvatarSize(this.value);

  final double value;
}

/// Theme-aware circular avatar with image loading, fallback content, and ring.
class UyDoshAvatar extends StatelessWidget {
  const UyDoshAvatar({
    super.key,
    this.avatarUrl,
    this.displayName,
    this.initials,
    this.size = UyDoshAvatarSize.medium,
    this.customSize,
    this.backgroundColor,
    this.backgroundGradient,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth = 1,
    this.boxShadow,
    this.fallbackIcon = Icons.person,
    this.fallback,
    this.fontWeight = FontWeight.bold,
  });

  final String? avatarUrl;
  final String? displayName;
  final String? initials;
  final UyDoshAvatarSize size;
  final double? customSize;
  final Color? backgroundColor;
  final Gradient? backgroundGradient;
  final Color? foregroundColor;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;
  final IconData fallbackIcon;
  final Widget? fallback;
  final FontWeight fontWeight;

  double get _diameter => customSize ?? size.value;

  @override
  Widget build(BuildContext context) {
    final diameter = _diameter;
    final resolvedAvatarUrl = resolveAvatarUrl(avatarUrl);
    final effectiveBorderColor =
        borderColor ?? avatarCircleBorderColor(context);
    final effectiveBackground = backgroundColor ??
        Theme.of(context).colorScheme.surfaceContainerHighest;
    final effectiveForeground =
        foregroundColor ?? Theme.of(context).colorScheme.onSurfaceVariant;
    final fallbackChild = fallback ??
        _DefaultAvatarFallback(
          initials: _effectiveInitials,
          icon: fallbackIcon,
          color: effectiveForeground,
          fontSize: diameter * 0.38,
          iconSize: diameter * 0.5,
          fontWeight: fontWeight,
        );

    final fallbackContent = Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        color: backgroundGradient == null ? effectiveBackground : null,
        gradient: backgroundGradient,
      ),
      alignment: Alignment.center,
      child: fallbackChild,
    );

    return SizedBox(
      width: diameter,
      height: diameter,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: resolvedAvatarUrl == null && backgroundGradient == null
              ? effectiveBackground
              : null,
          boxShadow: boxShadow,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipOval(
                child: resolvedAvatarUrl != null
                    ? NetworkAvatarImage(
                        imageUrl: resolvedAvatarUrl,
                        size: diameter,
                        fallback: fallbackContent,
                      )
                    : fallbackContent,
              ),
            ),
            if (borderWidth > 0)
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: effectiveBorderColor,
                      width: borderWidth,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String get _effectiveInitials {
    final explicit = initials?.trim();
    if (explicit != null && explicit.isNotEmpty) return explicit;
    return StringUtils.extractInitials(displayName ?? "");
  }
}

class _DefaultAvatarFallback extends StatelessWidget {
  const _DefaultAvatarFallback({
    required this.initials,
    required this.icon,
    required this.color,
    required this.fontSize,
    required this.iconSize,
    required this.fontWeight,
  });

  final String initials;
  final IconData icon;
  final Color color;
  final double fontSize;
  final double iconSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    if (initials.isNotEmpty) {
      return Text(
        initials,
        style: TextStyle(
          color: color,
          fontWeight: fontWeight,
          fontSize: fontSize,
          letterSpacing: 0.3,
        ),
      );
    }

    return ThemeIcon(icon, size: iconSize, color: color);
  }
}
