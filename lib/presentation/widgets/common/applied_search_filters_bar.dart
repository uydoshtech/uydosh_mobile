import "package:flutter/material.dart";
import "package:uy_dosh/base/cache/location_cache.dart";
import "package:uy_dosh/base/cache/metro_cache.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/price_display_settings_state.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/listing_type_badge.dart";
import "package:uy_dosh/presentation/widgets/m_letter_icon.dart";

class AppliedSearchFiltersBar extends StatelessWidget {
  const AppliedSearchFiltersBar({
    required this.onPressed,
    super.key,
    this.listingTypeId,
    this.gender,
    this.locationId,
    this.subwayStationId,
    this.subwayLineId,
    this.minPrice,
    this.maxPrice,
    this.privateRoom,
    this.withPhoto,
    this.total,
    this.showLabel = true,
    this.alignRight = false,
    this.height = 56,
    this.chipSize = 36,
    this.endPadding = 0,
    this.alwaysShowPriceRange = false,
  });

  final VoidCallback onPressed;
  final int? listingTypeId;
  final int? gender; // 1 male, 2 female
  final int? locationId;
  final int? subwayStationId;
  final int? subwayLineId;
  final double? minPrice;
  final double? maxPrice;
  final bool? privateRoom;
  final bool? withPhoto;
  final int? total;
  final bool showLabel;
  final bool alignRight;
  final double height;
  final double chipSize;
  /// Extra scroll content padding on the trailing edge. Useful when this bar
  /// sits next to trailing actions (e.g. close/camera/lock) so the last chip
  /// never scrolls underneath those buttons.
  final double endPadding;
  /// When true, show the price pill even for the full default range (0–1000).
  final bool alwaysShowPriceRange;

  bool get _hasCustomPriceRange {
    if (minPrice == null && maxPrice == null) return false;
    const defaultMin = 0.0;
    const defaultMax = 1000.0;
    final minV = minPrice ?? defaultMin;
    final maxV = maxPrice ?? defaultMax;
    return minV != defaultMin || maxV != defaultMax;
  }

  String _truncateLabel(String s, {int maxChars = 15}) {
    final t = s.trim();
    if (t.length <= maxChars) return t;
    return "${t.substring(0, maxChars)}…";
  }

