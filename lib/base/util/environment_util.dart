abstract class EnvironmentUtil {
  static const basePath = String.fromEnvironment(
    "API_BASE_PATH",
    defaultValue: "http://3.140.249.173:3000",
  );

  /// Web URL for shareable links (https). Messengers like Telegram only make
  /// https:// links clickable, not custom schemes like uydosh://.
  static const shareWebBase = String.fromEnvironment(
    "SHARE_WEB_BASE",
    defaultValue: "https://uydosh.app",
  );

  static String? apiBasePath(String api) {
    return const bool.hasEnvironment("API_BASE_PATH")
        ? '${const String.fromEnvironment('API_BASE_PATH')}/$api'
        : null;
  }

  static const termsOfService = String.fromEnvironment(
    "TERMS_OF_SERVICE",
    defaultValue: "URL",
  );

  static const privacyPolicy = String.fromEnvironment(
    "PRIVACY_POLICY",
    defaultValue: "https://uydoshtech.github.io/privacy-policy.html",
  );

  static const deleteAccount = String.fromEnvironment(
    "DELETE_ACCOUNT",
    defaultValue: "URL",
  );
}
