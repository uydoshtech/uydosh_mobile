import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_strings.dart";
import "package:uy_dosh/base/constants/app_config.dart";
import "package:uy_dosh/base/state/price_display_settings_state.dart";
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
    return ListenableBuilder(
      listenable: PriceDisplaySettingsState(),
      builder: (context, _) {
        final themeState = ThemeState();
        final color =
            isActive
                ? (activeColor ?? themeState.priceBadgeActiveColor)
                : (inactiveColor ?? themeState.priceBadgeInactiveColor);

        final display = PriceDisplaySettingsState().currency;

        /// Listing amounts from the API are UZS integers; the UI used to label
        /// them as "y.e." — treat both as the same nominal unit for display prefs.
        final listingNominalUzs =
            currencySymbol == null || currencySymbol == "y.e.";

        final resolvedCurrency =
            listingNominalUzs
                ? (display == PriceDisplayCurrency.usd ? "USD" : "UZS")
                : (currencySymbol ?? "USD");

        final resolvedMin =
            listingNominalUzs
                ? (display == PriceDisplayCurrency.usd
                    ? PriceRangeHelper.listingPriceToWholeUsdForDisplay(minPrice)
                    : PriceRangeHelper.listingPriceToUzsForDisplay(minPrice))
                : minPrice;
        final resolvedMax =
            listingNominalUzs
                ? (display == PriceDisplayCurrency.usd
                    ? PriceRangeHelper.listingPriceToWholeUsdForDisplay(maxPrice)
                    : PriceRangeHelper.listingPriceToUzsForDisplay(maxPrice))
                : maxPrice;

        final formattedPriceRange =
            !listingNominalUzs && resolvedCurrency == "y.e."
                ? PriceRangeHelper.formatPriceRangeWithYue(
                    resolvedMin,
                    resolvedMax,
                  )
                : PriceRangeHelper.formatPriceRange(resolvedMin, resolvedMax);

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
                SizedBox(width: showCurrency ? 4 : 6),
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
      },
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
    return "$minStr - $maxStr";
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

  static int uzsToUsdRounded(int uzs) {
    final rate = AppConfig.uzsPerUsd;
    if (rate <= 0) return uzs;
    return (uzs / rate).round();
  }

  /// Listings store [price] in two possible shapes in the wild:
  /// - **Index / USD scale** (~10–1000): what the create-listing slider posts
  ///   (whole “USD per month” style amounts, same scale as search filters).
  /// - **Full UZS** (large integers, e.g. ≥ [kListingPriceAssumeFullUzsThreshold]):
  ///   legacy or imported rows.
  ///
  /// We must not feed the small index through [uzsToUsdRounded] (that treated
  /// them as tiny UZS lumps and produced `$0`).
  static const int kListingPriceAssumeFullUzsThreshold = 50000;

  static bool listingPriceLikelyFullUzs(int stored) =>
      stored >= kListingPriceAssumeFullUzsThreshold;

  /// Value to show when the user wants **national currency (UZS)**.
  static int listingPriceToUzsForDisplay(int stored) {
    if (listingPriceLikelyFullUzs(stored)) return stored;
    final rate = AppConfig.uzsPerUsd;
    if (rate <= 0) return stored;
    return (stored * rate).round();
  }

  /// Whole USD for display when the user wants **USD** (index scale is already USD).
  static int listingPriceToWholeUsdForDisplay(int stored) {
    if (listingPriceLikelyFullUzs(stored)) return uzsToUsdRounded(stored);
    return stored;
  }

  /// Digits only (dot grouping). Currency codes are intentionally not shown.
  static String formatListingPriceRangeWithCurrency(int minUzs, int maxUzs) {
    final pref = PriceDisplaySettingsState().currency;
    if (pref == PriceDisplayCurrency.usd) {
      final minUsd = listingPriceToWholeUsdForDisplay(minUzs);
      final maxUsd = listingPriceToWholeUsdForDisplay(maxUzs);
      return formatPriceRange(minUsd, maxUsd);
    }
    final minNat = listingPriceToUzsForDisplay(minUzs);
    final maxNat = listingPriceToUzsForDisplay(maxUzs);
    return formatPriceRange(minNat, maxNat);
  }

  /// Snap to the nearest 10.000 UZS and render with `K` (thousands) or `M`
  /// (millions). Shared with [PriceRangePicker] and filter chips.
  static String formatUzsCompact(int uzs) {
    final snapped = ((uzs + 5000) ~/ 10000) * 10000;
    if (snapped >= 1000000) {
      final whole = snapped ~/ 1000000;
      final tenths = (snapped % 1000000) ~/ 100000;
      if (tenths == 0) return "${whole}M";
      return "$whole,${tenths}M";
    }
    return "${snapped ~/ 1000}K";
  }

  /// Search filters store bounds on listing USD-index scale (same as
  /// [SearchFiltersState] / [PriceRangePicker] storage).
  static String formatSearchFilterPriceChipLabel(
    double minUsdScale,
    double maxUsdScale,
  ) {
    final pref = PriceDisplaySettingsState().currency;
    final minI = minUsdScale.round();
    final maxI = maxUsdScale.round();
    if (pref == PriceDisplayCurrency.usd) {
      final minUsd = listingPriceToWholeUsdForDisplay(minI);
      final maxUsd = listingPriceToWholeUsdForDisplay(maxI);
      return formatPriceRange(minUsd, maxUsd);
    }
    final minNat = listingPriceToUzsForDisplay(minI);
    final maxNat = listingPriceToUzsForDisplay(maxI);
    return "${formatUzsCompact(minNat)}–${formatUzsCompact(maxNat)}";
  }

  /// Format price range with thousand separators
  static String formatPriceRangeWithSeparators(int minPrice, int maxPrice) {
    final minPriceString = _formatPriceWithSeparators(minPrice);
    final maxPriceString = _formatPriceWithSeparators(maxPrice);
    return "$minPriceString - $maxPriceString";
  }

  /// Format price range with currency symbol
  static String formatPriceRangeWithCurrency(
    int minPrice,
    int maxPrice, {
    String currencySymbol = "\$",
  }) {
    return "$currencySymbol$minPrice - $currencySymbol$maxPrice";
  }

  /// Format price range with thousand separators and currency
  static String formatPriceRangeWithSeparatorsAndCurrency(
    int minPrice,
    int maxPrice, {
    String currencySymbol = "\$",
  }) {
    final minPriceString = _formatPriceWithSeparators(minPrice);
    final maxPriceString = _formatPriceWithSeparators(maxPrice);
    return "$currencySymbol$minPriceString - $currencySymbol$maxPriceString";
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
    return ListenableBuilder(
      listenable: PriceDisplaySettingsState(),
      builder: (context, _) {
        final themeState = ThemeState();
        final color =
            isActive
                ? (activeColor ?? themeState.priceBadgeActiveColor)
                : (inactiveColor ?? themeState.priceBadgeInactiveColor);

        final display = PriceDisplaySettingsState().currency;
        final listingNominalUzs =
            currencySymbol == null || currencySymbol == "y.e.";
        final resolvedCurrency =
            listingNominalUzs
                ? (display == PriceDisplayCurrency.usd ? "USD" : "UZS")
                : (currencySymbol ?? "USD");
        final resolvedMin =
            listingNominalUzs
                ? (display == PriceDisplayCurrency.usd
                    ? PriceRangeHelper.listingPriceToWholeUsdForDisplay(minPrice)
                    : PriceRangeHelper.listingPriceToUzsForDisplay(minPrice))
                : minPrice;
        final resolvedMax =
            listingNominalUzs
                ? (display == PriceDisplayCurrency.usd
                    ? PriceRangeHelper.listingPriceToWholeUsdForDisplay(maxPrice)
                    : PriceRangeHelper.listingPriceToUzsForDisplay(maxPrice))
                : maxPrice;

        final formattedPriceRange =
            !listingNominalUzs && resolvedCurrency == "y.e."
                ? PriceRangeHelper.formatPriceRangeWithYue(
                    resolvedMin,
                    resolvedMax,
                  )
                : PriceRangeHelper.formatPriceRange(resolvedMin, resolvedMax);

        return Text(
          formattedPriceRange,
          style: style ?? TextStyle(color: color, fontWeight: FontWeight.w600),
        );
      },
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
    return ListenableBuilder(
      listenable: PriceDisplaySettingsState(),
      builder: (context, _) {
        final themeState = ThemeState();
        final color =
            isActive
                ? (activeColor ?? themeState.priceBadgeActiveColor)
                : (inactiveColor ?? themeState.priceBadgeInactiveColor);

        final display = PriceDisplaySettingsState().currency;
        final listingNominalUzs =
            currencySymbol == null || currencySymbol == "y.e.";
        final resolvedCurrency =
            listingNominalUzs
                ? (display == PriceDisplayCurrency.usd ? "USD" : "UZS")
                : (currencySymbol ?? "USD");
        final resolvedMin =
            listingNominalUzs
                ? (display == PriceDisplayCurrency.usd
                    ? PriceRangeHelper.listingPriceToWholeUsdForDisplay(minPrice)
                    : PriceRangeHelper.listingPriceToUzsForDisplay(minPrice))
                : minPrice;
        final resolvedMax =
            listingNominalUzs
                ? (display == PriceDisplayCurrency.usd
                    ? PriceRangeHelper.listingPriceToWholeUsdForDisplay(maxPrice)
                    : PriceRangeHelper.listingPriceToUzsForDisplay(maxPrice))
                : maxPrice;

        final formattedPriceRange =
            !listingNominalUzs && resolvedCurrency == "y.e."
                ? PriceRangeHelper.formatPriceRangeWithYue(
                    resolvedMin,
                    resolvedMax,
                  )
                : PriceRangeHelper.formatPriceRange(resolvedMin, resolvedMax);
        final backgroundColor = themeState.priceBadgeBackgroundColor;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color, width: 0.5),
          ),
          child: Text(
            formattedPriceRange,
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
