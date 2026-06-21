import "dart:ui" show ImageFilter;

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/localization/l10n_extension.dart";
import "package:uy_dosh/base/state/animation_settings_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";
import "package:uy_dosh/presentation/widgets/common/glass_green_chat_cta_button.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_rendering.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/pulse_then_blink_dot_widget.dart";

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
/// width. When [onMessage] is null (e.g. admin viewing a listing they own
/// — you can't chat with yourself), the in-app chat CTA is hidden and
/// Telegram takes the full width.
/// When [onMessage] is non-null, [inAppChatCtaLabel] should describe the chat
/// action for the **current listing owner** (e.g. ARB `chat_with`). When null,
/// falls back to [AppLocalizations.uydosh_chat].
enum ListingDetailActionBarNotificationDot { top, primary }

class ListingDetailContactActionBar extends StatelessWidget {
  const ListingDetailContactActionBar({
    this.onMessage,
    this.onTelegram,
    this.inAppChatCtaLabel,
    this.onSecondary,
    this.secondaryLabel,
    this.secondaryIcon,
    this.primaryIcon,
    this.notificationDot,
    this.notificationDotTrigger = 0,
    this.embedded = false,
    this.onMemberProfiles,
    this.memberProfilesCount,
    super.key,
  }) : assert(
          onMessage != null || onTelegram != null,
          "ListingDetailContactActionBar needs at least one CTA",
        );

  final VoidCallback? onMessage;
  final VoidCallback? onTelegram;
  final String? inAppChatCtaLabel;
  final VoidCallback? onSecondary;
  final String? secondaryLabel;
  final IconData? secondaryIcon;
  final IconData? primaryIcon;
  final ListingDetailActionBarNotificationDot? notificationDot;
  final int notificationDotTrigger;

  /// When true, renders only the CTA column (no sticky frosted footer).
  final bool embedded;

