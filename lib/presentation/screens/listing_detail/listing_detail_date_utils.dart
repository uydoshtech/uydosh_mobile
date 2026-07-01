import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/util/date_utils.dart" as app_date_utils;

/// Move-in date formatting utilities. Parsing and formatting are done outside
/// build to avoid DateTime.parse() and heavy logic in build methods.
class ListingDetailDateUtils {
  ListingDetailDateUtils._();

  /// Format move-in date string for display. Returns raw string if parsing fails.
  static String formatMoveInDate(String moveInDate, String currentLanguage) {
    try {
      final date = DateTime.parse(moveInDate);
      final now = DateTime.now();
      final difference = date.difference(now).inDays;

      if (difference == 0) {
        return L10n.get("today");
      } else if (difference == 1) {
        return L10n.get("tomorrow");
      } else if (difference > 0 && difference <= 7) {
        return L10n.pluralForLanguage(
          "in_days",
          difference,
          currentLanguage,
        );
      } else {
        final monthKeys = [
          "january", "february", "march", "april", "may", "june",
          "july", "august", "september", "october", "november", "december",
        ];
        final localizedMonth = L10n.get(monthKeys[date.month - 1]);
        return "${localizedMonth.substring(0, 3)} ${date.day}, ${date.year}";
      }
    } catch (_) {
      return moveInDate;
    }
  }

  /// Parse createdAt string safely. Returns null if parsing fails.
  static DateTime? parseCreatedAt(String? createdAt) {
    if (createdAt == null || createdAt.isEmpty) return null;
    try {
      return DateTime.parse(createdAt);
    } catch (_) {
      return null;
    }
  }

  /// Format publication date for display.
  static String? formatPublicationDate(BuildContext context, String? createdAt) {
    final date = parseCreatedAt(createdAt);
    if (date == null) return null;
    final uzDate = app_date_utils.AppDateUtils.toUzbekistanTime(date);
    return app_date_utils.AppDateUtils.formatDateWithShortMonth(context, uzDate);
  }

  /// Compact publication date for listing cards (date only, no time).
  static String? formatListingCardPublicationDate(
    BuildContext context,
    String? createdAt,
  ) {
    final date = parseCreatedAt(createdAt);
    if (date == null) return null;
    final uzDate = app_date_utils.AppDateUtils.toUzbekistanTime(date);
    return app_date_utils.AppDateUtils.formatListingPublicationDate(
      context,
      uzDate,
    );
  }
}
