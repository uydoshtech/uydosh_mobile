import "package:flutter/foundation.dart";
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

  /// Current unread messages count
  int get unreadCount => _unreadCount;

  /// Whether there are any unread messages
  bool get hasUnreadMessages => _unreadCount > 0;

  /// Whether the state has been initialized
  bool get isInitialized => _isInitialized;

  /// The conversation id associated with the most recently observed incoming
  /// message push (best-effort; may be null).
  int? get lastIncomingConversationId => _lastIncomingConversationId;

  /// Update the unread messages count
  void updateUnreadCount(int count) {
    if (_unreadCount != count) {
      _unreadCount = count;
      _isInitialized = true;
      notifyListeners();
      logger.d("🔔 UnreadMessagesState: Updated unread count to $count");
    }
  }

  /// Increment unread count (when new message arrives)
  void incrementUnreadCount({int? conversationId}) {
    _unreadCount++;
    _isInitialized = true;
    _lastIncomingConversationId = conversationId;
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

  /// Clear all unread messages (when all messages are read)
  void clearUnreadCount() {
    if (_unreadCount > 0) {
      _unreadCount = 0;
      _isInitialized = true;
      notifyListeners();
      logger.d("🔔 UnreadMessagesState: Cleared unread count");
    }
  }

  /// Reset the state
  void reset() {
    _unreadCount = 0;
    _isInitialized = false;
    notifyListeners();
  }
}
