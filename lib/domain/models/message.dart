import "package:freezed_annotation/freezed_annotation.dart";
import "package:uy_dosh/domain/models/message_attachment.dart";
import "package:uy_dosh/domain/models/message_sender.dart";

part "message.freezed.dart";
part "message.g.dart";

/// Aggregated reaction counts for a chat message (from API `reactions` array).
class MessageReactionCount {
  const MessageReactionCount({required this.reaction, required this.count});
  final String reaction;
  final int count;
  factory MessageReactionCount.fromJson(Map<String, dynamic> json) {
    return MessageReactionCount(
      reaction: json["reaction"] as String,
      count: (json["count"] as num).toInt(),
    );
  }
}

class MessageListingRating {
  const MessageListingRating({
    required this.count,
    this.average,
    this.myStars,
    this.myReasons = const [],
    this.myCategoryRatings = const {},
    this.myVerdict,
    this.distribution = const {},
  });

  final double? average;
  final int count;
  final int? myStars;
  final List<String> myReasons;
  final Map<String, int> myCategoryRatings;
  final String? myVerdict;
  final Map<int, int> distribution;

  factory MessageListingRating.fromJson(Map<String, dynamic> json) {
    final rawDistribution = json["distribution"];
    final distribution = <int, int>{};
    if (rawDistribution is Map) {
      rawDistribution.forEach((key, value) {
        final star = int.tryParse(key.toString());
        if (star == null) return;
        distribution[star] = (value as num?)?.toInt() ?? 0;
      });
    }
    final rawCategoryRatings = json["my_category_ratings"];
    final categoryRatings = <String, int>{};
    if (rawCategoryRatings is Map) {
      rawCategoryRatings.forEach((key, value) {
        categoryRatings[key.toString()] = (value as num?)?.toInt() ?? 0;
      });
    }
    return MessageListingRating(
      average: (json["average"] as num?)?.toDouble(),
      count: (json["count"] as num?)?.toInt() ?? 0,
      myStars: (json["my_stars"] as num?)?.toInt(),
      myReasons: (json["my_reasons"] as List?)?.whereType<String>().toList() ??
          const [],
      myCategoryRatings: categoryRatings,
      myVerdict: json["my_verdict"] as String?,
      distribution: distribution,
    );
  }
}

MessageListingRating? _listingRatingFromJson(dynamic value) {
  if (value == null || value is! Map) return null;
  return MessageListingRating.fromJson(Map<String, dynamic>.from(value));
}

Map<String, dynamic>? _listingRatingToJson(MessageListingRating? value) {
  if (value == null) return null;
  return {
    "average": value.average,
    "count": value.count,
    "my_stars": value.myStars,
    "my_reasons": value.myReasons,
    "my_category_ratings": value.myCategoryRatings,
    "my_verdict": value.myVerdict,
    "distribution": value.distribution.map(
      (key, val) => MapEntry(key.toString(), val),
    ),
  };
}

List<MessageReactionCount>? _messageReactionsFromJson(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is! List) {
    return null;
  }
  return value
      .map(
        (e) => MessageReactionCount.fromJson(e as Map<String, dynamic>),
      )
      .toList();
}

List<Map<String, dynamic>>? _messageReactionsToJson(
  List<MessageReactionCount>? value,
) {
  if (value == null) {
    return null;
  }
  return value
      .map(
        (e) => <String, dynamic>{"reaction": e.reaction, "count": e.count},
      )
      .toList();
}

@freezed
abstract class Message with _$Message {
  const factory Message({
    required int id,
    @JsonKey(name: "conversation_id") required int conversationId,
    @JsonKey(name: "sender_id") required int senderId,
    required String content,
    @JsonKey(name: "message_type") required String messageType,
    @JsonKey(name: "created_at") required String createdAt,
    @JsonKey(name: "updated_at") required String updatedAt,
    @JsonKey(name: "reply_to_message_id") int? replyToMessageId,
    @JsonKey(name: "is_edited") bool? isEdited,
    @JsonKey(name: "edited_at") String? editedAt,
    @JsonKey(name: "is_deleted") bool? isDeleted,
    @JsonKey(name: "deleted_at") String? deletedAt,
    @JsonKey(name: "previous_content") String? previousContent,
    // Related data
    MessageSender? sender,
    List<MessageAttachment>? attachments,
    @JsonKey(name: "reply_to_message") Message? replyToMessage,
    @JsonKey(name: "is_read_by_current_user") bool? isReadByCurrentUser,
    @JsonKey(name: "is_read_by_recipient") bool? isReadByRecipient,
    @JsonKey(
      name: "reactions",
      fromJson: _messageReactionsFromJson,
      toJson: _messageReactionsToJson,
    )
    List<MessageReactionCount>? reactions,
    @JsonKey(name: "my_reaction") String? myReaction,
    @JsonKey(
      name: "listing_rating",
      fromJson: _listingRatingFromJson,
      toJson: _listingRatingToJson,
    )
    MessageListingRating? listingRating,
  }) = _Message;

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);
}

/// Whether a message should show edit UI / “edited” affordances.
extension MessageVisibleEditState on Message {
  bool get isVisiblyEdited {
    if (isEdited == true) return true;
    final at = editedAt;
    if (at != null && at.isNotEmpty) return true;
    final prev = previousContent;
    return prev != null && prev.isNotEmpty;
  }
}

@freezed
sealed class MessageType with _$MessageType {
  const factory MessageType.text() = _Text;
  const factory MessageType.image() = _Image;
  const factory MessageType.file() = _File;
  const factory MessageType.location() = _Location;
  const factory MessageType.system() = _System;

  const MessageType._();

  factory MessageType.fromString(String type) {
    switch (type) {
      case "text":
        return const MessageType.text();
      case "image":
        return const MessageType.image();
      case "file":
        return const MessageType.file();
      case "location":
        return const MessageType.location();
      case "system":
        return const MessageType.system();
      default:
        return const MessageType.text();
    }
  }

  String get value {
    return when(
      text: () => "text",
      image: () => "image",
      file: () => "file",
      location: () => "location",
      system: () => "system",
    );
  }
}
