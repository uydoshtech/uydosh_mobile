import "package:flutter/material.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// Centered "no data" column used across empty list screens.
///
/// Layout (top to bottom):
///   [icon] – [SizedBox(16)] – [title] – optional [SizedBox(8)] + [subtitle] –
///   optional [SizedBox(24)] + [action]
///
/// Colors follow [ThemeState] via [ThemeHelper] so the state reacts to runtime
/// theme switches (light/blue) the same way messaging inbox screens do.
///
/// Set [fillViewportForRefresh] when this widget is the sole child of a
/// [RefreshIndicator]/pull-to-refresh scrollable: it wraps the column in a
/// [SingleChildScrollView] with [AlwaysScrollableScrollPhysics] and a viewport
/// sized box so the pull gesture works even when content doesn't overflow.
class UydoshEmptyColumn extends StatelessWidget {
  const UydoshEmptyColumn({
    required this.title,
    super.key,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.iconSize = 64,
    this.action,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.titleStyle,
    this.subtitleStyle,
    this.fillViewportForRefresh = false,
    this.viewportFillFraction = 0.7,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final double iconSize;
  final Widget? action;
  final EdgeInsetsGeometry padding;
  final TextStyle? titleStyle;
  final TextStyle? subtitleStyle;

  /// Wrap the column in a scrollable with a viewport-sized box so a parent
  /// pull-to-refresh gesture still works when the list is empty.
  final bool fillViewportForRefresh;

  /// Fraction of the screen height used for the viewport when
  /// [fillViewportForRefresh] is true. Defaults to 0.7 to keep the content
  /// roughly centered without forcing the user to scroll.
  final double viewportFillFraction;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, _) {
        final themeState = ThemeState();
        final column = Padding(
          padding: padding,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                ThemeIcon(
                  icon,
                  size: iconSize,
                  color: themeState.secondaryTextColor,
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: titleStyle ??
                      TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: themeState.textColor,
                      ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle!,
                    textAlign: TextAlign.center,
                    style: subtitleStyle ??
                        TextStyle(
                          fontSize: 16,
                          color: themeState.secondaryTextColor,
                        ),
                  ),
                ],
                if (action != null) ...[
                  const SizedBox(height: 24),
                  action!,
                ],
              ],
            ),
          ),
        );

        if (!fillViewportForRefresh) return column;

        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * viewportFillFraction,
            child: column,
          ),
        );
      },
    );
  }
}
