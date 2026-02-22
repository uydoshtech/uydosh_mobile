import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/util/environment_util.dart";
import "package:uy_dosh/domain/models/support_chat_message.dart";
import "package:uy_dosh/domain/models/support_chat_thread.dart";

abstract class ISupportChatService {
  // Admin methods (use /admin/support-chat)
  Future<SupportChatThreadsResponse> getThreads({
    int page = 1,
    int limit = 20,
    String? status,
  });
  Future<SupportChatThread?> getThread(int threadId);
  Future<SupportChatMessagesResponse> getMessages(
    int threadId, {
    int page = 1,
    int limit = 50,
  });
  Future<SupportChatMessage?> sendMessage(int threadId, String body);
  Future<SupportChatThread?> updateThreadStatus(
    int threadId,
    String status,
  );

  // User methods (use /support-chat)
  Future<SupportChatThread> createThread({String? subject});
  Future<SupportChatThreadsResponse> getUserThreads({
    int page = 1,
    int limit = 20,
    String? status,
  });
  Future<SupportChatThread?> getUserThread(int threadId);
  Future<SupportChatMessagesResponse> getUserMessages(
    int threadId, {
    int page = 1,
    int limit = 50,
  });
  Future<SupportChatMessage?> userSendMessage(int threadId, String body);
}

class SupportChatThreadsResponse {
  SupportChatThreadsResponse({
    required this.threads,
    required this.total,
    required this.page,
    required this.limit,
  });

  final List<SupportChatThread> threads;
  final int total;
  final int page;
  final int limit;
}

class SupportChatMessagesResponse {
  SupportChatMessagesResponse({
    required this.messages,
    required this.total,
    required this.page,
    required this.limit,
  });

  final List<SupportChatMessage> messages;
  final int total;
  final int page;
  final int limit;
}

class SupportChatService implements ISupportChatService {
  SupportChatService(this._oauthApiClient);

  final IOAuthApiClient _oauthApiClient;

  static const String _adminBasePath = "/admin/support-chat";
  static const String _userBasePath = "/support-chat";

  @override
  Future<SupportChatThreadsResponse> getThreads({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        "page": page,
        "limit": limit,
      };
      if (status != null && status.isNotEmpty) {
        queryParams["status"] = status;
      }

      final response = await _oauthApiClient.get<dynamic>(
        "$_adminBasePath/threads",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        queryParameters: queryParams,
      );

      List<dynamic> data;
      Map<String, dynamic> pagination;

      if (response is Map<String, dynamic>) {
        data = response["data"] as List<dynamic>? ?? [];
        pagination = response["pagination"] as Map<String, dynamic>? ?? {};
      } else if (response is List) {
        data = response;
        pagination = {"total": data.length, "page": page, "limit": limit};
      } else if (response is String) {
        throw Exception(
          "Support chat route not found. "
          "Deploy the backend with the latest support chat code and run migrations.",
        );
      } else {
        throw Exception(
          "Unexpected response format (${response.runtimeType}). "
          "Ensure the backend is deployed with support chat routes.",
        );
      }

      return SupportChatThreadsResponse(
        threads: data
            .map((e) => SupportChatThread.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: (pagination["total"] as num?)?.toInt() ?? 0,
        page: (pagination["page"] as num?)?.toInt() ?? page,
        limit: (pagination["limit"] as num?)?.toInt() ?? limit,
      );
    } catch (e) {
      logger.d("Error fetching support chat threads: $e");
      rethrow;
    }
  }

  @override
  Future<SupportChatThread?> getThread(int threadId) async {
    try {
      final response = await _oauthApiClient.get<dynamic>(
        "$_adminBasePath/threads/$threadId",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
      );

      if (response is! Map<String, dynamic>) return null;
      final data = response["data"] as Map<String, dynamic>?;
      if (data == null) return null;

      return SupportChatThread.fromJson(data);
    } catch (e) {
      logger.d("Error fetching support chat thread: $e");
      rethrow;
    }
  }

  @override
  Future<SupportChatMessagesResponse> getMessages(
    int threadId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _oauthApiClient.get<dynamic>(
        "$_adminBasePath/threads/$threadId/messages",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        queryParameters: {"page": page, "limit": limit},
      );

      if (response is! Map<String, dynamic>) {
        throw Exception("Unexpected response format");
      }

      final data = response["data"] as List<dynamic>? ?? [];
      final pagination = response["pagination"] as Map<String, dynamic>? ?? {};

      return SupportChatMessagesResponse(
        messages: data
            .map((e) => SupportChatMessage.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: (pagination["total"] as num?)?.toInt() ?? 0,
        page: (pagination["page"] as num?)?.toInt() ?? page,
        limit: (pagination["limit"] as num?)?.toInt() ?? limit,
      );
    } catch (e) {
      logger.d("Error fetching support chat messages: $e");
      rethrow;
    }
  }

  @override
  Future<SupportChatMessage?> sendMessage(int threadId, String body) async {
    try {
      final response = await _oauthApiClient.post<dynamic, _SendMessageRequest>(
        "$_adminBasePath/threads/$threadId/messages",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        data: _SendMessageRequest(body: body),
      );

      if (response is! Map<String, dynamic>) return null;
      final data = response["data"] as Map<String, dynamic>?;
      if (data == null) return null;

      return SupportChatMessage.fromJson(data);
    } catch (e) {
      logger.d("Error sending support chat message: $e");
      rethrow;
    }
  }

