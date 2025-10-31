abstract class EnvironmentUtil {
  static const basePath = String.fromEnvironment(
    "API_BASE_PATH",
    defaultValue: "http://3.140.249.173:3000",
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
    defaultValue: "URL",
  );

  static const deleteAccount = String.fromEnvironment(
    "DELETE_ACCOUNT",
    defaultValue: "URL",
  );
}
