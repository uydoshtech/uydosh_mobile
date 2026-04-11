import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";

/// Toolbar height for [MainNavigation] and [CommonAppBar]. In-body headers that
/// mimic an app bar should use this so they match the home tab bar.
const double standardAppBarToolbarHeight = kToolbarHeight;

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppBar({
    required this.title, super.key,
    this.actions,
    this.leading,
    this.showBackButton = false,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.automaticallyImplyLeading = true,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final bool automaticallyImplyLeading;

  @override
  Widget build(BuildContext context) {
    final injectDefaultBack = showBackButton && leading == null;
    final effectiveLeading =
        leading ??
        (injectDefaultBack
            ? ThreeDAppBarIconButton.backLeading(context)
            : null);

    return UydoshAppBar(
      title:
          centerTitle
              ? Text(
                title,
                style:
                    Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ) ??
                    const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textLight,
                    ),
              )
              : Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    title,
                    style:
                        Theme.of(context).appBarTheme.titleTextStyle?.copyWith(
                          fontWeight: FontWeight.bold,
                        ) ??
                        const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textLight,
                        ),
                  ),
                ),
              ),
      backgroundColor:
          backgroundColor ?? Theme.of(context).appBarTheme.backgroundColor,
      foregroundColor:
          foregroundColor ??
          Theme.of(context).appBarTheme.foregroundColor ??
          AppColors.textLight,
      elevation: elevation ?? 0,
      automaticallyImplyLeading:
          automaticallyImplyLeading && showBackButton && !injectDefaultBack,
      leading: effectiveLeading,
      actions: actions,
      centerTitle: centerTitle,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(standardAppBarToolbarHeight);
}
