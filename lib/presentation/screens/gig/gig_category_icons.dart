import "package:flutter/material.dart";
import "package:uy_dosh/domain/models/gig/gig_category.dart";

/// Maps a gig category `code` to a [Material] icon. Falls back to a generic
/// handyman icon for unknown codes (e.g. categories added on the backend
/// after the client was built).
///
/// Codes mirror the seed migration `_0009_gig_categories_seed.js`.
IconData gigCategoryIcon(String? code) {
  switch (code) {
    case "cleaning":
      return Icons.cleaning_services_rounded;
    case "moving":
      return Icons.local_shipping_rounded;
    case "repairs":
      return Icons.handyman_rounded;
    case "delivery":
      return Icons.delivery_dining_rounded;
    case "tutoring":
      return Icons.menu_book_rounded;
    case "beauty":
      return Icons.spa_rounded;
    case "it_tech":
      return Icons.computer_rounded;
    case "events":
      return Icons.celebration_rounded;
    case "auto":
      return Icons.directions_car_rounded;
    case "pets":
      return Icons.pets_rounded;
    case "other":
      return Icons.more_horiz_rounded;
    default:
      return Icons.handyman_outlined;
  }
}

extension GigCategoryIconX on GigCategory {
  IconData get icon => gigCategoryIcon(code);
}
