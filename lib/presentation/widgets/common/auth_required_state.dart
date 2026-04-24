import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/logout_service.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// Standardized "log in required" column used when a screen can't load its
/// data because the user isn't authenticated (or the session has expired).
///
/// Shape: `lock_outline` icon → bold title → muted message → `GhostButton`
/// (icon + text) that triggers [onLogin].
///
/// Defaults are wired to localized copy:
///   * title   → `auth_required_title`
///   * message → `session_expired`
///   * button  → `menu_registration`
///
/// Provide overrides for screens that want context-specific copy (e.g.
/// "Please log in to view your favorites.").
///
/// For the common "log the current session out and send the user to the auth
/// wizard" flow, use [AuthRequiredState.logoutAndReauthenticate] as [onLogin].
class AuthRequiredState extends StatelessWidget {
  const AuthRequiredState({
    required this.onLogin,
    super.key,
    this.title,
    this.message,
    this.buttonLabel,
    this.icon = Icons.lock_outline,
    this.iconSize = 80,
    this.iconColor,
    this.textColor,
    this.titleColor,
    this.messageColor,
    this.titleFontSize = 20,
    this.titleFontWeight = FontWeight.bold,
    this.messageFontSize = 16,
    this.padding = const EdgeInsets.symmetric(horizontal: 32),
    this.spacingAfterIcon = 16,
    this.spacingAfterTitle = 8,
    this.spacingBeforeButton = 24,
  });

  final VoidCallback onLogin;
  final String? title;
  final String? message;
  final String? buttonLabel;
  final IconData icon;
  final double iconSize;
  final Color? iconColor;

  /// Fallback color applied to both the title and message when [titleColor]
  /// and/or [messageColor] aren't supplied.
  final Color? textColor;

  /// Overrides [textColor] for the title text only.
  final Color? titleColor;

  /// Overrides [textColor] for the message text only.
  final Color? messageColor;
  final double titleFontSize;
  final FontWeight titleFontWeight;
  final double messageFontSize;
  final EdgeInsetsGeometry padding;
  final double spacingAfterIcon;
  final double spacingAfterTitle;
  final double spacingBeforeButton;

  /// Default login action: perform a full logout (clearing stored session)
  /// and navigate to the auth wizard. Safe to pass directly as [onLogin].
  static VoidCallback logoutAndReauthenticate(BuildContext context) {
    return () async {
      await LogoutService().performLogout(context);
      if (!context.mounted) return;
      context.pushReplaceAuthWizard();
    };
  }

  Color _defaultIconColor() =>
      ThemeState().isBlueTheme ? AppColors.textLight : AppColors.textGrey400;

  Color _defaultTextColor() =>
      ThemeState().isBlueTheme ? AppColors.textLight : AppColors.textGrey400;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, _) {
        final effectiveIconColor = iconColor ?? _defaultIconColor();
        final fallbackTextColor = textColor ?? _defaultTextColor();
        final effectiveTitleColor = titleColor ?? fallbackTextColor;
        final effectiveMessageColor = messageColor ?? fallbackTextColor;
        final effectiveTitle = title ?? L10n.get("auth_required_title");
        final effectiveMessage = message ?? L10n.get("session_expired");
        final effectiveButtonLabel =
            buttonLabel ?? L10n.get("menu_registration");

        return Padding(
          padding: padding,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ThemeIcon(icon, size: iconSize, color: effectiveIconColor),
                SizedBox(height: spacingAfterIcon),
                Text(
                  effectiveTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: titleFontSize,
                    fontWeight: titleFontWeight,
                    color: effectiveTitleColor,
                  ),
                ),
                SizedBox(height: spacingAfterTitle),
                Text(
                  effectiveMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: messageFontSize,
                    color: effectiveMessageColor,
                  ),
                ),
                SizedBox(height: spacingBeforeButton),
                GhostButtonFactory.iconText(
                  onPressed: onLogin,
                  icon: Icons.login,
                  text: effectiveButtonLabel,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
