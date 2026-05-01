import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

/// Result returned by [PermissionRationaleScreen] via [Navigator.pop]:
///   - [allow]    → user tapped the primary CTA, caller should request the
///                  underlying OS permission.
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
                onPressed: () {
                  HapticFeedbackUtils.impact();
                  Navigator.of(context)
                      .pop(PermissionRationaleResult.allow);
                },
              ),
              if (secondaryLabel != null) ...[
                const SizedBox(height: 12),
                _PermissionSecondaryButton(
                  label: secondaryLabel!,
                  onPressed: () {
                    HapticFeedbackUtils.impact();
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

class _PermissionPrimaryButton extends StatefulWidget {
  const _PermissionPrimaryButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  State<_PermissionPrimaryButton> createState() =>
      _PermissionPrimaryButtonState();
}

class _PermissionPrimaryButtonState extends State<_PermissionPrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    // White face on the brand-blue backdrop — high contrast and a deliberate
    // departure from a tinted secondary so the "Allow" CTA is unambiguous.
    final shadows = _pressed
        ? ThreeDSurfaceStyle.pressedShadows(context)
        : ThreeDSurfaceStyle.elevatedShadows(context);
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: widget.onPressed,
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) => setState(() => _pressed = false),
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
          padding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            boxShadow: shadows,
          ),
          child: Text(
            widget.label,
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
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.35)),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
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
