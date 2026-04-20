import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

enum ChatSafetyWarningSeverity { medium, high }

class ChatSafetyWarningRibbon extends StatefulWidget {
  const ChatSafetyWarningRibbon({
    required this.title,
    required this.body,
    this.severity = ChatSafetyWarningSeverity.medium,
    this.onClose,
    super.key,
  });

  final String title;
  final String body;
  final ChatSafetyWarningSeverity severity;
  final VoidCallback? onClose;

  @override
  State<ChatSafetyWarningRibbon> createState() =>
      _ChatSafetyWarningRibbonState();
}

class _ChatSafetyWarningRibbonState extends State<ChatSafetyWarningRibbon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _blinkController;
  late final Animation<double> _blinkOpacity;

  @override
  void initState() {
    super.initState();

    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _blinkOpacity = Tween<double>(begin: 1.0, end: 0.20).animate(
      CurvedAnimation(parent: _blinkController, curve: Curves.easeInOut),
    );

    _blinkController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final scheme = Theme.of(context).colorScheme;
        final disableAnimations = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
        final title = widget.title.trimRight();
        final titleWithBang =
            (title.endsWith("!") || title.endsWith("！")) ? title : "$title!";

        // Chat safety warnings: always show as a clear "yellow" ribbon.
        // High risk is indicated via icon/border tint, while keeping the ribbon yellow.
        final yellow = Colors.amber.shade700;
        final bg = Color.lerp(yellow, Colors.white, 0.82)!;

        final border =
            (widget.severity == ChatSafetyWarningSeverity.high
                    ? scheme.error
                    : yellow)
                .withValues(alpha: 0.30);

        final iconColor =
            widget.severity == ChatSafetyWarningSeverity.high
                ? scheme.error
                : Colors.black.withValues(alpha: 0.82);

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
                FadeTransition(
                  opacity: disableAnimations
                      ? const AlwaysStoppedAnimation(1.0)
                      : _blinkOpacity,
                  child: ThemeIcon(
                    CupertinoIcons.exclamationmark_circle_fill,
                    size: 23, // ~25% larger than 18
                    color: iconColor,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titleWithBang,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.black.withValues(alpha: 0.92),
                          height: 1.15,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.body,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.25,
                          color: Colors.black.withValues(alpha: 0.74),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                if (widget.onClose != null)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    icon: ThemeIcon(
                      Icons.close,
                      size: 18,
                      color: Colors.black.withValues(alpha: 0.78),
                    ),
                    onPressed: widget.onClose,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

