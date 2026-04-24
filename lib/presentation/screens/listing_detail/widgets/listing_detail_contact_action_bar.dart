import "dart:ui" show ImageFilter;

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// Sticky bottom action bar shown on the listing detail screen for
/// non-owners. Exposes the two "start a conversation" channels (Telegram
/// + in-app chat) so contacting the listing owner is always one tap away,
/// independent of whether the compatibility section is expanded.
///
/// When the screen is using the liquid-glass chrome (blue/light themes)
/// this bar renders as a frosted footer that mirrors
/// [LiquidGlassAppBarFlexibleSpace] flipped vertically: top-rounded
/// corners, a thin top divider, backdrop blur over whatever content is
/// scrolling behind, and a soft sheen anchored to the curved top edge.
/// Requires the parent [Scaffold] to set `extendBody: true` so there's
/// actually body content behind the bar to blur.
///
/// The Telegram button is rendered only when [onTelegram] is non-null
/// (i.e. the listing has a telegram handle AND the admin contact flag is
/// on). When Telegram is absent the in-app chat button takes the full
/// width.
class ListingDetailContactActionBar extends StatelessWidget {
  const ListingDetailContactActionBar({
    required this.onMessage,
    this.onTelegram,
    super.key,
  });

  final VoidCallback onMessage;
  final VoidCallback? onTelegram;

  static const BorderRadius _topRadius = BorderRadius.vertical(
    top: Radius.circular(20),
  );

  bool _useLiquidGlass() =>
      ThemeState().isBlueTheme || ThemeState().isLightTheme;

  Color _getOpaqueSurfaceColor(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  Color _getSecondaryTextColor() {
    if (ThemeState().isBlueTheme) return Colors.white;
    if (ThemeState().isLightTheme) return Colors.black;
    return AppColors.textLight;
  }

  Color _getPrimaryFillColor() {
    if (ThemeState().isLightTheme) return Colors.black;
    if (ThemeState().isBlueTheme) return Colors.white;
    return AppColors.primary;
  }

  Color _getPrimaryForegroundColor() {
    if (ThemeState().isLightTheme) return Colors.white;
    if (ThemeState().isBlueTheme) return const Color(0xFF1E3A5F);
    return Colors.white;
  }

  Widget _telegramButton(BuildContext context) {
    final accentColor = ListingDetailThemeHelper.iconColor;
    final secondaryTextColor = _getSecondaryTextColor();
    return OutlinedButton.icon(
      onPressed: () {
        HapticFeedbackUtils.impact();
        onTelegram!.call();
      },
      icon: ThemeIcon(
        Icons.telegram,
        size: 18,
        color: accentColor,
      ),
      label: Text(
        L10n.get("open_in_telegram"),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: secondaryTextColor,
        ),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: accentColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _chatButton(BuildContext context) {
    final primaryFill = _getPrimaryFillColor();
    final primaryFg = _getPrimaryForegroundColor();
    return ElevatedButton.icon(
      onPressed: () {
        HapticFeedbackUtils.impact();
        onMessage();
      },
      icon: ThemeIcon(
        CupertinoIcons.bubble_left_bubble_right_fill,
        size: 18,
        color: primaryFg,
      ),
      label: Text(
        L10n.get("message"),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: primaryFg,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryFill,
        foregroundColor: primaryFg,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        elevation: 0,
      ),
    );
  }

  Widget _buildActions() {
    final hasTelegram = onTelegram != null;
    if (!hasTelegram) {
      return SizedBox(
        width: double.infinity,
        child: Builder(builder: _chatButton),
      );
    }
    return Row(
      children: [
        Expanded(child: Builder(builder: _telegramButton)),
        const SizedBox(width: 12),
        Expanded(child: Builder(builder: _chatButton)),
      ],
    );
  }

  /// Opaque fallback for themes that don't use liquid glass chrome.
  Widget _buildOpaqueBar(BuildContext context) {
    final dividerColor = Colors.black.withValues(alpha: 0.08);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: _getOpaqueSurfaceColor(context),
        border: Border(top: BorderSide(color: dividerColor)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: _buildActions(),
        ),
      ),
    );
  }

  /// Frosted liquid-glass footer. Mirrors the visual recipe in
  /// [LiquidGlassAppBarFlexibleSpace] but flips the structural chrome:
  /// the rounded edge and the divider move to the **top** of the bar.
  /// Sheen stays anchored to that curved top edge so the highlight reads
  /// as light falling from above onto the glass lip.
  Widget _buildGlassBar(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;
    // Keep the frosted tint anchored to the themed surface so the footer
    // reads the same regardless of what's scrolling past behind it.
    final baseTint = isDark ? BlueThemeColors.background : scheme.surface;

    // Matched to [LiquidGlassAppBarFlexibleSpace] so the header and
    // footer have identical frost characteristics.
    final blurSigma = isDark ? 18.0 : 22.0;
    final tintAlpha = isDark ? 0.44 : 0.32;
    final sheenHigh = isDark ? 0.08 : 0.05;
    final borderColor = (isDark ? Colors.white : Colors.black).withValues(
      alpha: isDark ? 0.10 : 0.08,
    );

    return ClipRRect(
      borderRadius: _topRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Stack(
          children: [
            // Tint + top divider.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: _topRadius,
                  color: baseTint.withValues(alpha: tintAlpha),
                  border: Border(
                    top: BorderSide(color: borderColor, width: 0.5),
                  ),
                ),
              ),
            ),
            // Soft sheen falling from the curved top edge.
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: _topRadius,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: sheenHigh),
                      Colors.white.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: _buildActions(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, _) {
        return _useLiquidGlass()
            ? _buildGlassBar(context)
            : _buildOpaqueBar(context);
      },
    );
  }
}
