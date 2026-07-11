// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complaint.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ComplaintComplainantProfile _$ComplaintComplainantProfileFromJson(
  Map<String, dynamic> json,
) => _ComplaintComplainantProfile(
  name: json['name'] as String?,
  avatarUrl: json['avatar_url'] as String?,
);

Map<String, dynamic> _$ComplaintComplainantProfileToJson(
  _ComplaintComplainantProfile instance,
) => <String, dynamic>{'name': instance.name, 'avatar_url': instance.avatarUrl};

_ComplaintComplainant _$ComplaintComplainantFromJson(
  Map<String, dynamic> json,
) => _ComplaintComplainant(
  id: (json['id'] as num?)?.toInt(),
  profile: json['profile'] == null
      ? null
      : ComplaintComplainantProfile.fromJson(
          json['profile'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$ComplaintComplainantToJson(
  _ComplaintComplainant instance,
) => <String, dynamic>{'id': instance.id, 'profile': instance.profile};

_Complaint _$ComplaintFromJson(Map<String, dynamic> json) => _Complaint(
  status: json['status'] == null
      ? 'pending'
      : _complaintStatusFromJson(json['status']),
  id: (json['id'] as num?)?.toInt(),
  complainantId: (json['complainant_id'] as num?)?.toInt(),
  complainant: json['complainant'] == null
      ? null
      : ComplaintComplainant.fromJson(
          json['complainant'] as Map<String, dynamic>,
        ),
  listingId: (json['listing_id'] as num?)?.toInt(),
  categoryId: (json['category_id'] as num?)?.toInt(),
  category: json['category'] == null
      ? null
      : ComplaintCategory.fromJson(json['category'] as Map<String, dynamic>),
  text: json['text'] as String?,
  createdAt: json['created_at'] as String?,
  updatedAt: json['updated_at'] as String?,
);

Map<String, dynamic> _$ComplaintToJson(_Complaint instance) =>
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

_CreateComplaintRequest _$CreateComplaintRequestFromJson(
  Map<String, dynamic> json,
) => _CreateComplaintRequest(
  listingId: (json['listing_id'] as num).toInt(),
  categoryId: (json['category_id'] as num).toInt(),
  text: json['text'] as String?,
);

Map<String, dynamic> _$CreateComplaintRequestToJson(
  _CreateComplaintRequest instance,
) => <String, dynamic>{
  'listing_id': instance.listingId,
  'category_id': instance.categoryId,
  'text': instance.text,
};
