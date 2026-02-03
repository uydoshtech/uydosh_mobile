import 'package:uy_dosh/domain/models/complaint.dart';
import 'package:uy_dosh/domain/models/complaint_category.dart';
import 'package:uy_dosh/base/api/client/oauth_api_client.dart';
import 'package:uy_dosh/base/logger/logger.dart';
import 'package:uy_dosh/base/api/client/public_api_client.dart';
import 'package:uy_dosh/base/api/client/json_encodable.dart';

abstract class IComplaintService {
  // Complaint Categories
  Future<List<ComplaintCategory>> getComplaintCategories();
  Future<ComplaintCategory> getComplaintCategory(int id);

  // Complaints
  Future<Complaint> createComplaint(CreateComplaintRequest request);
  Future<List<Complaint>> getComplaints({
    int? page,
    int? limit,
    String? status,
    int? listingId,
  });
  Future<Complaint> getComplaint(int id);
  Future<Complaint> updateComplaintStatus(int id, String status);
  Future<void> deleteComplaint(int id);
  Future<List<Complaint>> getUserComplaints(int userId);
  Future<List<Complaint>> getUserListingComplaints(int userId);
  Future<List<Complaint>> getListingComplaints(int listingId);
  Future<int> getListingComplaintsCount(int listingId);
  Future<int> getComplaintsCount({String? status});
}

class ComplaintService implements IComplaintService {
  final IPublicApiClient _publicApiClient;
  final IOAuthApiClient _oauthApiClient;

  ComplaintService(this._publicApiClient, this._oauthApiClient);

  @override
  Future<List<ComplaintCategory>> getComplaintCategories() async {
    try {
      logger.d('=== COMPLAINT CATEGORIES API REQUEST DEBUG ===');
      logger.d('Requesting: /complaint-categories');

      final response = await _publicApiClient.get<dynamic>(
        '/complaint-categories',
        (json) => json,
      );

      logger.d('Raw API Response: $response');
      logger.d('Response type: ${response.runtimeType}');
      if (response is Map) {
        logger.d('Response keys: ${response.keys.toList()}');
      }

      List<dynamic> categoriesData;
      if (response is Map && response.containsKey('data')) {
        logger.d('Found categories in "data" key');
        categoriesData = response['data'] as List<dynamic>;
      } else if (response is Map && response.containsKey('content')) {
        logger.d('Found categories in "content" key');
        categoriesData = response['content'] as List<dynamic>;
      } else if (response is List) {
        logger.d('Response is a direct list');
        categoriesData = response as List<dynamic>;
      } else {
        logger.d('No recognized data structure found, using fallback');
        categoriesData = <dynamic>[];
      }

      logger.d('Categories data length: ${categoriesData.length}');
      if (categoriesData.isNotEmpty) {
        logger.d('First category: ${categoriesData.first}');
      }

      final categories =
          categoriesData
              .map(
                (item) =>
                    ComplaintCategory.fromJson(item as Map<String, dynamic>),
              )
              .toList();

      logger.d('Parsed categories count: ${categories.length}');
      return categories;
    } catch (e) {
      logger.d('Error fetching complaint categories: $e');
      rethrow;
    }
  }

