import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/favorites_state.dart";
import "package:uy_dosh/base/state/gig_favorites_state.dart";
import "package:uy_dosh/base/state/price_display_settings_state.dart";
import "package:uy_dosh/base/state/user_listing_state.dart";
import "package:uy_dosh/base/utils/auth_flow.dart";
import "package:uy_dosh/base/utils/gig_navigation.dart";
import "package:uy_dosh/base/utils/moderation_staff_utils.dart";
import "package:uy_dosh/base/utils/currency_display_utils.dart";
import "package:uy_dosh/base/utils/peer_interaction_eligibility.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/gig/gig_request.dart";
import "package:uy_dosh/domain/services/gig_service.dart";
import "package:uy_dosh/domain/services/admin_entity_ownership_service.dart";
import "package:uy_dosh/base/utils/toast_reporting.dart";
import "package:uy_dosh/presentation/utils/conversation_entry_flow.dart";
import "package:uy_dosh/presentation/utils/destructive_action_flow.dart";
import "package:uy_dosh/presentation/screens/chat/chat_screen.dart";
import "package:uy_dosh/presentation/screens/messages/pushed_messages_inbox_scaffold.dart";
import "package:uy_dosh/presentation/screens/gig/gig_category_icons.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_date_utils.dart";
import "package:uy_dosh/presentation/widgets/gig/gig_category_icon_badge.dart";
import "package:uy_dosh/presentation/widgets/common/action_dropdown_menu.dart";
import "package:uy_dosh/presentation/widgets/common/favorite_heart_pulse_controller.dart";
import "package:uy_dosh/presentation/widgets/common/favorite_heart_toggle.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_elevated_surface.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/admin/reassign_owner_dialog.dart";
import "package:uy_dosh/presentation/widgets/price_badge.dart";

/// Detail view for a `GigRequest` (open task posted by a client).
///
/// Providers see a bottom CTA to message the client. The author of an
/// **open** task sees **Edit** (bottom CTA and overflow menu); once the task
/// is no longer open, neither CTA is shown.
class GigRequestDetailScreen extends StatefulWidget {
  const GigRequestDetailScreen({required this.requestId, super.key});

  final int requestId;

  @override
  State<GigRequestDetailScreen> createState() => _GigRequestDetailScreenState();
}

class _GigRequestDetailScreenState extends State<GigRequestDetailScreen> {
  late Future<GigRequest> _future;

  /// Session uid fallback while [UserListingState] has not finished hydrating.
  int? _sessionUserId;
  String? _sessionRole;
  bool _contactInFlight = false;
  bool _deleteInFlight = false;

  /// After a successful edit, parent feeds must refetch — detail shows fresh data
  /// but list tiles still hold stale [GigRequest] rows until refreshed.
  bool _editedWhileOpen = false;

  @override
  void initState() {
    super.initState();
    UserListingState().initialize();
    unawaited(UserListingState().refreshUserId());
    unawaited(_hydrateSessionUserId());
    unawaited(_hydrateSessionRole());
    _future = getIt<IGigService>().getRequest(widget.requestId);
    unawaited(
      _future.then((r) {
        GigFavoritesState().syncFromRequests([r]);
      }),
    );
  }

  Future<void> _persistRequestFavoriteToggle(
    BuildContext context,
    GigRequest request,
    bool wasFavorite,
    FavoriteHeartPulseController pulse,
  ) async {
    final gigFav = GigFavoritesState();
    final screenFav = FavoritesState();
    gigFav.toggleRequestLocal(request.id);
    if (!wasFavorite) {
      unawaited(pulse.playTapPulse());
      screenFav.markDirty();
    }
    try {
      await getIt<IGigService>().toggleFavoriteRequest(request.id);
    } catch (_) {
      gigFav.toggleRequestLocal(request.id);
      if (mounted) {
        ToastTheme.showError(
          context,
          message: L10n.get("favorite_toggle_error"),
        );
      }
    }
  }

