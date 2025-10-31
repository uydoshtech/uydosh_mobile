import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/constants/app_strings.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

/// A reusable component for displaying price information
/// Handles both badge display and utility functions for price formatting
/// Fully theme-aware for purple, blue, and light themes
class PriceBadge extends StatelessWidget {
  const PriceBadge({
    super.key,
    required this.price,
    this.showCurrency = true,
    this.showIcon = false,
    this.fontSize,
    this.padding,
    this.isActive = true,
    this.currencySymbol,
    this.activeColor,
    this.inactiveColor,
  });

  final int price;
  final bool showCurrency;
  final bool showIcon;
  final double? fontSize;
  final EdgeInsets? padding;
  final bool isActive;
  final String? currencySymbol;
  final Color? activeColor;
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    final themeState = ThemeState();
    final color =
        isActive
            ? (activeColor ?? _getThemeAwareActiveColor(themeState))
            : (inactiveColor ?? _getThemeAwareInactiveColor(themeState));

    final formattedPrice =
        currencySymbol == "y.e."
            ? PriceHelper.formatPriceWithYue(price)
            : PriceHelper.formatPrice(price);
    final currency = currencySymbol ?? "\$";
    final backgroundColor = _getThemeAwareBackgroundColor(themeState);

    return Container(
      padding:
          padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showIcon) ...[
            Icon(
              Icons.attach_money,
              color: color,
              size: fontSize != null ? fontSize! + 2 : 14,
            ),
            if (showCurrency) const SizedBox(width: 2),
          ],
          if (showCurrency && currency != "y.e.") ...[
            Text(
              currency,
              style: TextStyle(
                color: color,
                fontSize: fontSize ?? 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 1),
          ],
          Text(
            formattedPrice,
            style: TextStyle(
              color: color,
              fontSize: fontSize ?? 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Get theme-aware active color (green for purple/light, inverted for blue)
  Color _getThemeAwareActiveColor(ThemeState themeState) {
    if (themeState.isBlueTheme) {
      // Blue theme: white text on green background
      return Colors.white;
    }
    // Purple and light themes: use standard green
    return AppColors.statusActive;
  }

  /// Get theme-aware inactive color (red for purple/light, inverted for blue)
  Color _getThemeAwareInactiveColor(ThemeState themeState) {
    if (themeState.isBlueTheme) {
      // Blue theme: invert red to light blue-gray
      return const Color(0xFF7A8A9A);
    }
    // Purple and light themes: use standard red
    return AppColors.statusInactive;
  }

  /// Get theme-aware background color
  Color _getThemeAwareBackgroundColor(ThemeState themeState) {
    if (themeState.isBlueTheme) {
      // Blue theme: use green background for price badges
      return AppColors.statusActive; // Green background
    } else if (themeState.isPurpleTheme) {
      // Purple theme: use white background
      return Colors.white;
    } else {
      // Light theme: use white background
      return Colors.white;
    }
  }
}

/// Helper class for price utilities
/// Centralizes all price formatting logic
class PriceHelper {
  /// Format price for display
  /// Currently returns the price as a string with "y.e." suffix, but can be extended
  /// to add thousand separators, decimal places, etc.
  static String formatPrice(int price) {
    return price.toString();
  }

  /// Format price with "y.e." suffix
  static String formatPriceWithYue(int price) {
    return "${price.toString()} y.e.";
  }

  /// Format price with thousand separators
  static String formatPriceWithSeparators(int price) {
    final priceString = price.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < priceString.length; i++) {
      if (i > 0 && (priceString.length - i) % 3 == 0) {
        buffer.write(",");
      }
      buffer.write(priceString[i]);
    }

    return buffer.toString();
  }

  /// Format price with currency symbol
  static String formatPriceWithCurrency(
    int price, {
    String currencySymbol = "\$",
  }) {
    return "$currencySymbol${formatPrice(price)}";
  }

  /// Format price with thousand separators and currency
  static String formatPriceWithSeparatorsAndCurrency(
    int price, {
    String currencySymbol = "\$",
  }) {
    return "$currencySymbol${formatPriceWithSeparators(price)}";
  }

  /// Get localized price label
  static String getPriceLabel(BuildContext context) {
    final currentLanguage = LanguageAwareStringHelper.getCurrentLanguage(
      context,
    );
    return AppStrings.get("listing_price_label", currentLanguage);
  }
}

/// A simple widget for displaying just the price text
/// Useful for simple text display without badge styling
/// Fully theme-aware for purple, blue, and light themes
class PriceText extends StatelessWidget {
  const PriceText({
    super.key,
    required this.price,
    this.style,
    this.showCurrency = true,
    this.currencySymbol,
    this.isActive = true,
    this.activeColor,
    this.inactiveColor,
  });

  final int price;
  final TextStyle? style;
  final bool showCurrency;
  final String? currencySymbol;
  final bool isActive;
  final Color? activeColor;
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    final themeState = ThemeState();
    final color =
        isActive
            ? (activeColor ?? _getThemeAwareActiveColor(themeState))
            : (inactiveColor ?? _getThemeAwareInactiveColor(themeState));

    final formattedPrice =
        currencySymbol == "y.e."
            ? PriceHelper.formatPriceWithYue(price)
            : PriceHelper.formatPrice(price);
    final currency = currencySymbol ?? "\$";

    return Text(
      (showCurrency && currency != "y.e.")
          ? "$currency $formattedPrice"
          : formattedPrice,
      style: style ?? TextStyle(color: color, fontWeight: FontWeight.w600),
    );
  }

  /// Get theme-aware active color (green for purple/light, inverted for blue)
  Color _getThemeAwareActiveColor(ThemeState themeState) {
    if (themeState.isBlueTheme) {
      // Blue theme: invert green to white
      return Colors.white;
    }
    // Purple and light themes: use standard green
    return AppColors.statusActive;
  }

  /// Get theme-aware inactive color (red for purple/light, inverted for blue)
  Color _getThemeAwareInactiveColor(ThemeState themeState) {
    if (themeState.isBlueTheme) {
      // Blue theme: invert red to light blue-gray
      return const Color(0xFF7A8A9A);
    }
    // Purple and light themes: use standard red
    return AppColors.statusInactive;
  }
}

/// A compact price display widget
/// Smaller than PriceBadge, useful for tight spaces
/// Fully theme-aware for purple, blue, and light themes
class CompactPriceBadge extends StatelessWidget {
  const CompactPriceBadge({
    super.key,
    required this.price,
    this.showCurrency = true,
    this.fontSize,
    this.isActive = true,
    this.currencySymbol,
    this.activeColor,
    this.inactiveColor,
  });

