import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_strings.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/localization/l10n.dart";

/// A reusable component for displaying price range information
/// Handles both badge display and utility functions for price range formatting
/// Fully theme-aware for blue and light themes
class PriceRangeBadge extends StatelessWidget {
  const PriceRangeBadge({
    required this.minPrice, required this.maxPrice, super.key,
    this.showCurrency = true,
    this.showIcon = false,
    this.fontSize,
    this.padding,
    this.isActive = true,
    this.currencySymbol,
    this.activeColor,
    this.inactiveColor,
  });

  final int minPrice;
  final int maxPrice;
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
            ? (activeColor ?? themeState.priceBadgeActiveColor)
            : (inactiveColor ?? themeState.priceBadgeInactiveColor);

    final formattedPriceRange =
        currencySymbol == "y.e."
            ? PriceRangeHelper.formatPriceRangeWithYue(minPrice, maxPrice)
            : PriceRangeHelper.formatPriceRange(minPrice, maxPrice);
    final currency = currencySymbol ?? "\$";
    final backgroundColor = themeState.priceBadgeBackgroundColor;

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
            formattedPriceRange,
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

}

/// Helper class for price range utilities
/// Centralizes all price range formatting logic
class PriceRangeHelper {
  /// Format price range for display
  /// Returns the price range as a string (e.g., "50-250")
  static String formatPriceRange(int minPrice, int maxPrice) {
    return "$minPrice-$maxPrice";
  }

  /// Format price range with "y.e." suffix
  static String formatPriceRangeWithYue(int minPrice, int maxPrice) {
    return "$minPrice - $maxPrice y.e.";
  }

  /// Format price range with thousand separators
  static String formatPriceRangeWithSeparators(int minPrice, int maxPrice) {
    final minPriceString = _formatPriceWithSeparators(minPrice);
    final maxPriceString = _formatPriceWithSeparators(maxPrice);
    return "$minPriceString-$maxPriceString";
  }

  /// Format price range with currency symbol
  static String formatPriceRangeWithCurrency(
    int minPrice,
    int maxPrice, {
    String currencySymbol = "\$",
  }) {
    return "$currencySymbol$minPrice-$currencySymbol$maxPrice";
  }

  /// Format price range with thousand separators and currency
  static String formatPriceRangeWithSeparatorsAndCurrency(
    int minPrice,
    int maxPrice, {
    String currencySymbol = "\$",
  }) {
    final minPriceString = _formatPriceWithSeparators(minPrice);
    final maxPriceString = _formatPriceWithSeparators(maxPrice);
    return "$currencySymbol$minPriceString-$currencySymbol$maxPriceString";
  }

  /// Helper method to format a single price with thousand separators
  static String _formatPriceWithSeparators(int price) {
    final priceString = price.toString();
    final buffer = StringBuffer();

    for (var i = 0; i < priceString.length; i++) {
      if (i > 0 && (priceString.length - i) % 3 == 0) {
        buffer.write(",");
      }
      buffer.write(priceString[i]);
    }

    return buffer.toString();
  }

  /// Get localized price range label
  static String getPriceRangeLabel(BuildContext context) {
    final currentLanguage = L10n.currentLanguage;
    return AppStrings.get("listing_price_range_label", currentLanguage);
  }
}

/// A simple widget for displaying just the price range text
/// Useful for simple text display without badge styling
/// Fully theme-aware for blue and light themes
class PriceRangeText extends StatelessWidget {
  const PriceRangeText({
    required this.minPrice, required this.maxPrice, super.key,
    this.style,
    this.showCurrency = true,
    this.currencySymbol,
    this.isActive = true,
    this.activeColor,
    this.inactiveColor,
  });

  final int minPrice;
  final int maxPrice;
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
            ? (activeColor ?? themeState.priceBadgeActiveColor)
            : (inactiveColor ?? themeState.priceBadgeInactiveColor);

    final formattedPriceRange =
        currencySymbol == "y.e."
            ? PriceRangeHelper.formatPriceRangeWithYue(minPrice, maxPrice)
            : PriceRangeHelper.formatPriceRange(minPrice, maxPrice);
    final currency = currencySymbol ?? "\$";

    return Text(
      (showCurrency && currency != "y.e.")
          ? "$currency $formattedPriceRange"
          : formattedPriceRange,
      style: style ?? TextStyle(color: color, fontWeight: FontWeight.w600),
    );
  }
}

/// A compact price range display widget
/// Smaller than PriceRangeBadge, useful for tight spaces
/// Fully theme-aware for blue and light themes
class CompactPriceRangeBadge extends StatelessWidget {
  const CompactPriceRangeBadge({
    required this.minPrice, required this.maxPrice, super.key,
    this.showCurrency = true,
    this.fontSize,
    this.isActive = true,
    this.currencySymbol,
    this.activeColor,
    this.inactiveColor,
  });

  final int minPrice;
  final int maxPrice;
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
            ? (activeColor ?? themeState.priceBadgeActiveColor)
            : (inactiveColor ?? themeState.priceBadgeInactiveColor);

    final formattedPriceRange =
        currencySymbol == "y.e."
            ? PriceRangeHelper.formatPriceRangeWithYue(minPrice, maxPrice)
            : PriceRangeHelper.formatPriceRange(minPrice, maxPrice);
    final currency = currencySymbol ?? "\$";
    final backgroundColor = themeState.priceBadgeBackgroundColor;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color, width: 0.5),
      ),
      child: Text(
        (showCurrency && currency != "y.e.")
            ? "$currency$formattedPriceRange"
            : formattedPriceRange,
        style: TextStyle(
          color: color,
          fontSize: fontSize ?? 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
