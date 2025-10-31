import 'package:uy_dosh/domain/models/listing.dart';
import 'package:uy_dosh/domain/models/listing_detail.dart';

class ListingUtils {
  /// Returns true if the listing is featured (featured_at is not null)
  static bool isCurrentlyFeatured(Listing listing) {
    return listing.featuredAt != null;
  }

  /// Returns true if the listing detail is featured (featured_at is not null)
  static bool isCurrentlyFeaturedDetail(ListingDetail listingDetail) {
    return listingDetail.featuredAt != null;
  }
}
