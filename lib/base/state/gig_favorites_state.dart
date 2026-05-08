import "package:flutter/material.dart";
import "package:uy_dosh/domain/models/gig/gig_offer.dart";
import "package:uy_dosh/domain/models/gig/gig_request.dart";

class _IdNotifier extends ChangeNotifier {}

/// Tracks bookmarked gig [GigOffer]s and [GigRequest]s with the same
/// per-id notification pattern as [FavoritesState].
class GigFavoritesState extends ChangeNotifier {
  factory GigFavoritesState() => _instance;
  GigFavoritesState._internal();
  static final GigFavoritesState _instance = GigFavoritesState._internal();

  final Set<int> _favoriteOfferIds = {};
  final Set<int> _favoriteRequestIds = {};
  final Map<int, _IdNotifier> _offerNotifiers = {};
  final Map<int, _IdNotifier> _requestNotifiers = {};

  Set<int> get favoriteOfferIds => Set<int>.from(_favoriteOfferIds);
  Set<int> get favoriteRequestIds => Set<int>.from(_favoriteRequestIds);

  bool isOfferFavorite(int offerId) => _favoriteOfferIds.contains(offerId);

  bool isRequestFavorite(int requestId) =>
      _favoriteRequestIds.contains(requestId);

  Listenable listenableForOffer(int offerId) {
    return _offerNotifiers.putIfAbsent(offerId, _IdNotifier.new);
  }

  Listenable listenableForRequest(int requestId) {
    return _requestNotifiers.putIfAbsent(requestId, _IdNotifier.new);
  }

  void _notifyOfferChanged(int offerId) {
    final n = _offerNotifiers[offerId];
    if (n == null) return;
    n.notifyListeners();
    if (!n.hasListeners) {
      _offerNotifiers.remove(offerId);
    }
  }

  void _notifyRequestChanged(int requestId) {
    final n = _requestNotifiers[requestId];
    if (n == null) return;
    n.notifyListeners();
    if (!n.hasListeners) {
      _requestNotifiers.remove(requestId);
    }
  }

  /// Optimistic toggle for offer bookmark local state.
  void toggleOfferLocal(int offerId) {
    if (_favoriteOfferIds.contains(offerId)) {
      _favoriteOfferIds.remove(offerId);
    } else {
      _favoriteOfferIds.add(offerId);
    }
    _notifyOfferChanged(offerId);
  }

  /// Optimistic toggle for task bookmark local state.
  void toggleRequestLocal(int requestId) {
    if (_favoriteRequestIds.contains(requestId)) {
      _favoriteRequestIds.remove(requestId);
    } else {
      _favoriteRequestIds.add(requestId);
    }
    _notifyRequestChanged(requestId);
  }

  void syncFromOffers(Iterable<GigOffer> offers) {
    for (final o in offers) {
      final flag = o.isFavorited;
      if (flag == null) continue;
      final was = _favoriteOfferIds.contains(o.id);
      if (flag && !was) {
        _favoriteOfferIds.add(o.id);
        _notifyOfferChanged(o.id);
      } else if (!flag && was) {
        _favoriteOfferIds.remove(o.id);
        _notifyOfferChanged(o.id);
      }
    }
  }

  void syncFromRequests(Iterable<GigRequest> requests) {
    for (final r in requests) {
      final flag = r.isFavorited;
      if (flag == null) continue;
      final was = _favoriteRequestIds.contains(r.id);
      if (flag && !was) {
        _favoriteRequestIds.add(r.id);
        _notifyRequestChanged(r.id);
      } else if (!flag && was) {
        _favoriteRequestIds.remove(r.id);
        _notifyRequestChanged(r.id);
      }
    }
  }

  /// Seed from the favorites-only API lists ([is_favorited] is always true).
  void markOfferFavorited(int offerId) {
    if (_favoriteOfferIds.contains(offerId)) return;
    _favoriteOfferIds.add(offerId);
    _notifyOfferChanged(offerId);
  }

  void markRequestFavorited(int requestId) {
    if (_favoriteRequestIds.contains(requestId)) return;
    _favoriteRequestIds.add(requestId);
    _notifyRequestChanged(requestId);
  }

  void removeOfferFavorite(int offerId) {
    if (!_favoriteOfferIds.remove(offerId)) return;
    _notifyOfferChanged(offerId);
  }

  void removeRequestFavorite(int requestId) {
    if (!_favoriteRequestIds.remove(requestId)) return;
    _notifyRequestChanged(requestId);
  }
}
