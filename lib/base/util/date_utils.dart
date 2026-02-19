import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";

class AppDateUtils {
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

}
