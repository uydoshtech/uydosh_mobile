import "package:flutter/foundation.dart";
import "package:flutter/scheduler.dart";
import "package:uy_dosh/base/logger/logger.dart";

/// Global state to track unread messages count
/// This is used to show the blinking green dot indicator in the navigation bar
class UnreadMessagesState extends ChangeNotifier {
  factory UnreadMessagesState() => _instance;
  UnreadMessagesState._internal();
  static final UnreadMessagesState _instance = UnreadMessagesState._internal();

  int _unreadCount = 0;
  bool _isInitialized = false;
  int? _lastIncomingConversationId;
  int? _activeConversationId;
  final Map<int, int> _conversationUnreadCounts = {};

  /// Current unread messages count
  int get unreadCount => _unreadCount;

  /// Whether there are any unread messages
  bool get hasUnreadMessages => _unreadCount > 0;

  bool hasUnreadForConversation(int conversationId) =>
      (_conversationUnreadCounts[conversationId] ?? 0) > 0;

  /// Whether the state has been initialized
  bool get isInitialized => _isInitialized;

  /// The conversation id associated with the most recently observed incoming
  /// message push (best-effort; may be null).
  int? get lastIncomingConversationId => _lastIncomingConversationId;

  /// Conversation currently open in the chat screen (best-effort).
  int? get activeConversationId => _activeConversationId;

  void setActiveConversationId(int? conversationId) {
    if (_activeConversationId == conversationId) return;
    _activeConversationId = conversationId;
    _safeNotifyListeners();
  }

  /// Notifies listeners, but defers the notification to the next frame if
  /// we are currently inside a build/layout phase. This avoids
  /// "setState() or markNeedsBuild() called during build" errors when the
  /// state is mutated from another widget's `initState` while ancestor
  /// `ListenableBuilder`s are still being built.
  void _safeNotifyListeners() {
    final phase = SchedulerBinding.instance.schedulerPhase;
    final isBuilding = phase == SchedulerPhase.persistentCallbacks ||
        phase == SchedulerPhase.midFrameMicrotasks ||
        phase == SchedulerPhase.transientCallbacks;
    if (isBuilding) {
      SchedulerBinding.instance.addPostFrameCallback((_) => notifyListeners());
    } else {
      notifyListeners();
    }
  }

  /// Update the unread messages count
  void updateUnreadCount(int count) {
    if (_unreadCount != count) {
      _unreadCount = count;
      _isInitialized = true;
      notifyListeners();
      logger.d("🔔 UnreadMessagesState: Updated unread count to $count");
    }
  }

  void updateFromConversations(Map<int, int> unreadCountsByConversation) {
    _conversationUnreadCounts
      ..clear()
      ..addAll(unreadCountsByConversation);
    final nextUnreadCount = unreadCountsByConversation.values.fold<int>(
      0,
      (sum, count) => sum + count,
    );
    if (_unreadCount != nextUnreadCount || !_isInitialized) {
      _unreadCount = nextUnreadCount;
      _isInitialized = true;
      notifyListeners();
      logger.d(
          "🔔 UnreadMessagesState: Updated unread count to $nextUnreadCount");
      return;
    }
    _isInitialized = true;
    _safeNotifyListeners();
  }

  /// Increment unread count (when new message arrives)
  void incrementUnreadCount({int? conversationId}) {
    _unreadCount++;
    _isInitialized = true;
    _lastIncomingConversationId = conversationId;
    if (conversationId != null) {
      _conversationUnreadCounts[conversationId] =
          (_conversationUnreadCounts[conversationId] ?? 0) + 1;
    }
    notifyListeners();
    logger.d(
      "🔔 UnreadMessagesState: Incremented unread count to $_unreadCount",
    );
  }

  /// Decrement unread count (when message is read)
  void decrementUnreadCount() {
    if (_unreadCount > 0) {
      _unreadCount--;
      _isInitialized = true;
      notifyListeners();
      logger.d(
        "🔔 UnreadMessagesState: Decremented unread count to $_unreadCount",
      );
    }
  }

  void clearConversationUnreadCount(int conversationId) {
    final count = _conversationUnreadCounts.remove(conversationId) ?? 0;
    final nextUnreadCount =
        (_unreadCount - count).clamp(0, _unreadCount).toInt();
    if (_unreadCount == nextUnreadCount && count == 0) return;
    _unreadCount = nextUnreadCount;
    _isInitialized = true;
    notifyListeners();
    logger.d(
      "🔔 UnreadMessagesState: Cleared unread count for conversation $conversationId",
    );
  }

  /// Clear all unread messages (when all messages are read)
  void clearUnreadCount() {
    if (_unreadCount > 0) {
      _unreadCount = 0;
      _conversationUnreadCounts.clear();
      _isInitialized = true;
      notifyListeners();
      logger.d("🔔 UnreadMessagesState: Cleared unread count");
    }
  }

  /// Reset the state
  void reset() {
    _unreadCount = 0;
    _isInitialized = false;
    _conversationUnreadCounts.clear();
    notifyListeners();
  }
}
