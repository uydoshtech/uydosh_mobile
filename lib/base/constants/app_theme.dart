import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";

/// Theme manager for switching between different app themes
class AppTheme {
  static const String blueTheme = "blue";
  static const String lightTheme = "light";
  static const String messagingTheme = "messaging";

  /// Get the current theme data based on theme name
  static ThemeData getTheme(String themeName) {
    switch (themeName) {
      case blueTheme:
        return _getBlueTheme();
      case messagingTheme:
        return _getMessagingTheme();
      case lightTheme:
      default:
        return _getLightTheme();
    }
  }

  /// Get the display name for a theme
  static String getThemeDisplayName(String themeName) {
    switch (themeName) {
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

      // Cursor and text selection theme for better visibility in blue theme
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.white, // White cursor for better visibility on dark background
        selectionColor: Colors.white.withOpacity(
          0.3,
        ), // Semi-transparent white for selection
        selectionHandleColor: Colors.white, // White selection handles
      ),

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: BlueThemeColors.primary, // Blue background (original)
        foregroundColor: BlueThemeColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        surfaceTintColor:
            Colors.transparent, // Disable surface tint to prevent color changes
        scrolledUnderElevation: 0, // Prevent elevation changes on scroll
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
          side: BorderSide(color: BlueThemeColors.buttonPrimary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: BlueThemeColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: BlueThemeColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: BlueThemeColors.inputFocused, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: BlueThemeColors.inputError),
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: BlueThemeColors.navigationBackground,
        selectedItemColor: BlueThemeColors.navigationSelected,
        unselectedItemColor: BlueThemeColors.navigationUnselected,
        type: BottomNavigationBarType.fixed,
      ),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: BlueThemeColors.buttonPrimary,
        foregroundColor: BlueThemeColors.textPrimary,
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: BlueThemeColors.divider,
        thickness: 1,
      ),

      // Progress indicator theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Colors.white,
      ),

      // Icon theme
      iconTheme: IconThemeData(color: BlueThemeColors.iconPrimary, size: 24),

      // Popup menu theme - White background with blue text and icons
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.white, // White background
        textStyle: TextStyle(
          color: BlueThemeColors.primary, // Blue text
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 8,
      ),

      // Drawer theme
      drawerTheme: DrawerThemeData(
        backgroundColor: const Color(0xFF1A1A1A), // Dark almost black color
        surfaceTintColor: BlueThemeColors.primary,
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
      colorScheme: ColorScheme.fromSeed(
        seedColor: LightThemeColors.primary,
        primary:
            LightThemeColors
                .textPrimary, // Black for cursor color in light theme
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
      ),
      useMaterial3: true,

      // Cursor and text selection theme for better visibility in light theme
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.black, // Black cursor
        selectionColor: Colors.black.withOpacity(
          0.2,
        ), // Semi-transparent black for selection
        selectionHandleColor: Colors.black, // Black selection handles
      ),

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor:
            LightThemeColors
                .surface, // Light gray surface instead of hardcoded purple
        foregroundColor:
            LightThemeColors.textPrimary, // Black text on light background
        elevation: 1, // Slight elevation for light theme
        centerTitle: true,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color:
              LightThemeColors
                  .textPrimary, // Explicitly set title text to black
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: LightThemeColors.card,
        elevation:
            10, // Maximum elevation for the most prominent shadows in light theme
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        shadowColor:
            LightThemeColors
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
          side: BorderSide(color: LightThemeColors.buttonPrimary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: LightThemeColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: LightThemeColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: LightThemeColors.inputFocused,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: LightThemeColors.inputError),
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: LightThemeColors.navigationBackground,
        selectedItemColor: LightThemeColors.navigationSelected,
        unselectedItemColor: LightThemeColors.navigationUnselected,
        type: BottomNavigationBarType.fixed,
      ),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: LightThemeColors.buttonPrimary,
        foregroundColor: Colors.white,
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: LightThemeColors.divider,
        thickness: 1,
      ),

      // Icon theme
      iconTheme: IconThemeData(color: LightThemeColors.iconPrimary, size: 24),

      // Popup menu theme - White background with light theme primary text and icons
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.white, // White background
        textStyle: TextStyle(
          color: LightThemeColors.primary, // Light theme primary text
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 8,
      ),

      // Drawer theme
      drawerTheme: DrawerThemeData(
        backgroundColor: LightThemeColors.surface,
        surfaceTintColor: LightThemeColors.primary,
      ),

      // Text theme
      textTheme: TextTheme(
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

      // Cursor and text selection theme for better visibility
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: Colors.white, // White cursor for better visibility on dark background
        selectionColor: Colors.white.withValues(
          alpha: 0.3,
        ), // Semi-transparent white for selection
        selectionHandleColor: Colors.white, // White selection handles
      ),

      // AppBar theme
      appBarTheme: AppBarTheme(
        backgroundColor: MessagingThemeColors.appBarBackground,
        foregroundColor: MessagingThemeColors.appBarForeground,
        elevation: 0,
        centerTitle: true,
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
          side: BorderSide(color: MessagingThemeColors.buttonPrimary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MessagingThemeColors.inputBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: MessagingThemeColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: MessagingThemeColors.inputFocused,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: MessagingThemeColors.inputError),
        ),
      ),

      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: MessagingThemeColors.navigationSelected,
        unselectedItemColor: MessagingThemeColors.navigationUnselected,
        backgroundColor: MessagingThemeColors.background,
        type: BottomNavigationBarType.fixed,
      ),

      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: MessagingThemeColors.buttonPrimary,
        foregroundColor: MessagingThemeColors.buttonText,
      ),

      // Icon theme
      iconTheme: IconThemeData(
        color: MessagingThemeColors.iconPrimary,
        size: 24,
      ),

      // Popup menu theme - White background with messaging theme primary text and icons
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.white, // White background
        textStyle: TextStyle(
          color: MessagingThemeColors.primary, // Messaging theme primary text
          fontSize: 16,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 8,
      ),

      // Text theme
      textTheme: TextTheme(
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
