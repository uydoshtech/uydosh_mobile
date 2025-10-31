import "package:flutter/material.dart";

/// Centralized color management for the app
/// All colors used throughout the app should be defined here
class AppColors {
  // Primary Colors
  static const Color primary = Color(
    0xFF673AB7,
  ); // Deep Purple (matches Colors.deepPurple)
  static const Color primaryLight = Color(0xFF9B6DFF);
  static const Color primaryDark = Color(0xFF4A148C);

  // Secondary Colors
  static const Color secondary = Color(0xFF2196F3); // Blue
  static const Color secondaryLight = Color(0xFF64B5F6);
  static const Color secondaryDark = Color(0xFF1976D2);

  // Success Colors
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);

  // Warning Colors
  static const Color warning = Color(0xFFFF9800); // Orange
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);

  // Error Colors
  static const Color error = Color(0xFFF44336); // Red
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFD32F2F);

  // Neutral Colors
  static const Color background = Color(0xFF121212); // Dark background
  static const Color surface = Color(0xFF1E1E1E); // Dark surface
  static const Color card = Color(0xFF2D2D2D); // Dark card
  static const Color divider = Color(0xFF424242);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF); // White text
  static const Color textSecondary = Color(0xFFB3B3B3); // Light gray text
  static const Color textHint = Color(0xFF757575); // Gray hint text
  static const Color textDisabled = Color(0xFF616161); // Disabled text

  // Input Colors
  static const Color inputBackground = Color(
    0xFFFFFFFF,
  ); // White input background
  static const Color inputBorder = Color(0xFFE0E0E0); // Light gray border
  static const Color inputFocused = Color(0xFF6B46C1); // Purple when focused
  static const Color inputError = Color(0xFFD32F2F); // Red for errors

  // Metro Line Colors
  static const Color metroLine1 = Color(0xFFE53E3E); // Red
  static const Color metroLine2 = Color(0xFF3182CE); // Blue
  static const Color metroLine3 = Color(0xFF38A169); // Green
  static const Color metroLine4 = Color(0xFFFF9800); // Orange

  // Metro line colors with alternative names for backward compatibility
  static const Color lineRed = metroLine1;
  static const Color lineBlue = metroLine2;
  static const Color lineGreen = metroLine3;
  static const Color lineOrange = metroLine4;

  // Icon Colors
  static const Color iconPrimary = Color(
    0xFF6B46C1,
  ); // Purple for primary icons
  static const Color iconSecondary = Color(
    0xFF2196F3,
  ); // Blue for secondary icons
  static const Color iconSuccess = Color(0xFF4CAF50); // Green for success icons
  static const Color iconWarning = Color(
    0xFFFF9800,
  ); // Orange for warning icons
  static const Color iconError = Color(0xFFF44336); // Red for error icons
  static const Color iconDisabled = Color(
    0xFF757575,
  ); // Gray for disabled icons

  // Button Colors
  static const Color buttonPrimary = Color(0xFF6B46C1); // Purple primary button
  static const Color buttonSecondary = Color(
    0xFF2196F3,
  ); // Blue secondary button
  static const Color buttonSuccess = Color(0xFF4CAF50); // Green success button
  static const Color buttonWarning = Color(0xFFFF9800); // Orange warning button
  static const Color buttonError = Color(0xFFF44336); // Red error button
  static const Color buttonDisabled = Color(0xFF757575); // Gray disabled button

  // Card Colors
  static const Color cardBackground = Color(
    0xFFFFFFFF,
  ); // White card background
  static const Color cardBorder = Color(0xFFE0E0E0); // Light gray card border
  static const Color cardShadow = Color(
    0x1A000000,
  ); // Black shadow with 10% opacity

  // List Item Colors
  static const Color listItemBackground = Color(
    0xFFFFFFFF,
  ); // White list item background
  static const Color listItemSelected = Color(
    0xFFF3E5F5,
  ); // Light purple for selected items
  static const Color listItemHover = Color(0xFFF5F5F5); // Light gray for hover

  // Navigation Colors
  static const Color navigationBackground = Color(
    0xFF1E1E1E,
  ); // Dark navigation background
  static const Color navigationSelected = Color(
    0xFF6B46C1,
  ); // Purple for selected nav item
  static const Color navigationUnselected = Color(
    0xFF757575,
  ); // Gray for unselected nav item

  // Loading Colors
  static const Color loadingBackground = Color(
    0x80000000,
  ); // Semi-transparent black
  static const Color loadingSpinner = Color(
    0xFF6B46C1,
  ); // Purple loading spinner

  // Overlay Colors
  static const Color overlayBackground = Color(
    0x80000000,
  ); // Semi-transparent black overlay
  static const Color modalBackground = Color(
    0xFFFFFFFF,
  ); // White modal background

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF6B46C1),
    Color(0xFF9B6DFF),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFF2196F3),
    Color(0xFF64B5F6),
  ];

  static const List<Color> successGradient = [
    Color(0xFF4CAF50),
    Color(0xFF81C784),
  ];

  static const List<Color> warningGradient = [
    Color(0xFFFF9800),
    Color(0xFFFFB74D),
  ];

  static const List<Color> errorGradient = [
    Color(0xFFF44336),
    Color(0xFFE57373),
  ];

  // Onboarding Colors - Specific colors for onboarding screen in purple theme
  static const Color onboardingPrimary = Color(
    0xFF9B6DFF,
  ); // Light purple for onboarding primary (matches original)
  static const Color onboardingSecondary = Color(
    0xFF9B6DFF,
  ); // Light purple for onboarding secondary (matches original)
  static const Color onboardingSurface = Color(
    0xFF4A148C,
  ); // Dark purple surface (matches original)
  static const Color onboardingBackground = Color(
    0xFF673AB7,
  ); // Purple background (matches original)
  static const Color onboardingCard = Color(
    0xFFFFFFFF,
  ); // White card (matches original)
  static const Color onboardingText = Color(
    0xFFFFFFFF,
  ); // White text (matches original)
  static const Color onboardingTextSecondary = Color(
    0xFFB3B3B3,
  ); // Light gray text (matches original)

  // Status colors
  static const Color statusActive = Color(0xFF4CAF50); // Green
  static const Color statusInactive = Color(0xFFF44336); // Red
  static const Color statusActiveLight = Color(0xFF81C784); // Light green
  static const Color statusInactiveLight = Color(0xFFE57373); // Light red

  // Favorite colors
  static const Color favoriteActive = Color(0xFFF44336); // Red
  static const Color favoriteInactive = Color(0xFF757575); // Grey

  // Gender colors
  static const Color genderMale = Color(0xFF2196F3); // Blue
  static const Color genderFemale = Color(0xFFE91E63); // Pink
  static const Color genderOther = Color(0xFF757575); // Grey

  // Text colors for different themes
  static const Color textLight = Color(0xFFFFFFFF); // White
  static const Color textDark = Color(0xFF000000); // Black
  static const Color textDark87 = Color(0xDD000000); // Black with 87% opacity
  static const Color textDark54 = Color(0x8A000000); // Black with 54% opacity
  static const Color textLight70 = Color(0xB3FFFFFF); // White with 70% opacity
  static const Color textLight24 = Color(0x3DFFFFFF); // White with 24% opacity
  static const Color textGrey = Color(0xFF757575); // Grey
  static const Color textGrey600 = Color(0xFF757575); // Grey 600
  static const Color textGrey500 = Color(0xFF9E9E9E); // Grey 500
  static const Color textGrey400 = Color(0xFFBDBDBD); // Grey 400

  /// Get theme-aware text color for proper contrast
  /// Returns white text for dark themes, black text for light themes
  static Color getThemeAwareTextColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? textLight : textDark;
  }

  /// Get theme-aware text color with opacity for proper contrast
  /// Returns white text with opacity for dark themes, black text with opacity for light themes
  static Color getThemeAwareTextColorWithOpacity(
    BuildContext context,
    double opacity,
  ) {
    final brightness = Theme.of(context).brightness;
    if (brightness == Brightness.dark) {
      return textLight.withValues(alpha: opacity);
    } else {
      return textDark.withValues(alpha: opacity);
    }
  }

  /// Get theme-aware loading indicator color for proper contrast
  /// Returns primary color for dark themes, dark color for light themes
  static Color getThemeAwareLoadingColor(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark ? primary : textDark;
  }

  // Background colors
  static const Color backgroundLight = Color(0xFFF5F5F5); // Light grey
  static const Color backgroundDark = Color(0xFF1A1A1A); // Dark almost black

  // Border colors
  static const Color borderGrey300 = Color(0xFFE0E0E0); // Grey 300
  static const Color borderGrey50 = Color(0xFFFAFAFA); // Grey 50
  static const Color borderGrey600 = Color(0xFF757575); // Grey 600

  // Overlay and transparency colors
  static const Color overlayLight = Color(0x1A000000); // Black with 10% opacity
  static const Color overlayMedium = Color(
    0x33000000,
  ); // Black with 20% opacity
  static const Color overlayHeavy = Color(0x80000000); // Black with 50% opacity

  // Navigation and UI element colors
  static const Color navigationUnselectedLight = Color(
    0xFFBDBDBD,
  ); // Light grey for unselected nav items

  /// Get metro line color by line number
  static Color getMetroLineColor(int line) {
    switch (line) {
      case 1:
        return metroLine1;
      case 2:
        return metroLine2;
      case 3:
        return metroLine3;
      case 4:
        return metroLine4;
      default:
        return textDisabled;
    }
  }

  /// Get metro line color with opacity
  static Color getMetroLineColorWithOpacity(int line, double opacity) {
    return getMetroLineColor(line).withValues(alpha: opacity);
  }

  /// Get metro line color for icons
  static Color getMetroLineIconColor(int line) {
    return getMetroLineColor(line);
  }

  /// Get metro line color for backgrounds
  static Color getMetroLineBackgroundColor(int line) {
    return getMetroLineColor(line).withValues(alpha: 0.1);
  }

  // Metro line colors for string-based line identifiers
  static Color getMetroLineColorFromString(String line) {
    switch (line.toLowerCase()) {
      case "1":
        return metroLine1;
      case "2":
        return metroLine2;
      case "3":
        return metroLine3;
      case "4":
        return metroLine4;
      default:
        return metroLine1; // Default to red
    }
  }

  static Color getMetroLineColorWithOpacityFromString(
    String line,
    double opacity,
  ) {
    return getMetroLineColorFromString(line).withValues(alpha: opacity);
  }

  static Color getMetroLineColorLightFromString(String line) {
    return getMetroLineColorFromString(line).withValues(alpha: 0.1);
  }

  /// Get theme-aware primary color based on current theme
  /// This method should be used instead of hardcoded AppColors.primary
  /// to ensure proper theme adaptation
  static Color getThemeAwarePrimary() {
    // Import ThemeState here to avoid circular dependency
    // For now, return the default primary color
    // Components should use Theme.of(context).colorScheme.primary instead
    return primary;
  }
}

