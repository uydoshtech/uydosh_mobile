import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/group_shortlist_state.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/presentation/screens/group_housing/group_housing_flow.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_pill_button.dart";

/// Compact bookmark pill that opens the group housing shortlist sheet.
class GroupShortlistPillButton extends StatelessWidget {
  const GroupShortlistPillButton({
    required this.groupListingId,
    required this.isOwner,
    this.groupListingDetail,
    this.onChanged,
    super.key,
  });

  final int groupListingId;
  final bool isOwner;
  final ListingDetail? groupListingDetail;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: GroupShortlistState(),
      builder: (context, _) {
        final count =
            GroupShortlistState().shortlistCountForGroup(groupListingId);
        final tooltip = count > 0
            ? L10n.getWithParams(
                "group_shortlist_title_count",
                params: {"count": count.toString()},
              )
            : L10n.get("group_shortlist_title");

        return Semantics(
          button: true,
          label: tooltip,
          child: Tooltip(
            message: tooltip,
            child: ThreeDPillButton(
              neumorphicSoftUi: true,
              onPressed: () async {
                await GroupHousingFlow.openShortlistSheet(
                  context: context,
                  groupListingId: groupListingId,
                  isOwner: isOwner,
                  groupListingDetail: groupListingDetail,
                  onChanged: onChanged,
                );
              },
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ThemeIcon(
                    count > 0 ? Icons.bookmark : Icons.bookmark_outline,
                    size: 20,
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 6),
                    Text(
                      count > 99 ? "99+" : count.toString(),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
