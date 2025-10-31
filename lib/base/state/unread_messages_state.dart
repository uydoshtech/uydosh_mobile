import 'package:flutter/foundation.dart';
import 'package:uy_dosh/base/logger/logger.dart';

/// Global state to track unread messages count
/// This is used to show the blinking red dot indicator in the navigation bar
class UnreadMessagesState extends ChangeNotifier {
  static final UnreadMessagesState _instance = UnreadMessagesState._internal();
  factory UnreadMessagesState() => _instance;
  UnreadMessagesState._internal();

  int _unreadCount = 0;
  bool _isInitialized = false;

  /// Current unread messages count
  int get unreadCount => _unreadCount;

  /// Whether there are any unread messages
  bool get hasUnreadMessages => _unreadCount > 0;

  /// Whether the state has been initialized
  bool get isInitialized => _isInitialized;

  /// Update the unread messages count
  void updateUnreadCount(int count) {
    if (_unreadCount != count) {
      _unreadCount = count;
      _isInitialized = true;
      notifyListeners();
      logger.d('🔔 UnreadMessagesState: Updated unread count to $count');
    }
  }

  /// Increment unread count (when new message arrives)
  void incrementUnreadCount() {
    _unreadCount++;
    _isInitialized = true;
    notifyListeners();
    logger.d(
      '🔔 UnreadMessagesState: Incremented unread count to $_unreadCount',
    );
  }

  /// Decrement unread count (when message is read)
  void decrementUnreadCount() {
    if (_unreadCount > 0) {
      _unreadCount--;
      _isInitialized = true;
      notifyListeners();
      logger.d(
        '🔔 UnreadMessagesState: Decremented unread count to $_unreadCount',
      );
    }
  }

  /// Clear all unread messages (when all messages are read)
  void clearUnreadCount() {
    if (_unreadCount > 0) {
      _unreadCount = 0;
      _isInitialized = true;
      notifyListeners();
      logger.d('🔔 UnreadMessagesState: Cleared unread count');
    }
  }

  /// Reset the state
  void reset() {
    _unreadCount = 0;
    _isInitialized = false;
    notifyListeners();
  }
}
