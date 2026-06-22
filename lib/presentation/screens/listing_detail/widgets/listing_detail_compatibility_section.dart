import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "dart:async";
import "dart:math" as math;
import "package:uy_dosh/main.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/constants/app_strings.dart";
import "package:uy_dosh/base/config/client_listing_contacts_config.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/profile_completion_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/state/user_listing_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/domain/models/conversation_member.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/utils/listing_group_progress.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_group_compatibility_helper.dart";
import "package:uy_dosh/presentation/screens/listing_detail/profile_compatibility_field_icons.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_theme_helper.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_tile_shell.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_participant_avatar_stack.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/network_avatar_image.dart";
import "package:uy_dosh/presentation/widgets/common/liquid_glass_rendering.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/uydosh_link_button.dart";

/// Data class for a compatibility match (same value).
class CompatibilityMatch {
  const CompatibilityMatch({
    required this.labelKey,
    required this.label,
    required this.value,
  });

  final String labelKey;
  final String label;
  final String value;
}

/// Data class for a compatibility difference (user vs owner).
class CompatibilityDifference {
  const CompatibilityDifference({
    required this.labelKey,
    required this.label,
    required this.currentText,
    required this.ownerText,
  });

  final String labelKey;
  final String label;
  final String currentText;
  final String ownerText;
}

/// Compatibility section widget for listing detail screen.
/// Shows match percentage and expandable list of matches/differences.
class ListingDetailCompatibilitySection extends StatefulWidget {
  const ListingDetailCompatibilitySection({
    required this.listingDetail,
    required this.scrollController,
    required this.sectionKey,
    required this.compatibilityPercent,
    required this.isLoadingCompatibility,
    required this.compatibilityError,
    required this.matches,
    required this.differences,
    required this.dealbreakers,
    required this.scoredFieldCount,
    required this.totalFieldCount,
    required this.telegramHandle,
    required this.phoneNumber,
    required this.onTelegram,
    required this.onPhone,
    required this.onViewProfile,
    required this.onCompleteProfile,
    this.currentUserAvatarUrl,
    this.ownerAvatarUrl,
    this.isGroupCompatibility = false,
    this.groupMembers = const [],
    this.groupFullMatches = const [],
    this.groupPartialMatches = const [],
    this.groupDiscussItems = const [],
    this.groupPreferenceMatrix = const [],
    this.currentUserId,
    super.key,
  });

  final ListingDetail listingDetail;
  final ScrollController scrollController;
  final GlobalKey sectionKey;
  final int? compatibilityPercent;
  final bool isLoadingCompatibility;
  final String? compatibilityError;
  final List<CompatibilityMatch> matches;
  final List<CompatibilityDifference> differences;
  final List<CompatibilityDifference> dealbreakers;
  final int scoredFieldCount;
  final int totalFieldCount;
  final String? telegramHandle;
  final String? phoneNumber;
  final VoidCallback? onTelegram;
  final VoidCallback? onPhone;
  final VoidCallback onViewProfile;
  final VoidCallback onCompleteProfile;
  final String? currentUserAvatarUrl;
  final String? ownerAvatarUrl;
  final bool isGroupCompatibility;
  final List<ConversationMemberSummary> groupMembers;
  final List<GroupCompatibilityFullMatch> groupFullMatches;
  final List<GroupCompatibilityPartialMatch> groupPartialMatches;
  final List<GroupCompatibilityDiscussItem> groupDiscussItems;
  final List<GroupPreferenceMatrixRow> groupPreferenceMatrix;
  final int? currentUserId;

  @override
  State<ListingDetailCompatibilitySection> createState() =>
      _ListingDetailCompatibilitySectionState();
}

