import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/domain/services/listing_group_service.dart";

class _ShortlistKeyNotifier extends ChangeNotifier {}

/// Optimistic shortlist membership keyed by `(groupListingId, housingListingId)`.
class GroupShortlistState extends ChangeNotifier {
  factory GroupShortlistState() => _instance;
  GroupShortlistState._internal();
  static final GroupShortlistState _instance = GroupShortlistState._internal();

  final Map<int, int> _countByGroupListingId = {};
  final Map<String, bool> _shortlistedByKey = {};
  final Map<String, _ShortlistKeyNotifier> _notifiers = {};

  String _key(int groupListingId, int housingListingId) =>
      "$groupListingId:$housingListingId";

  int shortlistCountForGroup(int groupListingId) =>
      _countByGroupListingId[groupListingId] ?? 0;

  void setShortlistCountForGroup(int groupListingId, int count) {
    if (_countByGroupListingId[groupListingId] == count) return;
    _countByGroupListingId[groupListingId] = count;
    notifyListeners();
  }

  bool isShortlisted({
    required int groupListingId,
    required int housingListingId,
  }) =>
      _shortlistedByKey[_key(groupListingId, housingListingId)] ?? false;

  Listenable listenableFor({
    required int groupListingId,
    required int housingListingId,
  }) {
    return _notifiers.putIfAbsent(
      _key(groupListingId, housingListingId),
      _ShortlistKeyNotifier.new,
    );
  }

  void _notifyKey(int groupListingId, int housingListingId) {
    final n = _notifiers[_key(groupListingId, housingListingId)];
    n?.notifyListeners();
  }

  void seedShortlisted({
    required int groupListingId,
    required int housingListingId,
    required bool isShortlisted,
  }) {
    _shortlistedByKey[_key(groupListingId, housingListingId)] = isShortlisted;
    _notifyKey(groupListingId, housingListingId);
  }

  Future<bool> toggle({
    required int groupListingId,
    required int housingListingId,
  }) async {
    final key = _key(groupListingId, housingListingId);
    final was = _shortlistedByKey[key] ?? false;
    _shortlistedByKey[key] = !was;
    _adjustCount(groupListingId, delta: was ? -1 : 1);
    _notifyKey(groupListingId, housingListingId);
    notifyListeners();

    try {
      final nowShortlisted =
          await getIt<IListingGroupService>().toggleShortlist(
        groupListingId: groupListingId,
        housingListingId: housingListingId,
      );
      _shortlistedByKey[key] = nowShortlisted;
      _notifyKey(groupListingId, housingListingId);
      notifyListeners();
      return nowShortlisted;
    } catch (_) {
      _shortlistedByKey[key] = was;
      _adjustCount(groupListingId, delta: was ? 1 : -1);
      _notifyKey(groupListingId, housingListingId);
      notifyListeners();
      rethrow;
    }
  }

  void _adjustCount(int groupListingId, {required int delta}) {
    final current = _countByGroupListingId[groupListingId] ?? 0;
    _countByGroupListingId[groupListingId] =
        (current + delta).clamp(0, 9999);
  }

  Future<void> refreshCount(int groupListingId) async {
    try {
      final count = await getIt<IListingGroupService>().getShortlistCount(
        groupListingId: groupListingId,
      );
      setShortlistCountForGroup(groupListingId, count);
    } catch (_) {}
  }
}
