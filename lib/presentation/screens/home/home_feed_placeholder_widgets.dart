import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/presentation/widgets/common/common_state_builder.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_pill_button.dart";
import "package:uy_dosh/presentation/screens/home/notify_search_alert_ghost_button.dart";

/// Welcome state when the home feed has not loaded listings yet.
class HomeWelcomePlaceholder extends StatelessWidget {
  const HomeWelcomePlaceholder({
    required this.homeIconColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.onRefresh,
    super.key,
  });

  final Color homeIconColor;
  final Color titleColor;
  final Color subtitleColor;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ThemeIcon(Icons.home, size: 64, color: homeIconColor),
        const SizedBox(height: 16),
        L10n.text(
          "welcome_title",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 8),
        L10n.text(
          "welcome_subtitle",
          style: TextStyle(fontSize: 16, color: subtitleColor),
        ),
        const SizedBox(height: 24),
        GhostButtonFactory.iconText(
          onPressed: onRefresh,
          icon: Icons.refresh,
          text: L10n.get("refresh"),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(fontSize: 16),
          neumorphicSoftUi: true,
        ),
      ],
    );
  }
}

/// Empty search results with clear-filters + notify CTAs.
class HomeEmptySearchPlaceholder extends StatelessWidget {
  const HomeEmptySearchPlaceholder({
    required this.homeIconColor,
    required this.titleColor,
    required this.onClearFilters,
    required this.onNotifyMe,
    required this.emptySearchCtaHeight,
    super.key,
  });

  final Color homeIconColor;
  final Color titleColor;
  final VoidCallback onClearFilters;
  final VoidCallback? onNotifyMe;
  final double emptySearchCtaHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        ThemeIcon(
          Icons.search_off,
          size: 64,
          color: homeIconColor,
        ),
        const SizedBox(height: 16),
        L10n.text(
          "no_search_results",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 18),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                GhostButtonFactory.iconText(
                  onPressed: onClearFilters,
                  icon: Icons.filter_alt_off,
                  text: L10n.get("search_clear_filters"),
                  height: emptySearchCtaHeight,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  neumorphicSoftUi: true,
                ),
                const SizedBox(height: 12),
                NotifySearchAlertGhostButton(
                  height: emptySearchCtaHeight,
                  label: L10n.get("search_alert_notify_me"),
                  onPressed: onNotifyMe,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Feed-level error with retry pill (matches prior home feed styling).
class HomeFeedErrorPanel extends StatelessWidget {
  const HomeFeedErrorPanel({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return CommonStateBuilder(
      isLoading: false,
      hasError: true,
      isEmpty: false,
      errorMessage: message,
      errorAction: ThreeDPillButton(
        onPressed: onRetry,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ThemeIcon(Icons.refresh, size: 18),
            const SizedBox(width: 8),
            Text(
              L10n.get("retry"),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      child: Container(),
    );
  }
}

class HomeFeedLoadMoreFooter extends StatelessWidget {
  const HomeFeedLoadMoreFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return CenteredHouseLoadingIndicator(
      text: L10n.get("loading_listings"),
    );
  }
}
