import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/active_search_alerts_state.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/profile_completion_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/presentation/screens/messages/messages_inbox_screen.dart";
import "package:uy_dosh/presentation/widgets/common/blinking_dot_widget.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";

/// Messages inbox opened on top of [MainNavigation], using the same app bar and
/// body layout as the bottom-nav tab (no extra top [SafeArea] block and no
/// duplicate header divider).
class PushedMessagesInboxScaffold extends StatelessWidget {
  const PushedMessagesInboxScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UydoshAppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Align(
            alignment: Alignment.center,
            child: ThreeDAppBarIconButton.backLeading(context),
          ),
        ),
        title: L10n.text(
          "conversations",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: ListenableBuilder(
              listenable: Listenable.merge([
                AuthenticationState(),
                ActiveSearchAlertsState(),
              ]),
              builder: (context, _) {
                final signedIn = AuthenticationState().isAuthenticated;
                final activeAlerts =
                    signedIn && ActiveSearchAlertsState().hasActiveEnabledAlerts;
                return ThreeDAppBarIconButton(
                  borderRadius: const BorderRadius.all(Radius.circular(999)),
                  iconData: activeAlerts
                      ? Icons.notifications
                      : Icons.notifications_none_outlined,
                  onPressed: () {
                    if (!AuthenticationState().isAuthenticated) {
                      context.pushReplaceAuthWizard();
                      return;
                    }
                    context.pushNotifications();
                  },
                  semanticsLabel: activeAlerts
                      ? "${L10n.get("menu_notifications")}, ${L10n.get("notifications_appbar_semantics_active_alerts")}"
                      : L10n.get("menu_notifications"),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ListenableBuilder(
              listenable: AuthenticationState(),
              builder: (context, child) {
                final isAuthenticated = AuthenticationState().isAuthenticated;

                if (!isAuthenticated) {
                  return ThreeDAppBarIconButton(
                    borderRadius: const BorderRadius.all(Radius.circular(999)),
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

                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ThreeDAppBarIconButton(
                          borderRadius: const BorderRadius.all(
                            Radius.circular(999),
                          ),
                          iconData: Icons.person_outline,
                          onPressed: () => context.pushProfile(),
                          semanticsLabel: L10n.get("profile"),
                          iconSize: 28,
                        ),
                        if (needsCompletion)
                          Positioned(
                            right: 5,
                            top: 22,
                            child: BlinkingDotWidget(
                              color: AppColors.success,
                              size: 12,
                              duration: const Duration(milliseconds: 750),
                              borderColor:
                                  Theme.of(context).brightness == Brightness.dark
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
      body: const MessagesInboxScreen(showCustomHeader: false),
    );
  }
}
