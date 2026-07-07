import "dart:async";

import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/price_display_settings_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/listing_detail.dart";
import "package:uy_dosh/domain/models/message.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/domain/utils/listing_share_message.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_avatar.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_message_row.dart";
import "package:uy_dosh/presentation/widgets/chat/chat_participant_avatar_stack.dart";
import "package:uy_dosh/presentation/widgets/common/network_avatar_image.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_inline_spinner.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";

class ListingShareMessageBubble extends StatelessWidget {
  const ListingShareMessageBubble({
    required this.message,
    required this.payload,
    required this.isCurrentUser,
    required this.onOpenListing,
    required this.onRate,
    this.rating,
    this.optionNumber,
    this.onOpenPreviousListing,
    this.onOpenNextListing,
    this.leftAvatarInitials,
    this.rightAvatarInitials,
    this.leftAvatarUrl,
    this.rightAvatarUrl,
    this.isLandlordBubble = false,
    super.key,
  });

  final Message message;
  final ListingShareMessagePayload payload;
  final MessageListingRating? rating;
  final int? optionNumber;
  final bool isCurrentUser;
  final VoidCallback onOpenListing;
  final Future<void> Function(int stars) onRate;
  final VoidCallback? onOpenPreviousListing;
  final VoidCallback? onOpenNextListing;
  final String? leftAvatarInitials;
  final String? rightAvatarInitials;
  final String? leftAvatarUrl;
  final String? rightAvatarUrl;
  final bool isLandlordBubble;

  static const double _ownerAvatarGap = 8;
  static const Color _landlordAccentColor = Color(0xFFFF8A00);

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
    final showNavigationControls =
        onOpenPreviousListing != null || onOpenNextListing != null;

    return ChatMessageRow(
      isFromCurrentUser: isCurrentUser,
      leftAvatarInitials: leftAvatarInitials,
      rightAvatarInitials: rightAvatarInitials,
      leftAvatarUrl: leftAvatarUrl,
      rightAvatarUrl: rightAvatarUrl,
      bubbleAccentColor: isLandlordBubble ? _landlordAccentColor : null,
      bubbleChild: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(
                  minHeight: _ListingOwnerAvatar.size,
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    end: _ListingOwnerAvatar.size + _ownerAvatarGap,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (payload.intro != null &&
                          payload.intro!.isNotEmpty) ...[
                        Text.rich(
                          TextSpan(
                            text: payload.intro!,
                            children: [
                              if (optionNumber != null)
                                TextSpan(
                                  text: " #$optionNumber",
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                            ],
                          ),
                          style: TextStyle(
                            color: textColor.withValues(alpha: 0.85),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                      Text(
                        payload.title,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
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
              _ListingPriceLine(
                listingId: payload.listingId,
                initialPriceLabel: payload.priceLabel,
                color: textColor,
              ),
              const SizedBox(height: 10),
              _StarRatingRow(
                myStars: rating?.myStars,
                average: rating?.average,
                count: rating?.count ?? 0,
                onRate: onRate,
              ),
              const SizedBox(height: 8),
              _ListingShareFooter(
                footerColor: footerColor,
                borderColor: textColor.withValues(alpha: 0.12),
                showNavigationControls: showNavigationControls,
                onOpenListing: onOpenListing,
                onOpenPreviousListing: onOpenPreviousListing,
                onOpenNextListing: onOpenNextListing,
              ),
            ],
          ),
          PositionedDirectional(
            top: 0,
            end: 0,
            child: _ListingOwnerAvatar(
              listingId: payload.listingId,
              ownerUserId: payload.ownerUserId,
              ownerName: payload.ownerName,
              ownerAvatarUrl: payload.ownerAvatarUrl,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListingShareFooter extends StatelessWidget {
  const _ListingShareFooter({
    required this.footerColor,
    required this.borderColor,
    required this.showNavigationControls,
    required this.onOpenListing,
    required this.onOpenPreviousListing,
    required this.onOpenNextListing,
  });

  final Color footerColor;
  final Color borderColor;
  final bool showNavigationControls;
  final VoidCallback onOpenListing;
  final VoidCallback? onOpenPreviousListing;
  final VoidCallback? onOpenNextListing;

  @override
  Widget build(BuildContext context) {
    final previousTooltip =
        MaterialLocalizations.of(context).previousPageTooltip;
    final nextTooltip = MaterialLocalizations.of(context).nextPageTooltip;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: borderColor)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (showNavigationControls)
            _ListingNavigationButton(
              icon: Icons.chevron_left_rounded,
              color: footerColor,
              tooltip: previousTooltip,
              onPressed: onOpenPreviousListing,
            ),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedbackUtils.impact();
                  onOpenListing();
                },
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
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
          ),
          if (showNavigationControls)
            _ListingNavigationButton(
              icon: Icons.chevron_right_rounded,
              color: footerColor,
              tooltip: nextTooltip,
              onPressed: onOpenNextListing,
            ),
        ],
      ),
    );
  }
}

class _ListingNavigationButton extends StatelessWidget {
  const _ListingNavigationButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled
              ? () {
                  HapticFeedbackUtils.selectionClick();
                  onPressed!();
                }
              : null,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Icon(
              icon,
              size: 24,
              color: color.withValues(alpha: enabled ? 0.95 : 0.32),
            ),
          ),
        ),
      ),
    );
  }
}

