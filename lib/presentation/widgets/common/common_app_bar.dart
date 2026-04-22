import "dart:ui";

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
    this.liquidGlass = true,
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
  final bool liquidGlass;

  @override
  Widget build(BuildContext context) {
    final injectDefaultBack = showBackButton && leading == null;
    final effectiveLeading =
        leading ??
        (injectDefaultBack
            ? ThreeDAppBarIconButton.backLeading(context)
            : null);

    final theme = Theme.of(context);
    final appBarTheme = theme.appBarTheme;
    final defaultBg = backgroundColor ?? appBarTheme.backgroundColor;
    final resolvedBg =
        liquidGlass ? Colors.transparent : (defaultBg ?? Colors.transparent);

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
      backgroundColor: resolvedBg,
      foregroundColor:
          foregroundColor ??
          Theme.of(context).appBarTheme.foregroundColor ??
          AppColors.textLight,
      elevation: elevation ?? 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      forceMaterialTransparency: liquidGlass,
      flexibleSpace: liquidGlass ? const _LiquidGlassAppBarBackground() : null,
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

class _LiquidGlassAppBarBackground extends StatelessWidget {
  const _LiquidGlassAppBarBackground();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final base =
        theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface;
    // "Liquid glass": blur + translucent tint + subtle highlights/border.
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                base.withOpacity(0.28),
                base.withOpacity(0.12),
              ],
            ),
            border: Border(
              bottom: BorderSide(
                color: Colors.white.withOpacity(0.14),
                width: 1,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(0.10),
                  Colors.white.withOpacity(0.00),
                ],
              ),
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}
