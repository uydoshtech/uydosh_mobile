import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/group_shortlist_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/ui_feedback_utils.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/presentation/screens/group_housing/group_housing_flow.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_rendering.dart";

/// Compact bookmark pill that opens the group housing shortlist sheet.
class GroupShortlistPillButton extends StatelessWidget {
  const GroupShortlistPillButton({
    required this.groupListingId,
    required this.isOwner,
    this.groupListingDetail,
    this.onChanged,
    this.compact = false,
    super.key,
  });

  final int groupListingId;
  final bool isOwner;
  final ListingDetail? groupListingDetail;
  final VoidCallback? onChanged;

  /// Icon (+ count) only — for floating placement above group chat.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GroupShortlistState(),
      builder: (context, _) {
        final count =
            GroupShortlistState().shortlistCountForGroup(groupListingId);
        final tooltip = count > 0
            ? L10n.getWithParams(
                "group_shortlist_title_count",
                params: {"count": count.toString()},
              )
            : L10n.get("group_shortlist_title");

        return Semantics(
          button: true,
          label: tooltip,
          child: Tooltip(
            message: tooltip,
            child: _GlassShortlistPill(
              onPressed: () async {
                await GroupHousingFlow.openShortlistSheet(
                  context: context,
                  groupListingId: groupListingId,
                  isOwner: isOwner,
                  groupListingDetail: groupListingDetail,
                  onChanged: onChanged,
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: compact
                    ? _compactPillChildren(context, count)
                    : _fullPillChildren(context, count),
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _fullPillChildren(BuildContext context, int count) {
    return [
      Text(
        L10n.get("group_shortlist_title"),
        style: _pillTextStyle(context),
      ),
      const SizedBox(width: 8),
      Icon(
        Icons.bookmark,
        size: 20,
        color: _pillForegroundColor(context),
      ),
      if (count > 0) ...[
        const SizedBox(width: 6),
        Text(
          count > 99 ? "99+" : count.toString(),
          style: _pillTextStyle(context),
        ),
      ],
    ];
  }

  List<Widget> _compactPillChildren(BuildContext context, int count) {
    final label = count > 0
        ? L10n.getWithParams(
            "group_floating_shortlist_label",
            params: {"count": count > 99 ? "99+" : count.toString()},
          )
        : L10n.get("group_shortlist_title");

    return [
      Icon(
        Icons.bookmark,
        size: 20,
        color: _pillForegroundColor(context),
      ),
      const SizedBox(width: 8),
      Text(
        label,
        style: _pillTextStyle(context),
      ),
    ];
  }
}

Color _pillForegroundColor(BuildContext context) {
  final theme = Theme.of(context);
  return theme.brightness == Brightness.dark
      ? Colors.white
      : theme.colorScheme.onSurface;
}

TextStyle _pillTextStyle(BuildContext context) {
  return TextStyle(
    color: _pillForegroundColor(context),
    fontSize: 13,
    fontWeight: FontWeight.w700,
    height: 1.1,
  );
}

class _GlassShortlistPill extends StatefulWidget {
  const _GlassShortlistPill({
    required this.child,
    required this.onPressed,
  });

  final Widget child;
  final Future<void> Function()? onPressed;

  @override
  State<_GlassShortlistPill> createState() => _GlassShortlistPillState();
}

class _GlassShortlistPillState extends State<_GlassShortlistPill> {
  static const _borderRadius = BorderRadius.all(Radius.circular(999));

  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final enableGlass = LiquidGlassRendering.effectsEnabled(context);
    final useGlassChrome = ThemeState().usesLiquidGlassChrome;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      transform: Matrix4.translationValues(0, _pressed ? 1.5 : 0, 0),
      decoration: BoxDecoration(
        borderRadius: _borderRadius,
        boxShadow: useGlassChrome
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.10),
                  blurRadius: _pressed ? 8 : 14,
                  offset: Offset(0, _pressed ? 2 : 6),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: _borderRadius,
        child: LiquidGlassRendering.backdropBlur(
          enabled: enableGlass && useGlassChrome,
          sigma: LiquidGlassRendering.plateBlurSigma,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _enabled
                ? () {
                    UiFeedbackUtils.tap();
                    widget.onPressed?.call();
                  }
                : null,
            onTapDown: _enabled ? (_) => _setPressed(true) : null,
            onTapUp: _enabled ? (_) => _setPressed(false) : null,
            onTapCancel: _enabled ? () => _setPressed(false) : null,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: _borderRadius,
                gradient: useGlassChrome
                    ? _glassGradient(context, isDark: isDark)
                    : null,
                color: useGlassChrome ? null : theme.colorScheme.surface,
                border: Border.all(
                  color: useGlassChrome
                      ? (isDark ? Colors.white : Colors.black).withValues(
                          alpha: isDark ? 0.42 : 0.12,
                        )
                      : theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.45),
                  width: 0.8,
                ),
              ),
              child: Opacity(
                opacity: _enabled ? 1 : 0.55,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  LinearGradient _glassGradient(
    BuildContext context, {
    required bool isDark,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final blueTint =
        Color.lerp(BlueThemeColors.primaryLight, scheme.primary, 0.35) ??
            scheme.primary;
    final deepTint =
        Color.lerp(BlueThemeColors.primary, scheme.surface, 0.12) ??
            BlueThemeColors.primary;

    if (isDark) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withValues(alpha: 0.24),
          blueTint.withValues(alpha: 0.38),
          deepTint.withValues(alpha: 0.46),
        ],
        stops: const [0.0, 0.46, 1.0],
      );
    }

    final surfaceTint =
        Color.lerp(scheme.surface, scheme.primary, 0.08) ?? scheme.surface;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: 0.68),
        surfaceTint.withValues(alpha: 0.72),
        scheme.surface.withValues(alpha: 0.58),
      ],
      stops: const [0.0, 0.55, 1.0],
    );
  }
}
