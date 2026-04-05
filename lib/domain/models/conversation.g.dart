// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ConversationImpl _$$ConversationImplFromJson(Map<String, dynamic> json) =>
    _$ConversationImpl(
      id: (json['id'] as num).toInt(),
      listingId: (json['listing_id'] as num).toInt(),
      initiatorId: (json['initiator_id'] as num).toInt(),
      participantId: (json['participant_id'] as num).toInt(),
      isActive: json['is_active'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      lastMessageAt: json['last_message_at'] as String?,
      lastMessageContent: json['last_message_content'] as String?,
      lastMessageSenderId: (json['last_message_sender_id'] as num?)?.toInt(),
      listing: json['listing'] == null
          ? null
          : Listing.fromJson(json['listing'] as Map<String, dynamic>),
      otherUser: json['otherUser'] == null
          ? null
          : UserProfile.fromJson(json['otherUser'] as Map<String, dynamic>),
      unreadCount: (json['unread_count'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$ConversationImplToJson(_$ConversationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'listing_id': instance.listingId,
      'initiator_id': instance.initiatorId,
      'participant_id': instance.participantId,
      'is_active': instance.isActive,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'last_message_at': instance.lastMessageAt,
      'last_message_content': instance.lastMessageContent,
      'last_message_sender_id': instance.lastMessageSenderId,
      'listing': instance.listing,
      'otherUser': instance.otherUser,
      'unread_count': instance.unreadCount,
    };

_$ConversationSummaryImpl _$$ConversationSummaryImplFromJson(
        Map<String, dynamic> json) =>
    _$ConversationSummaryImpl(
      id: (json['id'] as num).toInt(),
      listingId: (json['listing_id'] as num).toInt(),
      initiatorId: (json['initiator_id'] as num).toInt(),
      participantId: (json['participant_id'] as num).toInt(),
      isActive: json['is_active'] as bool,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      lastMessageAt: json['last_message_at'] as String?,
      lastMessageContent: json['last_message_content'] as String?,
      lastMessageSenderId: (json['last_message_sender_id'] as num?)?.toInt(),
      listingTitle: json['listing_title'] as String?,
      listingTypeId: (json['listing_type_id'] as num?)?.toInt(),
      listingGender: (json['listing_gender'] as num?)?.toInt(),
      listingPrice: (json['listing_price'] as num?)?.toInt(),
      otherUserName: json['other_user_name'] as String?,
      otherUserAvatar: json['other_user_avatar'] as String?,
      unreadCount: (json['unread_count'] as num?)?.toInt(),
      listingSubwayLineId: (json['listing_subway_line_id'] as num?)?.toInt(),
      listingSubwayStationId:
          (json['listing_subway_station_id'] as num?)?.toInt(),
      listingLocationId: (json['listing_location_id'] as num?)?.toInt(),
      subwayStationNameUz: json['subway_station_name_uz'] as String?,
      subwayStationNameRu: json['subway_station_name_ru'] as String?,
      subwayStationNameEn: json['subway_station_name_en'] as String?,
      subwayStationLine: (json['subway_station_line'] as num?)?.toInt(),
      subwayStationOrdinal: (json['subway_station_ordinal'] as num?)?.toInt(),
      locationNameUz: json['location_name_uz'] as String?,
      locationNameRu: json['location_name_ru'] as String?,
      locationNameEn: json['location_name_en'] as String?,
      locationShortNameUz: json['location_short_name_uz'] as String?,
      locationShortNameRu: json['location_short_name_ru'] as String?,
      locationShortNameEn: json['location_short_name_en'] as String?,
    );

Map<String, dynamic> _$$ConversationSummaryImplToJson(
        _$ConversationSummaryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'listing_id': instance.listingId,
      'initiator_id': instance.initiatorId,
      'participant_id': instance.participantId,
      'is_active': instance.isActive,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'last_message_at': instance.lastMessageAt,
      'last_message_content': instance.lastMessageContent,
      'last_message_sender_id': instance.lastMessageSenderId,
      'listing_title': instance.listingTitle,
      'listing_type_id': instance.listingTypeId,
      'listing_gender': instance.listingGender,
      'listing_price': instance.listingPrice,
      'other_user_name': instance.otherUserName,
      'other_user_avatar': instance.otherUserAvatar,
      'unread_count': instance.unreadCount,
      'listing_subway_line_id': instance.listingSubwayLineId,
      'listing_subway_station_id': instance.listingSubwayStationId,
      'listing_location_id': instance.listingLocationId,
      'subway_station_name_uz': instance.subwayStationNameUz,
      'subway_station_name_ru': instance.subwayStationNameRu,
      'subway_station_name_en': instance.subwayStationNameEn,
      'subway_station_line': instance.subwayStationLine,
      'subway_station_ordinal': instance.subwayStationOrdinal,
      'location_name_uz': instance.locationNameUz,
      'location_name_ru': instance.locationNameRu,
      'location_name_en': instance.locationNameEn,
      'location_short_name_uz': instance.locationShortNameUz,
      'location_short_name_ru': instance.locationShortNameRu,
      'location_short_name_en': instance.locationShortNameEn,
    };
