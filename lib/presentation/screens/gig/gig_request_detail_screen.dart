import "dart:async";

import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/user_listing_state.dart";
import "package:uy_dosh/base/utils/gig_navigation.dart";
import "package:uy_dosh/base/utils/int_format_utils.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/gig/gig_request.dart";
import "package:uy_dosh/domain/services/gig_service.dart";
import "package:uy_dosh/domain/services/messaging_service.dart";
import "package:uy_dosh/presentation/screens/chat/chat_screen.dart";
import "package:uy_dosh/presentation/screens/gig/gig_category_icons.dart";
import "package:uy_dosh/presentation/widgets/common/action_dropdown_menu.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_elevated_surface.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";

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

  List<Widget> _appBarActions(BuildContext context, GigRequest request) {
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
            onPressed: () => unawaited(_editRequest(request)),
          ),
        ],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: UserListingState(),
      builder: (context, _) {
        return FutureBuilder<GigRequest>(
          future: _future,
          builder: (context, snap) {
            return Scaffold(
              appBar: AppBar(
                leading: ThreeDAppBarIconButton.backLeading(context),
                title: Text(L10n.get("gigs_request_detail_title")),
                actions: snap.hasData ? _appBarActions(context, snap.data!) : const <Widget>[],
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
          builder: (_) => ChatScreen(
            conversationId: conversation.id,
            gigRequestId: request.id,
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
  });

  final GigRequest request;
  final bool contactInFlight;
  final VoidCallback onContactPressed;
  final bool showContactCta;
  final VoidCallback? onEditPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final language = LanguageState().currentLanguage;
    final categoryName = request.category?.localizedName(language) ?? "";
    final description = _localizedDescription(language);
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    final hasBottomCta = onEditPressed != null || showContactCta;
    final listBottomPad = hasBottomCta ? 110.0 + bottomInset : 24.0 + bottomInset;

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
                            Icon(
                              request.category!.icon,
                              size: 14,
                              color:
                                  scheme.onSurface.withValues(alpha: 0.72),
                            ),
                            const SizedBox(width: 6),
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
            left: 16,
            right: 16,
            bottom: 16 + bottomInset,
            child: onEditPressed != null
                ? PrimaryButton(
                    onPressed: onEditPressed,
                    height: 54,
                    width: double.infinity,
                    borderRadius: BorderRadius.circular(16),
                    child: Text(
                      L10n.get("gigs_request_edit_cta"),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
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
          "currency": request.currencyCode,
        },
      );
    }
    return L10n.get("gigs_request_budget_open");
  }
}
