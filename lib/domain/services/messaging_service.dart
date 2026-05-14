import "dart:io";
import "dart:typed_data";

import "package:dio/dio.dart";
import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/domain/models/message.dart";
import "package:uy_dosh/domain/models/message_attachment.dart";
import "package:uy_dosh/domain/models/messaging_requests.dart";
import "package:uy_dosh/domain/models/pageable_response.dart";

// Empty request class for delete operations
class _EmptyRequest implements IJsonEncodable {
  @override
  Map<String, dynamic> toJson() => {};
}

abstract class IMessagingService {
  // Conversations
  Future<PageableResponse<ConversationSummary>> getConversations({
    int page = 1,
    int limit = 20,
    bool archived = false,
  });

  Future<PageableResponse<ConversationSummary>> getParticipantConversations({
    int page = 1,
    int limit = 20,
    bool archived = false,
  });

  Future<Conversation> getConversation(int conversationId);

  /// Open (or reactivate) a conversation.
  ///
  /// Mutually-exclusive shapes are accepted:
  ///   - Listing chat: pass [listingId] + [participantId].
  ///   - Gig-request chat: pass [gigRequestId]; [participantId] is ignored
  ///     (the backend forces it to the request's `client_user_id` to prevent
  ///     address-book scraping).
  ///   - Gig booking chat: pass [gigBookingId]; [participantId] is ignored
  ///     (the backend sets it to the other party on that booking).
  Future<Conversation> createConversation({
    int? listingId,
    int? participantId,
    int? gigRequestId,
    int? gigBookingId,
  });

  Future<void> deleteConversation(int conversationId);

  Future<void> archiveConversation(int conversationId);

  Future<void> unarchiveConversation(int conversationId);

  // Messages
  Future<PageableResponse<Message>> getMessages({
    required int conversationId,
    int page = 1,
    int limit = 50,
  });

  Future<Message> sendMessage({
    required int conversationId,
    required String content,
    String messageType = "text",
    int? replyToMessageId,
  });

  Future<Message> editMessage({
    required int messageId,
    required String newContent,
  });

  Future<void> deleteMessage(int messageId);

  // Read status
  Future<void> markMessagesAsRead(int conversationId);

  Future<int> getUnreadMessageCount();

  // Safety
  Future<Map<String, dynamic>> safetyCheckConversation({
    required int conversationId,
    int limit = 8,
  });

  /// Requests Gemini-backed translations for messages in [conversationId].
  ///
  /// By default the server uses the caller's
  /// `user_profile.preferred_language`. Pass [targetLanguage] (`'en'`/`'ru'`/
  /// `'uz'`) to override per-conversation — used by the chat screen's
  /// "Translate to…" action so a viewer can read messages in a language other
  /// than their app/profile default without flipping the global setting.
  ///
  /// Server returns both cached and freshly generated translations so the
  /// client can use a single call as the source of truth. Capped to 50 ids
  /// per request.
  ///
  /// Throws [ChatTranslateQuotaExceededException] when the monthly Gemini
  /// chat translation quota is exhausted (`403`, `code: gemini_quota_exceeded`).
  Future<Map<String, dynamic>> translateUnseenMessages({
    required int conversationId,
    required List<int> messageIds,
    String? targetLanguage,
  });

  // Attachments
  Future<MessageAttachment> uploadAttachment({
    required int messageId,
    required File file,
  });

  Future<MessageAttachment> uploadAttachmentFromBytes({
    required int messageId,
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  });

  Future<void> deleteAttachment(int attachmentId);

  /// Sets or replaces the current user's reaction on a message (same push /
  /// inbox behavior as a new text message for the peer).
  Future<Message> setMessageReaction({
    required int messageId,
    required String reaction,
  });

  /// Removes the current user's reaction from a message.
  Future<Message> removeMessageReaction({required int messageId});
}

class MessagingService implements IMessagingService {

  MessagingService(this._apiClient);
  final IOAuthApiClient _apiClient;