  Future<void> _hydrateSessionUserId() async {
    final id = await SessionManager.getUserId();
    if (mounted) setState(() => _sessionUserId = id);
  }

  Future<void> _hydrateSessionRole() async {
    final r = await SessionManager.getUserRole();
    if (mounted) setState(() => _sessionRole = r);
  }

  bool _staffMayModerate() =>
      ModerationStaffUtils.isModerationStaff(_sessionRole);

  bool _isTaskOwner(GigRequest request) {
    final uid = UserListingState().currentUserId ?? _sessionUserId;
    return uid != null && uid == request.clientUserId;
  }

  Future<void> _editRequest(GigRequest request) async {
    final updated = await context.pushEditGigRequest(request);
    if (updated != null && mounted) {
      setState(() {
        _editedWhileOpen = true;
        _future = getIt<IGigService>().getRequest(widget.requestId);
      });
      unawaited(
        _future.then((r) {
          GigFavoritesState().syncFromRequests([r]);
        }),
      );
    }
  }

  Future<void> _confirmAndDeleteTask(GigRequest request) async {
    if (_deleteInFlight) return;
    await DestructiveActionFlow.runAfterDeleteConfirmed(
      context: context,
      titleKey: "gigs_request_delete_title",
      messageKey: "gigs_request_delete_message",
      errorToastKey: "gigs_request_delete_failed",
      onConfirmed: () async {
        setState(() => _deleteInFlight = true);
        try {
          await getIt<IGigService>().cancelRequest(request.id);
          if (!mounted) return;
          ToastReporting.successKey(context, "gigs_request_delete_success");
          Navigator.of(context).pop(true);
        } finally {
          if (mounted) setState(() => _deleteInFlight = false);
        }
      },
    );
  }

  List<Widget> _ownerOverflowMenu(BuildContext context, GigRequest request) {
    final open = request.status == GigRequestStatus.open;
    final isOwner = _isTaskOwner(request);
    final staff = _staffMayModerate();
    final items = <ActionMenuItem>[];
    final staffActingOnOther = staff && !isOwner;
    if (staff) {
      items.add(
        ActionMenuItem(
          value: "reassign_request",
          icon: Icons.swap_horiz,
          textKey: "admin_reassign_owner_menu",
          enabled: !_deleteInFlight,
          onPressed: () => unawaited(_reassignRequestOwner(request)),
          labelFontWeight: FontWeight.w600,
        ),
      );
    }
    if (open && (isOwner || staff)) {
      items.add(
        ActionMenuItem(
          value: "edit_task",
          icon: Icons.edit_outlined,
          textKey: "gigs_request_edit_cta",
          enabled: !_deleteInFlight,
          onPressed: () => unawaited(_editRequest(request)),
          labelFontWeight: staffActingOnOther ? FontWeight.w600 : null,
        ),
      );
      items.add(
        ActionMenuItem(
          value: "delete_task",
          icon: Icons.delete_outline_rounded,
          textKey: "gigs_request_delete_menu",
          iconColor: Colors.red,
          textColor: Colors.red,
          enabled: !_deleteInFlight,
          onPressed: () => unawaited(_confirmAndDeleteTask(request)),
          labelFontWeight: staffActingOnOther ? FontWeight.w600 : null,
        ),
      );
    }
    if (items.isEmpty) return const <Widget>[];
    return [
      ActionDropdownMenu(
        items: items,
      ),
    ];
  }

  Future<void> _reassignRequestOwner(GigRequest request) async {
    final ok = await showReassignOwnerDialog(
      context,
      entityType: AdminEntityOwnershipType.gigRequest,
      entityId: request.id,
      fromUserId: request.clientUserId,
    );
    if (!ok || !mounted) return;
    setState(() {
      _future = getIt<IGigService>().getRequest(widget.requestId);
    });
    unawaited(
      _future.then((r) {
        GigFavoritesState().syncFromRequests([r]);
      }),
    );
  }

