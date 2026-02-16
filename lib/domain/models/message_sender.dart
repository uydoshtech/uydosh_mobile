import "package:freezed_annotation/freezed_annotation.dart";

part "message_sender.freezed.dart";
part "message_sender.g.dart";

@freezed
class MessageSender with _$MessageSender {
  const factory MessageSender({
    required int id,
    required String email,
    @JsonKey(name: "firebase_uid") required String firebaseUid,
    @JsonKey(name: "telegram_id") String? telegramId,
    MessageSenderProfile? profile,
  }) = _MessageSender;

  factory MessageSender.fromJson(Map<String, dynamic> json) =>
      _$MessageSenderFromJson(json);
}

@freezed
class MessageSenderProfile with _$MessageSenderProfile {
  const factory MessageSenderProfile({
    String? name,
    @JsonKey(name: "avatar_url") String? avatarUrl,
  }) = _MessageSenderProfile;

  factory MessageSenderProfile.fromJson(Map<String, dynamic> json) =>
      _$MessageSenderProfileFromJson(json);
}
