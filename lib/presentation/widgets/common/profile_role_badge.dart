import "package:flutter/material.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

/// Material icon for a known profile role; `null` for unknown / unset roles.
IconData? profileRoleIcon(String? role) {
  return switch (role) {
    "admin" => Icons.shield,
    "moderator" => Icons.shield_outlined,
    "manager" => Icons.supervisor_account_outlined,
    "landlord" => Icons.home_work,
    "tenant" => Icons.key,
    "service_requester" => Icons.assignment_ind,
    "service_provider" => Icons.home_repair_service,
    _ => null,
  };
}

/// Compact circular role indicator for the profile header row.
class ProfileRoleIconBadge extends StatelessWidget {
  const ProfileRoleIconBadge({
    required this.role,
    required this.label,
    super.key,
  });

  final String? role;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final icon = profileRoleIcon(role);

    return Tooltip(
      message: label,
      child: Semantics(
        label: label,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.42),
            border: Border.all(
              color: scheme.outline.withValues(alpha: 0.28),
            ),
          ),
          alignment: Alignment.center,
          child: ThemeIcon(
            icon ?? Icons.badge_outlined,
            size: 18,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.88),
          ),
        ),
      ),
    );
  }
}

/// Neumorphic role capsule (e.g. profile header).
class ProfileRoleNeumorphicBadge extends StatelessWidget {
  const ProfileRoleNeumorphicBadge({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, _) {
        final theme = Theme.of(context);
        final scheme = theme.colorScheme;
        final bg = theme.cardTheme.color ?? scheme.surface;

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: ThreeDSurfaceStyle.surfaceGradient(context, bg),
            boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.25,
                letterSpacing: 0.15,
                color: scheme.onSurface,
              ),
            ),
          ),
        );
      },
    );
  }
}