/// Blue theme colors based on the image
class BlueThemeColors {
  // Primary Colors - Using darker blue for better contrast
  static const Color primary = Color(
    0xFF1E3A5F,
  ); // Darker blue for better contrast
  static const Color primaryLight = Color(0xFF3A7BBF);
  static const Color primaryDark = Color(0xFF142A45);

  // Secondary Colors - Using the lighter blue from the image
  static const Color secondary = Color(
    0xFF70C0C8,
  ); // Light teal from outer square
  static const Color secondaryLight = Color(0xFF8DD0D8);
  static const Color secondaryDark = Color(0xFF5AA0A8);

  // Success Colors
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);

  // Warning Colors
  static const Color warning = Color(0xFFFF9800); // Orange
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);

  // Error Colors
  static const Color error = Color(0xFFF44336); // Red
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFD32F2F);

  // Neutral Colors
  static const Color background = Color(0xFF1E3A5F); // Dark blue background
  static const Color surface = Color(0xFF142A45); // Darker blue surface
  static const Color card = Color(0xFF1A2A3A); // Dark blue card
  static const Color divider = Color(0xFF2A3A4A);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF); // White text
  static const Color textSecondary = Color(0xFFB3C0CC); // Light blue-gray text
  static const Color textHint = Color(0xFF7A8A9A); // Blue-gray hint text
  static const Color textDisabled = Color(0xFF5A6A7A); // Disabled text

  // Input Colors
  static const Color inputBackground = Color(
    0xFFFFFFFF,
  ); // White input background
  static const Color inputBorder = Color(0xFFE0E8F0); // Light blue-gray border
  static const Color inputFocused = Color(0xFF3A7BBF); // Blue when focused
  static const Color inputError = Color(0xFFD32F2F); // Red for errors

  // Metro Line Colors
  static const Color metroLine1 = Color(0xFFE53E3E); // Red
  static const Color metroLine2 = Color(0xFF3A7BBF); // Blue (using primary)
  static const Color metroLine3 = Color(0xFF38A169); // Green
  static const Color metroLine4 = Color(0xFFFF9800); // Orange

  // Icon Colors
  static const Color iconPrimary = Color(0xFF3A7BBF); // Blue for primary icons
  static const Color iconSecondary = Color(
    0xFF70C0C8,
  ); // Light teal for secondary icons
  static const Color iconSuccess = Color(0xFF4CAF50); // Green for success icons
  static const Color iconWarning = Color(
    0xFFFF9800,
  ); // Orange for warning icons
  static const Color iconError = Color(0xFFF44336); // Red for error icons
  static const Color iconDisabled = Color(
    0xFF7A8A9A,
  ); // Blue-gray for disabled icons

  // Button Colors
  static const Color buttonPrimary = Color(0xFF3A7BBF); // Blue primary button
  static const Color buttonSecondary = Color(
    0xFF70C0C8,
  ); // Light teal secondary button
  static const Color buttonSuccess = Color(0xFF4CAF50); // Green success button
  static const Color buttonWarning = Color(0xFFFF9800); // Orange warning button
  static const Color buttonError = Color(0xFFF44336); // Red error button
  static const Color buttonDisabled = Color(
    0xFF7A8A9A,
  ); // Blue-gray disabled button

  // Card Colors
  static const Color cardBackground = Color(
    0xFFFFFFFF,
  ); // White card background
  static const Color cardBorder = Color(
    0xFFE0E8F0,
  ); // Light blue-gray card border
  static const Color cardShadow = Color(
    0x1A000000,
  ); // Black shadow with 10% opacity

  // List Item Colors
  static const Color listItemBackground = Color(
    0xFFFFFFFF,
  ); // White list item background
  static const Color listItemSelected = Color(
    0xFFE8F4F8,
  ); // Light blue for selected items
  static const Color listItemHover = Color(0xFFF0F8FF); // Light blue for hover

  // Navigation Colors
  static const Color navigationBackground = Color(
    0xFF142A45,
  ); // Darker blue navigation background
  static const Color navigationSelected = Color(
    0xFF3A7BBF,
  ); // Blue for selected nav item
  static const Color navigationUnselected = Color(
    0xFF7A8A9A,
  ); // Blue-gray for unselected nav item

  // Loading Colors
  static const Color loadingBackground = Color(
    0x80000000,
  ); // Semi-transparent black
  static const Color loadingSpinner = Color(0xFF3A7BBF); // Blue loading spinner

  // Overlay Colors
  static const Color overlayBackground = Color(
    0x80000000,
  ); // Semi-transparent black overlay
  static const Color modalBackground = Color(
    0xFFFFFFFF,
  ); // White modal background

  // Gradient Colors
  static const List<Color> primaryGradient = [
    Color(0xFF3A7BBF),
    Color(0xFF5A9BD9),
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFF70C0C8),
    Color(0xFF8DD0D8),
  ];

  // Onboarding Colors - Specific colors for onboarding screen in blue theme
  static const Color onboardingPrimary = Color(
    0xFF1E3A5F,
  ); // Dark blue for onboarding primary
  static const Color onboardingSecondary = Color(
    0xFF3A7BBF,
  ); // Blue for onboarding secondary
  static const Color onboardingSurface = Color(
    0xFF142A45,
  ); // Darker blue surface
  static const Color onboardingBackground = Color(
    0xFF1E3A5F,
  ); // Dark blue background
  static const Color onboardingCard = Color(0xFF1A2A3A); // Dark blue card
  static const Color onboardingText = Color(0xFFFFFFFF); // White text
  static const Color onboardingTextSecondary = Color(
    0xFFB3C0CC,
  ); // Light blue-gray text

  static const List<Color> successGradient = [
    Color(0xFF4CAF50),
    Color(0xFF81C784),
  ];

  static const List<Color> warningGradient = [
    Color(0xFFFF9800),
    Color(0xFFFFB74D),
  ];

  static const List<Color> errorGradient = [
    Color(0xFFF44336),
    Color(0xFFE57373),
  ];

  /// Get metro line color by line number
  static Color getMetroLineColor(int line) {
    switch (line) {
      case 1:
        return metroLine1;
      case 2:
        return metroLine2;
      case 3:
        return metroLine3;
      case 4:
        return metroLine4;
      default:
        return textDisabled;
    }
  }

  /// Get metro line color with opacity
  static Color getMetroLineColorWithOpacity(int line, double opacity) {
    return getMetroLineColor(line).withValues(alpha: opacity);
  }

  /// Get metro line color for icons
  static Color getMetroLineIconColor(int line) {
    return getMetroLineColor(line);
  }

  /// Get metro line color for backgrounds
  static Color getMetroLineBackgroundColor(int line) {
    return getMetroLineColor(line).withValues(alpha: 0.1);
  }
}

