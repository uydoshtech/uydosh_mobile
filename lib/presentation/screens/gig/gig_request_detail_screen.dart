import "dart:async";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/favorites_state.dart";
import "package:uy_dosh/base/state/gig_favorites_state.dart";
import "package:uy_dosh/base/state/price_display_settings_state.dart";
import "package:uy_dosh/base/state/user_listing_state.dart";
import "package:uy_dosh/base/utils/gig_navigation.dart";
import "package:uy_dosh/base/utils/navigation_extensions.dart";
import "package:uy_dosh/base/utils/currency_display_utils.dart";
import "package:uy_dosh/base/utils/int_format_utils.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/gig/gig_request.dart";
import "package:uy_dosh/domain/services/gig_service.dart";
import "package:uy_dosh/domain/services/messaging_service.dart";
import "package:uy_dosh/presentation/screens/chat/chat_screen.dart";
import "package:uy_dosh/presentation/screens/messages/pushed_messages_inbox_scaffold.dart";
import "package:uy_dosh/presentation/screens/gig/gig_category_icons.dart";
import "package:uy_dosh/presentation/screens/listing_detail/listing_detail_date_utils.dart";
import "package:uy_dosh/presentation/widgets/gig/gig_category_icon_badge.dart";
import "package:uy_dosh/presentation/widgets/common/action_dropdown_menu.dart";
import "package:uy_dosh/presentation/widgets/common/confirmation_dialog.dart";
import "package:uy_dosh/presentation/widgets/common/favorite_heart_pulse_controller.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_elevated_surface.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
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

