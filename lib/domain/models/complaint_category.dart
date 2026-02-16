import "package:freezed_annotation/freezed_annotation.dart";

part "complaint_category.freezed.dart";
part "complaint_category.g.dart";

@freezed
class ComplaintCategory with _$ComplaintCategory {
  const factory ComplaintCategory({
    @JsonKey(name: "name_uz") required String nameUz, @JsonKey(name: "name_ru") required String nameRu, @JsonKey(name: "name_en") required String nameEn, int? id,
    @JsonKey(name: "created_at") String? createdAt,
    @JsonKey(name: "updated_at") String? updatedAt,
  }) = _ComplaintCategory;

  factory ComplaintCategory.fromJson(Map<String, dynamic> json) =>
      _$ComplaintCategoryFromJson(json);
}
