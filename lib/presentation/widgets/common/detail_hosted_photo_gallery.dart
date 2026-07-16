import "dart:ui";

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:smooth_page_indicator/smooth_page_indicator.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/utils/platform_device.dart";
import "package:uy_dosh/base/utils/ui_performance_policy.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_tile_shell.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_rendering.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_logo_spinner.dart";

/// Listing-style photo gallery tile: elevated shell, 16:9 carousel with blur fill,
/// fullscreen affordance, counter, pager dots — shared by [ListingDetailPhotoSection],
/// gig offer detail, etc.
class DetailHostedPhotoGallery extends StatelessWidget {
  const DetailHostedPhotoGallery({
    required this.orderedRawPhotoUrls,
    required this.pageController,
    required this.buildPhotoUrl,
    required this.onPhotoTapCarouselIndex,
    this.useTileShell = true,
    this.topRightOverlay,
    super.key,
  });

  final List<String> orderedRawPhotoUrls;
  final PageController pageController;
  final String Function(String rawPhotoUrl) buildPhotoUrl;
  final void Function(int carouselIndex) onPhotoTapCarouselIndex;
  final bool useTileShell;

  /// Optional widget pinned to the carousel's top-right (e.g. favorite heart).
  /// When set and there are multiple photos, the page counter moves to top-left.
  final Widget? topRightOverlay;

  @override
  Widget build(BuildContext context) {
    final n = orderedRawPhotoUrls.length;
    assert(n > 0, "DetailHostedPhotoGallery requires at least one photo URL.");

    final dotStrokeColor = _detailPhotoCarouselDotStrokeColor(context);

    final content = Padding(
      padding: useTileShell
          ? const EdgeInsets.fromLTRB(5, 6, 5, 5)
          : EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                PageView.builder(
                  controller: pageController,
                  itemCount: n,
                  itemBuilder: (context, index) {
                    final rawUrl = orderedRawPhotoUrls[index];
                    final counterOnLeft = topRightOverlay != null && n > 1;
                    return GestureDetector(
                      onTap: () => onPhotoTapCarouselIndex(index),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Padding(
                          padding: useTileShell
                              ? const EdgeInsets.symmetric(horizontal: 8)
                              : EdgeInsets.zero,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                _buildCoverFill(rawUrl),
                                ColoredBox(
                                  color: Colors.black.withValues(alpha: 0.12),
                                ),
                                Positioned.fill(
                                  child: CachedNetworkImage(
                                    imageUrl: buildPhotoUrl(rawUrl),
                                    fit: BoxFit.contain,
                                    memCacheWidth: 720,
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
                                  child: DetailPhotoGlassPill(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 4,
                                    ),
                                    child: ThemeIcon(
                                      Icons.fullscreen,
                                      color: Colors.white,
                                      useThemeColor: false,
                                      size: 18,
                                    ),
                                  ),
                                ),
                                if (n > 1)
                                  Positioned(
                                    top: 12,
                                    left: counterOnLeft ? 12 : null,
                                    right: counterOnLeft ? null : 12,
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
                if (topRightOverlay != null)
                  Positioned(
                    top: 12,
                    right: useTileShell ? 20 : 12,
                    child: topRightOverlay!,
                  ),
              ],
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
          ],
        ],
      ),
    );

    final gallery = useTileShell
        ? ListingDetailTileShell(
            useLiquidGlass:
                ThemeState().usesLiquidGlassChrome,
            child: content,
          )
        : content;

    return SizedBox(
      width: double.infinity,
      child: gallery,
    );
  }

  /// Cover-fill behind the [BoxFit.contain] foreground photo. For portrait
  /// photos this fills the empty side bars.
  ///
  /// [ImageFiltered] forces a per-frame blur layer that keeps the whole
  /// carousel tile from being raster-cached while the page scrolls, which is a
  /// significant cost on low-end Android. Skip the blur there and show a plain
  /// cover fill — the foreground photo still reads the same.
  Widget _buildCoverFill(String rawUrl) {
    return CachedNetworkImage(
      imageUrl: buildPhotoUrl(rawUrl),
      fit: BoxFit.cover,
      memCacheWidth: 320,
      fadeInDuration: const Duration(milliseconds: 300),
      fadeInCurve: Curves.easeOut,
      // Blur only the loaded photo via [imageBuilder] so the loading
      // placeholder (logo spinner) and error icon stay sharp.
      imageBuilder: (context, imageProvider) {
        final image = Image(image: imageProvider, fit: BoxFit.cover);
        if (isAndroidDevice) return image;
        return ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: image,
        );
      },
      placeholder: (context, url) => Container(
        color: Colors.grey[200],
        child: const Center(
          child: UydoshLogoSpinner(onLightBackground: true),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey[300],
        child: ThemeIcon(
          Icons.image_not_supported,
          color: Colors.grey[600],
          size: 48,
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
    return DetailPhotoGlassPill(
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

/// Liquid-glass pill for controls overlaid on detail photo carousels.
class DetailPhotoGlassPill extends StatelessWidget {
  const DetailPhotoGlassPill({
    required this.child,
    required this.padding,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AnimationSettingsState(),
      builder: (context, _) {
        // The pill's [BackdropFilter] floats over the scrolling carousel, so it
        // re-blurs every frame. Skip it on Android (low-end GPU cost); use a
        // solid pill fill there instead of a translucent gradient.
        final enableGlass = LiquidGlassRendering.effectsEnabled(context);
        final solidSurface = UiPerformancePolicy.solidColorsPreferredForDevice;

        const radius = BorderRadius.all(Radius.circular(999));

        final pillDecoration = solidSurface
            ? BoxDecoration(
                borderRadius: radius,
                color: const Color(0xFF2A2A2A),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.18),
                  width: 0.6,
                ),
              )
            : BoxDecoration(
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
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: solidSurface
                ? const [
                    BoxShadow(
                      color: Color(0x33000000),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: Color(0x4D000000),
                      blurRadius: 14,
                      offset: Offset(0, 4),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: LiquidGlassRendering.backdropBlur(
              enabled: enableGlass && !solidSurface,
              sigma: LiquidGlassRendering.switchGlassBlurSigma,
              child: DecoratedBox(
                decoration: pillDecoration,
                child: content,
              ),
            ),
          ),
        );
      },
    );
  }
}
