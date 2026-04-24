import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

class ChatSecurityRibbon extends StatelessWidget {
  const ChatSecurityRibbon({required this.onClose, super.key});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final ts = ThemeState();
        final scheme = Theme.of(context).colorScheme;
        final bg = Color.lerp(scheme.primary, ts.cardColor, 0.86)!;
        final border = scheme.primary.withValues(alpha: 0.18);
        final titleColor = ts.textColor;
        final bodyColor = ts.secondaryTextColor;
        final shieldColor = ts.isBlueTheme ? Colors.white : scheme.primary;

        return Material(
          color: bg,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: border)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ThemeIcon(
                  Icons.shield,
                  size: 23, // 18 * 1.25 ≈ 23
                  color: shieldColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        L10n.get("chat_security_ribbon_title"),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: titleColor,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        L10n.get("chat_security_ribbon_body"),
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.25,
                          color: bodyColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.all(8),
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  icon: ThemeIcon(Icons.close, size: 18, color: ts.textColor),
                  onPressed: () {
                    HapticFeedbackUtils.impact();
                    onClose();
                  },
                  tooltip: L10n.get("close"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

