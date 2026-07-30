import "package:flutter/material.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_glass_dialog.dart";

class PublishConsentGate {
  PublishConsentGate._();

  static const String _acceptedKey = "publish_consent_rules_v1";

  static Future<bool> ensureAccepted(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_acceptedKey) ?? false) return true;
    if (!context.mounted) return false;

    final accepted = await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (_) => const _PublishConsentDialog(),
        ) ??
        false;

    if (accepted) {
      await prefs.setBool(_acceptedKey, true);
    }
    return accepted;
  }
}

class _PublishConsentDialog extends StatefulWidget {
  const _PublishConsentDialog();

  @override
  State<_PublishConsentDialog> createState() => _PublishConsentDialogState();
}

class _PublishConsentDialogState extends State<_PublishConsentDialog> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final isLightTheme = ThemeState().isLightTheme;
    final checkboxFillColor = isLightTheme
        ? WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.selected)) return Colors.black;
            return Colors.white;
          })
        : null;
    final checkboxSide =
        isLightTheme ? const BorderSide(color: Colors.black, width: 1.6) : null;

    return UydoshGlassDialog(
      fallbackBackgroundColor: ThemeState().cardColor,
      title: Text(
        L10n.get("publish_consent_title"),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: onSurface,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            L10n.get("publish_consent_body"),
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.78),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              HapticFeedbackUtils.selection();
              setState(() => _agreed = !_agreed);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _agreed,
                    activeColor: isLightTheme
                        ? Colors.black
                        : BlueThemeColors.primaryLight,
                    checkColor: isLightTheme ? Colors.white : null,
                    fillColor: checkboxFillColor,
                    side: checkboxSide,
                    onChanged: (value) {
                      HapticFeedbackUtils.selection();
                      setState(() => _agreed = value ?? false);
                    },
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        L10n.get("publish_consent_checkbox"),
                        style: TextStyle(
                          color: onSurface,
                          fontWeight: FontWeight.w600,
                          height: 1.25,
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
      actions: [
        TextButton(
          onPressed: () {
            HapticFeedbackUtils.impact();
            Navigator.of(context).pop(false);
          },
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: Text(L10n.get("cancel")),
        ),
        FilledButton(
          onPressed: _agreed
              ? () {
                  HapticFeedbackUtils.impact();
                  Navigator.of(context).pop(true);
                }
              : null,
          child: Text(L10n.get("publish_consent_continue")),
        ),
      ],
    );
  }
}
