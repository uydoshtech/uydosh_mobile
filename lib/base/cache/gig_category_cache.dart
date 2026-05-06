import "package:uy_dosh/domain/models/gig/gig_category.dart";

/// Static cache for gig service categories, mirroring [AmenitiesCache] /
/// [LocationCache]: data lives on the client so the chip ribbon and the
/// category picker render instantly without waiting on a network round-trip.
///
/// Source of truth on the backend is the seed migration
/// `_0009_gig_categories_seed.js`. IDs here MUST match the rows produced by
/// that migration on a fresh DB (auto-incremented in the order the seed
/// inserts them).
///
/// ## Reordering as admin
/// Display order in the app is driven by the position of each entry in
/// [_categories]. Drag a `GigCategory(...)` row up or down in this list to
/// move the corresponding chip / picker entry. The `sortOrder` field is
/// re-derived from list position by [getOrdered] so you don't have to keep
/// the numbers in sync — just rearrange the list.
class GigCategoryCache {
  /// Categories in the order they should appear in the UI. The first entry
  /// is the leftmost chip in the hub ribbon and the topmost row in the
  /// publish-screen picker. Defaults to the order set in the seed
  /// migration; rearrange freely.
  static const List<GigCategory> _categories = [
    GigCategory(
      id: 1,
      code: "cleaning",
      nameUz: "Tozalash",
      nameRu: "Уборка",
      nameEn: "Cleaning",
      isActive: true,
    ),
    GigCategory(
      id: 2,
      code: "moving",
      nameUz: "Koʻchish",
      nameRu: "Переезд",
      nameEn: "Moving",
      isActive: true,
    ),
    GigCategory(
      id: 3,
      code: "repairs",
      nameUz: "Taʼmirlash",
      nameRu: "Ремонт и мастер на час",
      nameEn: "Repairs & Handyman",
      isActive: true,
    ),
    GigCategory(
      id: 4,
      code: "delivery",
      nameUz: "Yetkazib berish",
      nameRu: "Доставка",
      nameEn: "Delivery",
      isActive: true,
    ),
    GigCategory(
      id: 5,
      code: "tutoring",
      nameUz: "Repetitorlik",
      nameRu: "Репетиторы",
      nameEn: "Tutoring",
      isActive: true,
    ),
    GigCategory(
      id: 6,
      code: "beauty",
      nameUz: "Goʻzallik",
      nameRu: "Красота и уход",
      nameEn: "Beauty & Wellness",
      isActive: true,
    ),
    GigCategory(
      id: 7,
      code: "it_tech",
      nameUz: "IT va texnologiyalar",
      nameRu: "IT и техника",
      nameEn: "IT & Tech",
      isActive: true,
    ),
    GigCategory(
      id: 8,
      code: "events",
      nameUz: "Tadbirlar",
      nameRu: "Мероприятия",
      nameEn: "Events",
      isActive: true,
    ),
    GigCategory(
      id: 9,
      code: "auto",
      nameUz: "Avto xizmatlar",
      nameRu: "Авто-услуги",
      nameEn: "Auto Services",
      isActive: true,
    ),
    GigCategory(
      id: 10,
      code: "pets",
      nameUz: "Hayvonlar uchun",
      nameRu: "Уход за животными",
      nameEn: "Pet Care",
      isActive: true,
    ),
    GigCategory(
      id: 11,
      code: "other",
      nameUz: "Boshqa",
      nameRu: "Другое",
      nameEn: "Other",
      isActive: true,
    ),
  ];

  /// Active categories in their admin-defined display order. `sortOrder` on
  /// each returned instance reflects its index in [_categories], so call
  /// sites that already rely on `c.sortOrder` (e.g. legacy code paths)
  /// keep working without changes.
  static List<GigCategory> getOrdered() {
    final out = <GigCategory>[];
    for (var i = 0; i < _categories.length; i++) {
      final c = _categories[i];
      if (!c.isActive) continue;
      out.add(GigCategory(
        id: c.id,
        code: c.code,
        nameUz: c.nameUz,
        nameRu: c.nameRu,
        nameEn: c.nameEn,
        isActive: c.isActive,
        parentId: c.parentId,
        iconUrl: c.iconUrl,
        sortOrder: i,
      ));
    }
    return out;
  }

  /// All known categories, including inactive ones, in admin-defined order.
  /// Most callers want [getOrdered]; this is exposed for admin tooling.
  static List<GigCategory> getAll() => List<GigCategory>.unmodifiable(_categories);

  /// Look up a category by its DB id. Returns `null` if the cache hasn't
  /// been told about that id (e.g. the backend grew a new category that
  /// the client build predates).
  static GigCategory? getById(int id) {
    for (final c in _categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Look up a category by its `code`. Useful for icon mapping and the few
  /// places the app stores a category by code rather than id.
  static GigCategory? getByCode(String code) {
    for (final c in _categories) {
      if (c.code == code) return c;
    }
    return null;
  }
}