class _GigRequestDetailScreenState extends State<GigRequestDetailScreen>
    with TickerProviderStateMixin {
  late Future<GigRequest> _future;

  /// Session uid fallback while [UserListingState] has not finished hydrating.
  int? _sessionUserId;
  bool _contactInFlight = false;
  bool _deleteInFlight = false;
  bool _requestFavoriteBusy = false;

  /// After a successful edit, parent feeds must refetch — detail shows fresh data
  /// but list tiles still hold stale [GigRequest] rows until refreshed.
  bool _editedWhileOpen = false;
  late final FavoriteHeartPulseController _requestFavPulse;

  @override
  void initState() {
    super.initState();
    _requestFavPulse = FavoriteHeartPulseController(vsync: this);
    UserListingState().initialize();
    unawaited(UserListingState().refreshUserId());
    unawaited(_hydrateSessionUserId());
    _future = getIt<IGigService>().getRequest(widget.requestId);
    unawaited(
      _future.then((r) {
        GigFavoritesState().syncFromRequests([r]);
      }),
    );
  }

  Future<void> _hydrateSessionUserId() async {
    final id = await SessionManager.getUserId();
    if (mounted) setState(() => _sessionUserId = id);
  }

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
    final confirmed = await CommonConfirmationDialogs.showDeleteConfirmation(
      context: context,
      titleKey: "gigs_request_delete_title",
      messageKey: "gigs_request_delete_message",
    );
    if (confirmed != true || !mounted) return;
    if (_deleteInFlight) return;
    setState(() => _deleteInFlight = true);
    try {
      await getIt<IGigService>().cancelRequest(request.id);
      if (!mounted) return;
      ToastTheme.showSuccess(
        context,
        message: L10n.get("gigs_request_delete_success"),
      );
      Navigator.of(context).pop(true);
    } catch (_) {
      if (!mounted) return;
      ToastTheme.showError(
        context,
        message: L10n.get("gigs_request_delete_failed"),
      );
    } finally {
      if (mounted) setState(() => _deleteInFlight = false);
    }
  }

  Future<void> _toggleRequestFavorite(GigRequest request) async {
    if (_requestFavoriteBusy) return;
    final gigFav = GigFavoritesState();
    final screenFav = FavoritesState();
    final was = gigFav.isRequestFavorite(request.id);
    gigFav.toggleRequestLocal(request.id);
    if (!was) {
      unawaited(_requestFavPulse.playTapPulse());
      screenFav.markDirty();
    }
    setState(() => _requestFavoriteBusy = true);
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
    } finally {
      if (mounted) {
        setState(() => _requestFavoriteBusy = false);
      }
    }
  }

  @override
  void dispose() {
    _requestFavPulse.dispose();
    super.dispose();
  }

  List<Widget> _ownerOverflowMenu(BuildContext context, GigRequest request) {
    final open = request.status == GigRequestStatus.open;
    final isOwner = _isTaskOwner(request);
    if (!isOwner || !open) return const <Widget>[];
    return [
      ActionDropdownMenu(
        items: [
          ActionMenuItem(
            value: "edit_task",
            icon: Icons.edit_outlined,
            textKey: "gigs_request_edit_cta",
            enabled: !_deleteInFlight,
            onPressed: () => unawaited(_editRequest(request)),
          ),
          ActionMenuItem(
            value: "delete_task",
            icon: Icons.delete_outline_rounded,
            textKey: "gigs_request_delete_menu",
            iconColor: Colors.red,
            textColor: Colors.red,
            enabled: !_deleteInFlight,
            onPressed: () => unawaited(_confirmAndDeleteTask(request)),
          ),
        ],
      ),
    ];
  }

  void _openTaskChats(GigRequest? loaded) {
    if (!AuthenticationState().isAuthenticated) {
      context.pushAuthWizard();
      return;
    }
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
              final showOwnerMenu = request != null &&
                  _isTaskOwner(request) &&
                  request.status == GigRequestStatus.open;
              final canFavoriteTask = request != null &&
                  AuthenticationState().isAuthenticated &&
                  !_isTaskOwner(request);
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
                      ListenableBuilder(
                        listenable: GigFavoritesState()
                            .listenableForRequest(request.id),
                        builder: (context, _) {
                          final fav =
                              GigFavoritesState().isRequestFavorite(request.id);
                          _requestFavPulse.setFavoriteOutlineState(
                            isFavorite: fav,
                          );
                          return IconButton(
                            onPressed: _requestFavoriteBusy
                                ? null
                                : () => unawaited(
                                      _toggleRequestFavorite(request),
                                    ),
                            icon: AnimatedBuilder(
                              animation: _requestFavPulse.listenable,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _requestFavPulse.scale,
                                  child: child,
                                );
                              },
                              child: Icon(
                                fav ? Icons.favorite : Icons.favorite_border,
                                color: fav
                                    ? AppColors.favoriteActive
                                    : AppColors.favoriteInactive,
                              ),
                            ),
                          );
                        },
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
    final canEdit = isOwner && request.status == GigRequestStatus.open;
    final showContact = !isOwner;

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
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    await UserListingState().refreshUserId();
    final currentUserId = await SessionManager.getUserId();
    if (currentUserId == null) {
      if (!mounted) return;
      ToastTheme.showError(
        context,
        message: L10n.get("error_not_authenticated"),
      );
      return;
    }
    if (currentUserId == request.clientUserId) {
      if (!mounted) return;
      ToastTheme.showError(
        context,
        message: L10n.get("error_cannot_message_self"),
      );
      return;
    }

    setState(() => _contactInFlight = true);
    try {
      final conversation = await getIt<IMessagingService>().createConversation(
        gigRequestId: request.id,
      );
      if (!mounted) return;

      final clientName = (request.clientDisplayName ?? "").trim();
      navigator.push(
        MaterialPageRoute<void>(
          settings: RouteSettings(name: ChatScreen.routeName(conversation.id)),
          builder: (_) => ChatScreen(
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
        ),
      );
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(L10n.get("gigs_request_contact_failed"))),
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
      "uz" => (r.descriptionUz ?? r.descriptionRu ?? r.descriptionEn ?? "").trim(),
      "en" => (r.descriptionEn ?? r.descriptionRu ?? r.descriptionUz ?? "").trim(),
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
            "amount": IntFormatUtils.withDotThousands(display.amount),
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
