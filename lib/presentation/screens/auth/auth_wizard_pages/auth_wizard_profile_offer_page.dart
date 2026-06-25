import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

class AuthWizardProfileOfferPage extends StatelessWidget {
  const AuthWizardProfileOfferPage({
    required this.onCompleteNow,
    required this.onDoLater,
    super.key,
  });

  final VoidCallback onCompleteNow;
  final VoidCallback onDoLater;

  Color _textColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  Color _secondaryTextColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
              fontSize: 17,
              height: 1.0,
            ) ??
        const TextStyle(
          fontSize: 17,
          height: 1.0,
          fontWeight: FontWeight.w500,
        );

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: ThreeDSurfaceStyle.surfaceGradient(
                        context,
                        Theme.of(context).colorScheme.surface,
                      ),
                      boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
                    ),
                    child: ThemeIcon(
                      Icons.person_add_alt_1_outlined,
                      size: 42,
                      color: _textColor(context),
                    ),
                  ),
                  const SizedBox(height: 28),
                  L10n.text(
                    "complete_profile_prompt_title",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _textColor(context),
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      height: 1.12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  L10n.text(
                    "profile_completion_hint",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _secondaryTextColor(context),
                      fontSize: 16,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  L10n.text(
                    "complete_profile_prompt_body",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _secondaryTextColor(context),
                      fontSize: 15,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 32),
                  PrimaryButtonFactory.textIconCentered(
                    onPressed: onCompleteNow,
                    text: L10n.get("complete_profile_prompt_cta"),
                    icon: Icons.chevron_right,
                    width: double.infinity,
                    borderRadius: BorderRadius.circular(20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    textStyle: labelStyle,
                  ),
                  const SizedBox(height: 14),
                  GhostButtonFactory.textIconCentered(
                    onPressed: onDoLater,
                    text: L10n.get("complete_profile_prompt_later"),
                    icon: Icons.close,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    textStyle: labelStyle,
                    isOnboardingButton: true,
                    neumorphicSoftUi: !ThemeState().isLightTheme,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
