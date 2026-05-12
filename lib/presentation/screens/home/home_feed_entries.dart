import "package:flutter/foundation.dart";
import "package:uy_dosh/domain/models/listing.dart";

/// One row in the home feed: either a calendar-day header or a listing tile.
@immutable
class HomeFeedEntry {
  const HomeFeedEntry.dateHeader(this.day, {required this.isFirstDateHeader})
      : listing = null;
  const HomeFeedEntry.listing(this.listing)
      : day = null,
        isFirstDateHeader = null;

  final Listing? listing;
  final DateTime? day;
  final bool? isFirstDateHeader;
}

List<HomeFeedEntry> homeFeedEntriesWithDateHeaders(List<Listing> listings) {
  final out = <HomeFeedEntry>[];
  DateTime? lastCalendarDay;
  var isFirstDateHeader = true;
  for (final listing in listings) {
    DateTime created;
    try {
      created = DateTime.parse(listing.createdAt).toLocal();
    } catch (_) {
      created = DateTime.now();
    }
    final day = DateTime(created.year, created.month, created.day);
    if (lastCalendarDay == null ||
        lastCalendarDay.year != day.year ||
        lastCalendarDay.month != day.month ||
        lastCalendarDay.day != day.day) {
      out.add(
        HomeFeedEntry.dateHeader(day, isFirstDateHeader: isFirstDateHeader),
      );
      isFirstDateHeader = false;
      lastCalendarDay = day;
    }
    out.add(HomeFeedEntry.listing(listing));
  }
  return out;
}
