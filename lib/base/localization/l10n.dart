import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_strings.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

/// Supported app locales (uz, ru, en).
const List<Locale> supportedLocales = [
  Locale("uz"),
  Locale("ru"),
  Locale("en"),
];

/// Unified localization API. Use LanguageState as the single source of truth.
///
/// Replaces StringHelper and LanguageAwareStringHelper for consistent API
/// and maintainability.
class L10n {
  L10n._();

  /// Current app language from LanguageState.
  static String get currentLanguage => LanguageState().currentLanguage;

  /// Get localized string for the current language.
  /// [key] - AppStrings key (e.g. "home", "error")
  static String get(String key, {String? fallback}) {
    return AppStrings.get(key, currentLanguage, fallback: fallback);
  }

  /// Get localized string with parameters (e.g. "In {days} days").
  static String getWithParams(
    String key, {
    Map<String, String>? params,
    String? fallback,
  }) {
    return AppStrings.getWithParams(
      key,
      currentLanguage,
      params: params,
      fallback: fallback,
    );
  }

  /// Get localized string for a specific language (e.g. for share text).
  static String getForLanguage(String key, String language, {String? fallback}) {
    return AppStrings.get(key, language, fallback: fallback);
  }

  /// Get localized string with params for a specific language.
  static String getWithParamsForLanguage(
    String key,
    String language, {
    Map<String, String>? params,
    String? fallback,
  }) {
    return AppStrings.getWithParams(
      key,
      language,
      params: params,
      fallback: fallback,
    );
  }

  /// Check if key exists for current language.
  static bool hasKey(String key) {
    return AppStrings.hasKey(key, currentLanguage);
  }

  /// Get all strings for current language.
  static Map<String, String> getAll() {
    return AppStrings.getAllForLanguage(currentLanguage);
  }

  /// Returns a Text widget that rebuilds when language changes.
  static Widget text(
    String key, {
    BuildContext? context,
    String? fallback,
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return ListenableBuilder(
      listenable: LanguageState(),
      builder: (context, child) {
        return Text(
          get(key, fallback: fallback),
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }

  /// Returns a Text widget with params that rebuilds when language changes.
  static Widget textWithParams(
    String key, {
    Map<String, String>? params,
    String? fallback,
    BuildContext? context,
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return ListenableBuilder(
      listenable: LanguageState(),
      builder: (context, child) {
        return Text(
          getWithParams(key, params: params, fallback: fallback),
          style: style,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
        );
      },
    );
  }

  /// Build an input field with localized hint that rebuilds on language change.
  static Widget inputField(
    String key, {
    required Widget Function(String hintText) builder,
    String? fallback,
  }) {
    return ListenableBuilder(
      listenable: LanguageState(),
      builder: (context, child) {
        final hintText = get(key, fallback: fallback);
        return builder(hintText);
      },
    );
  }
}
