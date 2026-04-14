import "package:flutter/material.dart";
import "package:uy_dosh/presentation/widgets/common/neumorphic_toggle.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// A reusable settings row with an icon, title, optional subtitle, and a neumorphic toggle.
/// Used for settings like haptic feedback, onboarding, and animations.
class UydoshToggle extends StatelessWidget {
  const UydoshToggle({
    required this.title,
    required this.value,
    required this.onChanged,
    this.icon,
    this.iconColor,
    this.subtitle,
    this.contentPadding,
    super.key,
  });

  final IconData? icon;
  final Widget title;
  final Widget? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color? iconColor;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    final effectiveIconColor = iconColor ?? Theme.of(context).iconTheme.color;

    return ListTile(
      contentPadding: contentPadding,
      leading: icon != null ? ThemeIcon(icon, color: effectiveIconColor) : null,
      title: title,
      subtitle: subtitle,
      trailing: NeumorphicThemeAwareToggle(
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
