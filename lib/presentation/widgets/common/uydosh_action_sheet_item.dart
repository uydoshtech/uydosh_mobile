import "package:flutter/material.dart";

/// A reusable action sheet / bottom sheet list tile with optional icon and title.
/// Used for modal action menus (e.g. admin complaint status).
class UydoshActionSheetItem extends StatelessWidget {
  const UydoshActionSheetItem({
    required this.title,
    super.key,
    this.icon,
    this.onTap,
  });

  final Widget title;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon != null ? Icon(icon) : null,
      title: title,
      onTap: onTap,
    );
  }
}
