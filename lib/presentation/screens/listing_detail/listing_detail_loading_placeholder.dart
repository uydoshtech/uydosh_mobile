import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_config.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_u_spinner.dart";

/// Listing detail fetch / transition loading (shared initial + in-flight copy).
///
/// Uses the branded UyDosh "U" spinner with a theme-aware glyph color
/// (white "U" + chimney on blue/dark themes, black on light) over the fixed
/// red roof.
class ListingDetailLoadingBody extends StatelessWidget {
  const ListingDetailLoadingBody({
    this.textStyle,
    super.key,
  });

  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, _) {
        final glyphColor =
            ThemeState().isLightTheme ? Colors.black : Colors.white;
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              UydoshUSpinner(
                color: glyphColor,
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
      },
    );
  }
}
