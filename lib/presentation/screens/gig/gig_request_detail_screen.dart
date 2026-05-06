import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/gig/gig_request.dart";
import "package:uy_dosh/domain/services/gig_service.dart";
import "package:uy_dosh/domain/services/messaging_service.dart";
import "package:uy_dosh/presentation/screens/chat/chat_screen.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_elevated_surface.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";

/// Read-only detail view for a `GigRequest` (open task posted by a client).
///
/// Bottom CTA opens a chat with the request author. The chat is created
/// against the gig-request context (`POST /conversations` with
/// `context_type='gig_request'`), so it's properly scoped to this request
/// and idempotent — re-opening the screen and tapping again surfaces the
/// same conversation rather than creating a duplicate.
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
    _future = getIt<IGigService>().getRequest(widget.requestId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: ThreeDAppBarIconButton.backLeading(context),
        title: Text(L10n.get("gigs_request_detail_title")),
      ),
      body: FutureBuilder<GigRequest>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
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
          return _RequestDetailContent(
            request: request,
            contactInFlight: _contactInFlight,
            onContactPressed: () => _openChat(request),
          );
        },
      ),
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
  });

  final GigRequest request;
  final bool contactInFlight;
  final VoidCallback onContactPressed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final language = LanguageState().currentLanguage;
    final categoryName = request.category?.localizedName(language) ?? "";
    final description = _localizedDescription(language);
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Stack(
      children: [
        ListView(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 110 + bottomInset),
          children: [
            ThreeDElevatedSurface(
              baseColor: scheme.surface,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (categoryName.isNotEmpty)
                      Text(
                        categoryName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          letterSpacing: 0.5,
                          color: scheme.secondary,
                          fontWeight: FontWeight.w700,
                        ),
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
        Positioned(
          left: 16,
          right: 16,
          bottom: 16 + bottomInset,
          child: PrimaryButtonFactory.iconText(
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
          "amount": request.budgetAmount!.toString(),
          "currency": request.currencyCode,
        },
      );
    }
    return L10n.get("gigs_request_budget_open");
  }
}
