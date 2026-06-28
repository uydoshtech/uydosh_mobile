import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/utils/ui_performance_policy.dart";

/// Theme manager for switching between different app themes
class AppTheme {
  static const String systemTheme = "system";
  static const String blueTheme = "blue";
  static const String lightTheme = "light";
  static const String messagingTheme = "messaging";

  /// Global fallback fonts used when the default platform font lacks a glyph.
  ///
  /// Empty by design: en/ru/uz UI is covered by the system Roboto / SF font,
  /// and the OS already provides its own fallback chain for Arabic / CJK /
  /// symbol glyphs in user-generated content. Listing a single non-Latin
  /// font here forces its shaping rules onto mixed-script text (it broke
  /// description rendering on the listing detail screen in May 2026).
  static const List<String> fontFamilyFallback = <String>[];

  /// Shared alpha for popup menus and [DropdownButton] panels so content behind shows slightly.
  static const double menuOverlaySurfaceOpacity = 0.92;

  /// Light blue tinted surface for popup/dropdown panels (replaces pure white).
  static const Color menuOverlaySurfaceColor = Color(0xFFE8F1FB);

  /// Padding inside popup menus (Material default: 8 vertical).
  static const EdgeInsets popupMenuPadding =
      EdgeInsets.symmetric(vertical: 8.0);

  /// Elevation for [PopupMenuThemeData] and [DropdownButton] menus ([kElevationToShadow] includes 16).
  static const int menuPanelElevation = 16;

  /// Darker shadow under popup/dropdown panels (Material default is easy to miss on busy UIs).
  static const Color menuPanelShadowColor = Color(0x59000000);

  /// Get the current theme data based on theme name
  static ThemeData getTheme(String themeName) {
    switch (resolveTheme(themeName)) {
      case blueTheme:
        return _getBlueTheme();
      case messagingTheme:
        return _getMessagingTheme();
      case lightTheme:
      default:
        return _getLightTheme();
    }
  }

  /// Convert a stored preference into a concrete app theme.
  static String resolveTheme(String themeName) {
    if (themeName != systemTheme) {
      return normalizeThemeName(themeName);
    }

    final brightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    return brightness == Brightness.dark ? blueTheme : lightTheme;
  }

  /// Normalize legacy and unknown theme names.
  static String normalizeThemeName(String themeName) {
    switch (themeName) {
      case "purple":
        return blueTheme;
      case systemTheme:
      case blueTheme:
      case lightTheme:
      case messagingTheme:
        return themeName;
      default:
        return systemTheme;
    }
  }

  /// Get the display name for a theme
  static String getThemeDisplayName(String themeName) {
    switch (themeName) {
      case systemTheme:
        return "System Theme";
      case blueTheme:
        return "Blue Theme";
      case messagingTheme:
        return "Messaging Theme";
      case lightTheme:
      default:
        return "Light Theme";
    }
  }

