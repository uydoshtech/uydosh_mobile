import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart" show AppColors;
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/active_search_alerts_state.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/profile_completion_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/presentation/screens/messages/messages_inbox_screen.dart";
import "package:uy_dosh/presentation/widgets/common/app_bar_profile_icon.dart";
import "package:uy_dosh/presentation/widgets/common/blinking_dot_widget.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_app_bar_flexible_space.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";

/// Messages inbox opened on top of [MainNavigation], using the same app bar
/// styling as the main shell so the "Сообщения" header matches the standard
/// liquid-glass bar on the home tab. The only difference vs. the bottom-nav
/// variant is a back leading (pushed route has no drawer to open).
class PushedMessagesInboxScaffold extends StatelessWidget {
  const PushedMessagesInboxScaffold({super.key});

  Widget _threeDAppBarIconButton({
    required IconData iconData,
    required VoidCallback onPressed,
    required String semanticsLabel,
    double iconSize = 26,
    BorderRadius? borderRadius,
    Widget? iconWidget,
    EdgeInsets padding = const EdgeInsets.all(6),
    double contentSlotSize = 28,
  }) {
    return ThreeDAppBarIconButton(
      iconData: iconData,
      onPressed: onPressed,
      semanticsLabel: semanticsLabel,
      iconSize: iconSize,
      borderRadius: borderRadius,
      iconWidget: iconWidget,
      padding: padding,
      contentSlotSize: contentSlotSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, _) {
        final themeState = ThemeState();
        final useLiquidGlassAppBar =
            themeState.isBlueTheme || themeState.isLightTheme;
        final appBarTheme = Theme.of(context).appBarTheme;
        return Scaffold(
          backgroundColor: themeState.backgroundColor,
          extendBodyBehindAppBar: useLiquidGlassAppBar,
          appBar: UydoshAppBar(
            backgroundColor:
                useLiquidGlassAppBar
                    ? liquidGlassAppBarMaterialColor(context)
                    : appBarTheme.backgroundColor,
            surfaceTintColor:
                useLiquidGlassAppBar
                    ? Colors.transparent
                    : appBarTheme.surfaceTintColor,
            elevation: useLiquidGlassAppBar ? 0 : null,
            scrolledUnderElevation: useLiquidGlassAppBar ? 0 : null,
            shadowColor:
                useLiquidGlassAppBar
                    ? Colors.transparent
                    : appBarTheme.shadowColor,
            forceMaterialTransparency: useLiquidGlassAppBar,
            flexibleSpace:
                useLiquidGlassAppBar
                    ? const LiquidGlassAppBarFlexibleSpace()
                    : null,
            foregroundColor: appBarTheme.foregroundColor,
            automaticallyImplyLeading: false,
            centerTitle: true,
            title: _getAppBarTitle(context),
            leading: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Align(
                alignment: Alignment.center,
                child: ThreeDAppBarIconButton.backLeading(context),
              ),
            ),
            actions: [
              ListenableBuilder(
                listenable: Listenable.merge([
                  AuthenticationState(),
                  ActiveSearchAlertsState(),
                ]),
                builder: (context, _) {
                  final signedIn = AuthenticationState().isAuthenticated;
                  if (!signedIn) return const SizedBox.shrink();

                  final activeAlerts =
                      ActiveSearchAlertsState().hasActiveEnabledAlerts;

                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _threeDAppBarIconButton(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(999)),
                      iconData: activeAlerts
                          ? Icons.notifications
                          : Icons.notifications_none_outlined,
                      onPressed: () {
                        context.pushNotifications();
                      },
                      semanticsLabel: activeAlerts
                          ? "${L10n.get("menu_notifications")}, ${L10n.get("notifications_appbar_semantics_active_alerts")}"
                          : L10n.get("menu_notifications"),
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: ListenableBuilder(
                  listenable: AuthenticationState(),
                  builder: (context, child) {
                    final isAuthenticated =
                        AuthenticationState().isAuthenticated;

                    if (!isAuthenticated) {
                      return _threeDAppBarIconButton(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(999)),
                        iconData: Icons.person_outline,
                        onPressed: () => context.pushReplaceAuthWizard(),
                        semanticsLabel: L10n.get("profile"),
                        iconSize: 28,
                      );
                    }

                    return ListenableBuilder(
                      listenable: Listenable.merge([
                        ThemeState(),
                        ProfileCompletionState(),
                      ]),
                      builder: (context, child) {
                        final needsCompletion =
                            ProfileCompletionState().needsProfileCompletion;
                        final hasAvatar =
                            resolveAvatarUrl(
                              ProfileCompletionState().cachedAvatarUrl,
                            ) !=
                            null;

                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _threeDAppBarIconButton(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(999),
                              ),
                              iconData: Icons.person_outline,
                              onPressed: () => context.pushProfile(),
                              semanticsLabel: L10n.get("profile"),
                              iconSize: 28,
                              padding:
                                  hasAvatar
                                      ? EdgeInsets.zero
                                      : const EdgeInsets.all(6),
                              contentSlotSize: hasAvatar ? 40 : 28,
                              iconWidget: AppBarProfileIcon(
                                iconSize: hasAvatar ? 40 : 28,
                                iconColor:
                                    ThemeState().isBlueTheme
                                        ? Colors.white
                                        : Colors.black,
                              ),
                            ),
                            if (needsCompletion)
                              Positioned(
                                right: -2,
                                bottom: -2,
                                child: BlinkingDotWidget(
                                  color: AppColors.success,
                                  size: 12,
                                  duration:
                                      const Duration(milliseconds: 750),
                                  borderColor:
                                      Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.grey.shade300,
                                  borderWidth: 2,
                                ),
                              ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          body: Stack(
            children: [
              // Content "behind" the liquid-glass header so the backdrop
              // filter has real texture to frost through (same as the home
              // tab does via listing cards). Without this layer, an empty
              // messages inbox leaves the header blurring a flat color —
              // which reads as a different glass effect vs. the home shell.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: MediaQuery.paddingOf(context).top +
                    kToolbarHeight +
                    24,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.lerp(
                                themeState.backgroundColor,
                                Colors.white,
                                themeState.isBlueTheme ? 0.06 : 0.10,
                              ) ??
                              themeState.backgroundColor,
                          themeState.backgroundColor,
                        ],
                      ),
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              ),
              const MessagesInboxScreen(showCustomHeader: false),
            ],
          ),
        );
      },
    );
  }

  Widget _getAppBarTitle(BuildContext context) {
    final titleStyle =
        Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ) ??
        TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        );
    return L10n.text("conversations", style: titleStyle);
  }
}