  void _openTaskChats(GigRequest? loaded) {
    if (!AuthFlow.requireAuth(context)) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PushedMessagesInboxScaffold(
          filterGigRequestId: widget.requestId,
        ),
      ),
    );
  }

  Widget _messagesInboxAppBarButton({
    required bool hasOwnerOverflow,
    GigRequest? loadedRequest,
  }) {
    return Padding(
      padding: EdgeInsets.only(right: hasOwnerOverflow ? 6 : 0),
      child: ThreeDAppBarIconButton(
        iconData: Icons.chat_bubble_outline,
        onPressed: () => _openTaskChats(loadedRequest),
        semanticsLabel: L10n.get("gigs_request_messages_appbar_semantics"),
      ),
    );
  }

  void _popDetailToCaller() {
    Navigator.of(context).pop(_editedWhileOpen);
  }

  @override
  Widget build(BuildContext context) {
    // `PopScope(canPop: false)` routes Android (and similar) system back through
    // [_popDetailToCaller] so we return [_editedWhileOpen]. That disables iOS
    // interactive pop (edge swipe); allow pop on iOS only.
    final allowInteractivePop =
        defaultTargetPlatform == TargetPlatform.iOS && !kIsWeb;
    return PopScope(
      canPop: allowInteractivePop,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || !mounted) return;
        _popDetailToCaller();
      },
      child: ListenableBuilder(
        listenable: UserListingState(),
        builder: (context, _) {
          return FutureBuilder<GigRequest>(
            future: _future,
            builder: (context, snap) {
              final request = snap.data;
              final staff = _staffMayModerate();
              final isOwner =
                  request != null && _isTaskOwner(request);
              final open =
                  request != null && request.status == GigRequestStatus.open;
              final showOwnerMenu = request != null &&
                  (staff || (open && isOwner));
              final canFavoriteTask = request != null &&
                  PeerInteractionEligibility.mayInteractWithPublisher(
                    publisherUserId: request.clientUserId,
                    viewerUserIdFallback: _sessionUserId,
                  );
              return Scaffold(
                appBar: UydoshAppBar(
                  actionsPadding: const EdgeInsets.only(right: 8),
                  leading: ThreeDAppBarIconButton.backLeading(
                    context,
                    onPressed: _popDetailToCaller,
                  ),
                  title: Text(L10n.get("gigs_request_detail_title")),
                  actions: [
                    if (canFavoriteTask)
                      FavoriteHeartToggle(
                        listenable: GigFavoritesState()
                            .listenableForRequest(request.id),
                        shouldShow: (_) => true,
                        resolveIsFavorite: (_) =>
                            GigFavoritesState().isRequestFavorite(request.id),
                        hiddenBuilder: (_) => const SizedBox.shrink(),
                        onToggle: (ctx, wasFavorite, pulse) =>
                            _persistRequestFavoriteToggle(
                          ctx,
                          request,
                          wasFavorite,
                          pulse,
                        ),
                        builder: (context, ui) => IconButton(
                          onPressed: ui.onTap,
                          icon: AnimatedBuilder(
                            animation: ui.pulse.listenable,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: ui.pulse.scale,
                                child: child,
                              );
                            },
                            child: Icon(
                              ui.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: ui.isFavorite
                                  ? AppColors.favoriteActive
                                  : AppColors.favoriteInactive,
                            ),
                          ),
                        ),
                      ),
                    _messagesInboxAppBarButton(
                      hasOwnerOverflow: showOwnerMenu,
                      loadedRequest: request,
                    ),
                    if (request != null)
                      ..._ownerOverflowMenu(context, request),
                  ],
                ),
                body: _buildBody(context, snap),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, AsyncSnapshot<GigRequest> snap) {
    if (snap.connectionState != ConnectionState.done) {
      return const Center(child: HouseLoadingIndicator());
    }
    if (snap.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(snap.error.toString()),
        ),
      );
    }
    final request = snap.data;
    if (request == null) {
      return const SizedBox.shrink();
    }
    final isOwner = _isTaskOwner(request);
    final staff = _staffMayModerate();
    final canEdit =
        request.status == GigRequestStatus.open && (isOwner || staff);
    final showContact = !isOwner && !staff;

    return _RequestDetailContent(
      request: request,
      contactInFlight: _contactInFlight,
      onContactPressed: () => _openChat(request),
      onEditPressed: canEdit ? () => unawaited(_editRequest(request)) : null,
      showContactCta: showContact,
      editDisabled: _deleteInFlight,
    );
  }

  Future<void> _openChat(GigRequest request) async {
    if (_contactInFlight) return;
    setState(() => _contactInFlight = true);
    try {
      final clientName = (request.clientDisplayName ?? "").trim();
      await ConversationEntryFlow.openGigRequestChat(
        context: context,
        request: request,
        buildChat: (conversation) => ChatScreen(
          conversationId: conversation.id,
          conversationContextType: "gig_request",
          conversationParticipantId: request.clientUserId,
          gigRequestId: request.id,
          gigRequestDetailRouteBelow: true,
          gigRequestTitle: request.title,
          otherUserId: request.clientUserId,
          otherUserName: clientName.isNotEmpty ? clientName : null,
          otherUserInitials: clientName.isNotEmpty
              ? StringUtils.extractInitials(clientName)
              : null,
        ),
      );
    } finally {
      if (mounted) setState(() => _contactInFlight = false);
    }
  }
}