  // Helper method to check authentication before making API calls
  Future<void> _checkAuthentication() async {
    final isAuthenticated = await SessionManager.isAuthenticated();
    if (!isAuthenticated) {
      logger.d(
        "❌ MessagingService: User not authenticated, cannot perform operation",
      );
      throw Exception("User not authenticated. Please log in first.");
    }
    logger.d(
      "🔐 MessagingService: User is authenticated, proceeding with operation...",
    );
  }

  @override
  Future<PageableResponse<ConversationSummary>> getConversations({
    int page = 1,
    int limit = 20,
    bool archived = false,
  }) async {
    try {
      await _checkAuthentication();

      final response = await _apiClient.get<Map<String, dynamic>>(
        "/conversations",
        (json) => json as Map<String, dynamic>,
        queryParameters: {
          "page": page,
          "limit": limit,
          if (archived) "archived": "true",
        },
      );

      // Check if response is a list directly (not wrapped in an object)
      if (response is List) {
        final conversations =
            (response as List)
                .map(
                  (item) => ConversationSummary.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList();

        return PageableResponse<ConversationSummary>(
          data: conversations,
          total: conversations.length,
          page: page,
          limit: limit,
          totalPages: 1,
        );
      }

      // Check if response has 'data' field
      final conversationsData = response["data"];

      if (conversationsData is List) {
        // Direct list format
        final conversations =
            conversationsData
                .map(
                  (item) => ConversationSummary.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList();

        return PageableResponse<ConversationSummary>(
          data: conversations,
          total: response["total"] as int? ?? conversations.length,
          page: response["page"] as int? ?? page,
          limit: response["limit"] as int? ?? limit,
          totalPages: response["totalPages"] as int? ?? 1,
        );
      } else if (conversationsData is Map) {
        // Nested structure: data.conversations
        final conversationsList =
            conversationsData["conversations"] as List? ?? [];

        final conversations =
            conversationsList
                .map(
                  (item) => ConversationSummary.fromJson(
                    item as Map<String, dynamic>,
                  ),
                )
                .toList();

        return PageableResponse<ConversationSummary>(
          data: conversations,
          total: conversationsData["total"] as int? ?? conversations.length,
          page: conversationsData["page"] as int? ?? page,
          limit: conversationsData["limit"] as int? ?? limit,
          totalPages: conversationsData["totalPages"] as int? ?? 1,
        );
      } else {
        throw Exception(
          "Unexpected response structure: ${response.runtimeType}",
        );
      }
    } catch (e) {
      throw Exception("Failed to fetch conversations");
    }
  }

  @override
  Future<PageableResponse<ConversationSummary>> getParticipantConversations({
    int page = 1,
    int limit = 20,
    bool archived = false,
  }) async {
    try {
      await _checkAuthentication();

      final queryParams = <String, dynamic>{
        "page": page,
        "limit": limit,
        if (archived) "archived": "true",
      };

      final response = await _apiClient.get<Map<String, dynamic>>(
        "/conversations/participant",
        (json) => json as Map<String, dynamic>,
        queryParameters: queryParams,
      );

      // Handle different possible response structures
      List<dynamic> conversationsData;
      var total = 0;
      var totalPages = 0;

      if (response["data"] != null && response["data"] is Map) {
        final data = response["data"] as Map<String, dynamic>;
        if (data["conversations"] != null) {
          conversationsData = data["conversations"] as List<dynamic>;
          total = data["total"] ?? conversationsData.length;
          totalPages = data["totalPages"] ?? 1;
        } else {
          conversationsData = <dynamic>[];
        }
      } else if (response["conversations"] != null) {
        conversationsData = response["conversations"] as List<dynamic>;
        total = response["total"] ?? conversationsData.length;
        totalPages = response["totalPages"] ?? 1;
      } else {
        conversationsData = <dynamic>[];
      }

      final conversations =
          conversationsData
              .map(
                (json) =>
                    ConversationSummary.fromJson(json as Map<String, dynamic>),
              )
              .toList();

      return PageableResponse<ConversationSummary>(
        data: conversations,
        total: total,
        page: page,
        limit: limit,
        totalPages: totalPages,
      );
    } catch (e) {
      throw Exception("Failed to fetch participant conversations");
    }
  }

  @override
  Future<Conversation> getConversation(int conversationId) async {
    try {
      await _checkAuthentication();

      final response = await _apiClient.get<Conversation>(
        "/conversations/$conversationId",
        (json) => Conversation.fromJson(json as Map<String, dynamic>),
      );
      return response;
    } catch (e) {
      throw Exception("Failed to fetch conversation");
    }
  }

  @override
  Future<Conversation> createConversation({
    int? listingId,
    int? participantId,
    int? gigRequestId,
    int? gigBookingId,
  }) async {
    try {
      await _checkAuthentication();

      // Validate the caller picked exactly one shape. We assert at the call
      // site rather than silently coercing because mixing them is almost
      // always a bug (e.g. forgetting to pass listingId in a refactor).
      final isListing = listingId != null;
      final isGigRequest = gigRequestId != null;
      final isGigBooking = gigBookingId != null;
      final shapeCount =
          (isListing ? 1 : 0) + (isGigRequest ? 1 : 0) + (isGigBooking ? 1 : 0);
      if (shapeCount != 1) {
        throw ArgumentError(
          "createConversation requires exactly one of listingId, "
          "gigRequestId, or gigBookingId (received listingId=$listingId, "
          "gigRequestId=$gigRequestId, gigBookingId=$gigBookingId)",
        );
      }
      if (isListing && participantId == null) {
        throw ArgumentError(
          "participantId is required when opening a listing-scoped chat",
        );
      }

      final CreateConversationRequest request;
      if (isGigRequest) {
        request = CreateConversationRequest(
          contextType: "gig_request",
          contextId: gigRequestId,
        );
      } else if (isGigBooking) {
        request = CreateConversationRequest(
          contextType: "gig_booking",
          contextId: gigBookingId,
        );
      } else {
        request = CreateConversationRequest(
          listingId: listingId,
          participantId: participantId,
        );
      }

      final response = await _apiClient
          .post<Conversation, CreateConversationRequest>("/conversations", (
            json,
          ) {
            // Extract the data field from the response
            final jsonMap = json as Map<String, dynamic>;
            final conversationData = jsonMap["data"] as Map<String, dynamic>;

            // Remove fields that don't exist in the Conversation model
            final cleanJsonMap = Map<String, dynamic>.from(conversationData);
            cleanJsonMap.remove("initiator");
            cleanJsonMap.remove("participant");
            cleanJsonMap.remove("last_message_sender");
            cleanJsonMap.remove("listing");

            return Conversation.fromJson(cleanJsonMap);
          }, data: request);

      return response;
    } catch (e) {
      throw Exception("Failed to create conversation");
    }
  }

  @override
  Future<void> deleteConversation(int conversationId) async {
    try {
      await _checkAuthentication();

      await _apiClient.delete<Map<String, dynamic>, _EmptyRequest>(
        "/conversations/$conversationId",
        (json) => json as Map<String, dynamic>,
        data: _EmptyRequest(),
      );
    } catch (e) {
      throw Exception("Failed to delete conversation");
    }
  }

  @override
  Future<void> archiveConversation(int conversationId) async {
    await _checkAuthentication();
    try {
      await _apiClient.put<void, _EmptyRequest>(
        "/conversations/$conversationId/archive",
        (json) {},
        data: _EmptyRequest(),
      );
    } on DioException catch (e) {
      // 409 → chat has unread messages; surface a stable marker the BLoC
      // can detect without string-matching the localized error body.
      if (e.response?.statusCode == 409) {
        throw Exception("ARCHIVE_HAS_UNREAD");
      }
      throw Exception("Failed to archive conversation");
    } catch (_) {
      throw Exception("Failed to archive conversation");
    }
  }

  @override
  Future<void> unarchiveConversation(int conversationId) async {
    await _checkAuthentication();
    try {
      await _apiClient.put<void, _EmptyRequest>(
        "/conversations/$conversationId/unarchive",
        (json) {},
        data: _EmptyRequest(),
      );
    } catch (_) {
      throw Exception("Failed to unarchive conversation");
    }
  }

  @override
  Future<PageableResponse<Message>> getMessages({
    required int conversationId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      await _checkAuthentication();

      final response = await _apiClient.get<Map<String, dynamic>>(
        "/conversations/$conversationId/messages",
        (json) => json as Map<String, dynamic>,
        queryParameters: {"page": page, "limit": limit},
      );

      // Check if response indicates empty conversation
      if (response.isEmpty) {
        return PageableResponse<Message>(
          data: [],
          total: 0,
          page: page,
          limit: limit,
          totalPages: 0,
        );
      }

      // Check if response is a list directly (not wrapped in an object)
      if (response is List) {
        final messages =
            (response as List)
                .map((item) => Message.fromJson(item as Map<String, dynamic>))
                .toList();

        return PageableResponse<Message>(
          data: messages,
          total: messages.length,
          page: page,
          limit: limit,
          totalPages: 1,
        );
      }

      // Check if response has 'data' field
      final messagesData = response["data"];

      if (messagesData is List) {
        // Direct list format
        final messages =
            messagesData
                .map((item) => Message.fromJson(item as Map<String, dynamic>))
                .toList();

        return PageableResponse<Message>(
          data: messages,
          total: response["total"] as int? ?? messages.length,
          page: response["page"] as int? ?? page,
          limit: response["limit"] as int? ?? limit,
          totalPages: response["totalPages"] as int? ?? 1,
        );
      } else if (messagesData is Map) {
        // Nested structure: data.messages
        final messagesList = messagesData["messages"] as List? ?? [];

        final messages =
            messagesList
                .map((item) => Message.fromJson(item as Map<String, dynamic>))
                .toList();

        return PageableResponse<Message>(
          data: messages,
          total: messagesData["total"] as int? ?? messages.length,
          page: messagesData["page"] as int? ?? page,
          limit: messagesData["limit"] as int? ?? limit,
          totalPages: messagesData["totalPages"] as int? ?? 1,
        );
      } else {
        throw Exception(
          "Unexpected response structure: ${response.runtimeType}",
        );
      }
    } catch (e) {
      // Check if it's a 404 error (conversation not found or no messages)
      if (e.toString().contains("404") || e.toString().contains("Not Found")) {
        return PageableResponse<Message>(
          data: [],
          total: 0,
          page: page,
          limit: limit,
          totalPages: 0,
        );
      }

      throw Exception("Failed to fetch messages");
    }
  }

  @override
  Future<Message> sendMessage({
    required int conversationId,
    required String content,
    String messageType = "text",
    int? replyToMessageId,
  }) async {
    try {
      await _checkAuthentication();

      final request = SendMessageRequest(
        content: content,
        messageType: messageType,
        replyToMessageId: replyToMessageId,
      );

      final response = await _apiClient
          .post<Map<String, dynamic>, SendMessageRequest>(
            "/conversations/$conversationId/messages",
            (json) => json as Map<String, dynamic>,
            data: request,
          );

      // Extract message data from the nested structure
      final messageData = response["data"] as Map<String, dynamic>?;
      if (messageData == null) {
        throw Exception("No message data found in response");
      }

      // Parse the message from the extracted data
      final message = Message.fromJson(messageData);

      return message;
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        final data = e.response?.data;
        if (data is Map &&
            ((data["code"] == "USER_BLOCKED") ||
                (data["error"] as String? ?? "").contains("restricted"))) {
          throw Exception("USER_BLOCKED");
        }
      }
      throw Exception("Failed to send message");
    } catch (e) {
      throw Exception("Failed to send message");
    }
  }

  @override
  Future<Message> editMessage({
    required int messageId,
    required String newContent,
  }) async {
    try {
      final request = SendMessageRequest(content: newContent);

      final response = await _apiClient
          .put<Map<String, dynamic>, SendMessageRequest>(
            "/messages/$messageId",
            (json) => json as Map<String, dynamic>,
            data: request,
          );

      final messageData = response["data"] as Map<String, dynamic>?;
      if (messageData == null) {
        throw Exception("No message data found in response");
      }
      return Message.fromJson(messageData);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        final data = e.response?.data;
        if (data is Map &&
            ((data["code"] == "USER_BLOCKED") ||
                (data["error"] as String? ?? "").contains("restricted"))) {
          throw Exception("USER_BLOCKED");
        }
      }
      if (e.response?.statusCode == 400) {
        final data = e.response?.data;
        if (data is Map && data["code"] == "MESSAGE_EDIT_ONCE") {
          throw Exception("MESSAGE_EDIT_ONCE");
        }
      }
      throw Exception("Failed to edit message");
    } catch (e) {
      throw Exception("Failed to edit message");
    }
  }

