import "dart:async" show unawaited;

import "package:flutter/foundation.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/domain/services/user_price_display_currency_service.dart";

enum PriceDisplayCurrency {
  national,
  usd,
}

class PriceDisplaySettingsState extends ChangeNotifier {
  factory PriceDisplaySettingsState() => _instance;
  PriceDisplaySettingsState._internal();
  static final PriceDisplaySettingsState _instance =
      PriceDisplaySettingsState._internal();

  static const String _keyPriceDisplayCurrency = "price_display_currency";
  static const String _valueNational = "national";
  static const String _valueUsd = "usd";

  bool _isInitialized = false;
  PriceDisplayCurrency _currency = PriceDisplayCurrency.national;
  Future<void>? _hydrateFuture;

  bool get isInitialized => _isInitialized;
  PriceDisplayCurrency get currency => _currency;

  /// Convenience for dropdowns.
  String get currencySlug =>
      _currency == PriceDisplayCurrency.usd ? _valueUsd : _valueNational;

  static PriceDisplayCurrency _fromSlug(String? slug) =>
      slug?.trim() == _valueUsd
          ? PriceDisplayCurrency.usd
          : PriceDisplayCurrency.national;

  static String _toSlug(PriceDisplayCurrency currency) =>
      currency == PriceDisplayCurrency.usd ? _valueUsd : _valueNational;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyPriceDisplayCurrency)?.trim();
      _currency = _fromSlug(raw);
      logger.d("Loaded price display currency: $raw ($_currency)");
    } catch (e) {
      logger.d("Error initializing price display currency: $e");
      _currency = PriceDisplayCurrency.national;
    }
    _isInitialized = true;
    notifyListeners();
  }

  /// Loads the saved currency from the backend for the signed-in user so the
  /// preference follows the account across devices / logins (server wins).
  /// A no-op when unauthenticated or when the account has no saved value yet,
  /// preserving whatever [initialize] loaded from device prefs.
  Future<void> hydrateFromBackendForCurrentUser() async {
    if (_hydrateFuture != null) {
      await _hydrateFuture;
      return;
    }
    final run = _hydrateFromBackendImpl();
    _hydrateFuture = run;
    try {
      await run;
    } finally {
      if (_hydrateFuture == run) {
        _hydrateFuture = null;
      }
    }
  }

  Future<void> _hydrateFromBackendImpl() async {
    if (!await SessionManager.isAuthenticated()) return;
    try {
      final slug =
          await getIt<IUserPriceDisplayCurrencyService>().fetchMe();
      if (slug == null) {
        // No server value yet — keep the device-local preference untouched.
        logger.d("Price display currency: no server value; keeping local");
        return;
      }
      final serverCurrency = _fromSlug(slug);
      if (serverCurrency == _currency) return;
      _currency = serverCurrency;
      notifyListeners();
      await _writeLocal(serverCurrency);
      logger.d("Hydrated price display currency from backend: $serverCurrency");
    } catch (e) {
      logger.d("Price display currency hydrate failed: $e");
    }
  }

  /// Clears hydrate state when the backend session ends (logout / account switch).
  void onSessionEnded() {
    _hydrateFuture = null;
  }

  Future<void> setCurrency(PriceDisplayCurrency currency) async {
    if (_currency == currency) return;
    _currency = currency;
    notifyListeners();
    await _writeLocal(currency);
    unawaited(_persistRemote(currency));
  }

  Future<void> _writeLocal(PriceDisplayCurrency currency) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyPriceDisplayCurrency, _toSlug(currency));
    } catch (e) {
      logger.d("Error saving price display currency: $e");
    }
  }

  Future<void> _persistRemote(PriceDisplayCurrency currency) async {
    if (!await SessionManager.isAuthenticated()) return;
    try {
      await getIt<IUserPriceDisplayCurrencyService>().saveMe(_toSlug(currency));
    } catch (e) {
      logger.d("Price display currency remote persist failed: $e");
    }
  }
}
