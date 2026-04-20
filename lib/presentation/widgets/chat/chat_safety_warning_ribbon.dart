import "package:flutter/material.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

class ChatSafetyWarningRibbon extends StatelessWidget {
  const ChatSafetyWarningRibbon({
    required this.title,
    required this.body,
    this.onClose,
    super.key,
  });

  final String title;
  final String body;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final ts = ThemeState();
        final scheme = Theme.of(context).colorScheme;

        final bg = Color.lerp(Colors.orange.shade700, ts.cardColor, 0.88)!;
        final border = Colors.orange.withValues(alpha: 0.22);

        return Material(
          color: bg,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: border)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(top: 2),
                  child: ThemeIcon(
                    Icons.warning_amber_rounded,
                    size: 18,
                    color: ts.isBlueTheme ? Colors.white : scheme.onSurface,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: ts.textColor,
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        body,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.25,
                          color: ts.secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                if (onClose != null)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    icon: ThemeIcon(Icons.close, size: 18, color: ts.textColor),
                    onPressed: onClose,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

