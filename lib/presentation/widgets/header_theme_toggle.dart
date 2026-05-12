import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/ui_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// A compact theme toggle for the app header with sun/moon icons.
/// Matches the design: oval track with circular knob and theme icons.
class HeaderThemeToggle extends StatelessWidget {
  const HeaderThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        final isDark = themeState.isBlueTheme;

        // Colors based on current theme
        final trackColor = isDark
            ? const Color(0xFF1A1A1A)
            : const Color(0xFFE8E8E8);
        final knobColor = isDark ? Colors.white : const Color(0xFF424242);
        final iconColor = isDark ? Colors.white : const Color(0xFF424242);

        return GestureDetector(
          onTap: () async {
            UiFeedbackUtils.tap();
            await themeState.toggleTheme();
          },
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Tooltip(
              message: L10n.get("switch_theme"),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                width: 56,
                height: 28,
                decoration: BoxDecoration(
                  color: trackColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Icons: sun on left, moon on right
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ThemeIcon(
                            Icons.light_mode,
                            size: 16,
                            color: iconColor,
                          ),
                          ThemeIcon(
                            Icons.dark_mode,
                            size: 16,
                            color: iconColor,
                          ),
                        ],
                      ),
                    ),
                    // Animated knob
                    AnimatedAlign(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      alignment:
                          isDark ? Alignment.centerLeft : Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            color: knobColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
