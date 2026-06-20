import "dart:convert";

import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/logger/logger.dart";

/// Persists unsent chat composer text per conversation so drafts survive
/// leaving and re-opening a thread (and app restarts).
class ChatComposerDraftState {
  factory ChatComposerDraftState() => _instance;
  ChatComposerDraftState._internal();
  static final ChatComposerDraftState _instance =
      ChatComposerDraftState._internal();

  static const String _prefsKey = "chat_composer_drafts_v1";

  final Map<int, String> _drafts = {};
  bool _loaded = false;
  Future<void>? _loadFuture;

  Future<void> initialize() => ensureLoaded();

  Future<void> ensureLoaded() {
    return _loadFuture ??= _loadFromPrefs();
  }

  String? draftFor(int conversationId) {
    final text = _drafts[conversationId];
    if (text == null || text.isEmpty) return null;
    return text;
  }

  void setDraft(int conversationId, String text) {
    if (text.isEmpty) {
      _drafts.remove(conversationId);
    } else {
      _drafts[conversationId] = text;
    }
    _persist();
  }

  void clearDraft(int conversationId) {
    if (!_drafts.containsKey(conversationId)) return;
    _drafts.remove(conversationId);
    _persist();
  }

  Future<void> clearAll() async {
    _drafts.clear();
    _loaded = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
    } catch (e) {
      logger.d("Error clearing ChatComposerDraftState: $e");
    }
  }

  Future<void> _loadFromPrefs() async {
    if (_loaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          _drafts
            ..clear()
            ..addAll(
              decoded.map(
                (key, value) => MapEntry(
                  int.parse(key.toString()),
                  value.toString(),
                ),
              ),
            );
        }
      }
    } catch (e) {
      logger.d("Error loading ChatComposerDraftState: $e");
    }
    _loaded = true;
  }

  Future<void> _persist() async {
    await ensureLoaded();
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_drafts.isEmpty) {
        await prefs.remove(_prefsKey);
        return;
      }
      final encoded = jsonEncode(
        _drafts.map((key, value) => MapEntry(key.toString(), value)),
      );
      await prefs.setString(_prefsKey, encoded);
    } catch (e) {
      logger.d("Error saving ChatComposerDraftState: $e");
    }
  }
}