  @override
  Future<SupportChatThread?> updateThreadStatus(
    int threadId,
    String status,
  ) async {
    try {
      final response = await _oauthApiClient.patch<dynamic, _StatusRequest>(
        "$_adminBasePath/threads/$threadId/status",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        data: _StatusRequest(status: status),
      );

      if (response is! Map<String, dynamic>) return null;
      final data = response["data"] as Map<String, dynamic>?;
      if (data == null) return null;

      return SupportChatThread.fromJson(data);
    } catch (e) {
      logger.d("Error updating thread status: $e");
      rethrow;
    }
  }

  @override
  Future<SupportChatThread> createThread({String? subject}) async {
    try {
      final response = await _oauthApiClient.post<dynamic, _CreateThreadRequest>(
        "$_userBasePath/threads",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        data: _CreateThreadRequest(subject: subject),
      );

      if (response is! Map<String, dynamic>) {
        throw Exception("Unexpected response format");
      }
      final data = response["data"] as Map<String, dynamic>?;
      if (data == null) throw Exception("No thread data in response");

      return SupportChatThread.fromJson(data);
    } catch (e) {
      logger.d("Error creating support thread: $e");
      rethrow;
    }
  }

  @override
  Future<SupportChatThreadsResponse> getUserThreads({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    try {
      final queryParams = <String, dynamic>{"page": page, "limit": limit};
      if (status != null && status.isNotEmpty) queryParams["status"] = status;

      final response = await _oauthApiClient.get<dynamic>(
        "$_userBasePath/threads",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        queryParameters: queryParams,
      );

      List<dynamic> data;
      Map<String, dynamic> pagination;

      if (response is Map<String, dynamic>) {
        data = response["data"] as List<dynamic>? ?? [];
        pagination = response["pagination"] as Map<String, dynamic>? ?? {};
      } else if (response is List) {
        data = response;
        pagination = {"total": data.length, "page": page, "limit": limit};
      } else {
        throw Exception("Unexpected response format");
      }

      return SupportChatThreadsResponse(
        threads: data
            .map((e) => SupportChatThread.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: (pagination["total"] as num?)?.toInt() ?? 0,
        page: (pagination["page"] as num?)?.toInt() ?? page,
        limit: (pagination["limit"] as num?)?.toInt() ?? limit,
      );
    } catch (e) {
      logger.d("Error fetching user support threads: $e");
      rethrow;
    }
  }

  @override
  Future<SupportChatThread?> getUserThread(int threadId) async {
    try {
      final response = await _oauthApiClient.get<dynamic>(
        "$_userBasePath/threads/$threadId",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
      );

      if (response is! Map<String, dynamic>) return null;
      final data = response["data"] as Map<String, dynamic>?;
      if (data == null) return null;

      return SupportChatThread.fromJson(data);
    } catch (e) {
      logger.d("Error fetching user support thread: $e");
      rethrow;
    }
  }

  @override
  Future<SupportChatMessagesResponse> getUserMessages(
    int threadId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await _oauthApiClient.get<dynamic>(
        "$_userBasePath/threads/$threadId/messages",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        queryParameters: {"page": page, "limit": limit},
      );

      if (response is! Map<String, dynamic>) {
        throw Exception("Unexpected response format");
      }

      final data = response["data"] as List<dynamic>? ?? [];
      final pagination = response["pagination"] as Map<String, dynamic>? ?? {};

      return SupportChatMessagesResponse(
        messages: data
            .map((e) => SupportChatMessage.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: (pagination["total"] as num?)?.toInt() ?? 0,
        page: (pagination["page"] as num?)?.toInt() ?? page,
        limit: (pagination["limit"] as num?)?.toInt() ?? limit,
      );
    } catch (e) {
      logger.d("Error fetching user support messages: $e");
      rethrow;
    }
  }

  @override
  Future<SupportChatMessage?> userSendMessage(int threadId, String body) async {
    try {
      final response = await _oauthApiClient.post<dynamic, _SendMessageRequest>(
        "$_userBasePath/threads/$threadId/messages",
        (data) => data,
        basePath: EnvironmentUtil.basePath,
        data: _SendMessageRequest(body: body),
      );

      if (response is! Map<String, dynamic>) return null;
      final data = response["data"] as Map<String, dynamic>?;
      if (data == null) return null;

      return SupportChatMessage.fromJson(data);
    } catch (e) {
      logger.d("Error sending user support message: $e");
      rethrow;
    }
  }
}

class _CreateThreadRequest implements IJsonEncodable {
  _CreateThreadRequest({this.subject});

  final String? subject;

  @override
  Map<String, dynamic> toJson() =>
      subject != null && subject!.isNotEmpty ? {"subject": subject} : {};
}

class _SendMessageRequest implements IJsonEncodable {
  _SendMessageRequest({required this.body});

  final String body;

  @override
  Map<String, dynamic> toJson() => {"body": body};
}

class _StatusRequest implements IJsonEncodable {
  _StatusRequest({required this.status});

  final String status;

  @override
  Map<String, dynamic> toJson() => {"status": status};
}
