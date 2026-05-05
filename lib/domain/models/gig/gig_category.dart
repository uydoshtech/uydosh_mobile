/// Hand-rolled (non-freezed) DTO for `gig_categories`.
class GigCategory {
  const GigCategory({
    required this.id,
    required this.code,
    required this.nameUz,
    required this.nameRu,
    required this.nameEn,
    required this.isActive,
    this.parentId,
    this.iconUrl,
    this.sortOrder = 0,
  });

  factory GigCategory.fromJson(Map<String, dynamic> json) => GigCategory(
        id: (json["id"] as num).toInt(),
        parentId: (json["parent_id"] as num?)?.toInt(),
        code: json["code"] as String,
        nameUz: json["name_uz"] as String,
        nameRu: json["name_ru"] as String,
        nameEn: json["name_en"] as String,
        iconUrl: json["icon_url"] as String?,
        sortOrder: (json["sort_order"] as num?)?.toInt() ?? 0,
        isActive: json["is_active"] as bool? ?? true,
      );

  final int id;
  final int? parentId;
  final String code;
  final String nameUz;
  final String nameRu;
  final String nameEn;
  final String? iconUrl;
  final int sortOrder;
  final bool isActive;

  /// Localized name fallback chain: requested language → ru → en → uz.
  String localizedName(String language) {
    switch (language) {
      case "uz":
        return nameUz.isNotEmpty ? nameUz : nameRu;
      case "en":
        return nameEn.isNotEmpty ? nameEn : nameRu;
      case "ru":
      default:
        return nameRu.isNotEmpty ? nameRu : nameEn;
    }
  }
}
