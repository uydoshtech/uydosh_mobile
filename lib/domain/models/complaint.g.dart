// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complaint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ComplaintImpl _$$ComplaintImplFromJson(Map<String, dynamic> json) =>
    _$ComplaintImpl(
      status:
          json['status'] == null
              ? 'pending'
              : _complaintStatusFromJson(json['status']),
      id: (json['id'] as num?)?.toInt(),
      complainantId: (json['complainant_id'] as num?)?.toInt(),
      listingId: (json['listing_id'] as num?)?.toInt(),
      categoryId: (json['category_id'] as num?)?.toInt(),
      category:
          json['category'] == null
              ? null
              : ComplaintCategory.fromJson(
                json['category'] as Map<String, dynamic>,
              ),
      text: json['text'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$$ComplaintImplToJson(_$ComplaintImpl instance) =>
    <String, dynamic>{
      'status': instance.status,
      'id': instance.id,
      'complainant_id': instance.complainantId,
      'listing_id': instance.listingId,
      'category_id': instance.categoryId,
      'category': instance.category,
      'text': instance.text,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

_$CreateComplaintRequestImpl _$$CreateComplaintRequestImplFromJson(
  Map<String, dynamic> json,
) => _$CreateComplaintRequestImpl(
  listingId: (json['listing_id'] as num).toInt(),
  categoryId: (json['category_id'] as num).toInt(),
  text: json['text'] as String?,
);

Map<String, dynamic> _$$CreateComplaintRequestImplToJson(
  _$CreateComplaintRequestImpl instance,
) => <String, dynamic>{
  'listing_id': instance.listingId,
  'category_id': instance.categoryId,
  'text': instance.text,
};