class _ListingDetailCompatibilitySectionState
    extends State<ListingDetailCompatibilitySection> with RouteAware {
  static const double _matrixTableCornerRadius = 10;
  static const double _matrixUserHeaderHeight = 76;

  Timer? _scrollIntoViewTimer;
  final GlobalKey _matrixUserHeaderKey = GlobalKey();
  final GlobalKey _matrixTableKey = GlobalKey();
  OverlayEntry? _matrixStickyHeaderOverlay;
  bool _isCompatibilitySectionExpanded = true;
  bool _isMatrixExpanded = true;
  bool _showMatrixStickyHeader = false;
  Rect? _matrixStickyHeaderBounds;
  Animation<double>? _transitionAnimation;
  Animation<double>? _entryAnimation;
  bool _didScheduleEntrySync = false;

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_handleParentScroll);
    final isAuthenticated = AuthenticationState().isAuthenticated;
    final isProfileComplete = ProfileCompletionState().isProfileComplete;
    _isCompatibilitySectionExpanded =
        !isAuthenticated || !isProfileComplete;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes so we can re-anchor (or hide) the pinned
    // matrix header when another screen — e.g. the group chat — is pushed on
    // top of the listing detail and later popped. Scroll events don't fire
    // during navigation, so without this the overlay lingers with stale
    // bounds and reappears misplaced after returning.
    routeObserver.unsubscribe(this);
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }

    // Defer the first sticky-header sync until the entry (push) transition has
    // settled. Measuring while the page is still sliding in reads the matrix at
    // transient coordinates that fall under the app bar, which wrongly pins the
    // header and hides the in-flow row. No scroll event follows the transition,
    // so without this the header stays blank until the user scrolls. Mirrors
    // the didPopNext handling for returning from a pushed route.
    if (!_didScheduleEntrySync) {
      _didScheduleEntrySync = true;
      _recomputeStickyHeaderAfterEntryTransition();
    }
  }

  @override
  void didPushNext() {
    // Navigating away (e.g. opening the group chat): drop the overlay so it
    // can't sit on top of the pushed route.
    _setMatrixStickyHeaderVisible(false);
  }

  @override
  void didPopNext() {
    // Returning to the listing detail: recompute the pinned header position
    // from the now-settled layout instead of trusting pre-navigation bounds.
    //
    // didPopNext fires as soon as the pop starts, while the page transition is
    // still animating. Measuring then would read the table mid-slide and pin
    // the overlay to transient coordinates that never correct (no scroll
    // event follows). Wait for the transition to finish before measuring.
    _recomputeStickyHeaderAfterTransition();
  }

  void _recomputeStickyHeaderAfterTransition() {
    _transitionAnimation?.removeStatusListener(_handleTransitionStatus);
    _transitionAnimation = null;

    final secondary = ModalRoute.of(context)?.secondaryAnimation;
    if (secondary == null ||
        secondary.status == AnimationStatus.dismissed) {
      _scheduleMatrixStickyHeaderUpdate();
      return;
    }

    _transitionAnimation = secondary;
    secondary.addStatusListener(_handleTransitionStatus);
  }

  void _handleTransitionStatus(AnimationStatus status) {
    if (status != AnimationStatus.dismissed &&
        status != AnimationStatus.completed) {
      return;
    }
    _transitionAnimation?.removeStatusListener(_handleTransitionStatus);
    _transitionAnimation = null;
    if (mounted) _scheduleMatrixStickyHeaderUpdate();
  }

  void _recomputeStickyHeaderAfterEntryTransition() {
    _entryAnimation?.removeStatusListener(_handleEntryStatus);
    _entryAnimation = null;

    final animation = ModalRoute.of(context)?.animation;
    if (animation == null ||
        animation.status == AnimationStatus.completed ||
        animation.status == AnimationStatus.dismissed) {
      _scheduleMatrixStickyHeaderUpdate();
      return;
    }

    _entryAnimation = animation;
    animation.addStatusListener(_handleEntryStatus);
  }

  void _handleEntryStatus(AnimationStatus status) {
    if (status != AnimationStatus.dismissed &&
        status != AnimationStatus.completed) {
      return;
    }
    _entryAnimation?.removeStatusListener(_handleEntryStatus);
    _entryAnimation = null;
    if (mounted) _scheduleMatrixStickyHeaderUpdate();
  }

  @override
  void didUpdateWidget(ListingDetailCompatibilitySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.groupPreferenceMatrix != widget.groupPreferenceMatrix ||
        oldWidget.groupMembers != widget.groupMembers ||
        oldWidget.currentUserId != widget.currentUserId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _updateMatrixStickyHeader();
      });
    }
  }

  @override
  void deactivate() {
    if (_showMatrixStickyHeader) {
      _showMatrixStickyHeader = false;
      _matrixStickyHeaderBounds = null;
      _removeMatrixStickyHeaderOverlay();
    }
    super.deactivate();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _transitionAnimation?.removeStatusListener(_handleTransitionStatus);
    _transitionAnimation = null;
    _entryAnimation?.removeStatusListener(_handleEntryStatus);
    _entryAnimation = null;
    widget.scrollController.removeListener(_handleParentScroll);
    _removeMatrixStickyHeaderOverlay();
    _scrollIntoViewTimer?.cancel();
    super.dispose();
  }

  bool _hasGroupPreferenceMatrix() {
    return widget.groupMembers.length >= 3 &&
        widget.groupPreferenceMatrix.isNotEmpty;
  }

  List<int> _orderedMatrixUserIds() {
    final currentUserId =
        widget.currentUserId ?? UserListingState().currentUserId;
    final matrixUserIds = widget.groupPreferenceMatrix.first.cells
        .map((cell) => cell.userId)
        .toList(growable: false);
    if (currentUserId == null) return matrixUserIds;
    return [
      if (matrixUserIds.contains(currentUserId)) currentUserId,
      ...matrixUserIds.where((id) => id != currentUserId),
    ];
  }

  ConversationMemberSummary? _matrixMemberFor(int userId) {
    for (final member in widget.groupMembers) {
      if (member.userId == userId) return member;
    }
    return null;
  }

  String _matrixMemberName(int userId) {
    final member = _matrixMemberFor(userId);
    final name = member?.name.trim();
    final fallbackUserLabel = L10n.get("user");
    if (name == null || name.isEmpty) return fallbackUserLabel;

    final parts = name.split(RegExp(r"\s+"));
    if (parts.length < 2) return name;

    return "${parts.first} ${parts.last.characters.first}.";
  }

  double _matrixStickyHeaderTop(BuildContext context) {
    final scaffoldHeight = Scaffold.maybeOf(context)?.appBarMaxHeight;
    if (scaffoldHeight != null && scaffoldHeight > 0) {
      return scaffoldHeight;
    }
    final toolbarHeight =
        AppBarTheme.of(context).toolbarHeight ?? kToolbarHeight;
    return MediaQuery.viewPaddingOf(context).top + toolbarHeight;
  }

  bool _isListingDetailRouteCurrent() {
    final route = ModalRoute.of(context);
    return route == null || route.isCurrent;
  }

  void _handleParentScroll() {
    _updateMatrixStickyHeader();
  }

  void _updateMatrixStickyHeader() {
    if (!mounted ||
        !_isListingDetailRouteCurrent() ||
        !_hasGroupPreferenceMatrix() ||
        !_isCompatibilitySectionExpanded ||
        !_isMatrixExpanded) {
      _setMatrixStickyHeaderVisible(false);
      return;
    }

    final tableContext = _matrixTableKey.currentContext;
    final headerContext = _matrixUserHeaderKey.currentContext;
    if (tableContext == null || headerContext == null) {
      _setMatrixStickyHeaderVisible(false);
      return;
    }

    final tableBox = tableContext.findRenderObject();
    final headerBox = headerContext.findRenderObject();
    if (tableBox is! RenderBox ||
        headerBox is! RenderBox ||
        !tableBox.hasSize ||
        !headerBox.hasSize) {
      _setMatrixStickyHeaderVisible(false);
      return;
    }

    final pinTop = _matrixStickyHeaderTop(context);
    final headerTop = headerBox.localToGlobal(Offset.zero).dy;
    final tableTop = tableBox.localToGlobal(Offset.zero).dy;
    final tableBottom =
        tableBox.localToGlobal(Offset(0, tableBox.size.height)).dy;
    final viewportHeight = MediaQuery.sizeOf(context).height;

    final matrixVisible =
        tableBottom > pinTop && tableTop < viewportHeight;
    // Pin as soon as the app bar starts covering the in-flow header, not
    // after it has fully scrolled away (that left a visible gap).
    final shouldPin = matrixVisible && headerTop < pinTop;

    if (shouldPin) {
      final tableOrigin = tableBox.localToGlobal(Offset.zero);
      final stickyTop = math.max(headerTop, pinTop);
      _setMatrixStickyHeaderVisible(
        true,
        bounds: Rect.fromLTWH(
          tableOrigin.dx,
          stickyTop,
          tableBox.size.width,
          _matrixUserHeaderHeight,
        ),
      );
    } else {
      _setMatrixStickyHeaderVisible(false);
    }
  }

  void _setMatrixStickyHeaderVisible(
    bool visible, {
    Rect? bounds,
  }) {
    if (!visible) {
      if (!_showMatrixStickyHeader) return;
      _showMatrixStickyHeader = false;
      _matrixStickyHeaderBounds = null;
      _removeMatrixStickyHeaderOverlay();
      setState(() {});
      return;
    }

    final nextBounds = bounds;
    if (nextBounds == null) return;

    final boundsChanged = _matrixStickyHeaderBounds == null ||
        (_matrixStickyHeaderBounds!.left - nextBounds.left).abs() > 0.5 ||
        (_matrixStickyHeaderBounds!.top - nextBounds.top).abs() > 0.5 ||
        (_matrixStickyHeaderBounds!.width - nextBounds.width).abs() > 0.5;

    if (!_showMatrixStickyHeader || boundsChanged) {
      final becameVisible = !_showMatrixStickyHeader;
      _showMatrixStickyHeader = true;
      _matrixStickyHeaderBounds = nextBounds;
      _insertOrUpdateMatrixStickyHeaderOverlay();
      if (becameVisible) setState(() {});
    } else {
      _matrixStickyHeaderOverlay?.markNeedsBuild();
    }
  }

  void _removeMatrixStickyHeaderOverlay() {
    _matrixStickyHeaderOverlay?.remove();
    _matrixStickyHeaderOverlay = null;
  }

  void _insertOrUpdateMatrixStickyHeaderOverlay() {
    if (!mounted || !_showMatrixStickyHeader) {
      _removeMatrixStickyHeaderOverlay();
      return;
    }

    final overlay = Overlay.maybeOf(context);
    if (overlay == null) return;

    if (_matrixStickyHeaderOverlay == null) {
      _matrixStickyHeaderOverlay = OverlayEntry(
        builder: (context) => _buildMatrixStickyHeaderOverlay(),
      );
      overlay.insert(_matrixStickyHeaderOverlay!);
    } else {
      _matrixStickyHeaderOverlay!.markNeedsBuild();
    }
  }

  Widget _buildMatrixTableCell({
    required Widget child,
    required Color borderColor,
    bool isHeader = false,
    bool isLast = false,
    bool showBottomBorder = true,
    Alignment alignment = Alignment.center,
    Color? fillColor,
  }) {
    return Expanded(
      child: Container(
        constraints: BoxConstraints(minHeight: isHeader ? 76 : 36),
        alignment: alignment,
        padding: EdgeInsets.symmetric(
          horizontal: 6,
          vertical: isHeader ? 8 : 5,
        ),
        decoration: BoxDecoration(
          color: fillColor,
          border: Border(
            right: isLast ? BorderSide.none : BorderSide(color: borderColor),
            bottom: showBottomBorder
                ? BorderSide(color: borderColor)
                : BorderSide.none,
          ),
        ),
        child: child,
      ),
    );
  }

  Widget _buildMatrixUserHeaderRow({
    required List<int> orderedUserIds,
    required Color textColor,
    required Color borderColor,
    Key? key,
    bool pinned = false,
    bool? showBottomBorder,
  }) {
    final cellBottomBorder = showBottomBorder ?? !pinned;
    return KeyedSubtree(
      key: key,
      child: Row(
        children: [
          for (var i = 0; i < orderedUserIds.length; i++)
            _buildMatrixTableCell(
              isHeader: true,
              isLast: i == orderedUserIds.length - 1,
              borderColor: borderColor,
              showBottomBorder: cellBottomBorder,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeaderAvatar(
                    _matrixMemberFor(orderedUserIds[i])?.avatarUrl,
                    size: 28,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _matrixMemberName(orderedUserIds[i]),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: orderedUserIds.length >= 5 ? 11 : 12,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Color _matrixCardTintColor() {
    return _getDescriptionTextColor().withValues(alpha: 0.04);
  }

  Color _matrixHeaderSurfaceColor() {
    final cardBase =
        Theme.of(context).cardTheme.color ??
        Theme.of(context).colorScheme.surface;
    return Color.alphaBlend(_matrixCardTintColor(), cardBase);
  }

  Widget _buildMatrixStickyHeaderOverlay() {
    final bounds = _matrixStickyHeaderBounds;
    if (!_showMatrixStickyHeader ||
        bounds == null ||
        !_isListingDetailRouteCurrent()) {
      return const SizedBox.shrink();
    }

    final textColor = _getDescriptionTextColor();
    final borderColor = Colors.transparent;
    final orderedUserIds = _orderedMatrixUserIds();

    return Positioned(
      left: bounds.left,
      top: bounds.top,
      width: bounds.width,
      height: _matrixUserHeaderHeight,
      // The overlay lives in the root [Overlay], which has no [Material]
      // ancestor — without one the header's Text widgets render with Flutter's
      // yellow "missing Material" debug underlines.
      child: Material(
        type: MaterialType.transparency,
        child: ListenableBuilder(
          listenable: ThemeState(),
          builder: (context, _) => _buildMatrixStickyHeaderGlassShell(
            borderColor: borderColor,
            child: _buildPinnedMatrixUserHeaderRow(
              orderedUserIds: orderedUserIds,
              textColor: textColor,
              borderColor: borderColor,
            ),
          ),
        ),
      ),
    );
  }

  /// Compact header row sized exactly for the pinned overlay. Separate from
  /// the in-flow row so we avoid minHeight/padding overflow (yellow stripes).
  Widget _buildPinnedMatrixUserHeaderRow({
    required List<int> orderedUserIds,
    required Color textColor,
    required Color borderColor,
  }) {
    final nameFontSize = orderedUserIds.length >= 5 ? 11.0 : 12.0;

    return SizedBox(
      height: _matrixUserHeaderHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < orderedUserIds.length; i++)
            Expanded(
              // Mirror the in-flow header cell geometry exactly
              // ([_buildMatrixTableCell] with isHeader: true) so swapping the
              // faded in-flow row for this pinned overlay doesn't nudge the
              // avatar/name. The fixed 76px height + center alignment matches
              // the in-flow minHeight: 76 centering without overflowing.
              child: Container(
                alignment: Alignment.center,
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    right: i == orderedUserIds.length - 1
                        ? BorderSide.none
                        : BorderSide(color: borderColor),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildHeaderAvatar(
                      _matrixMemberFor(orderedUserIds[i])?.avatarUrl,
                      size: 28,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _matrixMemberName(orderedUserIds[i]),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: nameFontSize,
                        fontWeight: FontWeight.w700,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMatrixStickyHeaderBorderOverlay({
    required Color borderColor,
    required BorderRadius borderRadius,
  }) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          border: Border(
            top: BorderSide(color: borderColor),
            left: BorderSide(color: borderColor),
            right: BorderSide(color: borderColor),
            bottom: BorderSide(color: borderColor),
          ),
        ),
      ),
    );
  }

  Widget _buildMatrixStickyHeaderBackground({
    required bool isLightTheme,
    required bool enableGlass,
    required BorderRadius borderRadius,
  }) {
    // When frosted-glass effects are off (reduce motion / accessibility) there
    // is no backdrop blur to read through, so fall back to an opaque surface
    // that keeps the header text legible over scrolling content.
    if (!enableGlass) {
      return ColoredBox(color: _matrixHeaderSurfaceColor());
    }

    // Translucent plate over the glass-shell's backdrop blur so the scrolling
    // content shows through — matching the see-through in-flow header instead
    // of a flat opaque slab.
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        gradient: LiquidGlassRendering.plateGradient(
          context: context,
          isDark: isDark && !isLightTheme,
        ),
      ),
    );
  }

  Widget _buildMatrixStickyHeaderGlassShell({
    required Color borderColor,
    required Widget child,
  }) {
    const topRadius = BorderRadius.vertical(
      top: Radius.circular(_matrixTableCornerRadius),
    );
    final themeState = ThemeState();
    final isLightTheme = themeState.isLightTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final enableGlass = LiquidGlassRendering.effectsEnabled(context);

    return ClipRRect(
      borderRadius: topRadius,
      clipBehavior: Clip.hardEdge,
      child: LiquidGlassRendering.backdropBlur(
        enabled: enableGlass,
        sigma: isLightTheme ? 22.0 : (isDark ? 18.0 : 22.0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildMatrixStickyHeaderBackground(
              isLightTheme: isLightTheme,
              enableGlass: enableGlass,
              borderRadius: topRadius,
            ),
            child,
            _buildMatrixStickyHeaderBorderOverlay(
              borderColor: borderColor,
              borderRadius: topRadius,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void activate() {
    super.activate();
    _scheduleMatrixStickyHeaderUpdate();
  }

  void _scheduleMatrixStickyHeaderUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _updateMatrixStickyHeader();
    });
  }

  /// Extra scroll offset so the section header lands below the app bar when
  /// [Scaffold.extendBodyBehindAppBar] is active (blue / light themes).
  static double _listingDetailScrollTopInset(BuildContext ctx) {
    final themeState = ThemeState();
    final useLiquidGlassAppBar =
        themeState.isBlueTheme || themeState.isLightTheme;
    if (!useLiquidGlassAppBar) return 0;
    return MediaQuery.paddingOf(ctx).top + kToolbarHeight;
  }

  static void _maybeAnimateScrollIntoView(
    BuildContext ctx, {
    Duration duration = const Duration(milliseconds: 300),
    Curve curve = Curves.easeInOut,
  }) {
    final scrollable = Scrollable.maybeOf(ctx);
    final position = scrollable?.position;
    if (position == null) return;

    final renderObject = ctx.findRenderObject();
    if (renderObject is! RenderBox) return;

    final viewport = RenderAbstractViewport.of(renderObject);
    final topInset = _listingDetailScrollTopInset(ctx);

    final target =
        (viewport.getOffsetToReveal(renderObject, 0.0).offset - topInset)
            .clamp(position.minScrollExtent, position.maxScrollExtent);

    if ((target - position.pixels).abs() < 2) return;
    position.animateTo(target, duration: duration, curve: curve);
  }

  static IconData _getLifestyleIcon(String labelKey) =>
      ProfileCompatibilityFieldIcons.iconFor(labelKey);

  static Widget? _buildMatrixValueIcon(
    String iconKey, {
    required Color color,
  }) {
    final parts = iconKey.split(":");
    if (parts.length != 2) return null;
    final category = parts.first;
    final value = parts.last;

    Widget singleIcon(IconData icon) => Icon(icon, size: 18, color: color);

    Widget repeatedIcon(IconData icon, int count) {
      return Wrap(
        alignment: WrapAlignment.center,
        spacing: 2,
        runSpacing: 2,
        children: [
          for (var i = 0; i < count; i++) Icon(icon, size: 12, color: color),
        ],
      );
    }

    Widget ratingDots(int count) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (var i = 1; i <= 5; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Icon(
                i <= count ? Icons.circle : Icons.circle_outlined,
                size: 10,
                color: color.withValues(alpha: i <= count ? 0.9 : 0.45),
              ),
            ),
        ],
      );
    }

    int? ratingValue() {
      final parsed = int.tryParse(value);
      if (parsed == null) return null;
      return parsed.clamp(1, 5).toInt();
    }

    switch (category) {
      case "day":
        switch (value) {
          case "morning":
            return singleIcon(Icons.wb_sunny);
          case "evening":
            return singleIcon(Icons.schedule);
          case "night":
            return singleIcon(Icons.nights_stay);
        }
        return null;
      case "smoking":
        switch (value) {
          case "non-smoker":
            return singleIcon(Icons.smoke_free);
          case "occasional":
            return singleIcon(Icons.smoking_rooms);
          case "regular":
            return repeatedIcon(Icons.smoking_rooms, 2);
        }
        return null;
      case "pets":
        switch (value) {
          case "dont_like_pets":
            return singleIcon(Icons.block);
          case "like_pets":
            return singleIcon(Icons.favorite);
          case "have_cat":
          case "have_dog":
            return singleIcon(Icons.pets);
        }
        return null;
      case "cleanliness":
      case "noise":
      case "sociability":
        final count = ratingValue();
        return count == null ? null : ratingDots(count);
      case "alcohol":
        switch (value) {
          case "non-drinker":
            return singleIcon(Icons.block);
          case "occasional":
            return singleIcon(Icons.local_bar);
          case "regular":
            return repeatedIcon(Icons.local_bar, 2);
        }
        return null;
      case "guests":
        return singleIcon(value == "yes" ? Icons.check : Icons.close);
      case "cooking":
        return singleIcon(value == "yes" ? Icons.restaurant : Icons.close);
    }

    return null;
  }

  String _formatUzbekPhoneDisplay(String raw) {
    final d = raw.replaceAll(RegExp(r"\D"), "");
    // Handle +998XXXXXXXXX, 998XXXXXXXXX, or 9XXXXXXXX
    String? nine;
    if (d.startsWith("998") && d.length >= 12) {
      final rest = d.substring(3);
      if (rest.length >= 9 &&
          RegExp(r"^9[0134679]\d{7}$").hasMatch(rest.substring(0, 9))) {
        nine = rest.substring(0, 9);
      }
    } else if (d.startsWith("9") &&
        d.length >= 9 &&
        RegExp(r"^9[0134679]\d{7}$").hasMatch(d.substring(0, 9))) {
      nine = d.substring(0, 9);
    } else if (d.length == 9 && RegExp(r"^9[0134679]\d{7}$").hasMatch(d)) {
      nine = d;
    } else if (d.length > 9) {
      final m = RegExp(r"(9[0134679]\d{7})$").firstMatch(d);
      nine = m?.group(1);
    }

    if (nine == null || nine.length != 9) return raw.trim();
    return "+998 ${nine.substring(0, 2)} ${nine.substring(2, 5)} "
        "${nine.substring(5, 7)} ${nine.substring(7, 9)}";
  }

  Color _getDescriptionTextColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.textLight;
    } else {
      return AppColors.textDark87;
    }
  }

  Color _getLocationTextColor() {
    if (ThemeState().isBlueTheme) {
      return AppColors.textLight;
    } else {
      return AppColors.textDark87;
    }
  }

  Color _getIconColor() {
    if (ThemeState().isBlueTheme) {
      return Colors.white;
    } else if (ThemeState().isLightTheme) {
      return Colors.black;
    } else {
      return AppColors.iconPrimary;
    }
  }

  Color _getCompatibilityPercentColor() {
    if (widget.compatibilityPercent == null) return _getDescriptionTextColor();
    if (widget.compatibilityPercent! >= 80) {
      return ThemeState().isLightTheme
          ? AppColors.successDark
          : AppColors.success;
    }
    if (widget.compatibilityPercent! >= 60) return AppColors.warning;
    return AppColors.error;
  }

  Widget _buildHeaderAvatar(String? avatarUrl, {required double size}) {
    final resolvedUrl = resolveAvatarUrl(avatarUrl);
    final borderColor = ChatParticipantAvatarStack.avatarBorderColor(context);
    final fallback = CircleAvatar(
      radius: size / 2,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: ThemeIcon(
        Icons.person_outline,
        size: size * 0.45,
        color: _getIconColor(),
      ),
    );

    Widget avatarContent;
    if (resolvedUrl == null) {
      avatarContent = fallback;
    } else {
      avatarContent = ClipOval(
        child: NetworkAvatarImage(
          imageUrl: resolvedUrl,
          size: size,
          fallback: fallback,
        ),
      );
    }

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned.fill(child: avatarContent),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupHeaderAvatars() {
    return ChatParticipantAvatarStack(
      participants: widget.groupMembers,
      currentUserId: widget.currentUserId ?? UserListingState().currentUserId,
      avatarSize: 32,
      maxVisible: 5,
    );
  }

  Widget _buildGroupHeaderTitle(String headerPercentText) {
    final progress =
        ListingGroupProgress.fromListingDetail(widget.listingDetail);
    final membersNeeded =
        progress == null ? 0 : progress.target - progress.current;
    final subtitleColor = _getDescriptionTextColor().withValues(alpha: 0.8);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text.rich(
          TextSpan(
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _getDescriptionTextColor(),
            ),
            children: [
              TextSpan(text: L10n.get("group_compatibility_title")),
              TextSpan(
                text: " $headerPercentText",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: _getCompatibilityPercentColor(),
                ),
              ),
            ],
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        Row(
          children: [
            Flexible(
              child: Text(
                L10n.getWithParams(
                  "group_compatibility_subtitle",
                  params: {"count": widget.groupMembers.length.toString()},
                ),
                style: TextStyle(fontSize: 13, color: subtitleColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (membersNeeded > 0) ...[
              const SizedBox(width: 6),
              Icon(Icons.circle, size: 4, color: subtitleColor),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  L10n.plural(
                    "group_compatibility_persons_needed",
                    membersNeeded,
                  ),
                  style: TextStyle(fontSize: 13, color: subtitleColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        _buildGroupHeaderAvatars(),
      ],
    );
  }

  Widget _buildGroupPreferenceMatrix() {
    if (widget.groupMembers.length < 3 ||
        widget.groupPreferenceMatrix.isEmpty) {
      return const SizedBox.shrink();
    }

    final textColor = _getDescriptionTextColor();
    final borderColor = Colors.transparent;
    final themeState = ThemeState();
    final isLightTheme = themeState.isLightTheme;
    final isBlueTheme = themeState.isBlueTheme;
    final useValueClusterFills = isLightTheme;
    // Blue theme keeps the default container background and signals status via
    // green/orange/red icon colors instead of tinted cell fills.
    final useStatusIconColors = isBlueTheme;
    final notSpecifiedLabel = L10n.get("not_specified");
    final currentUserId =
        widget.currentUserId ?? UserListingState().currentUserId;
    final matrixUserIds = widget.groupPreferenceMatrix.first.cells
        .map((cell) => cell.userId)
        .toList(growable: false);
    final orderedUserIds = currentUserId == null
        ? matrixUserIds
        : [
            if (matrixUserIds.contains(currentUserId)) currentUserId,
            ...matrixUserIds.where((id) => id != currentUserId),
          ];
    final cellsByRowAndUserId = {
      for (final row in widget.groupPreferenceMatrix)
        row: {
          for (final cell in row.cells) cell.userId: cell,
        },
    };

    Widget tableCell({
      required Widget child,
      bool isHeader = false,
      bool isLast = false,
      Alignment alignment = Alignment.center,
      Color? fillColor,
    }) {
      return _buildMatrixTableCell(
        child: child,
        borderColor: borderColor,
        isHeader: isHeader,
        isLast: isLast,
        alignment: alignment,
        fillColor: fillColor,
      );
    }

    Color? statusColor(GroupPreferenceMatrixCellStatus status) {
      switch (status) {
        case GroupPreferenceMatrixCellStatus.fullMatch:
        case GroupPreferenceMatrixCellStatus.partialMatch:
          return isLightTheme ? AppColors.successDark : AppColors.success;
        case GroupPreferenceMatrixCellStatus.mismatch:
          return isLightTheme ? AppColors.warningDark : AppColors.warning;
        case GroupPreferenceMatrixCellStatus.conflict:
          return AppColors.error;
        case GroupPreferenceMatrixCellStatus.missing:
          return null;
      }
    }

    ({Color prominent, Color muted}) valueClusterFillPalette() {
      if (isLightTheme) {
        return (
          prominent: const Color(0xFFEAD9C3),
          muted: const Color(0xFFD5DED2),
        );
      }
      return (
        prominent: const Color(0xFF3C4451),
        muted: const Color(0xFF2D3E4F),
      );
    }

    bool rowHasValueSplit(GroupPreferenceMatrixRow row) {
      final valueKeys = row.cells
          .where(
            (cell) =>
                cell.status != GroupPreferenceMatrixCellStatus.missing &&
                cell.valueIconKey != null,
          )
          .map((cell) => cell.valueIconKey!)
          .toSet();
      return valueKeys.length > 1;
    }

    GroupPreferenceMatrixCellStatus resolveRowStatus(
      GroupPreferenceMatrixRow row,
    ) {
      var hasStatus = false;
      var hasPartialMatch = false;
      for (final cell in row.cells) {
        final status = cell.status;
        if (status == GroupPreferenceMatrixCellStatus.missing) continue;
        hasStatus = true;
        if (status == GroupPreferenceMatrixCellStatus.conflict) {
          return GroupPreferenceMatrixCellStatus.conflict;
        }
        if (status == GroupPreferenceMatrixCellStatus.mismatch) {
          return GroupPreferenceMatrixCellStatus.mismatch;
        }
        if (status == GroupPreferenceMatrixCellStatus.partialMatch) {
          hasPartialMatch = true;
        }
      }

      if (!hasStatus) return GroupPreferenceMatrixCellStatus.missing;
      if (hasPartialMatch) {
        return GroupPreferenceMatrixCellStatus.partialMatch;
      }
      return GroupPreferenceMatrixCellStatus.fullMatch;
    }

    final rowStatusByRow = {
      for (final row in widget.groupPreferenceMatrix)
        row: resolveRowStatus(row),
    };

    GroupPreferenceMatrixCell? cellFor(
      GroupPreferenceMatrixRow row,
      int userId,
    ) {
      return cellsByRowAndUserId[row]?[userId];
    }

    GroupPreferenceMatrixCellStatus rowStatus(GroupPreferenceMatrixRow row) {
      return rowStatusByRow[row] ?? GroupPreferenceMatrixCellStatus.missing;
    }

    Color? matrixRowHeaderFillColor(GroupPreferenceMatrixRow row) {
      if (useStatusIconColors) return null;
      if (!useValueClusterFills) {
        return statusColor(rowStatus(row))?.withValues(alpha: 0.08);
      }

      final status = rowStatus(row);
      if (status == GroupPreferenceMatrixCellStatus.conflict) {
        return AppColors.error.withValues(alpha: 0.12);
      }
      if (!rowHasValueSplit(row)) {
        return valueClusterFillPalette().muted;
      }
      return valueClusterFillPalette().prominent;
    }

    Color? matrixCellFillColor(
      GroupPreferenceMatrixRow row,
      GroupPreferenceMatrixCell? cell,
    ) {
      if (cell == null ||
          cell.status == GroupPreferenceMatrixCellStatus.missing) {
        return null;
      }

      if (useStatusIconColors) return null;
      if (!useValueClusterFills) {
        return statusColor(cell.status)?.withValues(alpha: 0.08);
      }

      if (cell.status == GroupPreferenceMatrixCellStatus.conflict) {
        return AppColors.error.withValues(alpha: 0.12);
      }
      if (!rowHasValueSplit(row)) {
        return valueClusterFillPalette().muted;
      }

      // Highlight divergent values; majority-aligned cluster stays muted.
      return cell.status == GroupPreferenceMatrixCellStatus.mismatch
          ? valueClusterFillPalette().prominent
          : valueClusterFillPalette().muted;
    }

    Widget valueText(
      String value, {
      GroupPreferenceMatrixCellStatus status =
          GroupPreferenceMatrixCellStatus.missing,
    }) {
      final isMissing = value == notSpecifiedLabel;
      final accentColor = statusColor(status);
      return Text(
        value,
        textAlign: TextAlign.center,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: orderedUserIds.length >= 5 ? 11 : 12,
          fontWeight: isMissing ? FontWeight.w400 : FontWeight.w600,
          color: isMissing
              ? textColor.withValues(alpha: 0.55)
              : (accentColor ?? textColor).withValues(alpha: 0.9),
        ),
      );
    }

    Widget iconValueCell(
      GroupPreferenceMatrixRow row,
      int userId, {
      GroupPreferenceMatrixCell? cell,
    }) {
      cell ??= cellFor(row, userId);
      final value = cell?.value ?? notSpecifiedLabel;
      final status = cell?.status ?? GroupPreferenceMatrixCellStatus.missing;
      final iconKey = cell?.valueIconKey;
      if (iconKey == null || value == notSpecifiedLabel) {
        return valueText(value, status: status);
      }

      final iconColor = useStatusIconColors
          ? (statusColor(status) ?? textColor).withValues(alpha: 0.9)
          : textColor.withValues(alpha: 0.9);
      final visual = _buildMatrixValueIcon(
        iconKey,
        color: iconColor,
      );
      if (visual == null) return valueText(value, status: status);

      return Tooltip(
        message: value,
        child: Semantics(
          label: "${row.label}: $value",
          child: ExcludeSemantics(child: visual),
        ),
      );
    }

    Widget matrixRowHeader(GroupPreferenceMatrixRow row) {
      final accentColor = statusColor(rowStatus(row));

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: matrixRowHeaderFillColor(row),
          border: Border(
            bottom: BorderSide(color: borderColor),
          ),
        ),
        child: Row(
          children: [
            ThemeIcon(
              _getLifestyleIcon(row.labelKey),
              size: 18,
              color: (accentColor ?? textColor).withValues(
                alpha: 0.85,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: accentColor ?? textColor,
                    ),
                  ),
                  if (row.alignmentSummary != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      row.alignmentSummary!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: (accentColor ?? textColor).withValues(
                          alpha: 0.75,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    Widget matrixValueTableCell(
      GroupPreferenceMatrixRow row,
      int index,
    ) {
      final userId = orderedUserIds[index];
      final cell = cellFor(row, userId);

      return tableCell(
        isLast: index == orderedUserIds.length - 1,
        fillColor: matrixCellFillColor(row, cell),
        child: iconValueCell(row, userId, cell: cell),
      );
    }

    final chevronColor = ListingDetailThemeHelper.locationTextColor;

    final matrixWidget = SizedBox(
      width: double.infinity,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          initiallyExpanded: true,
          onExpansionChanged: _onMatrixExpansionChanged,
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          iconColor: chevronColor,
          collapsedIconColor: chevronColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.transparent),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.transparent),
          ),
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ThemeIcon(
                    Icons.table_chart_outlined,
                    size: 20,
                    color: textColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      L10n.get("group_preference_matrix_title"),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                L10n.get("group_preference_matrix_subtitle"),
                style: TextStyle(
                  fontSize: 12,
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          children: [
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(_matrixTableCornerRadius),
              child: DecoratedBox(
                key: _matrixTableKey,
                decoration: BoxDecoration(
                  border: Border.all(color: borderColor),
                  borderRadius:
                      BorderRadius.circular(_matrixTableCornerRadius),
                ),
                child: Column(
                  children: [
                    Opacity(
                      opacity: _showMatrixStickyHeader ? 0 : 1,
                      child: _buildMatrixUserHeaderRow(
                        key: _matrixUserHeaderKey,
                        orderedUserIds: orderedUserIds,
                        textColor: textColor,
                        borderColor: borderColor,
                      ),
                    ),
                    for (final row in widget.groupPreferenceMatrix) ...[
                      matrixRowHeader(row),
                      Row(
                        children: [
                          for (var i = 0; i < orderedUserIds.length; i++)
                            matrixValueTableCell(row, i),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );

    if (_isMatrixExpanded) {
      _scheduleMatrixStickyHeaderUpdate();
    }
    return matrixWidget;
  }

  Widget _buildGroupCompatibilitySummaryBar() {
    final fullCount = widget.groupFullMatches.length;
    final partialCount = widget.groupPartialMatches.length;
    final discussCount = widget.groupDiscussItems.length;
    if (fullCount + partialCount + discussCount == 0) {
      return const SizedBox.shrink();
    }

    Widget statColumn({
      required IconData icon,
      required int count,
      required Color color,
      required String label,
    }) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                ),
                child: ThemeIcon(
                  icon,
                  size: 14,
                  color: Colors.white,
                  useThemeColor: false,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      count.toString(),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        color: _getDescriptionTextColor(),
                      ),
                    ),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.2,
                        color:
                            _getDescriptionTextColor().withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final columns = <Widget>[
      if (fullCount > 0)
        statColumn(
          icon: Icons.check,
          count: fullCount,
          color: AppColors.success,
          label: L10n.get("group_compatibility_summary_full"),
        ),
      if (partialCount > 0)
        statColumn(
          icon: Icons.warning_amber_rounded,
          count: partialCount,
          color: AppColors.warning,
          label: L10n.get("group_compatibility_summary_partial"),
        ),
      if (discussCount > 0)
        statColumn(
          icon: Icons.warning_amber_rounded,
          count: discussCount,
          color: AppColors.error,
          label: L10n.get("group_compatibility_summary_discuss"),
        ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: _getDescriptionTextColor().withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _getDescriptionTextColor().withValues(alpha: 0.12),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            for (var i = 0; i < columns.length; i++) ...[
              if (i > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: _getDescriptionTextColor().withValues(alpha: 0.15),
                  ),
                ),
              columns[i],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGroupCompatibilityBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildGroupPreferenceMatrix(),
        if (widget.groupPreferenceMatrix.isEmpty)
          UydoshLinkButton(
            text: L10n.get("complete_profile"),
            onPressed: widget.onCompleteProfile,
            color: _getIconColor(),
            outlined: true,
            maxLines: 1,
          ),
        const SizedBox(height: 14),
        _buildGroupCompatibilitySummaryBar(),
      ],
    );
  }

  Widget _buildOverlappingHeaderAvatars() {
    const size = 32.0;
    const overlap = 8.0;

    return SizedBox(
      width: size * 2 - overlap,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            child: _buildHeaderAvatar(widget.currentUserAvatarUrl, size: size),
          ),
          Positioned(
            left: size - overlap,
            child: _buildHeaderAvatar(widget.ownerAvatarUrl, size: size),
          ),
        ],
      ),
    );
  }

  void _onMatrixExpansionChanged(bool isExpanded) {
    HapticFeedbackUtils.impact();
    _isMatrixExpanded = isExpanded;
    if (!isExpanded) {
      _setMatrixStickyHeaderVisible(false);
    } else {
      _scheduleMatrixStickyHeaderUpdate();
    }
  }

  void _onExpansionChanged(bool isExpanded) {
    HapticFeedbackUtils.impact();
    _isCompatibilitySectionExpanded = isExpanded;
    if (!isExpanded) {
      _setMatrixStickyHeaderVisible(false);
    } else if (_isMatrixExpanded) {
      _scheduleMatrixStickyHeaderUpdate();
    }
    if (!isExpanded) return;

    // Measure the 350ms from a settled layout (after the tap's frame has
    // flushed), matching the pattern in [ListingDetailMapSection] that fixed
    // the same scroll-jitter there. Starting the Timer mid-frame and then
    // awaiting `endOfFrame` inside it schedules an extra frame that shifts
    // layout *between* our target calculation and the scroll animation,
    // producing the visible "up then back down" jerk.
    //
    // Cancelling the pending Timer still protects against rapid
    // expand/collapse queuing multiple scroll adjustments.
    _scrollIntoViewTimer?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scrollIntoViewTimer = Timer(const Duration(milliseconds: 350), () {
        if (!mounted) return;
        final ctx = widget.sectionKey.currentContext;
        if (ctx == null || !ctx.mounted) return;
        _maybeAnimateScrollIntoView(ctx);
      });
    });
  }

  /// Builds the expandable body of the compatibility tile. Returned as a single
  /// widget (rather than spread into the [ExpansionTile.children]) so it can be
  /// wrapped in an [AnimatedSize] that animates the height change when the body
  /// swaps from the loading placeholder to the resolved content.
  Widget _buildCompatibilityContent({
    required bool isAuthenticated,
    required String? percentText,
  }) {
    if (!isAuthenticated) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Text(
          L10n.get("compatibility_sign_in"),
          style: TextStyle(
            fontSize: 14,
            color: _getDescriptionTextColor(),
          ),
        ),
      );
    }

    if (widget.isLoadingCompatibility) {
      return Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: _getIconColor(),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            L10n.get("compatibility_calculating"),
            style: TextStyle(
              fontSize: 14,
              color: _getDescriptionTextColor(),
            ),
          ),
        ],
      );
    }

    if (widget.compatibilityError != null || percentText == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UydoshLinkButton(
            text: L10n.get("complete_profile"),
            onPressed: widget.onCompleteProfile,
            color: _getIconColor(),
            outlined: true,
            maxLines: 1,
          ),
        ],
      );
    }

    return ValueListenableBuilder<bool>(
      valueListenable: ClientListingContactsConfig.showListingContacts,
      builder: (context, showContacts, _) {
        if (widget.isGroupCompatibility) {
          return _buildGroupCompatibilityBody();
        }

        final hasPhone = showContacts &&
            (widget.phoneNumber?.trim().isNotEmpty ?? false) &&
            widget.onPhone != null;
        final phoneDisplay = hasPhone
            ? _formatUzbekPhoneDisplay(widget.phoneNumber!)
            : null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.dealbreakers.isNotEmpty) ...[
              Text(
                L10n.get("compatibility_critical_differences"),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.error,
                ),
              ),
              const SizedBox(height: 8),
              ...widget.dealbreakers.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ThemeIcon(
                        _getLifestyleIcon(item.labelKey),
                        size: 20,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.error,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    "${item.label}: ${item.currentText} ",
                              ),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: ThemeIcon(
                                  Icons.compare_arrows,
                                  size: 16,
                                  color: AppColors.error,
                                ),
                              ),
                              TextSpan(text: " ${item.ownerText}"),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (widget.matches.isNotEmpty) ...[
              Text(
                L10n.get("compatibility_matches"),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _getLocationTextColor(),
                  decoration: TextDecoration.underline,
                  decorationColor: _getLocationTextColor(),
                ),
              ),
              const SizedBox(height: 8),
              ...widget.matches.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ThemeIcon(
                        _getLifestyleIcon(item.labelKey),
                        size: 20,
                        color: _getDescriptionTextColor(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "${item.label}: ${item.value}",
                          style: TextStyle(
                            fontSize: 14,
                            color: _getDescriptionTextColor(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (widget.differences.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                L10n.get("compatibility_differences"),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _getLocationTextColor(),
                  decoration: TextDecoration.underline,
                  decorationColor: _getLocationTextColor(),
                ),
              ),
              const SizedBox(height: 8),
              ...widget.differences.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ThemeIcon(
                        _getLifestyleIcon(item.labelKey),
                        size: 20,
                        color: _getDescriptionTextColor(),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(
                              fontSize: 14,
                              color: _getDescriptionTextColor(),
                            ),
                            children: [
                              TextSpan(
                                text:
                                    "${item.label}: ${item.currentText} ",
                              ),
                              WidgetSpan(
                                alignment: PlaceholderAlignment.middle,
                                child: ThemeIcon(
                                  Icons.compare_arrows,
                                  size: 16,
                                  color: _getDescriptionTextColor(),
                                ),
                              ),
                              TextSpan(text: " ${item.ownerText}"),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (widget.matches.isEmpty &&
                widget.differences.isEmpty &&
                widget.dealbreakers.isEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  UydoshLinkButton(
                    text: L10n.get("complete_profile"),
                    onPressed: widget.onCompleteProfile,
                    color: _getIconColor(),
                    outlined: true,
                    maxLines: 1,
                  ),
                ],
              ),
            // Telegram / in-app chat CTAs live in the sticky
            // [ListingDetailContactActionBar] at the bottom of the
            // screen (always reachable). Phone stays here because
            // it's a compat-adjacent conditional contact channel
            // (gated by admin flag + handle presence) and it's the
            // only inline contact we still surface in-section.
            if (hasPhone) ...[
              const SizedBox(height: 16),
              GhostButton(
                onPressed: () {
                  HapticFeedbackUtils.impact();
                  widget.onPhone?.call();
                },
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                borderWidth: 1.5,
                borderColor: _getIconColor(),
                textColor: _getDescriptionTextColor(),
                iconColor: _getIconColor(),
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ThemeIcon(
                      Icons.phone,
                      size: 18,
                      color: _getIconColor(),
                    ),
                    const SizedBox(width: 8),
                    Text(phoneDisplay ?? L10n.get("contact_user")),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 14),
            GhostButtonFactory.iconText(
              onPressed: () {
                HapticFeedbackUtils.impact();
                widget.onViewProfile();
              },
              width: double.infinity,
              icon: Icons.person_outline,
              iconSize: 18,
              text: L10n.get("view_profile"),
              padding: const EdgeInsets.symmetric(vertical: 12),
              borderColor: _getIconColor(),
              textColor: _getDescriptionTextColor(),
              iconColor: _getIconColor(),
              textStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = AuthenticationState().isAuthenticated;
    final isOwner = UserListingState().isOwner(widget.listingDetail.user.id);
    final isGroupForming =
        ListingGroupProgress.isGroupFormingDetail(widget.listingDetail);

    // One-on-one compatibility is viewer vs owner; group compatibility is about
    // the whole forming group — owners need that section too (including while
    // group scores are still loading and [isGroupCompatibility] is false).
    if (isOwner && !isGroupForming && !widget.isGroupCompatibility) {
      return const SizedBox.shrink();
    }

    final percentText = widget.compatibilityPercent == null
        ? null
        : AppStrings.getWithParams(
            "compatibility_match_percentage",
            LanguageState().currentLanguage,
            params: {"percent": widget.compatibilityPercent!.toString()},
          );
    final headerPercentText = widget.compatibilityPercent == null
        ? L10n.get("na")
        : "${widget.compatibilityPercent}%";

    final isProfileComplete = ProfileCompletionState().isProfileComplete;

    final chevronColor = ListingDetailThemeHelper.locationTextColor;

    return ListingDetailTileShell(
      useLiquidGlass: ListingDetailThemeHelper.useGlassTiles,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          backgroundColor: Colors.transparent,
          collapsedBackgroundColor: Colors.transparent,
          initiallyExpanded: !isAuthenticated || !isProfileComplete,
          onExpansionChanged: _onExpansionChanged,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.transparent),
          ),
          collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Colors.transparent),
          ),
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          iconColor: chevronColor,
          collapsedIconColor: chevronColor,
          title: KeyedSubtree(
            key: widget.sectionKey,
            // Animate the header height change when compatibility data lands
            // and the layout swaps from the one-on-one placeholder (avatars +
            // "N/A") to the taller group header (title + subtitle + avatar
            // stack), so the tile grows smoothly instead of snapping.
            child: ClipRect(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                clipBehavior: Clip.hardEdge,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (isAuthenticated) ...[
                      if (!widget.isGroupCompatibility)
                        _buildOverlappingHeaderAvatars(),
                      if (!widget.isGroupCompatibility)
                        const SizedBox(width: 10),
                    ] else
                      ThemeIcon(
                        ThemeState().isBlueTheme
                            ? CupertinoIcons.group_solid
                            : CupertinoIcons.group,
                        size: 24,
                        color: ThemeState().isBlueTheme
                            ? Colors.white
                            : ThemeState().isLightTheme
                                ? Colors.black
                                : _getIconColor(),
                      ),
                    if (!isAuthenticated) const SizedBox(width: 8),
                    Expanded(
                      child: widget.isGroupCompatibility && isAuthenticated
                          ? _buildGroupHeaderTitle(headerPercentText)
                          : Text(
                              L10n.get("compatibility_title"),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _getDescriptionTextColor(),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                    if (isAuthenticated && !widget.isGroupCompatibility) ...[
                      const SizedBox(width: 8),
                      widget.isLoadingCompatibility
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: _getIconColor(),
                              ),
                            )
                          : Text(
                              headerPercentText,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: _getCompatibilityPercentColor(),
                              ),
                            ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          children: [
            // Animate the height change when the body swaps from the loading
            // placeholder to the resolved compatibility content, so the tile
            // expands smoothly instead of jerking once data is available
            // (mirrors the "View room in 3D" tile's reveal animation).
            ClipRect(
              child: AnimatedSize(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                alignment: Alignment.topCenter,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: double.infinity,
                  child: _buildCompatibilityContent(
                    isAuthenticated: isAuthenticated,
                    percentText: percentText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
