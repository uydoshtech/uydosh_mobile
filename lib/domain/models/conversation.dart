import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uy_dosh/domain/models/listing.dart';
import 'package:uy_dosh/domain/models/user_profile.dart';
import 'package:uy_dosh/domain/models/message.dart';

part 'conversation.freezed.dart';
part 'conversation.g.dart';

@freezed
class Conversation with _$Conversation {
  const factory Conversation({
    required int id,
    @JsonKey(name: 'listing_id') required int listingId,
    @JsonKey(name: 'initiator_id') required int initiatorId,
    @JsonKey(name: 'participant_id') required int participantId,
    @JsonKey(name: 'last_message_at') String? lastMessageAt,
    @JsonKey(name: 'last_message_content') String? lastMessageContent,
    @JsonKey(name: 'last_message_sender_id') int? lastMessageSenderId,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
    // Related data
    Listing? listing,
    UserProfile? otherUser,
    @JsonKey(name: 'unread_count') int? unreadCount,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
}

@freezed
class ConversationSummary with _$ConversationSummary {
  const factory ConversationSummary({
    required int id,
    @JsonKey(name: 'listing_id') required int listingId,
    @JsonKey(name: 'initiator_id') required int initiatorId,
    @JsonKey(name: 'participant_id') required int participantId,
    @JsonKey(name: 'last_message_at') String? lastMessageAt,
    @JsonKey(name: 'last_message_content') String? lastMessageContent,
    @JsonKey(name: 'last_message_sender_id') int? lastMessageSenderId,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
    // Summary data
    @JsonKey(name: 'listing_title') String? listingTitle,
    @JsonKey(name: 'listing_min_price') int? listingMinPrice,
    @JsonKey(name: 'listing_max_price') int? listingMaxPrice,
    @JsonKey(name: 'other_user_name') String? otherUserName,
    @JsonKey(name: 'other_user_avatar') String? otherUserAvatar,
    @JsonKey(name: 'unread_count') int? unreadCount,
    // Location and metro station data
    @JsonKey(name: 'listing_subway_line_id') int? listingSubwayLineId,
    @JsonKey(name: 'listing_subway_station_id') int? listingSubwayStationId,
    @JsonKey(name: 'listing_location_id') int? listingLocationId,
    @JsonKey(name: 'subway_station_name_uz') String? subwayStationNameUz,
    @JsonKey(name: 'subway_station_name_ru') String? subwayStationNameRu,
    @JsonKey(name: 'subway_station_name_en') String? subwayStationNameEn,
    @JsonKey(name: 'subway_station_line') int? subwayStationLine,
    @JsonKey(name: 'subway_station_ordinal') int? subwayStationOrdinal,
    @JsonKey(name: 'location_name_uz') String? locationNameUz,
    @JsonKey(name: 'location_name_ru') String? locationNameRu,
    @JsonKey(name: 'location_name_en') String? locationNameEn,
    @JsonKey(name: 'location_short_name_uz') String? locationShortNameUz,
    @JsonKey(name: 'location_short_name_ru') String? locationShortNameRu,
    @JsonKey(name: 'location_short_name_en') String? locationShortNameEn,
  }) = _ConversationSummary;

  factory ConversationSummary.fromJson(Map<String, dynamic> json) =>
      _$ConversationSummaryFromJson(json);
}
