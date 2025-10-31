import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_strings.dart";

class StringHelper {
  /// Get the current language code from the app's locale
  static String getCurrentLanguage(BuildContext context) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode;
  }

  /// Get a string for the current app language
  static String getCurrent(
    String key,
    BuildContext context, {
    String? fallback,
  }) {
    final language = getCurrentLanguage(context);
    return AppStrings.get(key, language, fallback: fallback);
  }

  /// Get a string with parameters for the current app language
  static String getCurrentWithParams(
    String key,
    BuildContext context, {
    Map<String, String>? params,
    String? fallback,
  }) {
    final language = getCurrentLanguage(context);
    return AppStrings.getWithParams(
      key,
      language,
      params: params,
      fallback: fallback,
    );
  }

  /// Get a string for a specific language
  static String get(String key, String language, {String? fallback}) {
    return AppStrings.get(key, language, fallback: fallback);
  }

  /// Get a string with parameters for a specific language
  static String getWithParams(
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

  /// Get all strings for the current app language
  static Map<String, String> getAllCurrent(BuildContext context) {
    final language = getCurrentLanguage(context);
    return AppStrings.getAllForLanguage(language);
  }

  /// Check if a key exists for the current app language
  static bool hasKey(String key, BuildContext context) {
    final language = getCurrentLanguage(context);
    return AppStrings.hasKey(key, language);
  }

  /// Get a Text widget with the current language string
  static Text getText(
    String key,
    BuildContext context, {
    String? fallback,
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    final text = getCurrent(key, context, fallback: fallback);
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Get a Text widget with parameters for the current language
  static Text getTextWithParams(
    String key,
    BuildContext context, {
    Map<String, String>? params,
    String? fallback,
    TextStyle? style,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    final text = getCurrentWithParams(
      key,
      context,
      params: params,
      fallback: fallback,
    );
    return Text(
      text,
      style: style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  /// Extract initials from a person's name
  /// Returns 2 letters for names with spaces (first and last name)
  /// Returns first 2 letters for single names
  /// Returns empty string if name is null or empty
  static String extractInitials(String? name) {
    if (name == null || name.trim().isEmpty) {
      return "";
    }

    final nameParts = name.trim().split(' ');

    if (nameParts.length >= 2) {
      // If there are multiple parts (first and last name), show first letter of each
      return "${nameParts[0][0].toUpperCase()}${nameParts[1][0].toUpperCase()}";
    } else {
      // If it's a single name, show first 2 letters and capitalize them
      final singleName = nameParts[0];
      if (singleName.length >= 2) {
        return singleName.substring(0, 2).toUpperCase();
      } else {
        return singleName[0].toUpperCase();
      }
    }
  }
}
