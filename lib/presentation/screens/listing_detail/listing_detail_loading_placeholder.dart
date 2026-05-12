import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";

/// Listing detail fetch / transition loading (shared initial + in-flight copy).
class ListingDetailLoadingBody extends StatelessWidget {
  const ListingDetailLoadingBody({
    this.textStyle,
    super.key,
  });

  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return CenteredHouseLoadingIndicator(
      text: L10n.get("loading_listing_details"),
      textStyle: textStyle,
    );
  }
}
