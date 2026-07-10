import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/web_multi_instance_guard_state.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";

/// Full-screen overlay shown on a browser tab that [WebMultiInstanceGuardState]
/// has revoked because a newer UyDosh tab was opened for this origin. Blocks
/// the entire app subtree until the user taps "use this tab", which reclaims
/// activity here and revokes the other tab instead.
class WebMultiInstanceLockScreen extends StatelessWidget {
  const WebMultiInstanceLockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.tab_unselected_rounded,
                  size: 56,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(height: 20),
                Text(
                  L10n.get("web_multi_instance_lock_title"),
                  style: theme.textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  L10n.get("web_multi_instance_lock_subtitle"),
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                PrimaryButtonFactory.text(
                  onPressed: () => WebMultiInstanceGuardState().reclaim(),
                  text: L10n.get("web_multi_instance_lock_use_here_button"),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
