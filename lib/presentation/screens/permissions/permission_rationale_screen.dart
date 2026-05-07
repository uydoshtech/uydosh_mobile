import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
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

  /// Text on the brand-blue primary pill ("Allow camera access" /
  /// "Open Settings" depending on context).
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
    return Scaffold(
      backgroundColor: BlueThemeColors.primary,
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
                  color: Colors.white.withValues(alpha: 0.12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                child: Icon(icon, color: Colors.white, size: 44),
              ),
              const SizedBox(height: 28),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
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
                  color: Colors.white.withValues(alpha: 0.82),
                  fontSize: 15.5,
                  height: 1.45,
                ),
              ),
              const Spacer(flex: 2),
              _PermissionPrimaryButton(
                label: primaryLabel,
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

/// Primary CTA on the rationale screen ("Allow camera access" / "Open
/// Settings"). White neumorphic pill — the dual-shadow soft-UI treatment
/// (`neumorphicSoftUi`) reads as a raised tablet on the brand-blue backdrop,
/// keeping it visually consistent with the onboarding wizard CTAs.
class _PermissionPrimaryButton extends StatelessWidget {
  const _PermissionPrimaryButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ThreeDPillButton(
        onPressed: onPressed,
        backgroundColor: Colors.white,
        neumorphicSoftUi: true,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 22),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: BlueThemeColors.primary,
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

/// Secondary "Not now" / "Skip" pill. Uses the lighter brand blue as its face
/// so the same neumorphic dual shadows give it a softly raised look against
/// the darker [BlueThemeColors.primary] page background, instead of the
/// previous flat outlined button.
class _PermissionSecondaryButton extends StatelessWidget {
  const _PermissionSecondaryButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ThreeDPillButton(
        onPressed: onPressed,
        backgroundColor: BlueThemeColors.primaryLight,
        neumorphicSoftUi: true,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 22),
        child: Center(
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
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
    required this.onPressed,
  });

  final String label;
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
          color: Colors.white.withValues(alpha: 0.78),
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,
          decorationColor: Colors.white.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
