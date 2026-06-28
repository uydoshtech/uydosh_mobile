import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/platform_device.dart";

/// Resolves the shared “screen canvas” fill from theme flags only (no [ThemeState]
/// singleton). [ThemeHelper.backgroundColor] and [ThemeHelper.appBarBackgroundColor]
/// both delegate here so scaffold and custom AppBars cannot drift to different
/// colors (e.g. a seam under the chat header).
@immutable
class ThemePalette {
  const ThemePalette({
    required this.isLightTheme,
    required this.isBlueTheme,
  });

  final bool isLightTheme;
  final bool isBlueTheme;

  /// One color for [Scaffold.backgroundColor] and app chrome that sits flush with it.
  Color get screenCanvasColor {
    if (isLightTheme) return LightThemeColors.surface;
    if (isBlueTheme) return BlueThemeColors.background;
    return LightThemeColors.surface;
  }
}

/// [AppBar.backgroundColor] for liquid-glass toolbars ([forceMaterialTransparency]).
///
/// With [MaterialType.transparency], Flutter does **not** paint this color as a
/// solid toolbar fill—the frosted look still comes from [AppBar.flexibleSpace]
/// (blur + tint) over the scrolling body. This value is still used to infer the
/// default status bar style from luminance.
///
/// [Colors.transparent] is treated as a dark surface (zero luminance), which
/// incorrectly selects light status icons on a light UI. On [Brightness.light],
/// pass an opaque light surface so the OS keeps its usual styling.
Color liquidGlassAppBarMaterialColor(BuildContext context) {
  final theme = Theme.of(context);
  if (theme.brightness == Brightness.dark) {
    return Colors.transparent;
  }
  return theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface;
}

/// Selected-state outline for compact preference chips (language/currency rows).
///
/// Dark themes use a near-white ring; light themes use [ColorScheme.primary] so
/// the stroke stays visible on pale chip surfaces (pure white would disappear).
Color preferenceSegmentSelectedBorderColor(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  if (scheme.brightness == Brightness.dark) {
    return Colors.white.withValues(alpha: 0.9);
  }
  return scheme.primary;
}

/// Outline color for circular user avatars.
///
/// Light surfaces get a black ring; dark surfaces get a white ring.
Color avatarCircleBorderColor(BuildContext context, {Color? background}) {
  if (background != null) return background;

  return Theme.of(context).brightness == Brightness.dark
      ? Colors.white
      : Colors.black;
}

/// Extension on [ThemeState] providing theme-aware color helpers.
/// Use these instead of duplicating _getThemeAware* logic across screens and widgets.
extension ThemeHelper on ThemeState {
  ThemePalette get _palette =>
      ThemePalette(isLightTheme: isLightTheme, isBlueTheme: isBlueTheme);

  /// Frosted-glass chrome (app bars, feed tiles, bottom-sheet plates).
  /// Blue/light themes on iOS/web; flat [ColorScheme.surface] cards on Android.
  bool get usesLiquidGlassChrome {
    if (isAndroidDevice) return false;
    return isBlueTheme || isLightTheme;
  }

  /// Screen/scaffold background color
  Color get backgroundColor => _palette.screenCanvasColor;

  /// AppBar background color
  Color get appBarBackgroundColor => _palette.screenCanvasColor;

  /// Primary text color
  Color get textColor {
    if (isLightTheme) return Colors.black;
    if (isBlueTheme) return BlueThemeColors.textPrimary;
    return Colors.black;
  }

  /// Primary/accent color
  Color get primaryColor {
    if (isLightTheme) return Colors.black;
    if (isBlueTheme) return BlueThemeColors.primary;
    return Colors.black;
  }

  /// Secondary/muted text color
  Color get secondaryTextColor {
    if (isLightTheme) return Colors.grey[600]!;
    if (isBlueTheme) return BlueThemeColors.textSecondary;
    return Colors.grey[600]!;
  }

  /// Primary button background color
  Color get buttonColor {
    if (isLightTheme) return Colors.black;
    if (isBlueTheme) return BlueThemeColors.buttonPrimary;
    return Colors.black;
  }

  /// Primary button text color
  Color get buttonTextColor {
    if (isLightTheme) return Colors.white;
    if (isBlueTheme) return Colors.white;
    return Colors.white;
  }

  /// Card background color
  Color get cardColor {
    if (isLightTheme) return LightThemeColors.messagesConversationTile;
    if (isBlueTheme) return BlueThemeColors.card;
    return Colors.white;
  }

  /// Card primary text color
  Color get cardTextColor {
    if (isLightTheme) return Colors.black;
    if (isBlueTheme) return BlueThemeColors.textPrimary;
    return Colors.black;
  }

  /// Card secondary/muted text color
  Color get cardSecondaryTextColor {
    if (isLightTheme) return Colors.grey[600]!;
    if (isBlueTheme) return BlueThemeColors.textSecondary;
    return Colors.grey[600]!;
  }

  /// Card icon color
  Color get cardIconColor {
    if (isLightTheme) return Colors.grey[600]!;
    if (isBlueTheme) return BlueThemeColors.iconPrimary;
    return Colors.grey[600]!;
  }

  /// Avatar background color
  Color get avatarColor {
    if (isLightTheme) return Colors.grey[300]!;
    if (isBlueTheme) return BlueThemeColors.primary;
    return Colors.grey[300]!;
  }

