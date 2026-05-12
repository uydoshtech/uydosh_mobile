import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// Full-screen error when listing detail fails to load (gradient icon + retry).
class ListingDetailFetchErrorBody extends StatelessWidget {
  const ListingDetailFetchErrorBody({
    required this.onRetry,
    super.key,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.warning, AppColors.favoriteActive],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(50),
            ),
            child: ThemeIconFactory.display(
              icon: Icons.wifi_off_rounded,
              size: 49,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            L10n.get("error_loading_listing_details"),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            L10n.get("error_internet_connection"),
            style: const TextStyle(fontSize: 14, color: AppColors.textLight70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          GhostButtonFactory.iconText(
            onPressed: onRetry,
            icon: Icons.refresh_rounded,
            text: L10n.get("retry"),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ],
      ),
    );
  }
}
