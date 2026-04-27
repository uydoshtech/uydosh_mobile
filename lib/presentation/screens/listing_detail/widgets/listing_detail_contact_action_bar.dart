import "dart:ui" show ImageFilter;

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n_extension.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";

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

  Widget _telegramButton(BuildContext context) {
    final accentColor = ListingDetailThemeHelper.iconColor;
    final secondaryTextColor = _getSecondaryTextColor();
    return _GlassNeumorphicCtaButton(
      onPressed: () {
        HapticFeedbackUtils.impact();
        onTelegram!.call();
      },
      icon: Icons.telegram,
      iconColor: accentColor,
      label: context.l10n.open_in_telegram,
      labelColor: secondaryTextColor,
      borderColor: accentColor,
      expandToParentWidth: false,
    );
  }

  Widget _chatButton(BuildContext context) {
    // "UyDosh Chat" should be the primary CTA vs Telegram.
    const brandGreen = Color(0xFF25C06D);
    final primaryFg = Colors.white;
    return _GlassNeumorphicCtaButton(
      onPressed: () {
        HapticFeedbackUtils.impact();
        onMessage();
      },
      icon: CupertinoIcons.shield_fill,
      iconColor: primaryFg,
      label: context.l10n.uydosh_chat,
      labelColor: primaryFg,
      fillColor: brandGreen,
      borderColor: brandGreen.withValues(alpha: 0.65),
      fontWeight: FontWeight.w700,
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
        IntrinsicWidth(child: Builder(builder: _telegramButton)),
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
    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final enableGlass =
        AnimationSettingsState().uiAnimationsEnabled && !disableAnimations;
    // Keep the frosted tint anchored to the themed surface so the footer
    // reads the same regardless of what's scrolling past behind it.
    final baseTint = isDark ? BlueThemeColors.background : scheme.surface;

    // Matched to [LiquidGlassAppBarFlexibleSpace] so the header and
    // footer have identical frost characteristics.
    final blurSigma = enableGlass ? (isDark ? 18.0 : 22.0) : 0.0;
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

class _GlassNeumorphicCtaButton extends StatefulWidget {
  const _GlassNeumorphicCtaButton({
    required this.onPressed,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.labelColor,
    required this.borderColor,
    this.fillColor,
    this.fontWeight = FontWeight.w600,
    /// False: width fits label; true: fill parent (full-width CTA).
    this.expandToParentWidth = true,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color labelColor;
  final Color borderColor;
  final Color? fillColor;
  final FontWeight fontWeight;
  final bool expandToParentWidth;

  @override
  State<_GlassNeumorphicCtaButton> createState() =>
      _GlassNeumorphicCtaButtonState();
}

class _GlassNeumorphicCtaButtonState extends State<_GlassNeumorphicCtaButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final scheme = theme.colorScheme;

    final disableAnimations =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final enableGlass =
        AnimationSettingsState().uiAnimationsEnabled && !disableAnimations;

    const radius = BorderRadius.all(Radius.circular(12));

    final shadows = _pressed
        ? ThreeDSurfaceStyle.pressedShadows(context)
        : ThreeDSurfaceStyle.elevatedShadows(context);

    final base =
        widget.fillColor ??
        (isDark
            ? scheme.surface.withValues(alpha: 0.08)
            : scheme.surface.withValues(alpha: 0.12));
    final faceColor =
        widget.fillColor != null ? base : base.withValues(alpha: isDark ? 0.38 : 0.55);
    final stroke = widget.borderColor.withValues(alpha: isDark ? 0.60 : 0.70);
    final useBackdropBlur = enableGlass && widget.fillColor == null;
    final expand = widget.expandToParentWidth;

    final labelRow = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ThemeIcon(
          widget.icon,
          size: 18,
          color: widget.iconColor,
        ),
        const SizedBox(width: 10),
        if (expand)
          Flexible(
            child: Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: widget.fontWeight,
                color: widget.labelColor,
                height: 1.0,
              ),
            ),
          )
        else
          Text(
            widget.label,
            maxLines: 1,
            style: TextStyle(
              fontSize: 14,
              fontWeight: widget.fontWeight,
              color: widget.labelColor,
              height: 1.0,
            ),
          ),
      ],
    );

    final face = DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        color: faceColor,
        border: Border.all(color: stroke, width: 0.9),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.lerp(faceColor, Colors.white, isDark ? 0.10 : 0.18)!
                .withValues(alpha: isDark ? 0.35 : 0.28),
            faceColor.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.62],
        ),
      ),
      child: expand ? Center(child: labelRow) : labelRow,
    );

    final clippedFace = ClipRRect(
      borderRadius: radius,
      child: useBackdropBlur
          ? Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: isDark ? 18 : 22,
                      sigmaY: isDark ? 18 : 22,
                    ),
                    child: const SizedBox.shrink(),
                  ),
                ),
                face,
              ],
            )
          : face,
    );

    return SizedBox(
      height: 48,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 90),
        transform: Matrix4.translationValues(0, _pressed ? 2 : 0, 0),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: radius,
            splashFactory: NoSplash.splashFactory,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            overlayColor: const WidgetStatePropertyAll(Colors.transparent),
            onTap: widget.onPressed,
            onHighlightChanged: (v) => setState(() => _pressed = v),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 90),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(borderRadius: radius, boxShadow: shadows),
              child: expand
                  ? ClipRRect(
                      borderRadius: radius,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (useBackdropBlur)
                            BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: isDark ? 18 : 22,
                                sigmaY: isDark ? 18 : 22,
                              ),
                              child: const SizedBox.expand(),
                            ),
                          face,
                        ],
                      ),
                    )
                  : clippedFace,
            ),
          ),
        ),
      ),
    );
  }
}
