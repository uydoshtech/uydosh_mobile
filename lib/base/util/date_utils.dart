import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:uy_dosh/base/localization/l10n.dart";

class AppDateUtils {
  /// Convert an absolute timestamp to Uzbekistan local time (Asia/Tashkent).
  ///
  /// Uzbekistan is UTC+5 and does not observe DST. We convert via UTC to avoid
  /// device-local timezone affecting the result.
  static DateTime toUzbekistanTime(DateTime dateTime) {
    return dateTime.toUtc().add(const Duration(hours: 5));
  }

  /// Format date with month name in the format: "hh:mm • dd MMMM YYYY"
  static String formatDateWithMonth(BuildContext context, DateTime dateTime) {
    final monthKeys = [
      "january",
      "february",
      "march",
      "april",
      "may",
      "june",
      "july",
      "august",
      "september",
      "october",
      "november",
      "december",
    ];
    final localizedMonth = L10n.get(monthKeys[dateTime.month - 1]);

    return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')} • ${dateTime.day.toString().padLeft(2, '0')} $localizedMonth ${dateTime.year}";
  }

  /// Format date in the format: "DD MONTH YYYY • hh:mm"
  static String formatDateWithShortMonth(BuildContext context, DateTime dateTime) {
    final monthKeys = [
      "january",
      "february",
      "march",
      "april",
      "may",
      "june",
      "july",
      "august",
      "september",
      "october",
      "november",
      "december",
    ];
    final localizedMonth = L10n.get(monthKeys[dateTime.month - 1]);

    return "${dateTime.day.toString().padLeft(2, '0')} $localizedMonth ${dateTime.year} • ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
  }

  /// Format date in the format: "DD MONTH YYYY"
  static String formatDateWithMonthDay(BuildContext context, DateTime dateTime) {
    final monthKeys = [
      "january",
      "february",
      "march",
      "april",
      "may",
      "june",
      "july",
      "august",
      "september",
      "october",
      "november",
      "december",
    ];
    final localizedMonth = L10n.get(monthKeys[dateTime.month - 1]);

    return "${dateTime.day.toString().padLeft(2, '0')} $localizedMonth ${dateTime.year}";
  }

  /// Chat / inbox date pill: localized **Today** on the current local calendar
  /// day; localized **Yesterday** on the previous calendar day; otherwise
  /// `d MMMM yyyy` (locale-aware).
  static String formatDateHeader(DateTime date, BuildContext context) {
    final localDate = date.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final messageDay = DateTime(
      localDate.year,
      localDate.month,
      localDate.day,
    );
    if (messageDay == today) {
      return L10n.get("today");
    }
    if (messageDay == yesterday) {
      return L10n.get("yesterday");
    }
    final localeName = Localizations.localeOf(context).toString();
    return DateFormat("d MMMM yyyy", localeName).format(localDate);
  }

  /// Compact label for a **past** [dt]: clock time when [Duration.inDays]
  /// from now is 0, localized **yesterday** when it is 1, N days ago when it
  /// is between 2 and 6 inclusive, else `dd.mm.yyyy`.
  static String formatRelativePastDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) {
      return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
    }
    if (diff.inDays == 1) return L10n.get("admin_support_chat_yesterday");
    if (diff.inDays < 7) {
      return L10n.plural("admin_support_chat_days_ago", diff.inDays);
    }
    return "${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}.${dt.year}";
  }
}
