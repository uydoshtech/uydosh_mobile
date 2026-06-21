import "dart:async";

import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/message.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/domain/utils/listing_share_message.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_avatar.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_message_row.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_participant_avatar_stack.dart";
import "package:uy_dosh/presentation/widgets/common/network_avatar_image.dart";

class ListingShareMessageBubble extends StatelessWidget {
  const ListingShareMessageBubble({
    required this.message,
    required this.payload,
    required this.isCurrentUser,
    required this.onOpenListing,
    required this.onRate,
    this.rating,
    this.leftAvatarInitials,
    this.rightAvatarInitials,
    this.leftAvatarUrl,
    this.rightAvatarUrl,
    super.key,
  });

  final Message message;
  final ListingShareMessagePayload payload;
  final MessageListingRating? rating;
  final bool isCurrentUser;
  final VoidCallback onOpenListing;
  final ValueChanged<int> onRate;
  final String? leftAvatarInitials;
  final String? rightAvatarInitials;
  final String? leftAvatarUrl;
  final String? rightAvatarUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeState = ThemeState();
    final textColor = isCurrentUser
        ? (themeState.isBlueTheme || themeState.isLightTheme
            ? Colors.black
            : AppColors.textDark87)
        : (themeState.isBlueTheme ? Colors.white : theme.colorScheme.onSurface);
    final footerColor = textColor.withValues(alpha: 0.95);