  /// Optional CTA rendered directly above the primary chat button in stacked layouts.
  final VoidCallback? onMemberProfiles;
  final int? memberProfilesCount;

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
    );
  }

  Widget _wrapWithNotificationDot(BuildContext context, Widget child) {
    final theme = Theme.of(context);
    final unreadColor = ThemeState().unreadIndicatorColor;
    final dotBorderColor = theme.brightness == Brightness.dark
        ? theme.colorScheme.surface
        : Colors.white;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: 10,
          top: -4,
          child: PulseThenBlinkDotWidget(
            trigger: notificationDotTrigger,
            color: unreadColor,
            size: 10,
            blinkDuration: const Duration(milliseconds: 750),
            borderColor: dotBorderColor,
            borderWidth: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _secondaryButton(BuildContext context, {double? width}) {
    final accentColor = ListingDetailThemeHelper.iconColor;
    final secondaryTextColor = _getSecondaryTextColor();
    final button = _GlassNeumorphicCtaButton(
      onPressed: () {
        HapticFeedbackUtils.impact();
        onSecondary!.call();
      },
      icon: secondaryIcon ?? Icons.group_outlined,
      iconColor: accentColor,
      label: secondaryLabel!,
      labelColor: secondaryTextColor,
      borderColor: accentColor,
      width: width,
    );
    if (notificationDot != ListingDetailActionBarNotificationDot.top) {
      return button;
    }
    return _wrapWithNotificationDot(context, button);
  }

  Widget _chatButton(BuildContext context, {double? width}) {
    final button = GlassGreenChatCtaButton(
      onPressed: () => onMessage!.call(),
      label: inAppChatCtaLabel ?? context.l10n.uydosh_chat,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      height: 48,
      width: width,
      icon: primaryIcon ?? CupertinoIcons.shield_fill,
    );
    if (notificationDot != ListingDetailActionBarNotificationDot.primary) {
      return button;
    }
    return _wrapWithNotificationDot(context, button);
  }

  bool get _hasSecondaryAction => onSecondary != null && secondaryLabel != null;

  List<Widget> _stackedPrimaryTail(
    BuildContext context, {
    required Widget primaryButton,
  }) {
    if (onMemberProfiles == null) {
      return [primaryButton];
    }
    final accentColor = ListingDetailThemeHelper.iconColor;
    final secondaryTextColor = _getSecondaryTextColor();
    return [
      _GlassNeumorphicCtaButton(
        onPressed: () {
          HapticFeedbackUtils.impact();
          onMemberProfiles!();
        },
        icon: Icons.group_outlined,
        iconColor: accentColor,
        leading: memberProfilesCount == null
            ? null
            : _MemberProfilesLeadingIcon(
                memberCount: memberProfilesCount!,
                color: accentColor,
              ),
        label: L10n.get("view_member_profiles"),
        labelColor: secondaryTextColor,
        borderColor: accentColor,
        width: double.infinity,
      ),
      const SizedBox(height: 8),
      primaryButton,
    ];
  }

  /// Stacked CTAs share one width. Sticky footer centers them; embedded
  /// mode stretches to the scroll content width.
  Widget _buildStackedActions(BuildContext context) {
    if (embedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _secondaryButton(context, width: double.infinity),
          const SizedBox(height: 8),
          ..._stackedPrimaryTail(
            context,
            primaryButton: _chatButton(context, width: double.infinity),
          ),
        ],
      );
    }

    // Align with heightFactor keeps the sticky footer shrink-wrapped. A plain
    // Center would expand to the scaffold bottom slot height and the glass
    // backdrop blur would cover the whole listing body.
    return Align(
      alignment: Alignment.topCenter,
      heightFactor: 1,
      widthFactor: 1,
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _secondaryButton(context),
            const SizedBox(height: 8),
            ..._stackedPrimaryTail(
              context,
              primaryButton: _chatButton(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarContent(BuildContext context) {
    if (!_hasSecondaryAction) return _buildActions(context);
    return _buildStackedActions(context);
  }

  Widget _buildActions(BuildContext context) {
    final hasTelegram = onTelegram != null;
    final hasChat = onMessage != null;
    if (hasTelegram && !hasChat) {
      return SizedBox(
        width: double.infinity,
        child: Builder(builder: _telegramButton),
      );
    }
    if (!hasTelegram) {
      if (embedded) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: _stackedPrimaryTail(
            context,
            primaryButton: _chatButton(context, width: double.infinity),
          ),
        );
      }
      return _chatButton(context, width: double.infinity);
    }
    return Row(
      children: [
        Expanded(child: Builder(builder: _telegramButton)),
        const SizedBox(width: 12),
        Expanded(
          child: Builder(
            builder: (context) => _chatButton(context, width: double.infinity),
          ),
        ),
      ],
    );
  }

  EdgeInsets _barPadding() {
    if (notificationDot != ListingDetailActionBarNotificationDot.top) {
      return const EdgeInsets.fromLTRB(16, 10, 16, 10);
    }
    // Leave room for the badge that sits slightly above the top CTA.
    return const EdgeInsets.fromLTRB(16, 14, 16, 10);
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
          padding: _barPadding(),
          child: _buildBarContent(context),
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
    final enableGlass = LiquidGlassRendering.effectsEnabled(context);
    // Keep the frosted tint anchored to the themed surface so the footer
    // reads the same regardless of what's scrolling past behind it.
    final baseTint = isDark ? BlueThemeColors.background : scheme.surface;

    // Matched to [LiquidGlassAppBarFlexibleSpace] so the header and
    // footer have identical frost characteristics.
    final tintColor = LiquidGlassRendering.chromeFillColor(
      baseTint,
      isDark: isDark,
    );
    final sheenHigh = LiquidGlassRendering.chromeSheenAlpha(isDark: isDark);
    final borderColor = (isDark ? Colors.white : Colors.black).withValues(
      alpha: isDark ? 0.10 : 0.08,
    );

    final backgroundChrome = Stack(
      children: [
        // Tint + top divider.
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: _topRadius,
              color: tintColor,
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
      ],
    );

    // Keep frosted chrome clipped to the rounded footer, but render action
    // buttons (and their notification dots) outside that clip so badges can
    // sit on the top-right corner of CTAs.
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: ClipRRect(
            borderRadius: _topRadius,
            child: LiquidGlassRendering.backdropBlur(
              enabled: enableGlass,
              sigma: isDark ? 18.0 : 22.0,
              child: backgroundChrome,
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: _barPadding(),
            child: _buildBarContent(context),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (embedded) {
      return ListenableBuilder(
        listenable: ThemeState(),
        builder: (context, _) => _buildBarContent(context),
      );
    }

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
    this.leading,
    this.width,
  });

  final VoidCallback onPressed;
  final IconData icon;
  final Color iconColor;
  final String label;
  final Color labelColor;
  final Color borderColor;
  final Widget? leading;
  final double? width;

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

    final base = isDark
        ? scheme.surface.withValues(alpha: 0.08)
        : scheme.surface.withValues(alpha: 0.12);
    final faceColor = base.withValues(alpha: isDark ? 0.38 : 0.55);
    final stroke = widget.borderColor.withValues(alpha: isDark ? 0.60 : 0.70);
    final useBackdropBlur = enableGlass;

    final labelRow = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        widget.leading ??
            ThemeIcon(
              widget.icon,
              size: 18,
              color: widget.iconColor,
            ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: widget.labelColor,
              height: 1.0,
            ),
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
      child: Center(child: labelRow),
    );

    Widget buildSizedButton(double? width) {
      return SizedBox(
        width: width,
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
                decoration:
                    BoxDecoration(borderRadius: radius, boxShadow: shadows),
                child: ClipRRect(
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
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (widget.width != null) return buildSizedButton(widget.width);

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.hasBoundedWidth ? constraints.maxWidth : null;
        return buildSizedButton(width);
      },
    );
  }
}

class _MemberProfilesLeadingIcon extends StatelessWidget {
  const _MemberProfilesLeadingIcon({
    required this.memberCount,
    required this.color,
  });

  final int memberCount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    const iconSize = 18.0;
    const overlap = 8.0;
    final visibleCount =
        memberCount < 1 ? 1 : (memberCount > 6 ? 6 : memberCount);
    final step = iconSize - overlap;

    return SizedBox(
      width: iconSize + (visibleCount - 1) * step,
      height: iconSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(
          visibleCount,
          (index) => Positioned(
            left: index * step,
            child: ThemeIcon(
              index.isEven ? Icons.person_outline : Icons.person,
              size: iconSize,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
