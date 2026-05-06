import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_strings.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// A reusable component for displaying price information
/// Handles both badge display and utility functions for price formatting
/// Fully theme-aware for blue and light themes
class PriceBadge extends StatelessWidget {
  const PriceBadge({
    required this.price, super.key,
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
            ? (activeColor ?? themeState.priceBadgeActiveColor)
            : (inactiveColor ?? themeState.priceBadgeInactiveColor);

    final formattedPrice =
        currencySymbol == "y.e."
            ? PriceHelper.formatPriceWithYue(price)
            : PriceHelper.formatPrice(price);
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
            ThemeIcon(
              Icons.payments,
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

    for (var i = 0; i < priceString.length; i++) {
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
    final currentLanguage = L10n.currentLanguage;
    return AppStrings.get("listing_price_label", currentLanguage);
  }
}

/// A simple widget for displaying just the price text
/// Useful for simple text display without badge styling
/// Fully theme-aware for blue and light themes
class PriceText extends StatelessWidget {
  const PriceText({
    required this.price, super.key,
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
            ? (activeColor ?? themeState.priceBadgeActiveColor)
            : (inactiveColor ?? themeState.priceBadgeInactiveColor);

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
}

/// A compact price display widget
/// Smaller than PriceBadge, useful for tight spaces
/// Fully theme-aware for blue and light themes
class CompactPriceBadge extends StatelessWidget {
  const CompactPriceBadge({
    required this.price, super.key,
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
            ? (activeColor ?? themeState.priceBadgeActiveColor)
            : (inactiveColor ?? themeState.priceBadgeInactiveColor);

    final formattedPrice =
        currencySymbol == "y.e."
            ? PriceHelper.formatPriceWithYue(price)
            : PriceHelper.formatPrice(price);
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
}

/// Green-outlined chip with a payments icon, matching listing tiles and
/// [ListingDetailMetaBadges] so marketplace prices stay visually consistent.
class ListingPaymentsOutlineBadge extends StatelessWidget {
  const ListingPaymentsOutlineBadge({
    required this.label,
    super.key,
    this.foregroundColor = Colors.green,
    this.padding = const EdgeInsets.all(4),
    this.borderRadius = 8,
    this.iconSize = 18,
    this.fontSize = 14,
  });

  final String label;
  final Color foregroundColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double iconSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: foregroundColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ThemeIcon(
            Icons.payments,
            size: iconSize,
            color: foregroundColor,
            useThemeColor: false,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              color: foregroundColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
