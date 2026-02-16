import "package:freezed_annotation/freezed_annotation.dart";
import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/domain/models/complaint_category.dart";

part "complaint.freezed.dart";
part "complaint.g.dart";

String _complaintStatusFromJson(Object? value) =>
    value is String && value.isNotEmpty ? value : "pending";

@freezed
class Complaint with _$Complaint {
  const factory Complaint({
    @JsonKey(
      name: "status",
      fromJson: _complaintStatusFromJson,
      defaultValue: "pending",
    )
    required String status, int? id,
    @JsonKey(name: "complainant_id") int? complainantId,
    @JsonKey(name: "listing_id") int? listingId,
    @JsonKey(name: "category_id") int? categoryId,
    @JsonKey(name: "category") ComplaintCategory? category,
    String? text,
    @JsonKey(name: "created_at") String? createdAt,
    @JsonKey(name: "updated_at") String? updatedAt,
  }) = _Complaint;

  factory Complaint.fromJson(Map<String, dynamic> json) =>
      _$ComplaintFromJson(json);
}

@freezed
class CreateComplaintRequest
    with _$CreateComplaintRequest
    implements IJsonEncodable {
  const factory CreateComplaintRequest({
    @JsonKey(name: "listing_id") required int listingId,
    @JsonKey(name: "category_id") required int categoryId,
    String? text,
  }) = _CreateComplaintRequest;

  factory CreateComplaintRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateComplaintRequestFromJson(json);
}
