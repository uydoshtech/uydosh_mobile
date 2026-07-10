import "package:uy_dosh/domain/constants/listing_type_ids.dart";

/// Role buckets used for first-time search / ribbon defaults.
abstract final class UserRoleCategories {
  static bool isTenantLike(String? role) =>
      role == "tenant" || role == "service_requester";

  static bool isLandlordLike(String? role) =>
      role == "landlord" || role == "service_provider";
}

/// First-time (or reset) search filter defaults for a user category.
class SearchFilterDefaults {
  const SearchFilterDefaults({
    required this.uiListingTypeId,
    required this.searchListingTypeIds,
    required this.minPrice,
    required this.maxPrice,
    this.gender,
  });

  /// Listing type shown in the search picker (ribbon anchor).
  final int uiListingTypeId;

  /// Listing types queried by the home feed / search APIs.
  final List<int> searchListingTypeIds;

  final double minPrice;
  final double maxPrice;

  /// Profile gender when available (1 male, 2 female).
  final int? gender;

  bool get hasMultiListingTypeSearch => searchListingTypeIds.length > 1;

  List<int>? get multiSearchListingTypeIds =>
      hasMultiListingTypeSearch ? List<int>.from(searchListingTypeIds) : null;

  int? get singleSearchListingTypeId => searchListingTypeIds.length == 1
      ? searchListingTypeIds.first
      : null;
}

/// Pure role → defaults mapping. No persistence or UI side effects.
abstract final class SearchFilterDefaultsPolicy {
  static const double defaultMinPrice = 10.0;
  static const double defaultMaxPrice = 500.0;

  static SearchFilterDefaults forRole(String? role, {int? profileGender}) {
    if (UserRoleCategories.isTenantLike(role)) {
      return _tenantLike(profileGender);
    }
    if (UserRoleCategories.isLandlordLike(role)) {
      return _landlordLike(profileGender);
    }
    return _tenantLike(profileGender);
  }

  static SearchFilterDefaults _tenantLike(int? profileGender) {
    return SearchFilterDefaults(
      uiListingTypeId: ListingTypeIds.roommateNeeded,
      searchListingTypeIds: const [ListingTypeIds.roommateNeeded],
      minPrice: defaultMinPrice,
      maxPrice: defaultMaxPrice,
      gender: profileGender,
    );
  }

  static SearchFilterDefaults _landlordLike(int? profileGender) {
    return SearchFilterDefaults(
      uiListingTypeId: ListingTypeIds.roomNeeded,
      searchListingTypeIds: List<int>.from(
        ListingTypeIds.landlordDemandListingTypeIds,
      ),
      minPrice: defaultMinPrice,
      maxPrice: defaultMaxPrice,
      gender: profileGender,
    );
  }

  /// Landlords who saved room-only filters before multi-type ids shipped.
  static bool shouldUpgradeLegacyLandlordSearch({
    required String? role,
    required int uiListingTypeId,
    required List<int> searchListingTypeIds,
    required bool hadExplicitListingTypeIds,
  }) {
    if (hadExplicitListingTypeIds) return false;
    if (!UserRoleCategories.isLandlordLike(role)) return false;
    if (uiListingTypeId != ListingTypeIds.roomNeeded) return false;
    if (searchListingTypeIds.length != 1) return false;
    return searchListingTypeIds.first == ListingTypeIds.roomNeeded;
  }

  static List<int> landlordDemandListingTypeIds() =>
      List<int>.from(ListingTypeIds.landlordDemandListingTypeIds);
}

/// Parses / encodes persisted multi-type listing filters.
abstract final class SearchFilterListingTypeIdsCodec {
  static const prefsKey = "search_listing_type_ids";
  static const serverKey = "listing_type_ids";
  static const legacyBundleKey = "landlord_demand_bundle";

  static List<int> sanitizeIds(Iterable<int> raw) {
    final out = <int>[];
    for (final id in raw) {
      if (id >= 1 && id <= 99 && !out.contains(id)) {
        out.add(id);
      }
    }
    return out;
  }

  static List<int> fromPrefsString(String? raw, {required int fallbackUiTypeId}) {
    final fallback = fallbackUiTypeId > 0 ? [fallbackUiTypeId] : <int>[];
    if (raw == null || raw.trim().isEmpty) {
      return fallback;
    }
    final parsed = sanitizeIds(
      raw.split(",").map((part) => int.tryParse(part.trim())).whereType<int>(),
    );
    return parsed.isEmpty ? fallback : parsed;
  }

  static String toPrefsString(List<int> ids) => sanitizeIds(ids).join(",");

  static List<int> fromServerJson(
    Map<String, dynamic> json, {
    required int fallbackUiTypeId,
  }) {
    final raw = json[serverKey];
    if (raw is List) {
      final parsed = sanitizeIds(
        raw.map((e) => e is num ? e.toInt() : int.tryParse("$e")).whereType<int>(),
      );
      if (parsed.isNotEmpty) return parsed;
    }

    final legacyBundle = json[legacyBundleKey];
    if (legacyBundle == true) {
      return SearchFilterDefaultsPolicy.landlordDemandListingTypeIds();
    }

    final single = json["listing_type_id"];
    if (single is num && single.toInt() > 0) {
      return [single.toInt()];
    }

    return fallbackUiTypeId > 0 ? [fallbackUiTypeId] : [];
  }

  static List<int>? toServerJson(List<int> ids, {required int uiListingTypeId}) {
    final sanitized = sanitizeIds(ids);
    if (sanitized.isEmpty) return null;
    if (sanitized.length == 1 && sanitized.first == uiListingTypeId) {
      return null;
    }
    return sanitized;
  }
}
