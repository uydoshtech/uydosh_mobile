import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_pill_button.dart";

/// Result returned by [PermissionRationaleScreen] via [Navigator.pop]:
///   - [allow]    → user tapped the primary CTA (OS permission may already
///                  have been requested via [PermissionRationaleScreen.onBeforePopAllow]).
///   - [skip]     → user dismissed the screen ("Not now" / back gesture).
///   - [openSettings] → user tapped "Open Settings" (only used by the
///                  "permanently denied" variant of the screen).
enum PermissionRationaleResult { allow, skip, openSettings }

/// Generic full-screen rationale used to "warm up" iOS / Android permission
/// prompts. We surface this **before** calling into `permission_handler` /
/// `FirebaseMessaging.requestPermission` so the user understands why we
/// need the permission and grants it at a higher rate. iOS only ever
/// surfaces its system prompt **once**, so a cold prompt that gets denied
/// is effectively unrecoverable without a Settings deep-link — this screen
/// avoids that trap.
///
/// This is a layout-only widget: callers (see `CameraPermissionGate`,
/// `NotificationPermissionGate`) own the flow that decides which copy to
/// show and what to do with the result.
class PermissionRationaleScreen extends StatelessWidget {
  const PermissionRationaleScreen({
    required this.icon,
    required this.title,
    required this.body,
    required this.primaryLabel,
    super.key,
    this.secondaryLabel,
    this.tertiaryLabel,
    this.onTertiary,
    this.onBeforePopAllow,
  });

  /// Icon shown above the title (e.g. [Icons.camera_alt],
  /// [Icons.notifications_active]).
  final IconData icon;
  final String title;
  final String body;

  /// Text on the primary pill ("Turn on notifications" / "Allow camera access"
  /// / "Open Settings" depending on context).
  final String primaryLabel;

  /// Text on the secondary "Not now" / "Skip" button. When `null`, no
  /// secondary button is shown.
  final String? secondaryLabel;

  /// Optional third action (e.g. "Use gallery instead" on the
  /// camera-denied screen). Only rendered when [tertiaryLabel] is set.
  final String? tertiaryLabel;
  final VoidCallback? onTertiary;

  /// When non-null, runs before popping with [PermissionRationaleResult.allow].
  /// Keeps this route visible while awaiting the OS permission UI so the route
  /// underneath (e.g. onboarding) does not show through.
  final Future<void> Function()? onBeforePopAllow;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final colors = _RationaleColors.of(context);
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + mq.padding.bottom * 0),
          child: Column(
            children: [
              const Spacer(flex: 1),
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.foreground.withValues(alpha: 0.12),
                  border: Border.all(
                    color: colors.foreground.withValues(alpha: 0.18),
                  ),
                ),
                child: Icon(icon, color: colors.foreground, size: 44),
              ),
              const SizedBox(height: 28),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.foreground,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                body,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.foreground.withValues(alpha: 0.82),
                  fontSize: 15.5,
                  height: 1.45,
                ),
              ),
              const Spacer(flex: 2),
              _PermissionPrimaryButton(
                label: primaryLabel,
                colors: colors,
                onPressed: () async {
                  final hook = onBeforePopAllow;
                  if (hook != null) {
                    await hook();
                  }
                  if (!context.mounted) return;
                  Navigator.of(context)
                      .pop(PermissionRationaleResult.allow);
                },
              ),
              if (secondaryLabel != null) ...[
                const SizedBox(height: 14),
                _PermissionSecondaryButton(
                  label: secondaryLabel!,
                  colors: colors,
                  onPressed: () {
                    Navigator.of(context)
                        .pop(PermissionRationaleResult.skip);
                  },
                ),
              ],
              if (tertiaryLabel != null) ...[
                const SizedBox(height: 8),
                _PermissionTertiaryButton(
                  label: tertiaryLabel!,
                  colors: colors,
                  onPressed: () {
                    HapticFeedbackUtils.impact();
                    if (onTertiary != null) {
                      onTertiary!();
                    } else {
                      Navigator.of(context)
                          .pop(PermissionRationaleResult.skip);
                    }
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Theme-aware palette for [PermissionRationaleScreen]. The blue theme keeps
/// its original dark-blue-with-white-text look; the light theme swaps to a
/// white backdrop with dark text/buttons so the screen doesn't render as
/// near-invisible white-on-white.
class _RationaleColors {
  const _RationaleColors({
    required this.background,
    required this.foreground,
    required this.primaryButtonBackground,
    required this.primaryButtonForeground,
    required this.secondaryButtonBackground,
    required this.secondaryButtonForeground,
  });

  factory _RationaleColors.of(BuildContext context) {
    if (ThemeState().isLightTheme) {
      return const _RationaleColors(
        background: LightThemeColors.onboardingBackground,
        foreground: LightThemeColors.onboardingText,
        primaryButtonBackground: LightThemeColors.buttonPrimary,
        primaryButtonForeground: Colors.white,
        secondaryButtonBackground: LightThemeColors.surface,
        secondaryButtonForeground: LightThemeColors.primary,
      );
    }
    if (ThemeState().isBlueTheme) {
      return const _RationaleColors(
        background: BlueThemeColors.primary,
        foreground: Colors.white,
        primaryButtonBackground: BlueThemeColors.primaryLight,
        primaryButtonForeground: Colors.white,
        secondaryButtonBackground: Colors.white,
        secondaryButtonForeground: BlueThemeColors.primary,
      );
    }
    return const _RationaleColors(
      background: AppColors.primary,
      foreground: Colors.white,
      primaryButtonBackground: AppColors.primaryLight,
      primaryButtonForeground: Colors.white,
      secondaryButtonBackground: Colors.white,
      secondaryButtonForeground: AppColors.primary,
    );
  }

  final Color background;
  final Color foreground;
  final Color primaryButtonBackground;
  final Color primaryButtonForeground;
  final Color secondaryButtonBackground;
  final Color secondaryButtonForeground;
}

/// Primary CTA on the rationale screen ("Turn on notifications" / "Allow
/// camera access"). Lighter brand-blue neumorphic pill so it reads as the
/// main action against the darker [BlueThemeColors.primary] backdrop.
class _PermissionPrimaryButton extends StatelessWidget {
  const _PermissionPrimaryButton({
    required this.label,
    required this.colors,
    required this.onPressed,
  });

  final String label;
  final _RationaleColors colors;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ThreeDPillButton(
        onPressed: onPressed,
        backgroundColor: colors.primaryButtonBackground,
        neumorphicSoftUi: true,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 22),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.primaryButtonForeground,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Secondary "Not now" / "Skip" pill. White neumorphic face with brand-blue
/// label text — visually lighter than the primary action above it.
class _PermissionSecondaryButton extends StatelessWidget {
  const _PermissionSecondaryButton({
    required this.label,
    required this.colors,
    required this.onPressed,
  });

  final String label;
  final _RationaleColors colors;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ThreeDPillButton(
        onPressed: onPressed,
        backgroundColor: colors.secondaryButtonBackground,
        neumorphicSoftUi: true,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 22),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: colors.secondaryButtonForeground,
              fontSize: 15.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}

class _PermissionTertiaryButton extends StatelessWidget {
  const _PermissionTertiaryButton({
    required this.label,
    required this.colors,
    required this.onPressed,
  });

  final String label;
  final _RationaleColors colors;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.foreground.withValues(alpha: 0.78),
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
          decorationColor: colors.foreground.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