class _RequestDetailContent extends StatefulWidget {
  const _RequestDetailContent({
    required this.request,
    required this.contactInFlight,
    required this.onContactPressed,
    required this.showContactCta,
    this.onEditPressed,
    this.editDisabled = false,
  });

  final GigRequest request;
  final bool contactInFlight;
  final VoidCallback onContactPressed;
  final bool showContactCta;
  final VoidCallback? onEditPressed;
  final bool editDisabled;

  @override
  State<_RequestDetailContent> createState() => _RequestDetailContentState();
}

class _RequestDetailContentState extends State<_RequestDetailContent> {
  bool _scrollLockedBecauseShort = true;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final language = LanguageState().currentLanguage;
    final categoryName = widget.request.category?.localizedName(language) ?? "";
    final description = _localizedDescription(language);
    final publicationFormatted = ListingDetailDateUtils.formatPublicationDate(
      context,
      widget.request.createdAt,
    );
    // Match [ListingDetailContactActionBar] structure (SafeArea + horizontal 16).
    // Extra bottom padding (24) keeps the CTA off the browser chrome when
    // safe-area inset is zero; on devices, SafeArea still adds system inset.
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final hasBottomCta = widget.onEditPressed != null || widget.showContactCta;
    final listBottomPad =
        hasBottomCta ? 118.0 + bottomInset : 24.0 + bottomInset;