  @override
  Widget build(BuildContext context) {
    final indicators = _buildIndicators(context);
    final onBar = Theme.of(context).colorScheme.onSurface;
    final label = total == null
        ? L10n.get("filters_bar_label")
        : "${L10n.get("filters_bar_label")} • $total";

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: SizedBox(
        height: height,
        child: Align(
          alignment: alignRight ? Alignment.centerRight : Alignment.centerLeft,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: alignRight,
                // Keep chip shadows/glass feel intact; rely on trailing padding
                // to keep chips from visually colliding with trailing actions.
                clipBehavior: Clip.none,
                child: Padding(
                  padding: alignRight
                      ? EdgeInsets.only(left: endPadding)
                      : EdgeInsets.only(right: endPadding),
                  child: Row(
                    mainAxisAlignment: alignRight
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (showLabel) ...[
                        // Reserve space for the overlaid tune icon.
                        const SizedBox(width: 18, height: 18),
                        const SizedBox(width: 6),
                        Text(
                          "$label :",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: onBar,
                            height: 1.0,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      ...indicators,
                    ],
                  ),
                ),
              ),
              if (showLabel)
                PositionedDirectional(
                  start: 0,
                  top: 0,
                  bottom: 0,
                  child: IgnorePointer(
                    child: Center(
                      child: ThemeIcon(
                        Icons.tune,
                        size: 18,
                        color: onBar,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildIndicators(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final onSurface = scheme.onSurface;
    const gap = SizedBox(width: 8);
    final chipBase = scheme.surface;

    BoxDecoration neumorphicChipDecoration({
      BorderRadius? radius,
      BoxBorder? border,
    }) {
      return BoxDecoration(
        borderRadius: radius ?? BorderRadius.circular(chipSize / 2),
        gradient: ThreeDSurfaceStyle.surfaceGradient(context, chipBase),
        boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
        border: border,
      );
    }

    Widget roundChip({required String tooltip, required Widget child}) {
      return Tooltip(
        message: tooltip,
        child: Container(
          width: chipSize,
          height: chipSize,
          decoration: neumorphicChipDecoration(),
          child: Center(child: child),
        ),
      );
    }

    final out = <Widget>[];

    final lt = listingTypeId;
    if (lt != null && lt > 0) {
      final code = ListingTypeHelper.getCodeFromId(lt);
      out.add(
        roundChip(
          tooltip: ListingTypeHelper.getText(context, code),
          child: Icon(
            ListingTypeHelper.getIcon(code),
            size: 20,
            color: ListingTypeHelper.getColor(code),
          ),
        ),
      );
      out.add(gap);
    }

    final g = gender ?? 0;
    if (g > 0) {
      final isMale = g == 1;
      out.add(
        roundChip(
          tooltip: L10n.get(isMale ? "male" : "female"),
          child: Icon(
            isMale ? Icons.male : Icons.female,
            size: 22,
            color: isMale ? Colors.blue : Colors.red,
          ),
        ),
      );
      out.add(gap);
    }

    if (alwaysShowPriceRange || _hasCustomPriceRange) {
      final minV = minPrice ?? 0.0;
      final maxV = maxPrice ?? 1000.0;
      out.add(
        ListenableBuilder(
          listenable: PriceDisplaySettingsState(),
          builder: (context, _) {
            final rangeLabel =
                PriceRangeHelper.formatSearchFilterPriceChipLabel(minV, maxV);
            // This chip sits inside the inline filter ribbon where the green
            // success color can read like an outline. Force a neutral outline
            // here only (other chips keep the shared decoration).
            final neutralOutline = Border.all(
              color: scheme.onSurface.withValues(alpha: 0.10),
              width: 1,
            );
            return Tooltip(
              message: rangeLabel,
              child: Container(
                height: chipSize,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                decoration: neumorphicChipDecoration(
                  radius: BorderRadius.circular(999),
                  border: neutralOutline,
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.payments,
                      size: 16,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      rangeLabel,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: onSurface,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
      out.add(gap);
    }

    final loc = locationId ?? 0;
    if (loc > 0) {
      final lang = L10n.currentLanguage;
      out.add(
        Tooltip(
          message: LocationCache.getLocationShortName(loc, lang),
          child: Container(
            height: chipSize,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: neumorphicChipDecoration(
              radius: BorderRadius.circular(999),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 16, color: AppColors.error),
                const SizedBox(width: 5),
                Text(
                  LocationCache.getLocationShortName(loc, lang),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: onSurface,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      out.add(gap);
    }

    final station = subwayStationId ?? 0;
    if (station > 0) {
      final lang = L10n.currentLanguage;
      final stationObj = MetroCache.getStationById(station);
      final stationLine = stationObj?.line;
      final stationColor =
          stationLine == null ? null : AppColors.getMetroLineColor(stationLine);
      final stationName = MetroCache.getStationLabel(station, lang).trim();
      final stationShort = _truncateLabel(stationName, maxChars: 15);
      out.add(
        Tooltip(
          message: stationName,
          child: Container(
            height: chipSize,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: neumorphicChipDecoration(
              radius: BorderRadius.circular(999),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ThemeIcon(Icons.train, color: stationColor, size: 20),
                const SizedBox(width: 6),
                Text(
                  stationShort.isEmpty ? L10n.get("all") : stationShort,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: onSurface,
                    height: 1.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      out.add(gap);
    } else {
      final line = subwayLineId ?? 0;
      if (line > 0) {
        final lang = L10n.currentLanguage;
        final trainColor = AppColors.getMetroLineColor(line);
        final lineName = MetroCache.getLineLabel(line, lang).trim();
        out.add(
          Tooltip(
            message: lineName,
            child: Container(
              height: chipSize,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: neumorphicChipDecoration(
                radius: BorderRadius.circular(999),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  MLetterIcon(color: trainColor, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    lineName.isEmpty ? L10n.get("all") : lineName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: onSurface,
                      height: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        out.add(gap);
      }
    }

    if (withPhoto == true) {
      out.add(
        roundChip(
          tooltip: L10n.get("search_filter_with_photo"),
          child: Icon(Icons.photo_camera_outlined, size: 19, color: onSurface),
        ),
      );
      out.add(gap);
    }

    if (privateRoom == true) {
      out.add(
        roundChip(
          tooltip: L10n.get("search_filter_private_room"),
          child: Icon(Icons.lock_outline, size: 19, color: onSurface),
        ),
      );
      out.add(gap);
    }

    // Remove trailing gap
    while (out.isNotEmpty && out.last is SizedBox) {
      out.removeLast();
    }

    if (out.isEmpty) {
      final allLabel = L10n.get("all");
      final isLight = Theme.of(context).brightness == Brightness.light;
      final Color allChipBg;
      final Color allChipFg;
      final BoxBorder? allChipBorder;
      final List<BoxShadow>? allChipShadow;
      if (isLight) {
        allChipBg = onSurface;
        allChipFg = scheme.surface;
        allChipBorder = null;
        allChipShadow = ThreeDSurfaceStyle.elevatedShadows(context);
      } else {
        allChipBg = Color.lerp(Colors.black, scheme.surface, 0.06)!;
        allChipFg = Colors.white;
        allChipBorder = Border.all(
          color: Colors.white.withValues(alpha: 0.14),
          width: 1,
        );
        allChipShadow = [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ];
      }
      out.add(
        Tooltip(
          message: allLabel,
          child: Container(
            height: chipSize,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: allChipBg,
              borderRadius: BorderRadius.circular(999),
              border: allChipBorder,
              boxShadow: allChipShadow,
            ),
            alignment: Alignment.center,
            child: Text(
              allLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: allChipFg,
                height: 1.0,
              ),
            ),
          ),
        ),
      );
    }

    return out;
  }
}

