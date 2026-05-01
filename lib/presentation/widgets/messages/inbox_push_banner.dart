import "package:firebase_messaging/firebase_messaging.dart" show AuthorizationStatus;
import "package:flutter/material.dart";

import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

/// Warning banner shown at the top of the messages inbox when the OS push
/// permission is missing — gives the user a one-tap path to grant it so
/// chat pushes start working.
///
/// Layout mirrors the larger "Enable notifications" card on the
/// Notifications screen (title row on top, full-width action button below)
/// so the two surfaces feel like the same system speaking. The inbox
/// variant adds a trailing close affordance because, unlike the settings
/// screen, this banner is opt-out via dismiss-with-cooldown.
///
/// Pure presentational. The host screen owns the visibility logic
/// (status load, dismiss cooldown, lifecycle) and supplies callbacks.
class InboxPushBanner extends StatelessWidget {
  const InboxPushBanner({
    required this.status,
    required this.busy,
    required this.onPressed,
    required this.onDismiss,
    super.key,
  });

  /// Either [AuthorizationStatus.denied] (→ "Open settings") or
  /// [AuthorizationStatus.notDetermined] (→ "Enable notifications"). Other
  /// values should never reach here — the host gates them out.
  final AuthorizationStatus status;

  /// `true` while a permission request / settings hop is in flight; disables
  /// the action button and replaces its leading icon with a spinner.
  final bool busy;

  /// Tapped the primary action — host should call
  /// `IPushNotificationService.requestPermissionAndRegister()` (when
  /// `notDetermined`) or `openAppSettings()` (when `denied`), then refresh
  /// status.
  final VoidCallback onPressed;

  /// Tapped the trailing close affordance — host should record the dismiss
  /// timestamp (cooldown) and hide the banner.
  final VoidCallback onDismiss;

  bool get _isDenied => status == AuthorizationStatus.denied;

  @override
  Widget build(BuildContext context) {
    // Same warning palette as `_pushEnableCard` on the Notifications screen,
    // so the two surfaces read as one system.
    final cardBg = AppColors.warning;
    const fg = Color(0xFF1F1300);
    final buttonBorderColor = Colors.black.withValues(alpha: 0.85);
    final buttonBg = Colors.white.withValues(alpha: 0.18);

    return Semantics(
      container: true,
      label: L10n.get("inbox_push_off_banner_title"),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: ThreeDSurfaceStyle.surfaceGradient(context, cardBg),
          boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
        ),
        child: Padding(
          // Slightly tighter than the full Notifications-screen card —
          // this is meant to be a hint at the top of a list, not a settings
          // tile.
          padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 1, right: 10),
                    child: Icon(
                      Icons.notifications_off_outlined,
                      size: 20,
                      color: fg,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      L10n.get("inbox_push_off_banner_title"),
                      style: const TextStyle(
                        color: fg,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        height: 1.25,
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                  Semantics(
                    button: true,
                    label:
                        MaterialLocalizations.of(context).closeButtonLabel,
                    child: IconButton(
                      iconSize: 18,
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints.tightFor(
                        width: 32,
                        height: 32,
                      ),
                      splashRadius: 18,
                      onPressed: busy ? null : onDismiss,
                      icon: const Icon(Icons.close, color: fg),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Right-pad the action row so it lines up with the title (which
              // ends ~6px short of the right edge thanks to the close button
              // padding).
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: buttonBg,
                      foregroundColor: fg,
                      side: BorderSide(color: buttonBorderColor, width: 1.5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.1,
                      ),
                    ),
                    onPressed: busy ? null : onPressed,
                    icon: busy
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(fg),
                            ),
                          )
                        : Icon(
                            _isDenied
                                ? Icons.settings_outlined
                                : Icons.notifications_outlined,
                            size: 18,
                          ),
                    label: Text(
                      _isDenied
                          ? L10n.get("notifications_open_settings")
                          : L10n.get("menu_enable_notifications"),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
