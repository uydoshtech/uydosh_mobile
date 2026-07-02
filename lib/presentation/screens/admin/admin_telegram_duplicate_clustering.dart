import "package:flutter/foundation.dart";
import "package:uy_dosh/domain/models/listing.dart";
import "package:uy_dosh/domain/models/listing_duplicate_hint.dart";

/// One row in the grouped duplicates feed: either a calendar-day header, a
/// standalone (non-duplicate) listing, or a cluster of mutually-flagged
/// duplicate listings rendered together.
@immutable
class GroupedDuplicateEntry {
  const GroupedDuplicateEntry.dateHeader(this.day)
    : listing = null,
      cluster = null;
  const GroupedDuplicateEntry.listing(this.listing)
    : day = null,
      cluster = null;
  const GroupedDuplicateEntry.cluster(this.cluster)
    : day = null,
      listing = null;

  final DateTime? day;
  final Listing? listing;
  final List<Listing>? cluster;
}

DateTime _calendarDayOf(Listing listing) {
  DateTime created;
  try {
    created = DateTime.parse(listing.createdAt).toLocal();
  } catch (_) {
    created = DateTime.now();
  }
  return DateTime(created.year, created.month, created.day);
}

/// Clusters [listings] that are mutually flagged as possible duplicates (via
/// [hints]) using union-find over the currently loaded page(s), then returns
/// an ordered feed: date headers + standalone tiles for non-duplicates, and a
/// single grouped entry per duplicate cluster (placed at the position of its
/// first — i.e. newest — member).
///
/// A hint only forms an edge when its `matchedListingId` is itself among the
/// loaded [listings]; if the matched sibling hasn't been paged in yet, the
/// listing is shown standalone (still carrying its hint for the caller to
/// badge individually).
List<GroupedDuplicateEntry> buildGroupedDuplicateEntries(
  List<Listing> listings,
  Map<int, ListingDuplicateHint?> hints,
) {
  final idIndex = {for (final listing in listings) listing.id: listing};
  final parent = <int, int>{};

  int find(int x) {
    parent.putIfAbsent(x, () => x);
    var root = x;
    while (parent[root] != root) {
      root = parent[root]!;
    }
    var cur = x;
    while (parent[cur] != cur) {
      final next = parent[cur]!;
      parent[cur] = root;
      cur = next;
    }
    return root;
  }

  void union(int a, int b) {
    final rootA = find(a);
    final rootB = find(b);
    if (rootA != rootB) parent[rootA] = rootB;
  }

  for (final listing in listings) {
    final matchedId = hints[listing.id]?.matchedListingId;
    if (matchedId != null &&
        matchedId > 0 &&
        matchedId != listing.id &&
        idIndex.containsKey(matchedId)) {
      union(listing.id, matchedId);
    }
  }

  final byRoot = <int, List<Listing>>{};
  for (final listing in listings) {
    byRoot.putIfAbsent(find(listing.id), () => []).add(listing);
  }

  final entries = <GroupedDuplicateEntry>[];
  final consumedRoots = <int>{};
  DateTime? lastDay;

  for (final listing in listings) {
    final root = find(listing.id);
    if (consumedRoots.contains(root)) continue;
    consumedRoots.add(root);

    final members = byRoot[root]!;
    if (members.length > 1) {
      entries.add(GroupedDuplicateEntry.cluster(members));
      continue;
    }

    final day = _calendarDayOf(listing);
    if (lastDay == null ||
        lastDay.year != day.year ||
        lastDay.month != day.month ||
        lastDay.day != day.day) {
      entries.add(GroupedDuplicateEntry.dateHeader(day));
      lastDay = day;
    }
    entries.add(GroupedDuplicateEntry.listing(listing));
  }

  return entries;
}