  /// Blue theme (new)
  static ThemeData _getBlueTheme() {
    return ThemeData(
      fontFamilyFallback: fontFamilyFallback,
      colorScheme: ColorScheme.fromSeed(
        seedColor: BlueThemeColors.primary,
        primary: BlueThemeColors.primary,
        onPrimary: BlueThemeColors.textPrimary,
        secondary: BlueThemeColors.secondary,
        onSecondary: BlueThemeColors.textPrimary,
        tertiary: BlueThemeColors.success,
        onTertiary: BlueThemeColors.textPrimary,
        surface: BlueThemeColors.primary,
        onSurface: BlueThemeColors.textPrimary,
        surfaceVariant: BlueThemeColors.card,
        onSurfaceVariant: BlueThemeColors.textSecondary,
        background: BlueThemeColors.background,
        onBackground: BlueThemeColors.textPrimary,
        error: BlueThemeColors.error,
        onError: BlueThemeColors.textPrimary,
        outline: BlueThemeColors.cardBorder,
        outlineVariant: BlueThemeColors.divider,
        shadow: BlueThemeColors.cardShadow,
        scrim: BlueThemeColors.overlayBackground,
        brightness: Brightness.dark,
        inverseSurface: BlueThemeColors.cardBackground,
        onInverseSurface: BlueThemeColors.textPrimary,
      ),
      useMaterial3: true,
      pageTransitionsTheme: const UiPerformancePageTransitionsTheme(),

      // Cursor and text selection theme for better visibility in blue theme
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors
            .white, // White cursor for better visibility on dark background
        selectionColor: Colors.white.withOpacity(
          0.3,
        ), // Semi-transparent white for selection
        selectionHandleColor: Colors.white, // White selection handles
      ),

      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: BlueThemeColors.primary, // Blue background (original)
        foregroundColor: BlueThemeColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: kToolbarHeight,
        surfaceTintColor:
            Colors.transparent, // Disable surface tint to prevent color changes
        scrolledUnderElevation: 0, // Prevent elevation changes on scroll
        titleTextStyle: TextStyle(
          color: BlueThemeColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: BlueThemeColors.card,
        elevation: 4,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: BlueThemeColors.buttonPrimary,
          foregroundColor: BlueThemeColors.textPrimary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: BlueThemeColors.buttonPrimary,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: BlueThemeColors.buttonPrimary,
          side: const BorderSide(color: BlueThemeColors.buttonPrimary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BlueThemeColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: BlueThemeColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              const BorderSide(color: BlueThemeColors.inputFocused, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: BlueThemeColors.inputError),
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: BlueThemeColors.navigationBackground,
        selectedItemColor: BlueThemeColors.navigationSelected,
        unselectedItemColor: BlueThemeColors.navigationUnselected,
        type: BottomNavigationBarType.fixed,
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: BlueThemeColors.buttonPrimary,
        foregroundColor: BlueThemeColors.textPrimary,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: BlueThemeColors.divider,
        thickness: 1,
      ),

      // Switch: fromSeed + our ColorScheme makes the *on* state track/thumb both
      // read as white on this background (broken pill). Mirror the *off* look: dark
      // track, light outline, contrasting thumb; when on, use button primary track.
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return BlueThemeColors.textDisabled;
          }
          if (states.contains(WidgetState.selected)) {
            return BlueThemeColors.textPrimary;
          }
          return BlueThemeColors.textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return BlueThemeColors.divider;
          }
          if (states.contains(WidgetState.selected)) {
            return BlueThemeColors.buttonPrimary;
          }
          return BlueThemeColors.card;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return BlueThemeColors.divider;
          }
          return BlueThemeColors.textPrimary.withValues(alpha: 0.55);
        }),
        trackOutlineWidth: const WidgetStatePropertyAll<double>(1),
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Colors.white,
      ),

      // Icon theme
      iconTheme:
          const IconThemeData(color: BlueThemeColors.textPrimary, size: 24),
      primaryIconTheme: const IconThemeData(
        color: BlueThemeColors.textPrimary,
        size: 24,
      ),

      // Popup menu theme - Light blue tinted background with blue text and icons.
      // Material 3 [PopupMenuItem] uses [labelTextStyle], not [textStyle], for labels;
      // without this, labels use [ColorScheme.onSurface] (white here) on a light menu.
      popupMenuTheme: PopupMenuThemeData(
        color: menuOverlaySurfaceColor.withValues(
          alpha: menuOverlaySurfaceOpacity,
        ),
        textStyle: const TextStyle(
          color: BlueThemeColors.primary, // Blue text
          fontSize: 16,
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return TextStyle(
              color: BlueThemeColors.primary.withValues(alpha: 0.38),
              fontSize: 16,
            );
          }
          return const TextStyle(
            color: BlueThemeColors.primary,
            fontSize: 16,
          );
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: menuPanelElevation.toDouble(),
        shadowColor: menuPanelShadowColor,
        menuPadding: popupMenuPadding,
      ),

      // Drawer theme — match chat / card tiles (ThemePalette.cardColor)
      drawerTheme: DrawerThemeData(
        backgroundColor: BlueThemeColors.card,
        surfaceTintColor: Colors.transparent,
        scrimColor: Colors.black.withValues(alpha: 0.12),
      ),

      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: BlueThemeColors.textPrimary),
        displayMedium: TextStyle(color: BlueThemeColors.textPrimary),
        displaySmall: TextStyle(color: BlueThemeColors.textPrimary),
        headlineLarge: TextStyle(color: BlueThemeColors.textPrimary),
        headlineMedium: TextStyle(color: BlueThemeColors.textPrimary),
        headlineSmall: TextStyle(color: BlueThemeColors.textPrimary),
        titleLarge: TextStyle(color: BlueThemeColors.textPrimary),
        titleMedium: TextStyle(color: BlueThemeColors.textPrimary),
        titleSmall: TextStyle(color: BlueThemeColors.textPrimary),
        bodyLarge: TextStyle(color: BlueThemeColors.textPrimary),
        bodyMedium: TextStyle(color: BlueThemeColors.textPrimary),
        bodySmall: TextStyle(
          color: BlueThemeColors.textPrimary,
        ), // White instead of secondary
        labelLarge: TextStyle(color: BlueThemeColors.textPrimary),
        labelMedium: TextStyle(
          color: BlueThemeColors.textPrimary,
        ), // White instead of secondary
        labelSmall: TextStyle(
          color: BlueThemeColors.textPrimary,
        ), // White instead of hint
      ),
    );
  }

  /// Light theme (new)
  static ThemeData _getLightTheme() {
    return ThemeData(
      fontFamilyFallback: fontFamilyFallback,
      colorScheme: ColorScheme.fromSeed(
        seedColor: LightThemeColors.primary,
        primary: LightThemeColors.primary,
        onPrimary: Colors.white,
        secondary: LightThemeColors.secondary,
        onSecondary: Colors.white,
        tertiary: LightThemeColors.success,
        onTertiary: Colors.white,
        surface: LightThemeColors.surface, // Light gray surface for AppBar
        onSurface: LightThemeColors.textPrimary, // Black text on light surface
        surfaceVariant: LightThemeColors.card,
        onSurfaceVariant: LightThemeColors.textSecondary,
        background: LightThemeColors.background,
        onBackground: LightThemeColors.textPrimary,
        error: LightThemeColors.error,
        onError: Colors.white,
        outline: LightThemeColors.cardBorder,
        outlineVariant: LightThemeColors.divider,
        shadow: LightThemeColors.cardShadow,
        scrim: LightThemeColors.overlayBackground,
        brightness: Brightness.light,
        inverseSurface: LightThemeColors.cardBackground,
        onInverseSurface: LightThemeColors.textPrimary,
        // Override primaryContainer and surface containers to neutral (Material 3
        // fromSeed auto-generates pinkish tints - we want neutral instead)
        primaryContainer: LightThemeColors.card,
        onPrimaryContainer: LightThemeColors.textPrimary,
        surfaceContainerHighest: LightThemeColors.card,
        surfaceContainerHigh: LightThemeColors.card,
        surfaceContainer: LightThemeColors.surface,
        surfaceContainerLow: LightThemeColors.surface,
        surfaceContainerLowest: LightThemeColors.background,
      ),
      useMaterial3: true,
      pageTransitionsTheme: const UiPerformancePageTransitionsTheme(),

      // Cursor and text selection theme for better visibility in light theme
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: LightThemeColors.primary,
        selectionColor: LightThemeColors.primary.withValues(alpha: 0.2),
        selectionHandleColor: LightThemeColors.primary,
      ),

      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: LightThemeColors
            .surface, // Light gray surface instead of hardcoded purple
        foregroundColor:
            LightThemeColors.textPrimary, // Black text on light background
        elevation: 1, // Slight elevation for light theme
        centerTitle: true,
        toolbarHeight: kToolbarHeight,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: LightThemeColors
              .textPrimary, // Explicitly set title text to black
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: LightThemeColors.card,
        elevation:
            10, // Maximum elevation for the most prominent shadows in light theme
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadowColor: LightThemeColors
            .cardShadow, // Explicitly set shadow color for better control
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: LightThemeColors.buttonPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: LightThemeColors.buttonPrimary,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: LightThemeColors.buttonPrimary,
          side: const BorderSide(color: LightThemeColors.buttonPrimary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LightThemeColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: LightThemeColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: LightThemeColors.inputFocused,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: LightThemeColors.inputError),
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: LightThemeColors.navigationBackground,
        selectedItemColor: LightThemeColors.navigationSelected,
        unselectedItemColor: LightThemeColors.navigationUnselected,
        type: BottomNavigationBarType.fixed,
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: LightThemeColors.buttonPrimary,
        foregroundColor: Colors.white,
      ),

      // Divider theme
      dividerTheme: const DividerThemeData(
        color: LightThemeColors.divider,
        thickness: 1,
      ),

      // Icon theme
      iconTheme:
          const IconThemeData(color: LightThemeColors.iconPrimary, size: 24),

      // Popup menu theme - Light blue tinted background with light theme primary text and icons
      popupMenuTheme: PopupMenuThemeData(
        color: menuOverlaySurfaceColor.withValues(
          alpha: menuOverlaySurfaceOpacity,
        ),
        textStyle: const TextStyle(
          color: LightThemeColors.primary, // Light theme primary text
          fontSize: 16,
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return TextStyle(
              color: LightThemeColors.primary.withValues(alpha: 0.38),
              fontSize: 16,
            );
          }
          return const TextStyle(
            color: LightThemeColors.primary,
            fontSize: 16,
          );
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: menuPanelElevation.toDouble(),
        shadowColor: menuPanelShadowColor,
        menuPadding: popupMenuPadding,
      ),

      // Drawer theme
      drawerTheme: DrawerThemeData(
        backgroundColor: LightThemeColors.surface,
        surfaceTintColor: LightThemeColors.primary,
        scrimColor: Colors.black.withValues(alpha: 0.10),
      ),

      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: LightThemeColors.textPrimary),
        displayMedium: TextStyle(color: LightThemeColors.textPrimary),
        displaySmall: TextStyle(color: LightThemeColors.textPrimary),
        headlineLarge: TextStyle(color: LightThemeColors.textPrimary),
        headlineMedium: TextStyle(color: LightThemeColors.textPrimary),
        headlineSmall: TextStyle(color: LightThemeColors.textPrimary),
        titleLarge: TextStyle(color: LightThemeColors.textPrimary),
        titleMedium: TextStyle(color: LightThemeColors.textPrimary),
        titleSmall: TextStyle(color: LightThemeColors.textPrimary),
        bodyLarge: TextStyle(color: LightThemeColors.textPrimary),
        bodyMedium: TextStyle(color: LightThemeColors.textPrimary),
        bodySmall: TextStyle(color: LightThemeColors.textSecondary),
        labelLarge: TextStyle(color: LightThemeColors.textPrimary),
        labelMedium: TextStyle(color: LightThemeColors.textSecondary),
        labelSmall: TextStyle(color: LightThemeColors.textHint),
      ),
    );
  }

  /// Messaging theme - Dark blue background with white cards (based on the image)
  static ThemeData _getMessagingTheme() {
    return ThemeData(
      fontFamilyFallback: fontFamilyFallback,
      colorScheme: ColorScheme.fromSeed(
        seedColor: MessagingThemeColors.primary,
        primary: MessagingThemeColors.primary,
        onPrimary: Colors.white,
        secondary: MessagingThemeColors.secondary,
        onSecondary: Colors.white,
        tertiary: MessagingThemeColors.success,
        onTertiary: Colors.white,
        surface: MessagingThemeColors.background,
        onSurface: MessagingThemeColors.textPrimary,
        surfaceVariant: MessagingThemeColors.card,
        onSurfaceVariant: MessagingThemeColors.textOnCard,
        background: MessagingThemeColors.background,
        onBackground: MessagingThemeColors.textPrimary,
        error: MessagingThemeColors.error,
        onError: Colors.white,
        outline: MessagingThemeColors.cardBorder,
        outlineVariant: MessagingThemeColors.divider,
        shadow: MessagingThemeColors.cardShadow,
        scrim: MessagingThemeColors.background.withValues(alpha: 0.8),
        brightness: Brightness.dark,
        inverseSurface: MessagingThemeColors.card,
        onInverseSurface: MessagingThemeColors.textOnCard,
      ),
      useMaterial3: true,
      pageTransitionsTheme: const UiPerformancePageTransitionsTheme(),

      // Cursor and text selection theme for better visibility
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors
            .white, // White cursor for better visibility on dark background
        selectionColor: Colors.white.withValues(
          alpha: 0.3,
        ), // Semi-transparent white for selection
        selectionHandleColor: Colors.white, // White selection handles
      ),

      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: MessagingThemeColors.appBarBackground,
        foregroundColor: MessagingThemeColors.appBarForeground,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: kToolbarHeight,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),

      // Card theme - White cards on dark blue background
      cardTheme: CardThemeData(
        color: MessagingThemeColors.cardBackground,
        elevation: 4,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadowColor: MessagingThemeColors.cardShadow,
      ),

      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MessagingThemeColors.buttonPrimary,
          foregroundColor: MessagingThemeColors.buttonText,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: MessagingThemeColors.buttonPrimary,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: MessagingThemeColors.buttonPrimary,
          side: const BorderSide(color: MessagingThemeColors.buttonPrimary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MessagingThemeColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: MessagingThemeColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: MessagingThemeColors.inputFocused,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: MessagingThemeColors.inputError),
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        selectedItemColor: MessagingThemeColors.navigationSelected,
        unselectedItemColor: MessagingThemeColors.navigationUnselected,
        backgroundColor: MessagingThemeColors.background,
        type: BottomNavigationBarType.fixed,
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: MessagingThemeColors.buttonPrimary,
        foregroundColor: MessagingThemeColors.buttonText,
      ),

      // Icon theme
      iconTheme: const IconThemeData(
        color: MessagingThemeColors.iconPrimary,
        size: 24,
      ),

      // Popup menu theme - Light blue tinted background with messaging theme primary text and icons
      popupMenuTheme: PopupMenuThemeData(
        color: menuOverlaySurfaceColor.withValues(
          alpha: menuOverlaySurfaceOpacity,
        ),
        textStyle: const TextStyle(
          color: MessagingThemeColors.primary, // Messaging theme primary text
          fontSize: 16,
        ),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return TextStyle(
              color: MessagingThemeColors.primary.withValues(alpha: 0.38),
              fontSize: 16,
            );
          }
          return const TextStyle(
            color: MessagingThemeColors.primary,
            fontSize: 16,
          );
        }),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: menuPanelElevation.toDouble(),
        shadowColor: menuPanelShadowColor,
        menuPadding: popupMenuPadding,
      ),

      // Text theme
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: MessagingThemeColors.textPrimary),
        displayMedium: TextStyle(color: MessagingThemeColors.textPrimary),
        displaySmall: TextStyle(color: MessagingThemeColors.textPrimary),
        headlineLarge: TextStyle(color: MessagingThemeColors.textPrimary),
        headlineMedium: TextStyle(color: MessagingThemeColors.textPrimary),
        headlineSmall: TextStyle(color: MessagingThemeColors.textPrimary),
        titleLarge: TextStyle(color: MessagingThemeColors.textPrimary),
        titleMedium: TextStyle(color: MessagingThemeColors.textPrimary),
        titleSmall: TextStyle(color: MessagingThemeColors.textPrimary),
        bodyLarge: TextStyle(color: MessagingThemeColors.textPrimary),
        bodyMedium: TextStyle(color: MessagingThemeColors.textPrimary),
        bodySmall: TextStyle(color: MessagingThemeColors.textSecondary),
        labelLarge: TextStyle(color: MessagingThemeColors.textPrimary),
        labelMedium: TextStyle(color: MessagingThemeColors.textPrimary),
        labelSmall: TextStyle(color: MessagingThemeColors.textSecondary),
      ),

      // List tile theme
      listTileTheme: ListTileThemeData(
        textColor: MessagingThemeColors.textOnCard,
        iconColor: MessagingThemeColors.iconOnCard,
        tileColor: MessagingThemeColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
