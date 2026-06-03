import "dart:convert";

import "package:flutter/foundation.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/domain/models/support_chat_thread.dart";
import "package:uy_dosh/domain/services/support_chat_service.dart";

/// Tracks whether the user has unseen support-chat replies so entry points
/// (e.g. the profile "Contact support" button) can surface a notification dot.
///
/// Detection is intentionally local-only — no backend read-tracking is needed.
/// We remember, per thread, the timestamp of the newest message the user has
/// already viewed. A thread counts as unread when its latest message is newer
/// than that mark. Because a user can only post from inside a thread (which
/// marks it seen via [markThreadSeen]), any advance past the seen mark can only
/// come from a support reply.
class SupportUnreadState extends ChangeNotifier {
  factory SupportUnreadState() => _instance;
  SupportUnreadState._internal();
  static final SupportUnreadState _instance = SupportUnreadState._internal();

  static const String _seenKey = "support_unread_seen_v1";
  static const String _seededKey = "support_unread_seeded_v1";

  bool _hasUnread = false;
  bool _loaded = false;
  bool _refreshing = false;

  /// threadId -> epoch millis of the newest message the user has seen.
  Map<int, int> _seen = {};

  /// Most recent thread snapshot, so [markThreadSeen] can recompute without a
  /// network round-trip.
  List<SupportChatThread> _threads = [];

  bool get hasUnread => _hasUnread;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_seenKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        _seen = decoded.map(
          (k, v) => MapEntry(int.parse(k), (v as num).toInt()),
        );
      }
    } catch (e) {
      logger.d("SupportUnreadState: failed to load seen map: $e");
      _seen = {};
    }
    _loaded = true;
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(
        _seen.map((k, v) => MapEntry(k.toString(), v)),
      );
      await prefs.setString(_seenKey, encoded);
    } catch (e) {
      logger.d("SupportUnreadState: failed to persist seen map: $e");
    }
  }

  /// Fetches the user's support threads and recomputes [hasUnread].
  Future<void> refresh() async {
    if (_refreshing) return;
    _refreshing = true;
    try {
      await _ensureLoaded();
      final response = await getIt<ISupportChatService>().getUserThreads(
        page: 1,
        limit: 50,
      );
      _threads = response.threads;

      final prefs = await SharedPreferences.getInstance();
      final seeded = prefs.getBool(_seededKey) ?? false;

      if (!seeded) {
        // First run after this feature ships: treat everything already in the
        // inbox as seen so existing users don't get a surprise dot on upgrade.
        for (final thread in _threads) {
          final last = thread.lastMessage;
          if (last != null) {
            _seen[thread.id] = last.createdAt.millisecondsSinceEpoch;
          }
        }
        await _persist();
        await prefs.setBool(_seededKey, true);
        _setHasUnread(false);
        return;
      }

      _recompute();
    } catch (e) {
      logger.d("SupportUnreadState: refresh failed: $e");
    } finally {
      _refreshing = false;
    }
  }

  /// Records that the user has viewed [threadId] up to [latestMessageTime],
  /// then recomputes [hasUnread] from the cached thread snapshot.
  Future<void> markThreadSeen(
    int threadId,
    DateTime latestMessageTime,
  ) async {
    await _ensureLoaded();
    final ms = latestMessageTime.millisecondsSinceEpoch;
    if (ms > (_seen[threadId] ?? 0)) {
      _seen[threadId] = ms;
      await _persist();
    }
    _recompute();
  }

  void _recompute() {
    var unread = false;
    for (final thread in _threads) {
      final last = thread.lastMessage;
      if (last == null) continue;
      if (last.createdAt.millisecondsSinceEpoch > (_seen[thread.id] ?? 0)) {
        unread = true;
        break;
      }
    }
    _setHasUnread(unread);
  }

  void _setHasUnread(bool value) {
    if (_hasUnread == value) return;
    _hasUnread = value;
    notifyListeners();
  }
}