  @override
  Future<ComplaintCategory> getComplaintCategory(int id) async {
    try {
      final category = await _publicApiClient.get<ComplaintCategory>(
        '/complaint-categories/$id',
        (json) => ComplaintCategory.fromJson(json as Map<String, dynamic>),
      );
      return category;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Complaint> createComplaint(CreateComplaintRequest request) async {
    try {
      logger.d('=== COMPLAINT SERVICE: Creating complaint ===');
      logger.d('Request: ${request.toJson()}');

      // First get the raw response to debug
      final rawResponse = await _oauthApiClient
          .post<Map<String, dynamic>, CreateComplaintRequest>(
            '/complaints',
            (json) => json as Map<String, dynamic>,
            data: request,
          );

      logger.d('=== COMPLAINT SERVICE: Raw response received ===');
      logger.d('Raw response: $rawResponse');
      logger.d('Response type: ${rawResponse.runtimeType}');
      logger.d('Response keys: ${rawResponse.keys.toList()}');

      // Try to parse the complaint from the response
      Complaint complaint;
      if (rawResponse.containsKey('data')) {
        logger.d('Found complaint in "data" key');
        complaint = Complaint.fromJson(
          rawResponse['data'] as Map<String, dynamic>,
        );
      } else if (rawResponse.containsKey('complaint')) {
        logger.d('Found complaint in "complaint" key');
        complaint = Complaint.fromJson(
          rawResponse['complaint'] as Map<String, dynamic>,
        );
      } else {
        logger.d('Complaint data is at root level');
        complaint = Complaint.fromJson(rawResponse);
      }

      logger.d('=== COMPLAINT SERVICE: Complaint created successfully ===');
      logger.d('Parsed complaint: ${complaint.toString()}');
      return complaint;
    } catch (e) {
      logger.d('=== COMPLAINT SERVICE: Error creating complaint: $e ===');
      logger.d('Error type: ${e.runtimeType}');
      if (e is Exception) {
        logger.d('Exception message: ${e.toString()}');
      }
      rethrow;
    }
  }

  @override
  Future<List<Complaint>> getComplaints({
    int? page,
    int? limit,
    String? status,
    int? listingId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (limit != null) queryParams['limit'] = limit.toString();
      if (status != null) queryParams['status'] = status;
      if (listingId != null) queryParams['listing_id'] = listingId.toString();

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');

      final response = await _oauthApiClient.get<dynamic>(
        '/complaints${queryString.isNotEmpty ? '?$queryString' : ''}',
        (json) => json,
      );

      final complaintsData = _extractComplaintsData(response);
      return (complaintsData ?? <dynamic>[])
          .map((item) => Complaint.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Complaint> getComplaint(int id) async {
    try {
      final complaint = await _oauthApiClient.get<Complaint>(
        '/complaints/$id',
        (json) => Complaint.fromJson(json as Map<String, dynamic>),
      );
      return complaint;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Complaint> updateComplaintStatus(int id, String status) async {
    try {
      // Create a simple request object for the status update
      final request = _StatusUpdateRequest(status: status);
      final complaint = await _oauthApiClient
          .put<Complaint, _StatusUpdateRequest>(
            '/complaints/$id/status',
            (json) => Complaint.fromJson(json as Map<String, dynamic>),
            data: request,
          );
      return complaint;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> deleteComplaint(int id) async {
    try {
      await _oauthApiClient.delete<Map<String, dynamic>, _EmptyRequest>(
        '/complaints/$id',
        (json) => json as Map<String, dynamic>,
        data: const _EmptyRequest(),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Complaint>> getUserComplaints(int userId) async {
    try {
      final response = await _oauthApiClient.get<dynamic>(
        '/users/$userId/complaints',
        (json) => json,
      );

      final complaintsData = _extractComplaintsData(response);
      return (complaintsData ?? <dynamic>[])
          .map((item) => Complaint.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Complaint>> getUserListingComplaints(int userId) async {
    try {
      final response = await _oauthApiClient.get<dynamic>(
        '/users/$userId/listing-complaints',
        (json) => json,
      );

      final complaintsData = _extractComplaintsData(response);
      return (complaintsData ?? <dynamic>[])
          .map((item) => Complaint.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<Complaint>> getListingComplaints(int listingId) async {
    try {
      final response = await _publicApiClient.get<dynamic>(
        '/listings/$listingId/complaints',
        (json) => json,
      );

      final complaintsData = _extractComplaintsData(response);
      if (complaintsData != null) {
        return complaintsData
            .map((item) => Complaint.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      // Fallback to the complaints list endpoint if response shape is unknown
      return await getComplaints(listingId: listingId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<int> getListingComplaintsCount(int listingId) async {
    try {
      final response = await _publicApiClient.get<dynamic>(
        '/complaints/counts-by-listing?listing_id=$listingId',
        (json) => json,
      );

      if (response is Map) {
        final data = response['data'];
        if (data is Map && data['count'] is num) {
          return (data['count'] as num).toInt();
        }
        if (response['count'] is num) {
          return (response['count'] as num).toInt();
        }
      }

      return 0;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<int> getComplaintsCount({String? status}) async {
    try {
      final queryParams = <String, String>{
        'page': '1',
        'limit': '1',
      };
      if (status != null) queryParams['status'] = status;

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');

      final response = await _oauthApiClient.get<dynamic>(
        '/complaints${queryString.isNotEmpty ? '?$queryString' : ''}',
        (json) => json,
      );

      final total = _extractPaginationTotal(response);
      if (total != null) {
        return total;
      }

      final data = _extractComplaintsData(response);
      return data?.length ?? 0;
    } catch (e) {
      rethrow;
    }
  }

  List<dynamic>? _extractComplaintsData(dynamic response) {
    if (response is Map) {
      final data = response['data'];
      final dataList = _extractListFromDataContainer(data);
      if (dataList != null) {
        return dataList;
      }

      final contentList = _extractListFromDataContainer(response['content']);
      if (contentList != null) {
        return contentList;
      }
    }
    if (response is List) {
      return response;
    }
    return null;
  }

  List<dynamic>? _extractListFromDataContainer(dynamic container) {
    if (container is List) {
      return container;
    }
    if (container is Map) {
      final content = container['content'];
      if (content is List) {
        return content;
      }
      final items = container['items'];
      if (items is List) {
        return items;
      }
      final results = container['results'];
      if (results is List) {
        return results;
      }
    }
    return null;
  }

  int? _extractPaginationTotal(dynamic response) {
    if (response is Map) {
      final pagination = response['pagination'];
      if (pagination is Map && pagination['total'] is num) {
        return (pagination['total'] as num).toInt();
      }
    }
    return null;
  }
}

// Helper class for status update requests
class _StatusUpdateRequest implements IJsonEncodable {
  final String status;

  _StatusUpdateRequest({required this.status});

  @override
  Map<String, dynamic> toJson() => {'status': status};
}

// Helper class for empty requests (like delete operations)
class _EmptyRequest implements IJsonEncodable {
  const _EmptyRequest();

  @override
  Map<String, dynamic> toJson() => {};
}
