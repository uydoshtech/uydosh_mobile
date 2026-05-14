import "package:dio/dio.dart";
import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/util/dio_api_error_message.dart";
import "package:uy_dosh/base/util/environment_util.dart";

/// Backend `entityType` for [IAdminEntityOwnershipService.reassignOwnership].
enum AdminEntityOwnershipType {
  listing("listing"),
  gigOffer("gig_offer"),
  gigRequest("gig_request");

  const AdminEntityOwnershipType(this.apiValue);
  final String apiValue;
}

class AdminEntityOwnershipReassignResult {
  AdminEntityOwnershipReassignResult({
    required this.entityType,
    required this.entityId,
    required this.previousOwnerUserId,
    required this.newOwnerUserId,
  });

  factory AdminEntityOwnershipReassignResult.fromJson(Map<String, dynamic> json) {
    int n(dynamic v) => v is int ? v : (v is num ? v.toInt() : 0);
    return AdminEntityOwnershipReassignResult(
      entityType: json["entityType"] as String? ?? "",
      entityId: n(json["entityId"]),
      previousOwnerUserId: n(json["previousOwnerUserId"]),
      newOwnerUserId: n(json["newOwnerUserId"]),
    );
  }

  final String entityType;
  final int entityId;
  final int previousOwnerUserId;
  final int newOwnerUserId;
}

class _ReassignOwnershipRequest implements IJsonEncodable {
  _ReassignOwnershipRequest({
    required this.entityType,
    required this.entityId,
    required this.toUserId,
    this.fromUserId,
  });

  final String entityType;
  final int entityId;
  final int toUserId;
  final int? fromUserId;

  @override
  Map<String, dynamic> toJson() => {
    "entityType": entityType,
    "entityId": entityId,
    "toUserId": toUserId,
    if (fromUserId != null) "fromUserId": fromUserId,
  };
}

abstract class IAdminEntityOwnershipService {
  Future<AdminEntityOwnershipReassignResult> reassignOwnership({
    required AdminEntityOwnershipType entityType,
    required int entityId,
    required int toUserId,
    int? fromUserId,
  });
}

class AdminEntityOwnershipService implements IAdminEntityOwnershipService {
  AdminEntityOwnershipService(this._oauthApiClient);

  final IOAuthApiClient _oauthApiClient;

  static Map<String, dynamic> _requireJsonMap(
    dynamic response,
    String message,
  ) {
    if (response is! Map) {
      throw Exception(message);
    }
    return Map<String, dynamic>.from(response);
  }

  @override
  Future<AdminEntityOwnershipReassignResult> reassignOwnership({
    required AdminEntityOwnershipType entityType,
    required int entityId,
    required int toUserId,
    int? fromUserId,
  }) async {
    try {
      final response = await _oauthApiClient
          .post<Map<String, dynamic>, _ReassignOwnershipRequest>(
            "/admin/ownership/reassign",
            (data) => _requireJsonMap(data, "Invalid reassign response"),
            basePath: EnvironmentUtil.basePath,
            data: _ReassignOwnershipRequest(
              entityType: entityType.apiValue,
              entityId: entityId,
              toUserId: toUserId,
              fromUserId: fromUserId,
            ),
          );
      return AdminEntityOwnershipReassignResult.fromJson(response);
    } on DioException catch (e) {
      logger.d("Admin reassign ownership: $e");
      throw Exception(dioApiErrorMessage(e));
    }
  }
}
