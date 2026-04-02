import "package:flutter_test/flutter_test.dart";
import "package:mocktail/mocktail.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/domain/models/message.dart";
import "package:uy_dosh/domain/models/pageable_response.dart";
import "package:uy_dosh/domain/services/gamification_service.dart";
import "package:uy_dosh/domain/services/messaging_service.dart";
import "package:uy_dosh/presentation/blocs/messaging_bloc.dart";

class MockMessagingService extends Mock implements IMessagingService {}

class MockGamificationService extends Mock implements IGamificationService {}

void main() {
  late MockMessagingService mockMessagingService;
  late MockGamificationService mockGamificationService;

  setUp(() {
    mockMessagingService = MockMessagingService();
    mockGamificationService = MockGamificationService();
  });

  group("MessagingBloc", () {
    test("initial state is MessagingInitial", () {
      final bloc = MessagingBloc(mockMessagingService, mockGamificationService);
      expect(bloc.state, isA<MessagingInitial>());
      bloc.close();
    });

    test("emits [loading, conversationsLoaded] when FetchConversations succeeds",
        () async {
      const conversations = [
        ConversationSummary(
          id: 1,
          listingId: 1,
          initiatorId: 1,
          participantId: 2,
          isActive: true,
          createdAt: "2024-01-01",
          updatedAt: "2024-01-01",
        ),
      ];
      when(() => mockMessagingService.getConversations(
            page: any(named: "page"),
            limit: any(named: "limit"),
          )).thenAnswer((_) async => const PageableResponse<ConversationSummary>(
                data: conversations,
                total: 1,
                page: 1,
                limit: 20,
                totalPages: 1,
              ));

      final bloc = MessagingBloc(mockMessagingService, mockGamificationService);

      bloc.add(FetchConversations());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<MessagingLoading>(),
          isA<ConversationsLoaded>(),
        ]),
      );

      bloc.close();
    });

    test("emits [loading, error] when FetchConversations fails", () async {
      when(() => mockMessagingService.getConversations(
            page: any(named: "page"),
            limit: any(named: "limit"),
          )).thenThrow(Exception("Network error"));

      final bloc = MessagingBloc(mockMessagingService, mockGamificationService);

      bloc.add(FetchConversations());

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<MessagingLoading>(),
          isA<MessagingError>(),
        ]),
      );

      bloc.close();
    });

    test("emits [loading, messagesLoaded] when FetchMessages succeeds", () async {
      const messages = [
        Message(
          id: 1,
          conversationId: 1,
          senderId: 1,
          content: "Hello",
          messageType: "text",
          createdAt: "2024-01-01",
          updatedAt: "2024-01-01",
        ),
      ];
      when(() => mockMessagingService.getMessages(
            conversationId: any(named: "conversationId"),
            page: any(named: "page"),
            limit: any(named: "limit"),
          )).thenAnswer((_) async => const PageableResponse<Message>(
                data: messages,
                total: 1,
                page: 1,
                limit: 50,
                totalPages: 1,
              ));

      final bloc = MessagingBloc(mockMessagingService, mockGamificationService);

      bloc.add(FetchMessages(conversationId: 1));

      await expectLater(
        bloc.stream,
        emitsInOrder([
          isA<MessagingLoading>(),
          isA<MessagesLoaded>(),
        ]),
      );

      bloc.close();
    });

    test("emits [messageSent] when SendMessage succeeds", () async {
      const message = Message(
        id: 1,
        conversationId: 1,
        senderId: 1,
        content: "Hello",
        messageType: "text",
        createdAt: "2024-01-01",
        updatedAt: "2024-01-01",
      );
      when(() => mockMessagingService.sendMessage(
            conversationId: any(named: "conversationId"),
            content: any(named: "content"),
            messageType: any(named: "messageType"),
            replyToMessageId: any(named: "replyToMessageId"),
          )).thenAnswer((_) async => message);

      when(() => mockGamificationService.recordFirstMessage())
          .thenAnswer((_) async => null);

      final bloc = MessagingBloc(mockMessagingService, mockGamificationService);

      bloc.add(SendMessage(conversationId: 1, content: "Hello"));

      await expectLater(
        bloc.stream,
        emits(isA<MessageSent>()),
      );

      bloc.close();
    });

    test("emits [conversationsCleared] when ClearConversations is added",
        () async {
      final bloc = MessagingBloc(mockMessagingService, mockGamificationService);

      bloc.add(ClearConversations());

      await expectLater(
        bloc.stream,
        emits(isA<ConversationsCleared>()),
      );

      bloc.close();
    });
  });
}
