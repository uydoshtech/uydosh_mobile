import "package:flutter/material.dart";
import "package:uy_dosh/domain/models/photo.dart";
import "package:uy_dosh/domain/models/photo_network_display.dart";
import "package:uy_dosh/presentation/widgets/common/detail_hosted_photo_gallery.dart";

/// Photo carousel section for listing detail screen — uses the shared
/// [DetailHostedPhotoGallery] chrome and carousel so gig offer detail stays
/// visually consistent.
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
    return DetailHostedPhotoGallery(
      orderedRawPhotoUrls:
          orderedPhotos.map((photo) => photo.networkDisplayPhotoUrl).toList(),
      pageController: pageController,
      buildPhotoUrl: buildPhotoUrl,
      onPhotoTapCarouselIndex: (carouselIndex) {
        final tapped = orderedPhotos[carouselIndex];
        final originalIndex = photos.indexWhere((p) => p.id == tapped.id);
        onPhotoTap(originalIndex >= 0 ? originalIndex : 0);
      },
    );
  }
}