  /// Avatar icon color
  Color get avatarIconColor {
    if (isLightTheme) return Colors.black;
    if (isBlueTheme) return BlueThemeColors.textPrimary;
    return Colors.black;
  }

  /// Pill/chip background color (e.g. quick questions)
  Color get pillColor {
    if (isLightTheme) return Colors.black;
    if (isBlueTheme) return Colors.white.withValues(alpha: 0.2);
    return Colors.black;
  }

  /// Pill/chip text color
  Color get pillTextColor {
    if (isLightTheme) return Colors.white;
    if (isBlueTheme) return Colors.white;
    return Colors.white;
  }

  /// Border/divider color
  Color get borderColor {
    if (isLightTheme) return Colors.grey.withValues(alpha: 0.2);
    if (isBlueTheme) return BlueThemeColors.divider;
    return Colors.grey.withValues(alpha: 0.2);
  }

  /// Input field background color
  Color get inputBackgroundColor {
    if (isLightTheme) return Colors.white;
    if (isBlueTheme) return BlueThemeColors.inputBackground;
    return Colors.white;
  }

  /// Multiline chat composer fill — on blue theme matches listing
  /// [WheelPickerPlateContainer] (`ColorScheme.surface`), not [inputBackgroundColor].
  Color chatComposerFieldBackground(BuildContext context) {
    if (isBlueTheme) return Theme.of(context).colorScheme.surface;
    return inputBackgroundColor;
  }

  Color chatComposerFieldTextColor(BuildContext context) {
    if (isBlueTheme) return Theme.of(context).colorScheme.onSurface;
    final bg = chatComposerFieldBackground(context);
    final brightness = ThemeData.estimateBrightnessForColor(bg);
    return brightness == Brightness.dark ? Colors.white : Colors.black;
  }

  Color chatComposerFieldHintColor(BuildContext context) {
    if (isBlueTheme) {
      return Theme.of(
        context,
      ).colorScheme.onSurfaceVariant.withValues(alpha: 0.7);
    }
    return chatComposerFieldTextColor(context).withValues(alpha: 0.6);
  }

  /// Extra top inset for tab scroll views when the main shell uses a liquid-glass
  /// app bar ([Scaffold.extendBodyBehindAppBar]). Add to your normal top padding.
  double mainShellGlassExtraTopInset(BuildContext context) {
    // MainNavigation enables liquid-glass AppBar for both blue and light themes.
    // When enabled, body is rendered behind the AppBar, so lists must offset by
    // the device top padding to avoid content appearing under the header.
    if (!usesLiquidGlassChrome) return 0;
    // Only account for the status bar / notch. Screens add their own
    // content spacing; adding an additional constant here tended to create a
    // visible "dead strip" under the shell header on some devices.
    return MediaQuery.paddingOf(context).top;
  }

  /// Chat input bar background (container behind the field).
  ///
  /// Blue theme: mostly transparent so messages can show through when the bar
  /// is stacked over the list (peer chat). Controls keep their own fills.
  Color get chatInputBarBackgroundColor {
    if (isLightTheme) return Colors.white;
    if (isBlueTheme) {
      if (isAndroidDevice) return BlueThemeColors.background;
      return BlueThemeColors.background.withValues(alpha: 0.2);
    }
    return Colors.white;
  }

  /// Send button / primary action icon color
  Color get sendButtonColor {
    if (isLightTheme) return Colors.black;
    if (isBlueTheme) return Colors.white;
    return Colors.black;
  }

  /// Selected tab border color
  Color get selectedTabBorderColor {
    if (isLightTheme) return Colors.black;
    if (isBlueTheme) return Colors.white;
    return Colors.black;
  }

  /// Selected tab text color
  Color get selectedTabTextColor {
    if (isLightTheme) return Colors.white;
    if (isBlueTheme) return Colors.white;
    return Colors.white;
  }

  /// Unselected tab text color (on card background)
  Color get unselectedTabTextColor {
    if (isLightTheme) return Colors.black;
    if (isBlueTheme) return BlueThemeColors.textPrimary;
    return Colors.black;
  }

  /// Unread / "new messages" indicator color (badges, dots).
  ///
  /// Separate from generic "success" green so we can tune contrast for the
  /// dark blue theme without impacting success toasts, buttons, etc.
  Color get unreadIndicatorColor {
    if (isBlueTheme) return const Color(0xFF34D399); // emerald-400
    return AppColors.success;
  }

  /// Text color for unread indicator badges (numbers inside the green dot).
  Color get unreadIndicatorTextColor {
    // Dark "ink" reads better on bright emerald at tiny sizes.
    if (isBlueTheme) return const Color(0xFF0B1220);
    return Colors.white;
  }

  // --- Price badge specific (green/red status colors) ---

  /// Price badge active (green) color
  Color get priceBadgeActiveColor {
    if (isBlueTheme) return Colors.white;
    return AppColors.statusActive;
  }

  /// Price badge inactive (red) color
  Color get priceBadgeInactiveColor {
    if (isBlueTheme) return const Color(0xFF7A8A9A);
    return AppColors.statusInactive;
  }

  /// Price badge background color
  Color get priceBadgeBackgroundColor {
    if (isBlueTheme) return AppColors.statusActive;
    return Colors.white;
  }
}
