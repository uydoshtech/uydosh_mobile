import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";

/// String utilities. For localization, use [L10n] instead.
@Deprecated("Use L10n for localization. This class is kept for extractInitials only.")
class StringHelper {
  /// Get the current language code. Uses LanguageState.
  static String getCurrentLanguage(BuildContext context) {
    return L10n.currentLanguage;
  }

  /// Get a string for the current app language.
  @Deprecated("Use L10n.get(key) instead")
  static String getCurrent(
    String key,
    BuildContext context, {
    String? fallback,
  }) {
    return L10n.get(key, fallback: fallback);
  }

  /// Get a string with parameters for the current app language.
  @Deprecated("Use L10n.getWithParams(key, params: params) instead")
  static String getCurrentWithParams(
    String key,
    BuildContext context, {
    Map<String, String>? params,
    String? fallback,
  }) {
    return L10n.getWithParams(
      key,
      params: params,
      fallback: fallback,
    );
  }

  /// Get a string for a specific language.
  static String get(String key, String language, {String? fallback}) {
    return L10n.getForLanguage(key, language, fallback: fallback);
  }

  /// Get a string with parameters for a specific language.
  static String getWithParams(
    String key,
    String language, {
    Map<String, String>? params,
    String? fallback,
  }) {
    return L10n.getWithParamsForLanguage(
      key,
      language,
      params: params,
      fallback: fallback,
    );
  }

  /// Get all strings for the current app language.
  @Deprecated("Use L10n.getAll() instead")
  static Map<String, String> getAllCurrent(BuildContext context) {
    return L10n.getAll();
  }

  /// Check if a key exists for the current app language.
  @Deprecated("Use L10n.hasKey(key) instead")
  static bool hasKey(String key, BuildContext context) {
    return L10n.hasKey(key);
  }

  /// Get a Text widget with the current language string.
  @Deprecated("Use L10n.text(key, style: style) instead")
  static Widget getText(
    String key,
    BuildContext context, {
    String? fallback,
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return L10n.text(
      key,
      fallback: fallback,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Get a Text widget with parameters for the current language.
  @Deprecated("Use L10n.textWithParams(key, params: params) instead")
  static Widget getTextWithParams(
    String key,
    BuildContext context, {
    Map<String, String>? params,
    String? fallback,
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return L10n.textWithParams(
      key,
      params: params,
      fallback: fallback,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Extract initials from a person's name.
  /// Returns 2 letters for names with spaces (first and last name)
  /// Returns first 2 letters for single names
  /// Returns empty string if name is null or empty
  static String extractInitials(String? name) {
    if (name == null || name.trim().isEmpty) {
      return "";
    }

    final nameParts = name.trim().split(' ');

    if (nameParts.length >= 2) {
      return "${nameParts[0][0].toUpperCase()}${nameParts[1][0].toUpperCase()}";
    } else {
      final singleName = nameParts[0];
      if (singleName.length >= 2) {
        return singleName.substring(0, 2).toUpperCase();
      } else {
        return singleName[0].toUpperCase();
      }
    }
  }
}
