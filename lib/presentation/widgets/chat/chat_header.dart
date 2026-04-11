import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/presentation/widgets/common/action_dropdown_menu.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_elevated_surface.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";

class ChatHeader extends StatelessWidget implements PreferredSizeWidget {

  const ChatHeader({
    required this.headerTitle,
    required this.onRefresh,
    required this.actionMenuItems,
    super.key,
  });
  final String headerTitle;
  final VoidCallback onRefresh;
  final List<ActionMenuItem> actionMenuItems;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, child) {
        final themeState = ThemeState();
        final appBarBackgroundColor = themeState.appBarBackgroundColor;
        final textColor = themeState.textColor;

        return UydoshAppBar(
          title: Row(
            children: [
              Expanded(
                child: Text(
                  headerTitle,
                  style: TextStyle(color: textColor),
                ),
              ),
            ],
          ),
          backgroundColor: appBarBackgroundColor,
          foregroundColor: textColor,
          actions: [
            Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: Center(
                child: ThreeDElevatedSurface(
                  baseColor: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(999),
                  child: Tooltip(
                    message: L10n.get("refresh"),
                    child: InkWell(
                      onTap: onRefresh,
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(6),
                        child: ThemeIcon(
                          Icons.refresh,
                          color: textColor,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: ActionDropdownMenu(
                items: actionMenuItems,
                icon: Icons.more_vert,
                iconColor: textColor,
                tooltip: L10n.get("actions"),
              ),
            ),
          ],
        );
      },
    );
  }

}
