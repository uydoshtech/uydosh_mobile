import "package:freezed_annotation/freezed_annotation.dart";

part "auth_response.freezed.dart";
part "auth_response.g.dart";

@freezed
abstract class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required String message,
    required User user,
    required String sessionToken,
    required bool requiresOTP,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}

@freezed
abstract class User with _$User {
  const factory User({
    required int id,
    required String email,
    @JsonKey(name: "created_at") required String createdAt, String? role,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}
