import "package:flutter_test/flutter_test.dart";
import "package:uy_dosh/domain/models/conversation_member.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_participant_avatar_stack.dart";

void main() {
  group("ChatParticipantAvatarStack.orderWithCurrentUserFirst", () {
    ConversationMemberSummary member(int id) => ConversationMemberSummary(
          userId: id,
          name: "User $id",
          avatarUrl: null,
        );

    test("puts current user first while preserving relative order of others",
        () {
      final participants = [member(10), member(20), member(30)];

      final ordered = ChatParticipantAvatarStack.orderWithCurrentUserFirst(
        participants,
        20,
      );

      expect(ordered.map((m) => m.userId).toList(), [20, 10, 30]);
    });

    test("returns original list when current user is absent or null", () {
      final participants = [member(10), member(20)];

      expect(
        ChatParticipantAvatarStack.orderWithCurrentUserFirst(participants, null),
        participants,
      );
      expect(
        ChatParticipantAvatarStack.orderWithCurrentUserFirst(participants, 99),
        participants,
      );
    });

    ConversationMemberSummary landlordMember(int id) => ConversationMemberSummary(
          userId: id,
          name: "Landlord $id",
          avatarUrl: null,
          role: "landlord_guest",
        );

    test("puts landlord second when landlordSecond is true", () {
      final participants = [
        member(10),
        landlordMember(20),
        member(30),
      ];

      final ordered = ChatParticipantAvatarStack.orderWithCurrentUserFirst(
        participants,
        30,
        landlordSecond: true,
      );

      expect(ordered.map((m) => m.userId).toList(), [30, 20, 10]);
    });

    test("puts landlord first when current user is absent and landlordSecond is true",
        () {
      final participants = [
        member(10),
        landlordMember(20),
        member(30),
      ];

      final ordered = ChatParticipantAvatarStack.orderWithCurrentUserFirst(
        participants,
        null,
        landlordSecond: true,
      );

      expect(ordered.map((m) => m.userId).toList(), [20, 10, 30]);
    });
  });
}
