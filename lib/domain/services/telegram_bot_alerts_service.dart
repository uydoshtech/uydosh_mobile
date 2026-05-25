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

class TelegramBotEnableLink {
  const TelegramBotEnableLink({
    required this.url,
    required this.botUsername,
    required this.startParam,
  });

  final String url;
  final String botUsername;
  final String startParam;

  factory TelegramBotEnableLink.fromJson(Map<String, dynamic> json) {
    final url = json["url"];
    final botUsername = json["botUsername"];
    final startParam = json["startParam"];
    if (url is! String ||
        url.trim().isEmpty ||
        botUsername is! String ||
        botUsername.trim().isEmpty ||
        startParam is! String ||
        startParam.trim().isEmpty) {
      throw Exception("Telegram enable link missing fields");
    }
    return TelegramBotEnableLink(
      url: url.trim(),
      botUsername: botUsername.trim(),
      startParam: startParam.trim(),
    );
  }
}

abstract class ITelegramBotAlertsService {
  Future<TelegramBotAlertsStatus> fetchStatus();
  Future<TelegramBotEnableLink> fetchEnableLink();
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
  Future<TelegramBotEnableLink> fetchEnableLink() async {
    final json = await _oauthApiClient.get<Map<String, dynamic>>(
      "/users/me/telegram-bot/enable-link",
      (raw) => raw as Map<String, dynamic>,
    );
    return TelegramBotEnableLink.fromJson(json);
  }
}
