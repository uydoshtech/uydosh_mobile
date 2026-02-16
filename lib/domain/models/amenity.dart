import "package:freezed_annotation/freezed_annotation.dart";

part "amenity.freezed.dart";
part "amenity.g.dart";

@freezed
class Amenity with _$Amenity {
  const factory Amenity({
    required int id,
    String? code, // Made optional since backend doesn't always provide it
    @JsonKey(name: "name_en") required String nameEn,
    @JsonKey(name: "name_ru") required String nameRu,
    @JsonKey(name: "name_uz") required String nameUz,
    String? icon, // Added icon field from backend response
    @JsonKey(name: "created_at") String? createdAt,
    @JsonKey(name: "updated_at") String? updatedAt,
  }) = _Amenity;

  factory Amenity.fromJson(Map<String, dynamic> json) =>
      _$$AmenityImplFromJson(json);
}
