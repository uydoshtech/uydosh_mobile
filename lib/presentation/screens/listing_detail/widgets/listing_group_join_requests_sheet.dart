import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/listing_group.dart";
import "package:uy_dosh/domain/services/listing_group_service.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";

Future<void> showListingGroupJoinRequestsSheet({
  required BuildContext context,
  required int listingId,
  required VoidCallback onChanged,
}) async {
  final service = getIt<IListingGroupService>();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      return _ListingGroupJoinRequestsSheet(
        listingId: listingId,
        service: service,
        onChanged: onChanged,
      );
    },
  );
}

class _ListingGroupJoinRequestsSheet extends StatefulWidget {
  const _ListingGroupJoinRequestsSheet({
    required this.listingId,
    required this.service,
    required this.onChanged,
  });

  final int listingId;
  final IListingGroupService service;
  final VoidCallback onChanged;

  @override
  State<_ListingGroupJoinRequestsSheet> createState() =>
      _ListingGroupJoinRequestsSheetState();
}

class _ListingGroupJoinRequestsSheetState
    extends State<_ListingGroupJoinRequestsSheet> {
  var _loading = true;
  List<ListingGroupJoinRequest> _requests = const [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final rows = await widget.service.listJoinRequests(
        listingId: widget.listingId,
      );
      if (!mounted) return;
      setState(() {
        _requests = rows;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _approve(ListingGroupJoinRequest request) async {
    HapticFeedbackUtils.impact();
    try {
      await widget.service.approveJoinRequest(
        listingId: widget.listingId,
        requestId: request.id,
      );
      if (!mounted) return;
      ToastTheme.showSuccess(
        context,
        message: L10n.get("group_join_request_approved"),
      );
      widget.onChanged();
      await _load();
    } catch (e) {
      if (!mounted) return;
      ToastTheme.showError(context, message: e.toString());
    }
  }

  Future<void> _reject(ListingGroupJoinRequest request) async {
    HapticFeedbackUtils.impact();
    try {
      await widget.service.rejectJoinRequest(
        listingId: widget.listingId,
        requestId: request.id,
      );
      if (!mounted) return;
      ToastTheme.showSuccess(
        context,
        message: L10n.get("group_join_request_rejected"),
      );
      widget.onChanged();
      await _load();
    } catch (e) {
      if (!mounted) return;
      ToastTheme.showError(context, message: e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              L10n.get("group_manage_requests"),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_requests.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  L10n.get("group_no_pending_requests"),
                  textAlign: TextAlign.center,
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _requests.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final request = _requests[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          StringUtils.extractInitials(request.applicantName),
                        ),
                      ),
                      title: Text(request.applicantName),
                      subtitle: request.message?.trim().isNotEmpty == true
                          ? Text(request.message!.trim())
                          : null,
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          TextButton(
                            onPressed: () => _reject(request),
                            child: Text(L10n.get("group_reject_member")),
                          ),
                          FilledButton(
                            onPressed: () => _approve(request),
                            child: Text(L10n.get("group_approve_member")),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