  @override
  Future<void> deleteMessage(int messageId) async {
    try {
      await _apiClient.delete<Map<String, dynamic>, _EmptyRequest>(
        "/messages/$messageId",
        (json) => json as Map<String, dynamic>,
        data: _EmptyRequest(),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        final data = e.response?.data;
        if (data is Map &&
            ((data["code"] == "USER_BLOCKED") ||
                (data["error"] as String? ?? "").contains("restricted"))) {
          throw Exception("USER_BLOCKED");
        }
      }
      throw Exception("Failed to delete message");
    } catch (e) {
      throw Exception("Failed to delete message");
    }
  }

  @override
  Future<void> markMessagesAsRead(int conversationId) async {
    try {
      final request = MarkMessagesAsReadRequest(conversationId: conversationId);

      await _apiClient.put<void, MarkMessagesAsReadRequest>(
        "/conversations/$conversationId/read",
        (json) {},
        data: request,
      );
    } catch (e) {
      throw Exception("Failed to mark messages as read");
    }
  }

  @override
  Future<int> getUnreadMessageCount() async {
    try {
      await _checkAuthentication();

      final response = await _apiClient.get<UnreadCountResponse>(
        "/messages/unread-count",
        (json) => UnreadCountResponse.fromJson(json as Map<String, dynamic>),
      );
      return response.count;
    } catch (e) {
      throw Exception("Failed to get unread message count");
    }
  }

