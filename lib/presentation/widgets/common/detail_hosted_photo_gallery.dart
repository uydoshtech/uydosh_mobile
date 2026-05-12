import "dart:ui" show ImageFilter;

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:smooth_page_indicator/smooth_page_indicator.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_tile_shell.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// Listing-style photo gallery tile: elevated shell, 16:9 carousel with blur fill,
/// fullscreen affordance, counter, pager dots — shared by [ListingDetailPhotoSection],
/// gig offer detail, etc.
class DetailHostedPhotoGallery extends StatelessWidget {
  const DetailHostedPhotoGallery({
    required this.orderedRawPhotoUrls,
    required this.pageController,
    required this.buildPhotoUrl,
    required this.onPhotoTapCarouselIndex,
    super.key,
  });

  final List<String> orderedRawPhotoUrls;
  final PageController pageController;
  final String Function(String rawPhotoUrl) buildPhotoUrl;
  final void Function(int carouselIndex) onPhotoTapCarouselIndex;

  @override
  Widget build(BuildContext context) {
    final n = orderedRawPhotoUrls.length;
    assert(n > 0, "DetailHostedPhotoGallery requires at least one photo URL.");

    final dotStrokeColor = _detailPhotoCarouselDotStrokeColor(context);

    return SizedBox(
      width: double.infinity,
      child: ListingDetailTileShell(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 6, 5, 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: PageView.builder(
                  controller: pageController,
                  itemCount: n,
                  itemBuilder: (context, index) {
                    final rawUrl = orderedRawPhotoUrls[index];
                    return GestureDetector(
                      onTap: () => onPhotoTapCarouselIndex(index),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ImageFiltered(
                                  imageFilter: ImageFilter.blur(
                                    sigmaX: (AnimationSettingsState()
                                                .uiAnimationsEnabled &&
                                            !(MediaQuery.maybeOf(context)
                                                    ?.disableAnimations ??
                                                false))
                                        ? 18
                                        : 0,
                                    sigmaY: (AnimationSettingsState()
                                                .uiAnimationsEnabled &&
                                            !(MediaQuery.maybeOf(context)
                                                    ?.disableAnimations ??
                                                false))
                                        ? 18
                                        : 0,
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: buildPhotoUrl(rawUrl),
                                    fit: BoxFit.cover,
                                    memCacheWidth: 320,
                                    memCacheHeight: 320,
                                    fadeInDuration:
                                        const Duration(milliseconds: 300),
                                    fadeInCurve: Curves.easeOut,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[200],
                                      child: const Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Container(
                                      color: Colors.grey[300],
                                      child: ThemeIcon(
                                        Icons.image_not_supported,
                                        color: Colors.grey[600],
                                        size: 48,
                                      ),
                                    ),
                                  ),
                                ),
                                ColoredBox(
                                  color: Colors.black.withValues(alpha: 0.12),
                                ),
                                Positioned.fill(
                                  child: CachedNetworkImage(
                                    imageUrl: buildPhotoUrl(rawUrl),
                                    fit: BoxFit.contain,
                                    memCacheWidth: 720,
                                    memCacheHeight: 720,
                                    fadeInDuration:
                                        const Duration(milliseconds: 300),
                                    fadeInCurve: Curves.easeOut,
                                    placeholder: (context, url) =>
                                        const SizedBox.shrink(),
                                    errorWidget: (context, url, error) =>
                                        const SizedBox.shrink(),
                                  ),
                                ),
                                const Positioned(
                                  bottom: 12,
                                  right: 12,
                                  child: _PhotoGlassPill(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 4,
                                    ),
                                    child: ThemeIcon(
                                      Icons.fullscreen,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                if (n > 1)
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: _PhotoCounterPill(
                                      text: "${index + 1}/$n",
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              if (n > 1) ...[
                const SizedBox(height: 10),
                Center(
                  child: SmoothPageIndicator(
                    controller: pageController,
                    count: n,
                    effect: WormEffect(
                      dotColor: dotStrokeColor,
                      activeDotColor: dotStrokeColor,
                      dotHeight: 8,
                      dotWidth: 8,
                      spacing: 8,
                      paintStyle: PaintingStyle.stroke,
                      strokeWidth: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Same stroke/dot colors as legacy [ListingDetailPhotoSection] worm indicator.
  static Color _detailPhotoCarouselDotStrokeColor(BuildContext context) {
    if (ThemeState().isLightTheme) return Colors.black;
    if (ThemeState().isBlueTheme) return Colors.white;
    return AppColors.primary;
  }
}

/// Liquid-glass page-counter pill over the carousel.
class _PhotoCounterPill extends StatelessWidget {
  const _PhotoCounterPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return _PhotoGlassPill(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.3,
          height: 1.0,
        ),
      ),
    );
  }
}

class _PhotoGlassPill extends StatelessWidget {
  const _PhotoGlassPill({
    required this.child,
    required this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AnimationSettingsState(),
      builder: (context, _) {
        final disableAnimations =
            MediaQuery.maybeOf(context)?.disableAnimations ?? false;
        final enableGlass =
            AnimationSettingsState().uiAnimationsEnabled && !disableAnimations;

        const radius = BorderRadius.all(Radius.circular(999));

        final glassDecoration = BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(alpha: 0.18),
              Colors.black.withValues(alpha: 0.38),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.28),
            width: 0.6,
          ),
        );

        final content = Padding(
          padding: padding,
          child: child,
        );

        return DecoratedBox(
          decoration: const BoxDecoration(
            borderRadius: radius,
            boxShadow: [
              BoxShadow(
                color: Color(0x4D000000),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: enableGlass
                ? BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                    child: DecoratedBox(
                      decoration: glassDecoration,
                      child: content,
                    ),
                  )
                : DecoratedBox(
                    decoration: glassDecoration,
                    child: content,
                  ),
          ),
        );
      },
    );
  }
}
