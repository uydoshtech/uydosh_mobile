import "package:freezed_annotation/freezed_annotation.dart";

part "message_sender.freezed.dart";
part "message_sender.g.dart";

@freezed
abstract class MessageSender with _$MessageSender {
  const factory MessageSender({
    required int id,
    // All three identity fields are independently nullable because a user may
    // have signed in via only one of Google (email + firebase_uid), Phone
    // (firebase_uid + phone_number), or Telegram (telegram_id). The backend
    // returns whichever are present and `null` for the rest.
    String? email,
    @JsonKey(name: "firebase_uid") String? firebaseUid,
    @JsonKey(name: "telegram_id") String? telegramId,
    @JsonKey(name: "phone_number") String? phoneNumber,
    MessageSenderProfile? profile,
  }) = _MessageSender;

  factory MessageSender.fromJson(Map<String, dynamic> json) =>
      _$MessageSenderFromJson(json);
}

@freezed
abstract class MessageSenderProfile with _$MessageSenderProfile {
  const factory MessageSenderProfile({
    String? name,
    @JsonKey(name: "avatar_url") String? avatarUrl,
  }) = _MessageSenderProfile;

  factory MessageSenderProfile.fromJson(Map<String, dynamic> json) =>
      _$MessageSenderProfileFromJson(json);
}