/// Messaging theme colors - dark blue background with white cards (based on the image)
class MessagingThemeColors {
  // Primary Colors - Dark blue for messaging interface
  static const Color primary = Color(0xFF1E3A5F); // Dark blue background
  static const Color primaryLight = Color(0xFF3A7BBF);
  static const Color primaryDark = Color(0xFF142A45);

  // Secondary Colors - Light teal for accents
  static const Color secondary = Color(0xFF70C0C8); // Light teal
  static const Color secondaryLight = Color(0xFF8DD0D8);
  static const Color secondaryDark = Color(0xFF5AA0A8);

  // Success Colors
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);

  // Warning Colors
  static const Color warning = Color(0xFFFF9800); // Orange
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);

  // Error Colors
  static const Color error = Color(0xFFF44336); // Red
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFD32F2F);

  // Neutral Colors - Dark blue theme
  static const Color background = Color(0xFF1E3A5F); // Dark blue background
  static const Color surface = Color(0xFF142A45); // Darker blue surface
  static const Color card = Color(0xFFFFFFFF); // White card background
  static const Color cardBorder = Color(0xFFE0E8F0); // Light border for cards
  static const Color divider = Color(0xFF2A3A4A);

  // Text Colors
  static const Color textPrimary = Color(
    0xFFFFFFFF,
  ); // White text on dark background
  static const Color textSecondary = Color(0xFFB3C0CC); // Light blue-gray text
  static const Color textHint = Color(0xFF7A8A9A); // Blue-gray hint text
  static const Color textDisabled = Color(0xFF5A6A7A); // Disabled text
  static const Color textOnCard = Color(
    0xFF000000,
  ); // Black text on white cards
  static const Color textOnCardSecondary = Color(
    0xFF6C757D,
  ); // Gray text on white cards

  // Input Colors
  static const Color inputBackground = Color(
    0xFFFFFFFF,
  ); // White input background
  static const Color inputBorder = Color(0xFFE0E8F0); // Light blue-gray border
  static const Color inputFocused = Color(0xFF3A7BBF); // Blue when focused
  static const Color inputError = Color(0xFFD32F2F); // Red for errors

  // AppBar Colors
  static const Color appBarBackground = Color(0xFF1E3A5F); // Dark blue app bar
  static const Color appBarForeground = Color(
    0xFFFFFFFF,
  ); // White text on app bar

  // Button Colors
  static const Color buttonPrimary = Color(0xFF3A7BBF); // Blue primary button
  static const Color buttonSecondary = Color(
    0xFF70C0C8,
  ); // Teal secondary button
  static const Color buttonText = Color(0xFFFFFFFF); // White text on buttons

  // Icon Colors
  static const Color iconPrimary = Color(
    0xFFFFFFFF,
  ); // White icons on dark background
  static const Color iconOnCard = Color(
    0xFF000000,
  ); // Black icons on white cards
  static const Color iconSecondary = Color(0xFFB3C0CC); // Light blue-gray icons

  // Card Colors
  static const Color cardBackground = Color(
    0xFFFFFFFF,
  ); // White card background
  static const Color cardShadow = Color(
    0x1A000000,
  ); // Black shadow with 10% opacity
  static const Color cardElevation = Color(
    0x0D000000,
  ); // Black shadow with 5% opacity

  // Navigation Colors
  static const Color navigationSelected = Color(
    0xFF3A7BBF,
  ); // Blue for selected nav item
  static const Color navigationUnselected = Color(
    0xFF7A8A9A,
  ); // Gray for unselected nav item
}

