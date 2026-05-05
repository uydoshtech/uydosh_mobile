import "dart:ui" show ImageFilter;

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:smooth_page_indicator/smooth_page_indicator.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";
import "package:uy_dosh/domain/models/photo.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_tile_shell.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// Photo carousel section for listing detail screen.
class ListingDetailPhotoSection extends StatelessWidget {
  const ListingDetailPhotoSection({
    required this.photos,
    required this.orderedPhotos,
    required this.pageController,
    required this.buildPhotoUrl,
    required this.onPhotoTap,
    super.key,
  });

  final List<Photo> photos;
  final List<Photo> orderedPhotos;
  final PageController pageController;
  final String Function(String photoUrl) buildPhotoUrl;
  final void Function(int originalIndex) onPhotoTap;

  @override
  Widget build(BuildContext context) {
    // Avoid O(n) lookups in the PageView builder.
    final originalIndexByUrl = <String, int>{};
    for (var i = 0; i < photos.length; i++) {
      originalIndexByUrl.putIfAbsent(photos[i].photoUrl, () => i);
    }

    return SizedBox(
      width: double.infinity,
      child: ListingDetailTileShell(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(5, 6, 5, 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                // A stable frame prevents “squeezing” artifacts and avoids hard-cropping
                // portrait photos too aggressively. 16:9 reads well for listing galleries.
                aspectRatio: 16 / 9,
                child: PageView.builder(
                  controller: pageController,
                  itemCount: orderedPhotos.length,
                  onPageChanged: (_) {},
                  itemBuilder: (context, index) {
                    final photo = orderedPhotos[index];
                    final originalIndex = originalIndexByUrl[photo.photoUrl] ?? 0;
                    return GestureDetector(
                      onTap: () =>
                          onPhotoTap(originalIndex >= 0 ? originalIndex : 0),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Background fill (blurred + slightly dimmed) so portrait photos
                                // look good in a horizontal carousel without distortion.
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
                                    imageUrl: buildPhotoUrl(photo.photoUrl),
                                    fit: BoxFit.cover,
                                    // Background is blurred at sigma:18, so
                                    // sub-300px detail is invisible. 320 is a
                                    // ~4× memory reduction over the prior 800
                                    // (~0.4 MB vs ~2.5 MB per cached entry).
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
                                // Foreground: the real photo, never distorted.
                                // 720 fits the detail card at typical phone
                                // density without overpaying for unused
                                // resolution (full-screen viewer keeps 1080).
                                Center(
                                  child: CachedNetworkImage(
                                    imageUrl: buildPhotoUrl(photo.photoUrl),
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
                                if (orderedPhotos.length > 1)
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: _PhotoCounterPill(
                                      text:
                                          "${index + 1}/${orderedPhotos.length}",
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
              if (orderedPhotos.length > 1) ...[
                const SizedBox(height: 10),
                Center(
                  child: SmoothPageIndicator(
                    controller: pageController,
                    count: orderedPhotos.length,
                    effect: WormEffect(
                      dotColor: ListingDetailThemeHelper.iconColor,
                      activeDotColor: ListingDetailThemeHelper.iconColor,
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
}

/// Liquid-glass page-counter pill (e.g. "2/5") shown over the photo carousel.
///
/// Thin wrapper around [_PhotoGlassPill] that renders the counter text with
/// the shared 3D glass treatment so it visually matches the fullscreen
/// button at the opposite corner.
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

/// Shared liquid-glass pill used for overlay chrome on the photo carousel
/// (page counter, fullscreen affordance, etc.).
///
/// Mirrors the translucent / blurred / hairline-bordered treatment used by
/// `UyDoshReviewPillButton` so overlays read as glass surfaces floating
/// above the photo rather than opaque black chips. The `BackdropFilter`
/// blur is gated on `AnimationSettingsState` (and the platform's "reduce
/// motion" flag) so the cheap solid-fill fallback is used when UI
/// animations are disabled.
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

        // Translucent top→bottom wash: a thin white highlight at the top
        // softens into a darker tint at the bottom, giving the pill a
        // subtle "liquid glass" highlight without an opaque fill.
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
