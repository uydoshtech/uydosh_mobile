import "package:freezed_annotation/freezed_annotation.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/models/user_profile.dart";

part "conversation.freezed.dart";
part "conversation.g.dart";

@freezed
class Conversation with _$Conversation {
  const factory Conversation({
    required int id,
    @JsonKey(name: "initiator_id") required int initiatorId,
    @JsonKey(name: "participant_id") required int participantId,
    @JsonKey(name: "is_active") required bool isActive,
    @JsonKey(name: "created_at") required String createdAt,
    @JsonKey(name: "updated_at") required String updatedAt,
    // Nullable since the gig-module conversations (`context_type` =
    // `gig_request` / `gig_offer` / `gig_booking`) don't carry a listing.
    // Legacy listing chats keep `listing_id` populated alongside
    // `context_type='listing'` for back-compat with grouped views.
    @JsonKey(name: "listing_id") int? listingId,
    @JsonKey(name: "context_type") String? contextType,
    @JsonKey(name: "context_id") int? contextId,
    @JsonKey(name: "gig_request_id") int? gigRequestId,
    @JsonKey(name: "gig_request_title") String? gigRequestTitle,
    @JsonKey(name: "last_message_at") String? lastMessageAt,
    @JsonKey(name: "last_message_content") String? lastMessageContent,
    @JsonKey(name: "last_message_sender_id") int? lastMessageSenderId,
    @JsonKey(name: "archived_at") String? archivedAt,
    // Related data
    Listing? listing,
    UserProfile? otherUser,
    @JsonKey(name: "unread_count") int? unreadCount,
  }) = _Conversation;

  factory Conversation.fromJson(Map<String, dynamic> json) =>
      _$ConversationFromJson(json);
}

@freezed
class ConversationSummary with _$ConversationSummary {
  const factory ConversationSummary({
    required int id,
    @JsonKey(name: "initiator_id") required int initiatorId,
    @JsonKey(name: "participant_id") required int participantId,
    @JsonKey(name: "is_active") required bool isActive,
    @JsonKey(name: "created_at") required String createdAt,
    @JsonKey(name: "updated_at") required String updatedAt,
    @JsonKey(name: "listing_id") int? listingId,
    @JsonKey(name: "context_type") String? contextType,
    @JsonKey(name: "context_id") int? contextId,
    @JsonKey(name: "gig_request_id") int? gigRequestId,
    @JsonKey(name: "gig_request_title") String? gigRequestTitle,
    /// Gig category id (`gig_categories.id`) for gig-scoped chats.
    @JsonKey(name: "gig_category_id") int? gigCategoryId,
    /// Budget / pricing type from the gig surface (`open`, `hourly`, etc.).
    @JsonKey(name: "gig_budget_type") String? gigBudgetType,
    @JsonKey(name: "last_message_at") String? lastMessageAt,
    @JsonKey(name: "last_message_content") String? lastMessageContent,
    @JsonKey(name: "last_message_sender_id") int? lastMessageSenderId,
    @JsonKey(name: "archived_at") String? archivedAt,
    // Summary data
    @JsonKey(name: "listing_title") String? listingTitle,
    @JsonKey(name: "listing_type_id") int? listingTypeId,
    @JsonKey(name: "listing_gender") int? listingGender,
    @JsonKey(name: "listing_price") int? listingPrice,
    /// When set (e.g. gig-request chats), [ConversationPriceDisplay] shows this currency instead of y.e.
    @JsonKey(name: "price_currency_code") String? priceCurrencyCode,
    @JsonKey(name: "other_user_name") String? otherUserName,
    @JsonKey(name: "other_user_avatar") String? otherUserAvatar,
    /// Gig row author: task client for `gig_request`, provider for `gig_offer` / `gig_booking`.
    @JsonKey(name: "gig_owner_name") String? gigOwnerName,
    @JsonKey(name: "gig_owner_avatar") String? gigOwnerAvatar,
    @JsonKey(name: "unread_count") int? unreadCount,
    // Location and metro station data
    @JsonKey(name: "listing_subway_line_id") int? listingSubwayLineId,
    @JsonKey(name: "listing_subway_station_id") int? listingSubwayStationId,
    @JsonKey(name: "listing_location_id") int? listingLocationId,
    @JsonKey(name: "subway_station_name_uz") String? subwayStationNameUz,
    @JsonKey(name: "subway_station_name_ru") String? subwayStationNameRu,
    @JsonKey(name: "subway_station_name_en") String? subwayStationNameEn,
    @JsonKey(name: "subway_station_line") int? subwayStationLine,
    @JsonKey(name: "subway_station_ordinal") int? subwayStationOrdinal,
    @JsonKey(name: "location_name_uz") String? locationNameUz,
    @JsonKey(name: "location_name_ru") String? locationNameRu,
    @JsonKey(name: "location_name_en") String? locationNameEn,
    @JsonKey(name: "location_short_name_uz") String? locationShortNameUz,
    @JsonKey(name: "location_short_name_ru") String? locationShortNameRu,
    @JsonKey(name: "location_short_name_en") String? locationShortNameEn,
  }) = _ConversationSummary;

  factory ConversationSummary.fromJson(Map<String, dynamic> json) =>
      _$ConversationSummaryFromJson(json);
}