  final int price;
  final bool showCurrency;
  final double? fontSize;
  final bool isActive;
  final String? currencySymbol;
  final Color? activeColor;
  final Color? inactiveColor;

  @override
  Widget build(BuildContext context) {
    final themeState = ThemeState();
    final color =
        isActive
            ? (activeColor ?? _getThemeAwareActiveColor(themeState))
            : (inactiveColor ?? _getThemeAwareInactiveColor(themeState));

    final formattedPrice =
        currencySymbol == "y.e."
            ? PriceHelper.formatPriceWithYue(price)
            : PriceHelper.formatPrice(price);
    final currency = currencySymbol ?? "\$";
    final backgroundColor = _getThemeAwareBackgroundColor(themeState);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Text(
        (showCurrency && currency != "y.e.")
            ? "$currency$formattedPrice"
            : formattedPrice,
        style: TextStyle(
          color: color,
          fontSize: fontSize ?? 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// Get theme-aware active color (green for purple/light, inverted for blue)
  Color _getThemeAwareActiveColor(ThemeState themeState) {
    if (themeState.isBlueTheme) {
      // Blue theme: invert green to white
      return Colors.white;
    }
    // Purple and light themes: use standard green
    return AppColors.statusActive;
  }

  /// Get theme-aware inactive color (red for purple/light, inverted for blue)
  Color _getThemeAwareInactiveColor(ThemeState themeState) {
    if (themeState.isBlueTheme) {
      // Blue theme: invert red to light blue-gray
      return const Color(0xFF7A8A9A);
    }
    // Purple and light themes: use standard red
    return AppColors.statusInactive;
  }

  /// Get theme-aware background color
  Color _getThemeAwareBackgroundColor(ThemeState themeState) {
    if (themeState.isBlueTheme) {
      // Blue theme: use green background for price badges
      return AppColors.statusActive; // Green background
    } else if (themeState.isPurpleTheme) {
      // Purple theme: use white background
      return Colors.white;
    } else {
      // Light theme: use white background
      return Colors.white;
    }
  }
}
