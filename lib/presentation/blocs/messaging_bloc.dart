import "package:flutter_bloc/flutter_bloc.dart";
import "package:flutter/foundation.dart";
import "package:freezed_annotation/freezed_annotation.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/state/achievement_unlock_state.dart";
import "package:uy_dosh/base/util/error_message_helper.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/domain/models/message.dart";
import "package:uy_dosh/domain/services/gamification_service.dart";
import "package:uy_dosh/domain/services/messaging_service.dart";

part "messaging_bloc.freezed.dart";

// Events
abstract class MessagingEvent {}

class FetchConversations extends MessagingEvent {

  FetchConversations({this.page = 1, this.limit = 20});
  final int page;
  final int limit;
}

class FetchParticipantConversations extends MessagingEvent {

  FetchParticipantConversations({this.page = 1, this.limit = 20});
  final int page;
  final int limit;
}

class CreateConversation extends MessagingEvent {

  CreateConversation({required this.listingId, required this.participantId});
  final int listingId;
  final int participantId;
}

class FetchMessages extends MessagingEvent {

  FetchMessages({required this.conversationId, this.page = 1, this.limit = 50});
  final int conversationId;
  final int page;
  final int limit;
}

class SendMessage extends MessagingEvent {

  SendMessage({
    required this.conversationId,
    required this.content,
    this.messageType = "text",
    this.replyToMessageId,
  });
  final int conversationId;
  final String content;
  final String messageType;
  final int? replyToMessageId;
}

class MarkMessagesAsRead extends MessagingEvent {

  MarkMessagesAsRead({required this.conversationId});
  final int conversationId;
}

class RefreshConversations extends MessagingEvent {}

class RefreshMessages extends MessagingEvent {

  RefreshMessages({required this.conversationId});
  final int conversationId;
}

class ClearConversations extends MessagingEvent {}

// States
@freezed
class MessagingState with _$MessagingState {
  const factory MessagingState.initial() = MessagingInitial;
  const factory MessagingState.loading() = MessagingLoading;
  const factory MessagingState.conversationsLoaded({
    required List<ConversationSummary> conversations,
    required bool hasMore,
    required int currentPage,
  }) = ConversationsLoaded;
  const factory MessagingState.conversationsCleared() = ConversationsCleared;
  const factory MessagingState.messagesLoaded({
    required List<Message> messages,
    required bool hasMore,
    required int currentPage,
    required int conversationId,
  }) = MessagesLoaded;
  const factory MessagingState.conversationCreated({
    required Conversation conversation,
  }) = ConversationCreated;
  const factory MessagingState.messageSent({required Message message}) =
      MessageSent;
  const factory MessagingState.messagesMarkedAsRead({
    required int conversationId,
    required int markedCount,
  }) = MessagesMarkedAsRead;
  const factory MessagingState.error({required String message}) =
      MessagingError;
}

// BLoC
class MessagingBloc extends Bloc<MessagingEvent, MessagingState> {

  MessagingBloc(this._messagingService, this._gamificationService)
      : super(const MessagingInitial()) {
    on<FetchConversations>(_onFetchConversations);
    on<FetchParticipantConversations>(_onFetchParticipantConversations);
    on<CreateConversation>(_onCreateConversation);
    on<FetchMessages>(_onFetchMessages);
    on<SendMessage>(_onSendMessage);
    on<MarkMessagesAsRead>(_onMarkMessagesAsRead);
    on<RefreshConversations>(_onRefreshConversations);
    on<RefreshMessages>(_onRefreshMessages);
    on<ClearConversations>(_onClearConversations);
  }
  final IMessagingService _messagingService;
  final IGamificationService _gamificationService;

  // Local cache for conversations to implement frontend workaround
  List<ConversationSummary> _cachedConversations = [];

  Future<void> _onFetchConversations(
    FetchConversations event,
    Emitter<MessagingState> emit,
  ) async {
    try {
      if (event.page == 1) {
        emit(const MessagingLoading());
      }

      final response = await _messagingService.getConversations(
        page: event.page,
        limit: event.limit,
      );

      // Cache conversations for frontend workaround
      if (event.page == 1) {
        _cachedConversations = List.from(response.data);
      } else {
        _cachedConversations.addAll(response.data);
      }

      emit(
        ConversationsLoaded(
          conversations: response.data,
          hasMore: response.hasMore,
          currentPage: event.page,
        ),
      );
    } catch (e) {
      // Check if this is an authentication error
      final errorMessage = e.toString();
      final isAuthError =
          errorMessage.contains("401") ||
          errorMessage.contains("Unauthorized") ||
          errorMessage.contains("Invalid or expired session token");

      if (isAuthError) {
        emit(
          const MessagingError(
            message: "Authentication required. Please log in again.",
          ),
        );
      } else {
        emit(
          MessagingError(message: ErrorMessageHelper.sanitizeErrorMessage(e)),
        );
      }
    }
  }

  Future<void> _onFetchParticipantConversations(
    FetchParticipantConversations event,
    Emitter<MessagingState> emit,
  ) async {
    try {
      if (event.page == 1) {
        emit(const MessagingLoading());
      }

      final response = await _messagingService.getParticipantConversations(
        page: event.page,
        limit: event.limit,
      );

      emit(
        ConversationsLoaded(
          conversations: response.data,
          hasMore: response.hasMore,
          currentPage: event.page,
        ),
      );
    } catch (e) {
      emit(MessagingError(message: ErrorMessageHelper.sanitizeErrorMessage(e)));
    }
  }

