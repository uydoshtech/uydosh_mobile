import 'package:freezed_annotation/freezed_annotation.dart';

part 'photo.freezed.dart';
part 'photo.g.dart';

@freezed
class Photo with _$Photo {
  const factory Photo({
    required int id,
    @JsonKey(name: 'photo_url') required String photoUrl,
    @JsonKey(name: 'photo_order') required int photoOrder,
    @JsonKey(name: 'is_primary') required bool isPrimary,
    @JsonKey(name: 'created_at') required String createdAt,
  }) = _Photo;

  factory Photo.fromJson(Map<String, dynamic> json) => _$PhotoFromJson(json);
}