  @override
  Future<Map<String, dynamic>> safetyCheckConversation({
    required int conversationId,
    int limit = 8,
  }) async {
    await _checkAuthentication();
    final response = await _apiClient.post<Map<String, dynamic>, IJsonEncodable>(
      "/conversations/$conversationId/safety-check",
      (json) => json as Map<String, dynamic>,
      data: _SafetyCheckRequest(limit: limit),
    );
    return response;
  }

  @override
  Future<Map<String, dynamic>> translateUnseenMessages({
    required int conversationId,
    required List<int> messageIds,
    String? targetLanguage,
  }) async {
    await _checkAuthentication();
    final ids = messageIds.take(50).toList();
    try {
      final response =
          await _apiClient.post<Map<String, dynamic>, IJsonEncodable>(
        "/conversations/$conversationId/translate-unseen",
        (json) => json as Map<String, dynamic>,
        data: _TranslateUnseenRequest(
          messageIds: ids,
          targetLanguage: targetLanguage,
        ),
      );
      return response;
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        final data = e.response?.data;
        if (data is Map && data["code"] == "gemini_quota_exceeded") {
          throw ChatTranslateQuotaExceededException();
        }
      }
      rethrow;
    }
  }

  @override
  Future<MessageAttachment> uploadAttachment({
    required int messageId,
    required File file,
  }) async {
    try {
      // For file uploads, you'll need to implement multipart form data
      // This is a simplified version - you may need to adjust based on your API
      final bytes = await file.readAsBytes();
      final fileName = file.path.split("/").last;
      final mimeType = _getMimeType(fileName);

      return await uploadAttachmentFromBytes(
        messageId: messageId,
        bytes: bytes,
        fileName: fileName,
        mimeType: mimeType,
      );
    } catch (e) {
      throw Exception("Failed to upload attachment");
    }
  }

  @override
  Future<MessageAttachment> uploadAttachmentFromBytes({
    required int messageId,
    required Uint8List bytes,
    required String fileName,
    required String mimeType,
  }) async {
    try {
      final request = UploadAttachmentRequest(
        messageId: messageId,
        fileName: fileName,
        fileType: _getFileTypeFromMimeType(mimeType),
        fileSize: bytes.length,
        mimeType: mimeType,
      );

      final response = await _apiClient
          .post<MessageAttachment, UploadAttachmentRequest>(
            "/messages/$messageId/attachments",
            (json) => MessageAttachment.fromJson(json as Map<String, dynamic>),
            data: request,
          );
      return response;
    } catch (e) {
      throw Exception("Failed to upload attachment");
    }
  }

  @override
  Future<void> deleteAttachment(int attachmentId) async {
    try {
      await _apiClient.delete<Map<String, dynamic>, _EmptyRequest>(
        "/attachments/$attachmentId",
        (json) => json as Map<String, dynamic>,
        data: _EmptyRequest(),
      );
    } catch (e) {
      throw Exception("Failed to delete attachment");
    }
  }

  String _getMimeType(String fileName) {
    final extension = fileName.split(".").last.toLowerCase();
    switch (extension) {
      case "jpg":
      case "jpeg":
        return "image/jpeg";
      case "png":
        return "image/png";
      case "gif":
        return "image/gif";
      case "pdf":
        return "application/pdf";
      case "doc":
        return "application/msword";
      case "docx":
        return "application/vnd.openxmlformats-officedocument.wordprocessingml.document";
      case "txt":
        return "text/plain";
      default:
        return "application/octet-stream";
    }
  }

  String _getFileTypeFromMimeType(String mimeType) {
    if (mimeType.startsWith("image/")) {
      return "image";
    } else if (mimeType.startsWith("video/")) {
      return "video";
    } else if (mimeType.startsWith("audio/")) {
      return "audio";
    } else {
      return "document";
    }
  }

  @override
  Future<Message> setMessageReaction({
    required int messageId,
    required String reaction,
  }) async {
    await _checkAuthentication();
    try {
      final response =
          await _apiClient.post<Map<String, dynamic>, _MessageReactionBody>(
            "/messages/$messageId/reactions",
            (json) => json as Map<String, dynamic>,
            data: _MessageReactionBody(reaction: reaction),
          );
      final messageData = response["data"] as Map<String, dynamic>?;
      if (messageData == null) {
        throw Exception("No message data found in response");
      }
      return Message.fromJson(messageData);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        final data = e.response?.data;
        if (data is Map &&
            ((data["code"] == "USER_BLOCKED") ||
                (data["error"] as String? ?? "").contains("restricted"))) {
          throw Exception("USER_BLOCKED");
        }
      }
      throw Exception("Failed to set reaction");
    } catch (e) {
      throw Exception("Failed to set reaction");
    }
  }

  @override
  Future<Message> removeMessageReaction({required int messageId}) async {
    await _checkAuthentication();
    try {
      final response =
          await _apiClient.delete<Map<String, dynamic>, _EmptyRequest>(
            "/messages/$messageId/reactions",
            (json) => json as Map<String, dynamic>,
            data: _EmptyRequest(),
          );
      final messageData = response["data"] as Map<String, dynamic>?;
      if (messageData == null) {
        throw Exception("No message data found in response");
      }
      return Message.fromJson(messageData);
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        final data = e.response?.data;
        if (data is Map &&
            ((data["code"] == "USER_BLOCKED") ||
                (data["error"] as String? ?? "").contains("restricted"))) {
          throw Exception("USER_BLOCKED");
        }
      }
      throw Exception("Failed to remove reaction");
    } catch (e) {
      throw Exception("Failed to remove reaction");
    }
  }
}

class _MessageReactionBody implements IJsonEncodable {
  _MessageReactionBody({required this.reaction});
  final String reaction;

  @override
  Map<String, dynamic> toJson() => {"reaction": reaction};
}

/// Monthly Gemini chat translation quota exceeded (`403` `gemini_quota_exceeded`).
class ChatTranslateQuotaExceededException implements Exception {
  ChatTranslateQuotaExceededException();
}

class _SafetyCheckRequest implements IJsonEncodable {
  _SafetyCheckRequest({required this.limit});
  final int limit;

  @override
  Map<String, dynamic> toJson() => {"limit": limit};
}

class _TranslateUnseenRequest implements IJsonEncodable {
  _TranslateUnseenRequest({required this.messageIds, this.targetLanguage});
  final List<int> messageIds;
  final String? targetLanguage;

  @override
  Map<String, dynamic> toJson() => {
        "message_ids": messageIds,
        if (targetLanguage != null && targetLanguage!.isNotEmpty)
          "target_language_code": targetLanguage,
      };
}