    return ChatMessageRow(
      isFromCurrentUser: isCurrentUser,
      leftAvatarInitials: leftAvatarInitials,
      rightAvatarInitials: rightAvatarInitials,
      leftAvatarUrl: leftAvatarUrl,
      rightAvatarUrl: rightAvatarUrl,
      bubbleChild: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (payload.intro != null && payload.intro!.isNotEmpty) ...[
            Text(
              payload.intro!,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.85),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
          ],
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  payload.title,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _ListingOwnerAvatar(
                listingId: payload.listingId,
                ownerUserId: payload.ownerUserId,
                ownerName: payload.ownerName,
                ownerAvatarUrl: payload.ownerAvatarUrl,
              ),
            ],
          ),
          if (payload.location != null) ...[
            const SizedBox(height: 6),
            _DetailLine(
              leading: const Icon(
                Icons.location_on,
                color: Colors.red,
                size: 20,
              ),
              label: payload.location!,
              color: textColor,
            ),
          ],
          if (payload.metro != null) ...[
            const SizedBox(height: 4),
            _DetailLine(
              leading: Icon(
                Icons.train,
                color: AppColors.getMetroLineColor(payload.metroLine ?? 1),
                size: 20,
              ),
              label: payload.metro!,
              color: textColor,
            ),
          ],
          const SizedBox(height: 10),
          _StarRatingRow(
            myStars: rating?.myStars,
            average: rating?.average,
            count: rating?.count ?? 0,
            onRate: onRate,
          ),
          const SizedBox(height: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedbackUtils.impact();
                onOpenListing();
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: textColor.withValues(alpha: 0.12),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.open_in_new,
                      size: 16,
                      color: footerColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      L10n.get("group_shortlist_view"),
                      style: TextStyle(
                        color: footerColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        height: 1.0,
                      ),
                      textHeightBehavior: const TextHeightBehavior(
                        applyHeightToFirstAscent: false,
                        applyHeightToLastDescent: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListingOwnerAvatar extends StatefulWidget {
  const _ListingOwnerAvatar({
    required this.listingId,
    this.ownerUserId,
    this.ownerName,
    this.ownerAvatarUrl,
  });

  final int listingId;
  final int? ownerUserId;
  final String? ownerName;
  final String? ownerAvatarUrl;

  static const double size = 36;

  @override
  State<_ListingOwnerAvatar> createState() => _ListingOwnerAvatarState();
}

class _ListingOwnerAvatarState extends State<_ListingOwnerAvatar> {
  static final Map<int, ({String? name, String? avatarUrl})> _cache = {};

  String? _name;
  String? _avatarUrl;
  var _loadStarted = false;

  @override
  void initState() {
    super.initState();
    _hydrateFromWidgetOrCache();
    if (_needsFetch) {
      unawaited(_loadOwnerProfile());
    }
  }

  @override
  void didUpdateWidget(covariant _ListingOwnerAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listingId != widget.listingId ||
        oldWidget.ownerName != widget.ownerName ||
        oldWidget.ownerAvatarUrl != widget.ownerAvatarUrl ||
        oldWidget.ownerUserId != widget.ownerUserId) {
      _hydrateFromWidgetOrCache();
      if (_needsFetch) {
        unawaited(_loadOwnerProfile());
      }
    }
  }

  bool get _needsFetch =>
      (_avatarUrl == null || _avatarUrl!.trim().isEmpty) &&
      (_name == null || _name!.trim().isEmpty);

  void _hydrateFromWidgetOrCache() {
    _name = widget.ownerName?.trim();
    _avatarUrl = widget.ownerAvatarUrl?.trim();
    final cached = _cache[widget.listingId];
    if (cached != null) {
      _name ??= cached.name;
      _avatarUrl ??= cached.avatarUrl;
    }
  }

  Future<void> _loadOwnerProfile() async {
    if (_loadStarted) return;
    _loadStarted = true;
    try {
      var userId = widget.ownerUserId;
      userId ??=
          (await getIt<IListingService>().getListingDetail(widget.listingId))
              .userId;
      final profile = await getIt<IUserProfileService>().getUserProfile(userId);
      _cache[widget.listingId] = (
        name: profile.name,
        avatarUrl: profile.avatarUrl,
      );
      if (!mounted) return;
      setState(() {
        _name = profile.name;
        _avatarUrl = profile.avatarUrl;
      });
    } catch (_) {
      _loadStarted = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = ChatParticipantAvatarStack.avatarBorderColor();
    final initials = StringUtils.extractInitials(_name ?? "");
    final resolvedUrl = resolveAvatarUrl(_avatarUrl);

    if (resolvedUrl == null) {
      return SizedBox(
        width: _ListingOwnerAvatar.size,
        height: _ListingOwnerAvatar.size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 1),
          ),
          child: Center(
            child: ChatAvatar(
              isCurrentUser: false,
              initials: initials.isEmpty ? null : initials,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: _ListingOwnerAvatar.size,
      height: _ListingOwnerAvatar.size,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipOval(
              child: NetworkAvatarImage(
                imageUrl: resolvedUrl,
                size: _ListingOwnerAvatar.size,
                fallback: ChatAvatar(
                  isCurrentUser: false,
                  initials: initials.isEmpty ? null : initials,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailLine extends StatelessWidget {
  const _DetailLine({
    required this.label,
    required this.color,
    this.leading,
  });

  final Widget? leading;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final icon = leading;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          icon,
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(
            label,
            style: TextStyle(color: color, fontSize: 15, height: 1.3),
          ),
        ),
      ],
    );
  }
}

class _StarRatingRow extends StatelessWidget {
  const _StarRatingRow({
    required this.myStars,
    required this.average,
    required this.count,
    required this.onRate,
  });

  final int? myStars;
  final double? average;
  final int count;
  final ValueChanged<int> onRate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = count > 0 && average != null
        ? L10n.getWithParams(
            "group_shortlist_rating_summary",
            params: {
              "average": average!.toStringAsFixed(1),
              "count": count.toString(),
            },
          )
        : L10n.get("group_shortlist_rate_prompt");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.transparent,
          child: Row(
            children: List.generate(5, (index) {
              final starValue = index + 1;
              final filled = (myStars ?? 0) >= starValue;
              return InkWell(
                onTap: () {
                  HapticFeedbackUtils.selectionClick();
                  onRate(starValue);
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
                  child: Icon(
                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 22,
                    color: filled
                        ? AppColors.warning
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }),
          ),
        ),
        Text(
          summary,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
