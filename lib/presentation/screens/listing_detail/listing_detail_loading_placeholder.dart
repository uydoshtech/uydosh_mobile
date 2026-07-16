import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_config.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_u_spinner.dart";

/// Listing detail fetch / transition loading (shared initial + in-flight copy).
///
/// Uses the branded UyDosh "U" spinner pinned to the black-letter mark
/// (black "U" + black chimney over the fixed red roof) regardless of the app
/// theme, matching the web Mini App's listing-details loader, rather than the
/// theme-flipping rotating-house indicator used elsewhere.
class ListingDetailLoadingBody extends StatelessWidget {
  const ListingDetailLoadingBody({
    this.textStyle,
    super.key,
  });

  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const UydoshUSpinner(
            color: Colors.black,
            size: AppConfig.defaultLoadingIndicatorSize,
          ),
          const SizedBox(height: 16),
          Text(
            L10n.get("loading_listing_details"),
            style: textStyle ??
                TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