/// Light theme colors - white backgrounds with black text
class LightThemeColors {
  // Primary Colors - Using black for light theme
  static const Color primary = Color(0xFF000000); // Pure black
  static const Color primaryLight = Color(0xFF333333); // Dark gray
  static const Color primaryDark = Color(0xFF000000); // Pure black

  // Secondary Colors - Using gray tones
  static const Color secondary = Color(0xFF666666); // Medium gray
  static const Color secondaryLight = Color(0xFF999999); // Light gray
  static const Color secondaryDark = Color(0xFF333333); // Dark gray

  // Success Colors - Same as main theme
  static const Color success = Color(0xFF4CAF50); // Green
  static const Color successLight = Color(0xFF81C784);
  static const Color successDark = Color(0xFF388E3C);

  // Warning Colors - Same as main theme
  static const Color warning = Color(0xFFFF9800); // Orange
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFF57C00);

  // Error Colors - Same as main theme
  static const Color error = Color(0xFFF44336); // Red
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFD32F2F);

  // Neutral Colors - Light theme with white backgrounds
  static const Color background = Color(0xFFFFFFFF); // Pure white background
  static const Color surface = Color(0xFFF8F9FA); // Very light gray surface
  static const Color card = Color(0xFFFFFFFF); // White card
  static const Color divider = Color(0xFFE9ECEF); // Very light gray divider

  // Text Colors - Black text for light theme
  static const Color textPrimary = Color(0xFF000000); // Black text
  static const Color textSecondary = Color(0xFF6C757D); // Medium gray text
  static const Color textHint = Color(0xFFADB5BD); // Light gray hint text
  static const Color textDisabled = Color(
    0xFFCED4DA,
  ); // Very light gray disabled text

  // Input Colors - Light theme inputs with black focus
  static const Color inputBackground = Color(
    0xFFFFFFFF,
  ); // White input background
  static const Color inputBorder = Color(0xFFE9ECEF); // Very light gray border
  static const Color inputFocused = Color(0xFF000000); // Black when focused
  static const Color inputError = Color(
    0xFFD32F2F,
  ); // Red for errors (same as main theme)

  // Metro Line Colors - Same as main theme for consistency
  static const Color metroLine1 = Color(0xFFE53E3E); // Red
  static const Color metroLine2 = Color(0xFF2196F3); // Blue
  static const Color metroLine3 = Color(0xFF38A169); // Green
  static const Color metroLine4 = Color(0xFFFF9800); // Orange

  // Icon Colors - Black primary icons for light theme consistency
  static const Color iconPrimary = Color(0xFF000000); // Black for primary icons
  static const Color iconSecondary = Color(
    0xFF6C757D,
  ); // Medium gray for secondary icons
  static const Color iconSuccess = Color(0xFF4CAF50); // Green for success icons
  static const Color iconWarning = Color(
    0xFFFF9800,
  ); // Orange for warning icons
  static const Color iconError = Color(0xFFF44336); // Red for error icons
  static const Color iconDisabled = Color(
    0xFFCED4DA,
  ); // Very light gray for disabled icons

  // Button Colors - Using black primary button for light theme consistency
  static const Color buttonPrimary = Color(0xFF000000); // Black primary button
  static const Color buttonSecondary = Color(
    0xFF6C757D,
  ); // Medium gray secondary button
  static const Color buttonSuccess = Color(0xFF4CAF50); // Green success button
  static const Color buttonWarning = Color(0xFFFF9800); // Orange warning button
  static const Color buttonError = Color(0xFFF44336); // Red error button
  static const Color buttonDisabled = Color(
    0xFFCED4DA,
  ); // Very light gray disabled button

  // Card Colors - Light theme cards
  static const Color cardBackground = Color(
    0xFFFFFFFF,
  ); // White card background
  static const Color cardBorder = Color(
    0xFFE9ECEF,
  ); // Very light gray card border
  static const Color cardShadow = Color(
    0x1A000000,
  ); // Black shadow with 10% opacity for subtle shadows

  // List Item Colors - Light theme list items with black selection
  static const Color listItemBackground = Color(
    0xFFFFFFFF,
  ); // White list item background
  static const Color listItemSelected = Color(
    0xFFF8F9FA,
  ); // Very light gray for selected items
  static const Color listItemHover = Color(
    0xFFF8F9FA,
  ); // Very light gray for hover

  // Navigation Colors - Light theme navigation with black selected items
  static const Color navigationBackground = Color(
    0xFFFFFFFF,
  ); // White navigation background
  static const Color navigationSelected = Color(
    0xFF000000,
  ); // Black for selected nav item
  static const Color navigationUnselected = Color(
    0xFFADB5BD,
  ); // Light gray for unselected nav item

  // Loading Colors - Black loading spinner for light theme consistency
  static const Color loadingBackground = Color(
    0x80000000,
  ); // Semi-transparent black
  static const Color loadingSpinner = Color(
    0xFF000000,
  ); // Black loading spinner

  // Overlay Colors - Light theme overlays
  static const Color overlayBackground = Color(
    0x80000000,
  ); // Semi-transparent black overlay (same as main theme)
  static const Color modalBackground = Color(
    0xFFFFFFFF,
  ); // White modal background

  // Gradient Colors - Much lighter gradients for light theme
  static const List<Color> primaryGradient = [
    Color(0xFFF8F9FA), // Very light gray
    Color(0xFFFFFFFF), // Pure white
  ];

  static const List<Color> secondaryGradient = [
    Color(0xFFE9ECEF), // Very light gray
    Color(0xFFF8F9FA), // Very light gray
  ];

  // Onboarding Colors - Specific colors for onboarding screen in light theme
  static const Color onboardingPrimary = Color(
    0xFF000000,
  ); // Black for onboarding primary
  static const Color onboardingSecondary = Color(
    0xFF6C757D,
  ); // Medium gray for onboarding secondary
  static const Color onboardingSurface = Color(
    0xFFFFFFFF,
  ); // White surface instead of light gray
  static const Color onboardingBackground = Color(
    0xFFFFFFFF,
  ); // White background
  static const Color onboardingCard = Color(0xFFFFFFFF); // White cards
  static const Color onboardingText = Color(0xFF000000); // Black text
  static const Color onboardingTextSecondary = Color(
    0xFF6C757D,
  ); // Medium gray secondary text

  static const List<Color> successGradient = [
    Color(0xFF4CAF50),
    Color(0xFF81C784),
  ];

  static const List<Color> warningGradient = [
    Color(0xFFFF9800),
    Color(0xFFFFB74D),
  ];

  static const List<Color> errorGradient = [
    Color(0xFFF44336),
    Color(0xFFE57373),
  ];

  // Additional gradient options for light theme - Much lighter
  static const List<Color> blackToWhiteGradient = [
    Color(0xFFF8F9FA), // Very light gray
    Color(0xFFFFFFFF), // Pure white
  ];

  static const List<Color> whiteToBlackGradient = [
    Color(0xFFFFFFFF), // Pure white
    Color(0xFFF8F9FA), // Very light gray
  ];

  static const List<Color> grayGradient = [
    Color(0xFFF8F9FA), // Very light gray
    Color(0xFFE9ECEF), // Very light gray
    Color(0xFFFFFFFF), // Pure white
  ];

  static const List<Color> subtleGradient = [
    Color(0xFFFFFFFF), // Pure white
    Color(0xFFF8F9FA), // Very light gray
    Color(0xFFE9ECEF), // Very light gray
  ];

  static const List<Color> darkGradient = [
    Color(0xFFF8F9FA), // Very light gray
    Color(0xFFE9ECEF), // Very light gray
    Color(0xFFDEE2E6), // Light gray
  ];

  // New ultra-light gradients for very subtle backgrounds
  static const List<Color> ultraLightGradient = [
    Color(0xFFFFFFFF), // Pure white
    Color(0xFFF8F9FA), // Very light gray
  ];

  static const List<Color> creamGradient = [
    Color(0xFFFFFFFF), // Pure white
    Color(0xFFFEFEFE), // Almost white
    Color(0xFFFDFDFD), // Very light cream
  ];

  static const List<Color> snowGradient = [
    Color(0xFFFFFFFF), // Pure white
    Color(0xFFF9FAFB), // Snow white
    Color(0xFFF3F4F6), // Very light blue-gray
  ];
}