    return Stack(
      children: [
        NotificationListener<ScrollMetricsNotification>(
          onNotification: (n) {
            if (!n.metrics.hasPixels) return false;
            final shouldLock = n.metrics.maxScrollExtent <= 0;
            if (shouldLock != _scrollLockedBecauseShort) {
              setState(() => _scrollLockedBecauseShort = shouldLock);
            }
            return false;
          },
          child: SingleChildScrollView(
            physics: _scrollLockedBecauseShort
                ? const NeverScrollableScrollPhysics()
                : const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(16, 16, 16, listBottomPad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                ThreeDElevatedSurface(
                  baseColor: scheme.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (categoryName.isNotEmpty)
                          Row(
                            children: [
                              if (widget.request.category != null) ...[
                                GigCategoryIconBadge(
                                  icon: widget.request.category!.icon,
                                  iconColor:
                                      scheme.onSurface.withValues(alpha: 0.72),
                                  badgeBackgroundColor:
                                      scheme.onSurface.withValues(alpha: 0.12),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Expanded(
                                child: Text(
                                  categoryName.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    letterSpacing: 0.5,
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.72),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 4),
                        Text(
                          widget.request.title,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: scheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListenableBuilder(
                          listenable: PriceDisplaySettingsState(),
                          builder: (context, _) {
                            if (widget.request.budgetAmount != null) {
                              return ListingPaymentsOutlineBadge(
                                label: _budgetLine(),
                              );
                            }
                            return Text(
                              _budgetLine(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: scheme.onSurface,
                              ),
                            );
                          },
                        ),
                        if (widget.request.addressText != null &&
                            widget.request.addressText!.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(
                                Icons.place_outlined,
                                size: 16,
                                color: scheme.onSurface.withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  widget.request.addressText!,
                                  style: TextStyle(
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.85),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (widget.request.scheduledAt != null) ...[
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.event_outlined,
                                size: 16,
                                color: scheme.onSurface.withValues(alpha: 0.7),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  widget.request.scheduledAt!,
                                  style: TextStyle(
                                    color: scheme.onSurface
                                        .withValues(alpha: 0.85),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (publicationFormatted != null &&
                            description.isEmpty) ...[
                          const SizedBox(height: 12),
                          Text(
                            "${L10n.get("publication_date")} $publicationFormatted",
                            style: TextStyle(
                              fontSize: 13,
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                              color: scheme.onSurface.withValues(alpha: 0.62),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  ThreeDElevatedSurface(
                    baseColor: scheme.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            L10n.get("gigs_request_description_label"),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: scheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            description,
                            style: TextStyle(
                              color: scheme.onSurface.withValues(alpha: 0.85),
                              height: 1.4,
                            ),
                          ),
                          if (publicationFormatted != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              "${L10n.get("publication_date")} $publicationFormatted",
                              style: TextStyle(
                                fontSize: 13,
                                height: 1.35,
                                fontWeight: FontWeight.w500,
                                color: scheme.onSurface.withValues(alpha: 0.62),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (hasBottomCta)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: widget.onEditPressed != null
                    ? PrimaryButtonFactory.iconText(
                        onPressed: widget.onEditPressed,
                        icon: Icons.edit_outlined,
                        text: L10n.get("gigs_request_edit_cta"),
                        isDisabled: widget.editDisabled,
                        height: 54,
                        width: double.infinity,
                        borderRadius: BorderRadius.circular(16),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      )
                    : PrimaryButtonFactory.iconText(
                        onPressed: widget.contactInFlight
                            ? null
                            : widget.onContactPressed,
                        icon: Icons.chat_bubble_outline,
                        text: L10n.get("gigs_request_contact_cta"),
                        isLoading: widget.contactInFlight,
                        height: 54,
                        width: double.infinity,
                        borderRadius: BorderRadius.circular(16),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
              ),
            ),
          ),
      ],
    );
  }

  String _localizedDescription(String language) {
    final r = widget.request;
    final raw = switch (language) {
      "uz" =>
        (r.descriptionUz ?? r.descriptionRu ?? r.descriptionEn ?? "").trim(),
      "en" =>
        (r.descriptionEn ?? r.descriptionRu ?? r.descriptionUz ?? "").trim(),
      _ => (r.descriptionRu ?? r.descriptionEn ?? r.descriptionUz ?? "").trim(),
    };
    return StringUtils.collapseExcessiveNewlines(raw);
  }

  String _budgetLine() {
    final r = widget.request;
    if (r.budgetAmount != null) {
      final display = CurrencyDisplayUtils.gigAmountForDisplay(
        amount: r.budgetAmount!,
        currencyCode: r.currencyCode,
      );
      return CurrencyDisplayUtils.stripEmptyCurrencyArtifacts(
        L10n.getWithParams(
          "gigs_request_budget_fixed",
          params: {
            "amount": CurrencyDisplayUtils.formatDisplayAmount(
              display.amount,
              display.currencyCode,
            ),
            "currency": CurrencyDisplayUtils.isoCodeForBadge(
              display.currencyCode,
            ),
          },
        ),
      );
    }
    return L10n.get("gigs_request_budget_open");
  }
}
