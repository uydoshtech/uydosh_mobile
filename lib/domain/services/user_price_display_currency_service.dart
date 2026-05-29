import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";

abstract class IUserPriceDisplayCurrencyService {
  /// GET /users/me/price-display-currency → `{ "price_display_currency": String? }`
  Future<String?> fetchMe();

  /// PATCH /users/me/price-display-currency with `{ "price_display_currency": ... }`
  Future<void> saveMe(String? currency);
}

class UserPriceDisplayCurrencyService implements IUserPriceDisplayCurrencyService {
  UserPriceDisplayCurrencyService(this._client);

  final IOAuthApiClient _client;

  @override
  Future<String?> fetchMe() async {
    final map = await _client.get<Map<String, dynamic>>(
      "/users/me/price-display-currency",
      (json) => Map<String, dynamic>.from(json as Map),
    );
    final raw = map["price_display_currency"];
    return raw is String ? raw : null;
  }

  @override
  Future<void> saveMe(String? currency) async {
    await _client.patch<Map<String, dynamic>, _PriceDisplayCurrencyPatchBody>(
      "/users/me/price-display-currency",
      (_) => <String, dynamic>{},
      data: _PriceDisplayCurrencyPatchBody(currency),
    );
  }
}

class _PriceDisplayCurrencyPatchBody implements IJsonEncodable {
  _PriceDisplayCurrencyPatchBody(this.currency);

  final String? currency;

  @override
  Map<String, dynamic> toJson() => {"price_display_currency": currency};
}
