// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complaint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ComplaintComplainantProfileImpl _$$ComplaintComplainantProfileImplFromJson(
        Map<String, dynamic> json) =>
    _$ComplaintComplainantProfileImpl(
      name: json['name'] as String?,
    );

Map<String, dynamic> _$$ComplaintComplainantProfileImplToJson(
        _$ComplaintComplainantProfileImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
    };

_$ComplaintComplainantImpl _$$ComplaintComplainantImplFromJson(
        Map<String, dynamic> json) =>
    _$ComplaintComplainantImpl(
      id: (json['id'] as num?)?.toInt(),
      profile: json['profile'] == null
          ? null
          : ComplaintComplainantProfile.fromJson(
              json['profile'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$ComplaintComplainantImplToJson(
        _$ComplaintComplainantImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'profile': instance.profile,
    };

_$ComplaintImpl _$$ComplaintImplFromJson(Map<String, dynamic> json) =>
    _$ComplaintImpl(
      status: json['status'] == null
          ? 'pending'
          : _complaintStatusFromJson(json['status']),
      id: (json['id'] as num?)?.toInt(),
      complainantId: (json['complainant_id'] as num?)?.toInt(),
      complainant: json['complainant'] == null
          ? null
          : ComplaintComplainant.fromJson(
              json['complainant'] as Map<String, dynamic>),
      listingId: (json['listing_id'] as num?)?.toInt(),
      categoryId: (json['category_id'] as num?)?.toInt(),
      category: json['category'] == null
          ? null
          : ComplaintCategory.fromJson(
              json['category'] as Map<String, dynamic>),
      text: json['text'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$$ComplaintImplToJson(_$ComplaintImpl instance) =>
    <String, dynamic>{
      'status': instance.status,
      'id': instance.id,
      'complainant_id': instance.complainantId,
      'complainant': instance.complainant,
      'listing_id': instance.listingId,
      'category_id': instance.categoryId,
      'category': instance.category,
      'text': instance.text,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

_$CreateComplaintRequestImpl _$$CreateComplaintRequestImplFromJson(
        Map<String, dynamic> json) =>
    _$CreateComplaintRequestImpl(
      listingId: (json['listing_id'] as num).toInt(),
      categoryId: (json['category_id'] as num).toInt(),
      text: json['text'] as String?,
    );

Map<String, dynamic> _$$CreateComplaintRequestImplToJson(
        _$CreateComplaintRequestImpl instance) =>
    <String, dynamic>{
      'listing_id': instance.listingId,
      'category_id': instance.categoryId,
      'text': instance.text,
    };
