import "package:firebase_messaging/firebase_messaging.dart" show AuthorizationStatus;
import "package:flutter/material.dart";

import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
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
    // Warning-tinted "alert" tile, matching `_pushEnableCard` on the
    // Notifications screen and ToastTheme.showWarning.
    final cardBg = AppColors.warning;
    const fg = Color(0xFF1F1300);
    const buttonFg = Color(0xFF1F1300);
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
                  IgnorePointer(
                    ignoring: busy,
                    child: Opacity(
                      opacity: busy ? 0.35 : 1,
                      child: IconButton(
                        tooltip: MaterialLocalizations.of(context)
                            .closeButtonTooltip,
                        onPressed: onDismiss,
                        icon: const Icon(Icons.close, size: 18, color: fg),
                        padding: const EdgeInsets.all(4),
                        constraints: const BoxConstraints(
                          minWidth: 28,
                          minHeight: 28,
                        ),
                        splashRadius: 18,
                      ),
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
                  child: PrimaryButtonFactory.iconTextCentered(
                    onPressed: busy ? null : onPressed,
                    isLoading: busy,
                    surfaceGradientBase: buttonBg,
                    textColor: buttonFg,
                    borderRadius: BorderRadius.circular(12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.1,
                      height: 1.0,
                    ),
                    iconSize: 18,
                    icon:
                        _isDenied
                            ? Icons.settings_outlined
                            : Icons.notifications_outlined,
                    text:
                        _isDenied
                            ? L10n.get("notifications_open_settings")
                            : L10n.get("menu_enable_notifications"),
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
