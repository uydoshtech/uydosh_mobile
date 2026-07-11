import "package:freezed_annotation/freezed_annotation.dart";

part "otp_code.freezed.dart";
part "otp_code.g.dart";

@freezed
abstract class OtpCode with _$OtpCode {
  const factory OtpCode({
    required int id,
    required String email,
    required String code, // 4-digit code
    required String type, // 'email_verification', 'password_reset', 'login'
    @JsonKey(name: "is_used") required bool isUsed,
    @JsonKey(name: "expires_at") required String expiresAt,
    @JsonKey(name: "created_at") required String createdAt,
    @JsonKey(name: "updated_at") required String updatedAt,
  }) = _OtpCode;

  factory OtpCode.fromJson(Map<String, dynamic> json) =>
      _$OtpCodeFromJson(json);
}

// Helper class for OTP types
class OtpTypes {
  static const String emailVerification = "email_verification";
  static const String passwordReset = "password_reset";
  static const String login = "login";
}
