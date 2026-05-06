import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_strings.dart";
import "package:uy_dosh/base/utils/int_format_utils.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// A reusable component for displaying price range information
/// Handles both badge display and utility functions for price range formatting
/// Fully theme-aware for blue and light themes
class PriceRangeBadge extends StatelessWidget {
  const PriceRangeBadge({
    required this.minPrice, required this.maxPrice, super.key,
    this.showCurrency = true,
    this.showIcon = false,
    this.iconSize,
    this.fontSize,
    this.padding,
    this.isActive = true,
    this.currencySymbol,
    this.activeColor,
    this.inactiveColor,
    this.badgeBackgroundColor,
    this.useTintBackground = false,
    this.tintAlpha = 0.12,
  });

  final int minPrice;
  final int maxPrice;
  final bool showCurrency;
  final bool showIcon;

  /// When null and [showIcon] is true, uses [fontSize] + 2 if [fontSize] is set, else 14.
  final double? iconSize;
  final double? fontSize;
  final EdgeInsets? padding;
  final bool isActive;
  final String? currencySymbol;
  final Color? activeColor;
  final Color? inactiveColor;

  /// When set, used as the container fill instead of [useTintBackground] / theme defaults.
  final Color? badgeBackgroundColor;

  /// When true, background is a light tint of the badge [color] (same idea as [ListingTypeBadge]).
  final bool useTintBackground;

  /// Opacity of the tint when [useTintBackground] is true (ignored otherwise).
  final double tintAlpha;

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
    final backgroundColor =
        badgeBackgroundColor ??
            (useTintBackground
                ? color.withValues(alpha: tintAlpha)
                : themeState.priceBadgeBackgroundColor);

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
            ThemeIcon(
              Icons.payments,
              color: color,
              size: iconSize ?? (fontSize != null ? fontSize! + 2 : 14),
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
  /// Returns the price range as a string (e.g., "50-250" or "50" when equal)
  static String formatPriceRange(int minPrice, int maxPrice) {
    final minStr = IntFormatUtils.withDotThousands(minPrice);
    final maxStr = IntFormatUtils.withDotThousands(maxPrice);
    if (minPrice == maxPrice) {
      return minStr;
    }
    return "$minStr-$maxStr";
  }

  /// Format price range with "y.e." suffix
  /// When min and max are equal, shows single price (e.g. "50 y.e.")
  static String formatPriceRangeWithYue(int minPrice, int maxPrice) {
    final minStr = IntFormatUtils.withDotThousands(minPrice);
    final maxStr = IntFormatUtils.withDotThousands(maxPrice);
    if (minPrice == maxPrice) {
      return "$minStr y.e.";
    }
    return "$minStr - $maxStr y.e.";
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
    return IntFormatUtils.withDotThousands(price);
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
