import "dart:ui" show ImageFilter;

import "package:cached_network_image/cached_network_image.dart";
import "package:flutter/material.dart";
import "package:flutter/widgets.dart";
import "package:smooth_page_indicator/smooth_page_indicator.dart";
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
                    final originalIndex = photos.indexOf(photo);
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
                                    sigmaX: 18,
                                    sigmaY: 18,
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: buildPhotoUrl(photo.photoUrl),
                                    fit: BoxFit.cover,
                                    memCacheWidth: 800,
                                    memCacheHeight: 800,
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
                                Center(
                                  child: CachedNetworkImage(
                                    imageUrl: buildPhotoUrl(photo.photoUrl),
                                    fit: BoxFit.contain,
                                    memCacheWidth: 1080,
                                    memCacheHeight: 1080,
                                    fadeInDuration:
                                        const Duration(milliseconds: 300),
                                    fadeInCurve: Curves.easeOut,
                                    placeholder: (context, url) =>
                                        const SizedBox.shrink(),
                                    errorWidget: (context, url, error) =>
                                        const SizedBox.shrink(),
                                  ),
                                ),
                                Positioned(
                                  bottom: 12,
                                  right: 12,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color:
                                          Colors.black.withValues(alpha: 0.6),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const ThemeIcon(
                                      Icons.fullscreen,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                if (orderedPhotos.length > 1)
                                  Positioned(
                                    top: 12,
                                    right: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.black.withValues(alpha: 0.6),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "${index + 1}/${orderedPhotos.length}",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
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
