import "package:flutter/foundation.dart";
import "package:shared_preferences/shared_preferences.dart";
import "package:uy_dosh/base/logger/logger.dart";

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

  bool get isInitialized => _isInitialized;
  PriceDisplayCurrency get currency => _currency;

  /// Convenience for dropdowns.
  String get currencySlug =>
      _currency == PriceDisplayCurrency.usd ? _valueUsd : _valueNational;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyPriceDisplayCurrency)?.trim();
      _currency = raw == _valueUsd
          ? PriceDisplayCurrency.usd
          : PriceDisplayCurrency.national;
      logger.d("Loaded price display currency: $raw ($_currency)");
    } catch (e) {
      logger.d("Error initializing price display currency: $e");
      _currency = PriceDisplayCurrency.national;
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> setCurrency(PriceDisplayCurrency currency) async {
    if (_currency == currency) return;
    _currency = currency;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _keyPriceDisplayCurrency,
        currency == PriceDisplayCurrency.usd ? _valueUsd : _valueNational,
      );
    } catch (e) {
      logger.d("Error saving price display currency: $e");
    }
  }
}

