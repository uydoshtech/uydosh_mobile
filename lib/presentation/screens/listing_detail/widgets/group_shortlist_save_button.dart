import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/group_shortlist_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/services/listing_group_service.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";

class GroupShortlistSaveButton extends StatefulWidget {
  const GroupShortlistSaveButton({
    required this.groupListingId,
    required this.housingListingId,
    this.groupSizeLabel,
    super.key,
  });

  final int groupListingId;
  final int housingListingId;
  final String? groupSizeLabel;

  @override
  State<GroupShortlistSaveButton> createState() =>
      _GroupShortlistSaveButtonState();
}

class _GroupShortlistSaveButtonState extends State<GroupShortlistSaveButton> {
  var _loading = false;
  var _seeded = false;

  @override
  void initState() {
    super.initState();
    _seedInitial();
  }

  Future<void> _seedInitial() async {
    try {
      final isOn = await getIt<IListingGroupService>().isOnShortlist(
        groupListingId: widget.groupListingId,
        housingListingId: widget.housingListingId,
      );
      if (!mounted) return;
      GroupShortlistState().seedShortlisted(
        groupListingId: widget.groupListingId,
        housingListingId: widget.housingListingId,
        isShortlisted: isOn,
      );
      setState(() => _seeded = true);
    } catch (_) {
      if (mounted) setState(() => _seeded = true);
    }
  }

  Future<void> _toggle() async {
    if (_loading) return;
    HapticFeedbackUtils.selection();
    setState(() => _loading = true);
    try {
      final nowShortlisted = await GroupShortlistState().toggle(
        groupListingId: widget.groupListingId,
        housingListingId: widget.housingListingId,
      );
      if (!mounted) return;
      ToastTheme.showSuccess(
        context,
        message: L10n.get(
          nowShortlisted
              ? "group_shortlist_added"
              : "group_shortlist_removed",
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ToastTheme.showError(context, message: e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_seeded) {
      return const SizedBox(
        height: 44,
        child: Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))),
      );
    }

    return ListenableBuilder(
      listenable: GroupShortlistState().listenableFor(
        groupListingId: widget.groupListingId,
        housingListingId: widget.housingListingId,
      ),
      builder: (context, _) {
        final isOn = GroupShortlistState().isShortlisted(
          groupListingId: widget.groupListingId,
          housingListingId: widget.housingListingId,
        );
        final label = widget.groupSizeLabel != null
            ? L10n.getWithParams(
                "group_shortlist_save_for_group",
                params: {"count": widget.groupSizeLabel!},
              )
            : L10n.get("group_shortlist_save");

        return OutlinedButton.icon(
          onPressed: _loading ? null : _toggle,
          icon: Icon(
            isOn ? Icons.bookmark : Icons.bookmark_outline,
            size: 20,
          ),
          label: Text(label),
        );
      },
    );
  }
}
