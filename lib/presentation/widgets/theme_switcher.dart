import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_theme.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/ui_feedback_utils.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";

/// Theme switcher widget for selecting app themes
class ThemeSwitcher extends StatefulWidget {
  const ThemeSwitcher({required this.child, super.key});

  final Widget child;

  @override
  State<ThemeSwitcher> createState() => _ThemeSwitcherState();
}

class _ThemeSwitcherState extends State<ThemeSwitcher> {
  final ThemeState _themeState = ThemeState();

  void _changeTheme(String themeName) {
    _themeState.changeTheme(themeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UydoshAppBar(
        leading: ThreeDAppBarIconButton.backLeading(context),
        title: Text(
          L10n.get("select_theme"),
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        backgroundColor:
            Theme.of(context).appBarTheme.backgroundColor ??
            Theme.of(context).colorScheme.primary,
        foregroundColor:
            Theme.of(context).appBarTheme.foregroundColor ?? Colors.white,
        actions: [
          ListenableBuilder(
            listenable: AnimationSettingsState(),
            builder: (context, _) {
              final enableMotion = AnimationSettingsState().uiAnimationsEnabled;
              final style =
                  enableMotion
                      ? null
                      : const AnimationStyle(
                          duration: Duration.zero,
                          reverseDuration: Duration.zero,
                        );

              return PopupMenuButton<String>(
                onOpened: UiFeedbackUtils.tap,
                onSelected: (themeName) {
                  UiFeedbackUtils.tap();
                  _changeTheme(themeName);
                },
                popUpAnimationStyle: style,
                itemBuilder:
                    (context) => [
                      PopupMenuItem(
                        value: AppTheme.lightTheme,
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              L10n.get("light_theme"),
                              style: Theme.of(context).popupMenuTheme.textStyle,
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: AppTheme.blueTheme,
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              L10n.get("blue_theme"),
                              style: Theme.of(context).popupMenuTheme.textStyle,
                            ),
                          ],
                        ),
                      ),
                    ],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const ThemeIcon(Icons.palette),
                      const SizedBox(width: 8),
                      ListenableBuilder(
                        listenable: _themeState,
                        builder: (context, child) {
                          return Text(_themeState.currentThemeDisplayName);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: widget.child,
    );
  }
}
