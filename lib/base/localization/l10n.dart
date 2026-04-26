import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_strings.dart";
import "package:uy_dosh/base/localization/plural.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

/// Supported app locales (uz, ru, en).
///
/// ## Migration to ARB-based localization
///
/// This app is migrating from hardcoded [AppStrings] to Flutter's ARB-based
/// localization. ARB files live in `l10n/app_*.arb`; run `flutter gen-l10n`
/// to regenerate `lib/l10n/app_localizations.dart`.
///
/// **When you have [BuildContext]**: Prefer `context.l10n` (see
/// [l10n_extension.dart]) for type-safe, ARB-backed strings.
///
/// **When you don't have context** (e.g. blocs, callbacks): Continue using
/// [L10n.get] / [L10n.getWithParams] which read from [AppStrings].
///
/// Gradually migrate call sites from [L10n] to `context.l10n` as you touch files.
/// Import [l10n_extension.dart] for `context.l10n` when you have [BuildContext].
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

  /// Get a localized, count-agreeing string for the current language.
  ///
  /// Looks up `<baseKey>_<category>` (e.g. `listing_views_count_few`) where
  /// the category is one of `one` / `few` / `many` / `other` per CLDR rules
  /// for the active language. Falls back through `_other`, `_many`, then the
  /// bare [baseKey] so missing forms degrade gracefully.
  ///
  /// `{count}` is automatically substituted; pass extra placeholders via
  /// [params] (those values override the auto-injected count if reused).
  static String plural(
    String baseKey,
    int count, {
    Map<String, String>? params,
  }) {
    return _plural(baseKey, count, currentLanguage, params: params);
  }

  /// Same as [plural] but for an explicit [language].
  static String pluralForLanguage(
    String baseKey,
    int count,
    String language, {
    Map<String, String>? params,
  }) {
    return _plural(baseKey, count, language, params: params);
  }

  static String _plural(
    String baseKey,
    int count,
    String language, {
    Map<String, String>? params,
  }) {
    final category = Plural.category(count, language);
    final mergedParams = <String, String>{
      "count": count.toString(),
      if (params != null) ...params,
    };
    for (final suffix in <String>{category, "other", "many", ""}) {
      final key = suffix.isEmpty ? baseKey : "${baseKey}_$suffix";
      if (AppStrings.hasKey(key, language)) {
        return AppStrings.getWithParams(
          key,
          language,
          params: mergedParams,
        );
      }
    }
    return baseKey;
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

  /// Returns a Text widget with a count-agreeing string that rebuilds when
  /// language changes. See [plural] for key resolution rules.
  static Widget pluralText(
    String baseKey,
    int count, {
    Map<String, String>? params,
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
          plural(baseKey, count, params: params),
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
