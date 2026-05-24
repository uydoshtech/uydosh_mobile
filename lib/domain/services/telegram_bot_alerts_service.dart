import "package:uy_dosh/base/api/client/oauth_api_client.dart";

class TelegramBotAlertsStatus {
  const TelegramBotAlertsStatus({
    required this.configured,
    required this.telegramLinked,
    required this.alertsEnabled,
  });

  final bool configured;
  final bool telegramLinked;
  final bool alertsEnabled;

  factory TelegramBotAlertsStatus.fromJson(Map<String, dynamic> json) {
    return TelegramBotAlertsStatus(
      configured: json["configured"] == true,
      telegramLinked: json["telegramLinked"] == true,
      alertsEnabled: json["alertsEnabled"] == true,
    );
  }
}

abstract class ITelegramBotAlertsService {
  Future<TelegramBotAlertsStatus> fetchStatus();
  Future<String> fetchEnableLinkUrl();
}

class TelegramBotAlertsService implements ITelegramBotAlertsService {
  TelegramBotAlertsService(this._oauthApiClient);

  final IOAuthApiClient _oauthApiClient;

  @override
  Future<TelegramBotAlertsStatus> fetchStatus() async {
    final json = await _oauthApiClient.get<Map<String, dynamic>>(
      "/users/me/telegram-bot/status",
      (raw) => raw as Map<String, dynamic>,
    );
    return TelegramBotAlertsStatus.fromJson(json);
  }

  @override
  Future<String> fetchEnableLinkUrl() async {
    final json = await _oauthApiClient.get<Map<String, dynamic>>(
      "/users/me/telegram-bot/enable-link",
      (raw) => raw as Map<String, dynamic>,
    );
    final url = json["url"];
    if (url is! String || url.trim().isEmpty) {
      throw Exception("Telegram enable link missing");
    }
    return url.trim();
  }
}
