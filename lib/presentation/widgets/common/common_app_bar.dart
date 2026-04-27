import "dart:ui";

import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
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
        liquidGlass
            ? liquidGlassAppBarMaterialColor(context)
            : (defaultBg ?? Colors.transparent);

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
      actionsPadding: const EdgeInsets.only(right: 8),
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
    final isLight = ThemeState().isLightTheme;
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final enableGlass =
        AnimationSettingsState().uiAnimationsEnabled && !disableAnimations;
    // "Liquid glass": blur + translucent tint + subtle highlights.
    // Light theme: weaker tint so content behind the bar stays visible through the blur.
    final blurSigma = enableGlass ? (isLight ? 22.0 : 18.0) : 0.0;
    final tintHigh = isLight ? 0.12 : 0.28;
    final tintLow = isLight ? 0.04 : 0.12;
    final sheenHigh = isLight ? 0.05 : 0.10;
    final shadowOpacity = isLight ? 0.06 : 0.10;

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                base.withValues(alpha: tintHigh),
                base.withValues(alpha: tintLow),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: shadowOpacity),
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
                  Colors.white.withValues(alpha: sheenHigh),
                  Colors.white.withValues(alpha: 0),
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
