import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

/// Terms / EULA acceptance step shown before register or login (Guideline 1.2).
class AuthWizardTermsFinishPage extends StatelessWidget {
  const AuthWizardTermsFinishPage({
    required this.onOpenTermsOfService,
    required this.termsAccepted,
    required this.onTermsAcceptedChanged,
    super.key,
  });

  final VoidCallback onOpenTermsOfService;
  final bool termsAccepted;
  final ValueChanged<bool> onTermsAcceptedChanged;

  Color _textColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  Color _secondaryTextColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  @override
  Widget build(BuildContext context) {
    final isLightTheme = ThemeState().isLightTheme;
    final checkboxFillColor = isLightTheme
        ? WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) return Colors.black;
            return Colors.white;
          })
        : null;
    final checkboxSide =
        isLightTheme ? const BorderSide(color: Colors.black, width: 1.6) : null;

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
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: ThreeDSurfaceStyle.surfaceGradient(
                        context,
                        Theme.of(context).colorScheme.surface,
                      ),
                      boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
                    ),
                    child: ThemeIcon(
                      Icons.verified_user_outlined,
                      size: 40,
                      color: _textColor(context),
                    ),
                  ),
                  const SizedBox(height: 28),
                  L10n.text(
                    "auth_terms_finish_title",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _textColor(context),
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  L10n.text(
                    "auth_terms_finish_body",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _secondaryTextColor(context),
                      fontSize: 16,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 28),
                  GhostButtonFactory.iconTextCentered(
                    onPressed: onOpenTermsOfService,
                    icon: Icons.open_in_new,
                    text: L10n.get("view_terms_of_service"),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    isOnboardingButton: true,
                    neumorphicSoftUi: true,
                    iconSize: 20,
                  ),
                  const SizedBox(height: 24),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      HapticFeedbackUtils.selection();
                      onTermsAcceptedChanged(!termsAccepted);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Checkbox(
                            value: termsAccepted,
                            activeColor: isLightTheme
                                ? Colors.black
                                : AppColors.primary,
                            checkColor: isLightTheme ? Colors.white : null,
                            fillColor: checkboxFillColor,
                            side: checkboxSide,
                            onChanged: (value) {
                              HapticFeedbackUtils.selection();
                              onTermsAcceptedChanged(value ?? false);
                            },
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                L10n.get("auth_terms_accept_checkbox"),
                                style: TextStyle(
                                  color: _textColor(context),
                                  fontSize: 15,
                                  height: 1.35,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
