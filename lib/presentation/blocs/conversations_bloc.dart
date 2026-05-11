import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/util/error_message_helper.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/domain/services/messaging_service.dart";

// Conversations-only bloc to keep inbox UI insulated from chat message states.

sealed class ConversationsEvent {
  const ConversationsEvent();
}

class ConversationsFetch extends ConversationsEvent {
  const ConversationsFetch({this.page = 1, this.limit = 20});
  final int page;
  final int limit;
}

class ConversationsRefresh extends ConversationsEvent {
  const ConversationsRefresh();
}

class ConversationsClear extends ConversationsEvent {
  const ConversationsClear();
}

class ConversationsArchive extends ConversationsEvent {
  const ConversationsArchive({required this.conversationId});
  final int conversationId;
}

class ConversationsUnarchive extends ConversationsEvent {
  const ConversationsUnarchive({required this.conversationId});
  final int conversationId;
}

sealed class ConversationsState {
  const ConversationsState();
}

class ConversationsInitial extends ConversationsState {
  const ConversationsInitial();
}

class ConversationsLoading extends ConversationsState {
  const ConversationsLoading();
}

class ConversationsLoaded extends ConversationsState {
  const ConversationsLoaded({
    required this.conversations,
    required this.hasMore,
    required this.currentPage,
  });

  final List<ConversationSummary> conversations;
  final bool hasMore;
  final int currentPage;
}

class ConversationsCleared extends ConversationsState {
  const ConversationsCleared();
}

class ConversationsError extends ConversationsState {
  const ConversationsError({required this.message});
  final String message;
}

class ConversationsBloc extends Bloc<ConversationsEvent, ConversationsState> {
  ConversationsBloc(this._messagingService) : super(const ConversationsInitial()) {
    on<ConversationsFetch>(_onFetch);
    on<ConversationsRefresh>(_onRefresh);
    on<ConversationsClear>(_onClear);
    on<ConversationsArchive>(_onArchive);
    on<ConversationsUnarchive>(_onUnarchive);
  }

  final IMessagingService _messagingService;

  Future<void> _onFetch(
    ConversationsFetch event,
    Emitter<ConversationsState> emit,
  ) async {
    try {
      if (event.page == 1) {
        emit(const ConversationsLoading());
      }

      final response = await _messagingService.getConversations(
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
      emit(ConversationsError(message: ErrorMessageHelper.sanitizeErrorMessage(e)));
    }
  }

  Future<void> _onRefresh(
    ConversationsRefresh event,
    Emitter<ConversationsState> emit,
  ) async {
    add(const ConversationsFetch(page: 1));
  }

  void _onClear(
    ConversationsClear event,
    Emitter<ConversationsState> emit,
  ) {
    emit(const ConversationsCleared());
  }

  Future<void> _onArchive(
    ConversationsArchive event,
    Emitter<ConversationsState> emit,
  ) async {
    try {
      await _messagingService.archiveConversation(event.conversationId);
      add(const ConversationsRefresh());
    } catch (e) {
      emit(ConversationsError(message: ErrorMessageHelper.sanitizeErrorMessage(e)));
    }
  }

  Future<void> _onUnarchive(
    ConversationsUnarchive event,
    Emitter<ConversationsState> emit,
  ) async {
    try {
      await _messagingService.unarchiveConversation(event.conversationId);
      add(const ConversationsRefresh());
    } catch (e) {
      emit(ConversationsError(message: ErrorMessageHelper.sanitizeErrorMessage(e)));
    }
  }
}