  Future<void> _onCreateConversation(
    CreateConversation event,
    Emitter<MessagingState> emit,
  ) async {
    try {
      emit(const MessagingLoading());

      final conversation = await _messagingService.createConversation(
        listingId: event.listingId,
        participantId: event.participantId,
      );

      emit(ConversationCreated(conversation: conversation));
    } catch (e) {
      emit(MessagingError(message: ErrorMessageHelper.sanitizeErrorMessage(e)));
    }
  }

  Future<void> _onFetchMessages(
    FetchMessages event,
    Emitter<MessagingState> emit,
  ) async {
    try {
      if (kDebugMode) {
        logger.d("🔄 [MessagingBloc] Starting to fetch messages...");
        logger.d("   - Conversation ID: ${event.conversationId}");
        logger.d("   - Page: ${event.page}");
        logger.d("   - Limit: ${event.limit}");
      }

      if (event.page == 1) {
        if (kDebugMode) {
          logger.d("🔄 [MessagingBloc] Emitting loading state...");
        }
        emit(const MessagingLoading());
      }

      if (kDebugMode) {
        logger.d("🌐 [MessagingBloc] Calling messaging service...");
      }
      final response = await _messagingService.getMessages(
        conversationId: event.conversationId,
        page: event.page,
        limit: event.limit,
      );

      if (kDebugMode) {
        logger.d("✅ [MessagingBloc] Messages fetched successfully!");
        logger.d("   - Messages count: ${response.data.length}");
        logger.d("   - Has more: ${response.hasMore}");
        logger.d("   - Current page: ${event.page}");
      }

      if (kDebugMode) {
        logger.d("🔄 [MessagingBloc] Emitting messages loaded state...");
      }
      emit(
        MessagesLoaded(
          messages: response.data,
          hasMore: response.hasMore,
          currentPage: event.page,
          conversationId: event.conversationId,
        ),
      );
      if (kDebugMode) {
        logger.d("✅ [MessagingBloc] Messages loaded state emitted successfully!");
      }
    } catch (e) {
      if (kDebugMode) {
        logger.d("❌ [MessagingBloc] Error fetching messages: $e");
        logger.d("❌ [MessagingBloc] Error type: ${e.runtimeType}");
        logger.d("❌ [MessagingBloc] Error details: $e");
      }
      emit(MessagingError(message: ErrorMessageHelper.sanitizeErrorMessage(e)));
    }
  }

  Future<void> _onSendMessage(
    SendMessage event,
    Emitter<MessagingState> emit,
  ) async {
    try {
      final message = await _messagingService.sendMessage(
        conversationId: event.conversationId,
        content: event.content,
        messageType: event.messageType,
        replyToMessageId: event.replyToMessageId,
      );

      // Record first message for achievement (runs at source - guaranteed)
      try {
        final achievement = await _gamificationService.recordFirstMessage();
        if (achievement != null) {
          AchievementUnlockState().setPendingAchievement(achievement);
        }
      } catch (e) {
        if (kDebugMode) {
          logger.d(
            "❌ [MessagingBloc] Error recording first message achievement: $e",
          );
        }
      }

      emit(MessageSent(message: message));
    } catch (e) {
      emit(MessagingError(message: ErrorMessageHelper.sanitizeErrorMessage(e)));
    }
  }

  Future<void> _onMarkMessagesAsRead(
    MarkMessagesAsRead event,
    Emitter<MessagingState> emit,
  ) async {
    try {
      await _messagingService.markMessagesAsRead(event.conversationId);

      // Frontend workaround: Update local cache to set unread count to 0
      final conversationIndex = _cachedConversations.indexWhere(
        (conv) => conv.id == event.conversationId,
      );

      if (conversationIndex != -1) {
        final updatedConversation = _cachedConversations[conversationIndex]
            .copyWith(unreadCount: 0);
        _cachedConversations[conversationIndex] = updatedConversation;

        if (kDebugMode) {
          logger.d(
            "🔧 [MessagingBloc] Frontend workaround: Set unread count to 0 for conversation ${event.conversationId}",
          );
        }
      }

      emit(
        MessagesMarkedAsRead(
          conversationId: event.conversationId,
          markedCount: 0, // We don't get the count back from the service
        ),
      );
    } catch (e) {
      emit(MessagingError(message: ErrorMessageHelper.sanitizeErrorMessage(e)));
    }
  }

  Future<void> _onRefreshConversations(
    RefreshConversations event,
    Emitter<MessagingState> emit,
  ) async {
    // If we have cached conversations, emit them immediately for better UX
    if (_cachedConversations.isNotEmpty) {
      emit(
        ConversationsLoaded(
          conversations: _cachedConversations,
          hasMore: false, // We don't know if there are more pages
          currentPage: 1,
        ),
      );
    }

    // Then fetch fresh data from server
    try {
      add(FetchConversations(page: 1));
    } catch (e) {
      // Check if this is an authentication error
      final errorMessage = e.toString();
      final isAuthError =
          errorMessage.contains("401") ||
          errorMessage.contains("Unauthorized") ||
          errorMessage.contains("Invalid or expired session token");

      if (isAuthError) {
        emit(
          const MessagingError(
            message: "Authentication required. Please log in again.",
          ),
        );
      } else {
        emit(
          MessagingError(message: ErrorMessageHelper.sanitizeErrorMessage(e)),
        );
      }
    }
  }

  Future<void> _onRefreshMessages(
    RefreshMessages event,
    Emitter<MessagingState> emit,
  ) async {
    add(FetchMessages(conversationId: event.conversationId, page: 1));
  }

  Future<void> _onClearConversations(
    ClearConversations event,
    Emitter<MessagingState> emit,
  ) async {
    // Clear cached conversations and emit cleared state
    _cachedConversations.clear();
    emit(const MessagingState.conversationsCleared());
  }
}
