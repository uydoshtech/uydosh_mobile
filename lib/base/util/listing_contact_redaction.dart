import "package:uy_dosh/base/config/client_listing_contact_ui_config.dart";
import "package:uy_dosh/base/utils/string_utils.dart";

/// Strips contact channels from listing copy shown in feed/detail when
/// [ClientListingContactUiConfig.hidePublicContactDetails] is true.
abstract final class ListingContactRedaction {
  static final RegExp telegramUsernameRe = RegExp(
    r"@([A-Za-z][A-Za-z0-9_]{3,30})\b",
  );

  /// Uzbekistan mobiles: +998 / 998 prefix or local 9XXXXXXXX.
  static final RegExp phoneRe = RegExp(
    r"\+998[\s\-]*9[0134679][\s\-]?\d{2}[\s\-]?\d{3}[\s\-]?\d{2}|"
    r"998[\s\-]*9[0134679][\s\-]?\d{2}[\s\-]?\d{3}[\s\-]?\d{2}|"
    r"(?<![0-9])9[0134679]\d{7}(?![0-9])",
  );

  static final RegExp telegramUrlRe = RegExp(
    r"https?://t\.me/[A-Za-z][A-Za-z0-9_]{3,30}",
    caseSensitive: false,
  );

  /// Ranges for tappable @ and phone in listing description (when contacts are shown).
  static List<({int start, int end, String kind, String text})> mergedContactMatches(
    String content,
  ) {
    final raw = <({int start, int end, String kind, String text})>[];
    for (final m in telegramUsernameRe.allMatches(content)) {
      raw.add((start: m.start, end: m.end, kind: "tg", text: m.group(0)!));
    }
    for (final m in phoneRe.allMatches(content)) {
      raw.add((start: m.start, end: m.end, kind: "phone", text: m.group(0)!));
    }
    raw.sort((a, b) {
      final byStart = a.start.compareTo(b.start);
      return byStart != 0 ? byStart : b.end.compareTo(a.end);
    });
    final kept = <({int start, int end, String kind, String text})>[];
    for (final m in raw) {
      final overlaps = kept.any(
        (k) => m.start < k.end && m.end > k.start,
      );
      if (overlaps) {
        continue;
      }
      kept.add(m);
    }
    kept.sort((a, b) => a.start.compareTo(b.start));
    return kept;
  }

  static List<({int start, int end})> _mergeIntervals(
    List<({int start, int end})> raw,
  ) {
    if (raw.isEmpty) {
      return raw;
    }
    final sorted = [...raw]..sort((a, b) => a.start.compareTo(b.start));
    final out = <({int start, int end})>[sorted.first];
    for (var i = 1; i < sorted.length; i++) {
      final r = sorted[i];
      final last = out.last;
      if (r.start <= last.end) {
        out[out.length - 1] = (
          start: last.start,
          end: r.end > last.end ? r.end : last.end,
        );
      } else {
        out.add(r);
      }
    }
    return out;
  }

  static String _stripByIntervals(
    String content,
    List<({int start, int end})> intervals,
  ) {
    if (intervals.isEmpty) {
      return content;
    }
    final sb = StringBuffer();
    var c = 0;
    for (final iv in intervals) {
      if (iv.start > c) {
        sb.write(content.substring(c, iv.start));
      }
      c = iv.end;
    }
    if (c < content.length) {
      sb.write(content.substring(c));
    }
    return sb.toString();
  }

  static String _stripContactHintLines(String s) {
    final stripped = s
        .replaceAll(
          RegExp(
            r"^\s*☎\s*номер\s+телефона.*$",
            multiLine: true,
            caseSensitive: false,
            dotAll: true,
          ),
          "",
        )
        .replaceAll(
          RegExp(
            r"^\s*telegram.*$",
            multiLine: true,
            caseSensitive: false,
            dotAll: true,
          ),
          "",
        );
    return StringUtils.collapseExcessiveNewlines(stripped).trim();
  }

  /// Removes @handles, phone numbers, t.me URLs, and common “phone below” label lines.
  static String stripForPublicDisplay(String content) {
    if (!ClientListingContactUiConfig.hidePublicContactDetails) {
      return StringUtils.collapseExcessiveNewlines(content);
    }
    final intervals = <({int start, int end})>[];
    for (final m in mergedContactMatches(content)) {
      intervals.add((start: m.start, end: m.end));
    }
    for (final m in telegramUrlRe.allMatches(content)) {
      intervals.add((start: m.start, end: m.end));
    }
    final merged = _mergeIntervals(intervals);
    final cut = _stripByIntervals(content, merged);
    return _stripContactHintLines(cut);
  }
}
