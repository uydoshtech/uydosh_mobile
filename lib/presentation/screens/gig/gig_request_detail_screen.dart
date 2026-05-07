import "dart:async";

import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
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
import "package:uy_dosh/presentation/widgets/gig/gig_category_icon_badge.dart";
import "package:uy_dosh/presentation/widgets/common/action_dropdown_menu.dart";
import "package:uy_dosh/presentation/widgets/common/confirmation_dialog.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_elevated_surface.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/price_badge.dart";

/// Detail view for a `GigRequest` (open task posted by a client).
///
/// Providers see a bottom CTA to message the client. The author of an
/// **open** task sees **Edit** (and a three-dot menu) instead; once the task
/// is no longer open, neither CTA is shown.
class GigRequestDetailScreen extends StatefulWidget {
  const GigRequestDetailScreen({required this.requestId, super.key});

  final int requestId;

  @override
  State<GigRequestDetailScreen> createState() => _GigRequestDetailScreenState();
}

class _GigRequestDetailScreenState extends State<GigRequestDetailScreen> {
  late Future<GigRequest> _future;
  bool _contactInFlight = false;
  bool _deleteInFlight = false;

  @override
  void initState() {
    super.initState();
    UserListingState().initialize();
    unawaited(UserListingState().refreshUserId());
    _future = getIt<IGigService>().getRequest(widget.requestId);
  }

  Future<void> _editRequest(GigRequest request) async {
    final updated = await context.pushEditGigRequest(request);
    if (updated != null && mounted) {
      setState(() {
        _future = getIt<IGigService>().getRequest(widget.requestId);
      });
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

  List<Widget> _ownerOverflowMenu(BuildContext context, GigRequest request) {
    final open = request.status == GigRequestStatus.open;
    final isOwner = UserListingState().isOwner(request.clientUserId);
    if (!isOwner || !open) return const <Widget>[];
    return [
      ActionDropdownMenu(
        padding: const EdgeInsets.only(right: 12),
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
        builder:
            (_) => PushedMessagesInboxScaffold(
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
      padding: EdgeInsets.only(right: hasOwnerOverflow ? 4 : 12),
      child: ThreeDAppBarIconButton(
        iconData: Icons.chat_bubble_outline,
        onPressed: () => _openTaskChats(loadedRequest),
        semanticsLabel: L10n.get("gigs_request_messages_appbar_semantics"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: UserListingState(),
      builder: (context, _) {
        return FutureBuilder<GigRequest>(
          future: _future,
          builder: (context, snap) {
            final request = snap.data;
            final showOwnerMenu = request != null &&
                UserListingState().isOwner(request.clientUserId) &&
                request.status == GigRequestStatus.open;
            return Scaffold(
              appBar: AppBar(
                leading: ThreeDAppBarIconButton.backLeading(context),
                title: Text(L10n.get("gigs_request_detail_title")),
                actions: [
                  _messagesInboxAppBarButton(
                    hasOwnerOverflow: showOwnerMenu,
                    loadedRequest: request,
                  ),
                  if (request != null) ..._ownerOverflowMenu(context, request),
                ],
              ),
              body: _buildBody(context, snap),
            );
          },
        );
      },
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
    final isOwner = UserListingState().isOwner(request.clientUserId);
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

class _RequestDetailContent extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final language = LanguageState().currentLanguage;
    final categoryName = request.category?.localizedName(language) ?? "";
    final description = _localizedDescription(language);
    // Match [ListingDetailContactActionBar] structure (SafeArea + horizontal 16).
    // Extra bottom padding (24) keeps the CTA off the browser chrome when
    // safe-area inset is zero; on devices, SafeArea still adds system inset.
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final hasBottomCta = onEditPressed != null || showContactCta;
    final listBottomPad = hasBottomCta ? 118.0 + bottomInset : 24.0 + bottomInset;

    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, listBottomPad),
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
                          if (request.category != null) ...[
                            GigCategoryIconBadge(
                              icon: request.category!.icon,
                              iconColor:
                                  scheme.onSurface.withValues(alpha: 0.72),
                              badgeBackgroundColor: scheme.onSurface
                                  .withValues(alpha: 0.12),
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
                      request.title,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: scheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (request.budgetAmount != null)
                      ListingPaymentsOutlineBadge(label: _budgetLine())
                    else
                      Text(
                        _budgetLine(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurface,
                        ),
                      ),
                    if (request.addressText != null &&
                        request.addressText!.isNotEmpty) ...[
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
                              request.addressText!,
                              style: TextStyle(
                                color:
                                    scheme.onSurface.withValues(alpha: 0.85),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (request.scheduledAt != null) ...[
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
                              request.scheduledAt!,
                              style: TextStyle(
                                color:
                                    scheme.onSurface.withValues(alpha: 0.85),
                              ),
                            ),
                          ),
                        ],
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
                    ],
                  ),
                ),
              ),
            ],
          ],
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
                child: onEditPressed != null
                    ? PrimaryButtonFactory.iconText(
                        onPressed: onEditPressed,
                        icon: Icons.edit_outlined,
                        text: L10n.get("gigs_request_edit_cta"),
                        isDisabled: editDisabled,
                        height: 54,
                        width: double.infinity,
                        borderRadius: BorderRadius.circular(16),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      )
                    : PrimaryButtonFactory.iconText(
                        onPressed: contactInFlight ? null : onContactPressed,
                        icon: Icons.chat_bubble_outline,
                        text: L10n.get("gigs_request_contact_cta"),
                        isLoading: contactInFlight,
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
    switch (language) {
      case "uz":
        return (request.descriptionUz ??
                request.descriptionRu ??
                request.descriptionEn ??
                "")
            .trim();
      case "en":
        return (request.descriptionEn ??
                request.descriptionRu ??
                request.descriptionUz ??
                "")
            .trim();
      case "ru":
      default:
        return (request.descriptionRu ??
                request.descriptionEn ??
                request.descriptionUz ??
                "")
            .trim();
    }
  }

  String _budgetLine() {
    if (request.budgetAmount != null) {
      return L10n.getWithParams(
        "gigs_request_budget_fixed",
        params: {
          "amount": IntFormatUtils.withDotThousands(request.budgetAmount!),
          "currency": CurrencyDisplayUtils.isoCode(request.currencyCode),
        },
      );
    }
    return L10n.get("gigs_request_budget_open");
  }
}
