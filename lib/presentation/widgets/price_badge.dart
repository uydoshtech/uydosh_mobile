import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_strings.dart";
import "package:uy_dosh/base/state/price_display_settings_state.dart";
import "package:uy_dosh/base/utils/int_format_utils.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";

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
    return ListenableBuilder(
      listenable: PriceDisplaySettingsState(),
      builder: (context, _) {
        final themeState = ThemeState();
        final color =
            isActive
                ? (activeColor ?? themeState.priceBadgeActiveColor)
                : (inactiveColor ?? themeState.priceBadgeInactiveColor);

        final listingNominalUzs =
            currencySymbol == null || currencySymbol == "y.e.";
        final display = PriceDisplaySettingsState().currency;
        final resolvedCurrency =
            listingNominalUzs
                ? (display == PriceDisplayCurrency.usd ? "USD" : "UZS")
                : (currencySymbol ?? "USD");
        final resolvedPrice =
            listingNominalUzs
                ? (display == PriceDisplayCurrency.usd
                    ? PriceRangeHelper.listingPriceToWholeUsdForDisplay(price)
                    : PriceRangeHelper.listingPriceToUzsForDisplay(price))
                : price;

        final useUzsCompact =
            listingNominalUzs && display == PriceDisplayCurrency.national;
        final formattedPrice =
            !listingNominalUzs && resolvedCurrency == "y.e."
                ? PriceHelper.formatPriceWithYue(resolvedPrice)
                : PriceHelper.formatPrice(
                    resolvedPrice,
                    uzsCompact: useUzsCompact,
                  );
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
      },
    );
  }

}

/// Helper class for price utilities
/// Centralizes all price formatting logic
class PriceHelper {
  /// Format price for display. UZS uses compact `K` / `M` labels; other
  /// currencies use `.` thousands grouping (e.g. 500.000).
  static String formatPrice(int price, {bool uzsCompact = false}) {
    if (uzsCompact) {
      return PriceRangeHelper.formatUzsCompact(price);
    }
    return IntFormatUtils.withDotThousands(price);
  }

  /// Format price with "y.e." suffix
  static String formatPriceWithYue(int price) {
    return "${IntFormatUtils.withDotThousands(price)} y.e.";
  }

  /// Format price with thousand separators
  static String formatPriceWithSeparators(int price) {
    return IntFormatUtils.withDotThousands(price);
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
    return ListenableBuilder(
      listenable: PriceDisplaySettingsState(),
      builder: (context, _) {
        final themeState = ThemeState();
        final color =
            isActive
                ? (activeColor ?? themeState.priceBadgeActiveColor)
                : (inactiveColor ?? themeState.priceBadgeInactiveColor);

        final listingNominalUzs =
            currencySymbol == null || currencySymbol == "y.e.";
        final display = PriceDisplaySettingsState().currency;
        final resolvedCurrency =
            listingNominalUzs
                ? (display == PriceDisplayCurrency.usd ? "USD" : "UZS")
                : (currencySymbol ?? "USD");
        final resolvedPrice =
            listingNominalUzs
                ? (display == PriceDisplayCurrency.usd
                    ? PriceRangeHelper.listingPriceToWholeUsdForDisplay(price)
                    : PriceRangeHelper.listingPriceToUzsForDisplay(price))
                : price;

        final useUzsCompact =
            listingNominalUzs && display == PriceDisplayCurrency.national;
        final formattedPrice =
            !listingNominalUzs && resolvedCurrency == "y.e."
                ? PriceHelper.formatPriceWithYue(resolvedPrice)
                : PriceHelper.formatPrice(
                    resolvedPrice,
                    uzsCompact: useUzsCompact,
                  );

        return Text(
          formattedPrice,
          style: style ?? TextStyle(color: color, fontWeight: FontWeight.w600),
        );
      },
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
    return ListenableBuilder(
      listenable: PriceDisplaySettingsState(),
      builder: (context, _) {
        final themeState = ThemeState();
        final color =
            isActive
                ? (activeColor ?? themeState.priceBadgeActiveColor)
                : (inactiveColor ?? themeState.priceBadgeInactiveColor);

        final listingNominalUzs =
            currencySymbol == null || currencySymbol == "y.e.";
        final display = PriceDisplaySettingsState().currency;
        final resolvedCurrency =
            listingNominalUzs
                ? (display == PriceDisplayCurrency.usd ? "USD" : "UZS")
                : (currencySymbol ?? "USD");
        final resolvedPrice =
            listingNominalUzs
                ? (display == PriceDisplayCurrency.usd
                    ? PriceRangeHelper.listingPriceToWholeUsdForDisplay(price)
                    : PriceRangeHelper.listingPriceToUzsForDisplay(price))
                : price;

        final useUzsCompact =
            listingNominalUzs && display == PriceDisplayCurrency.national;
        final formattedPrice =
            !listingNominalUzs && resolvedCurrency == "y.e."
                ? PriceHelper.formatPriceWithYue(resolvedPrice)
                : PriceHelper.formatPrice(
                    resolvedPrice,
                    uzsCompact: useUzsCompact,
                  );
        final backgroundColor = themeState.priceBadgeBackgroundColor;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color, width: 0.5),
          ),
          child: Text(
            formattedPrice,
            style: TextStyle(
              color: color,
              fontSize: fontSize ?? 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      },
    );
  }
}

/// Prominent monthly price badge matching [ListingTile]'s price card.
class ListingStoredPriceBadge extends StatelessWidget {
  const ListingStoredPriceBadge({
    required this.storedPrice,
    required this.listingTypeCode,
    this.minPrice,
    this.maxPrice,
    super.key,
  });

  final int storedPrice;
  final String listingTypeCode;
  final int? minPrice;
  final int? maxPrice;

  static const Color _accentGreen = Color(0xFF35C26B);
  static const Color _accentGreenLightTheme = Color(0xFF25884B);

  Color _priceAccentGreen() =>
      ThemeState().isLightTheme ? _accentGreenLightTheme : _accentGreen;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PriceDisplaySettingsState(),
      builder: (context, _) {
        final priceGreen = _priceAccentGreen();
        final amount = PriceRangeHelper.formatStoredListingPrice(
          storedPrice: storedPrice,
          listingTypeCode: listingTypeCode,
          minPrice: minPrice,
          maxPrice: maxPrice,
        );
        final isUsd =
            PriceDisplaySettingsState().currency == PriceDisplayCurrency.usd;
        final unit = L10n.get(
          isUsd ? "price_unit_usd_per_month" : "price_unit_uzs_per_month",
        );

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(
            color: priceGreen.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: priceGreen.withValues(alpha: 0.6)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ThemeIcon(
                Icons.payments,
                size: 16,
                color: priceGreen,
                useThemeColor: false,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  amount,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: priceGreen,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                unit,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                  color: priceGreen.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Green-outlined chip with a payments icon, matching listing tiles and
/// [ListingDetailMetaBadges] so marketplace prices stay visually consistent.
/// Pass currency as an ISO code only — use [CurrencyDisplayUtils.isoCode], not
/// [CurrencyDisplayUtils.codeWithFlag], so no flag emoji appears in this badge.
class ListingPaymentsOutlineBadge extends StatelessWidget {
  const ListingPaymentsOutlineBadge({
    required this.label,
    super.key,
    this.foregroundColor = Colors.green,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(4),
    this.borderRadius = 8,
    this.iconSize = 18,
    this.fontSize = 14,
  });

  final String label;
  final Color foregroundColor;

  /// Optional soft fill behind the badge (defaults to transparent).
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double iconSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
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