class _ListingPriceLine extends StatefulWidget {
  const _ListingPriceLine({
    required this.listingId,
    required this.color,
    this.initialPriceLabel,
  });

  final int listingId;
  final Color color;
  final String? initialPriceLabel;

  @override
  State<_ListingPriceLine> createState() => _ListingPriceLineState();
}

class _ListingPriceLineState extends State<_ListingPriceLine> {
  static final Map<int, String> _cache = {};

  String? _priceLabel;
  var _loadStarted = false;

  @override
  void initState() {
    super.initState();
    _hydrate();
    if (_needsFetch) {
      unawaited(_loadPriceLabel());
    }
  }

  @override
  void didUpdateWidget(covariant _ListingPriceLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.listingId != widget.listingId ||
        oldWidget.initialPriceLabel != widget.initialPriceLabel) {
      _loadStarted = false;
      _hydrate();
      if (_needsFetch) {
        unawaited(_loadPriceLabel());
      }
    }
  }

  bool get _needsFetch => _priceLabel == null || _priceLabel!.trim().isEmpty;

  void _hydrate() {
    final initial = widget.initialPriceLabel?.trim();
    _priceLabel = initial?.isEmpty == true ? null : initial;
    _priceLabel ??= _cache[widget.listingId];
  }

  Future<void> _loadPriceLabel() async {
    if (_loadStarted) return;
    _loadStarted = true;
    try {
      final detail = await getIt<IListingService>().getListingDetail(
        widget.listingId,
      );
      final label = _formatPriceLabel(detail);
      _cache[widget.listingId] = label;
      if (!mounted) return;
      setState(() => _priceLabel = label);
    } catch (_) {
      _loadStarted = false;
    }
  }

  static String _formatPriceLabel(ListingDetail detail) {
    final amount = PriceRangeHelper.formatStoredListingPrice(
      storedPrice: detail.price,
      listingTypeCode: detail.listingType.code,
      minPrice: detail.minPrice,
      maxPrice: detail.maxPrice,
    );
    final currency = PriceDisplaySettingsState().currency;
    final monthlyUnit = L10n.get(
      currency == PriceDisplayCurrency.usd
          ? "price_unit_usd_per_month"
          : "price_unit_uzs_per_month",
    );
    final currencyMarker = monthlyUnit.split("/").first.trim();
    if (currencyMarker.isEmpty) return amount;
    if (currency == PriceDisplayCurrency.usd) return "$currencyMarker$amount";
    return "$amount $currencyMarker";
  }

  @override
  Widget build(BuildContext context) {
    final label = _priceLabel;
    if (label == null || label.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: _DetailLine(
        leading: const Icon(
          Icons.payments_outlined,
          color: AppColors.successDark,
          size: 20,
        ),
        label: label,
        color: widget.color,
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
    final borderColor = ChatParticipantAvatarStack.avatarBorderColor(context);
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

class _StarRatingRow extends StatefulWidget {
  const _StarRatingRow({
    required this.myStars,
    required this.average,
    required this.count,
    required this.onRate,
  });

  final int? myStars;
  final double? average;
  final int count;
  final Future<void> Function(int stars) onRate;

  @override
  State<_StarRatingRow> createState() => _StarRatingRowState();
}

class _StarRatingRowState extends State<_StarRatingRow> {
  bool _isSaving = false;

  Future<void> _handleRate(int starValue) async {
    if (_isSaving) return;
    HapticFeedbackUtils.selectionClick();
    setState(() => _isSaving = true);
    try {
      await widget.onRate(starValue);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final summary = widget.count > 0 && widget.average != null
        ? L10n.getWithParams(
            "group_shortlist_rating_summary",
            params: {
              "average": widget.average!.toStringAsFixed(1),
              "count": widget.count.toString(),
            },
          )
        : L10n.get("group_shortlist_rate_prompt");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Material(
          color: Colors.transparent,
          child: Row(
            children: [
              ...List.generate(5, (index) {
                final starValue = index + 1;
                final filled = (widget.myStars ?? 0) >= starValue;
                return InkWell(
                  onTap: _isSaving ? null : () => _handleRate(starValue),
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
              if (_isSaving) ...[
                const SizedBox(width: 6),
                UydoshInlineSpinner(
                  color: theme.colorScheme.onSurfaceVariant,
                  dimension: 16,
                ),
              ],
            ],
          ),
        ),
        Text(
          summary,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.brightness == Brightness.light
                ? Colors.black
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
