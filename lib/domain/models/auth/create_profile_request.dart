import 'package:json_annotation/json_annotation.dart';
import 'package:uy_dosh/base/api/client/json_encodable.dart';

part 'create_profile_request.g.dart';

@JsonSerializable(includeIfNull: true)
class CreateProfileRequest implements IJsonEncodable {
  const CreateProfileRequest({
    @JsonKey(name: 'userId') required this.userId,
    required this.name,
    required this.gender,
    @JsonKey(name: 'universityId') this.universityId,
    @JsonKey(name: 'regionId') this.regionId,
  });

  @JsonKey(name: 'userId')
  final int userId;
  final String name;
  final int gender;
  @JsonKey(name: 'universityId')
  final int? universityId;
  @JsonKey(name: 'regionId')
  final int? regionId;

  factory CreateProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateProfileRequestFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CreateProfileRequestToJson(this);
}
