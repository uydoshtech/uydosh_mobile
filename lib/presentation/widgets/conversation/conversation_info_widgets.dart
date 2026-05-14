import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/price_display_settings_state.dart";
import "package:uy_dosh/base/utils/int_format_utils.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/common/network_avatar_image.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/price_range_badge.dart";

/// Shared widgets for displaying conversation/listing info in the messages inbox.
/// Used by ConversationTile, OutgoingConversationTile, and GroupedConversationsList.

/// Whether the grouped/header budget row should show (numeric listing price or gig open budget).
bool conversationSummaryShowsBudgetBadge(ConversationSummary conversation) {
  final numeric =
      conversation.listingPrice != null && conversation.listingPrice! > 0;
  final gigOpen = conversation.contextType == 'gig_request' &&
      conversation.gigBudgetType == 'open';
  return numeric || gigOpen;
}

/// Row for gig grouped inbox headers: author / provider avatar + name.
class ConversationGigOwnerRow extends StatelessWidget {
  const ConversationGigOwnerRow({
    required this.conversation,
    required this.textColor,
    required this.mutedColor,
    required this.avatarColor,
    required this.avatarIconColor,
    super.key,
  });

  final ConversationSummary conversation;
  final Color textColor;
  final Color mutedColor;
  final Color avatarColor;
  final Color avatarIconColor;

  static const double _avatarSize = 28;

  @override
  Widget build(BuildContext context) {
    final name = conversation.gigOwnerName?.trim();
    if (name == null || name.isEmpty) return const SizedBox.shrink();

    final url = resolveAvatarUrl(conversation.gigOwnerAvatar);

    Widget fallbackAvatar() {
      final initials = StringUtils.extractInitials(name);
      return CircleAvatar(
        radius: _avatarSize / 2,
        backgroundColor: avatarColor,
        child: initials.isNotEmpty
            ? Text(
                initials,
                style: TextStyle(
                  color: avatarIconColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              )
            : ThemeIcon(Icons.person, color: avatarIconColor, size: 16),
      );
    }

    final avatar = url != null
        ? ClipOval(
            child: NetworkAvatarImage(
              imageUrl: url,
              size: _avatarSize,
              fallback: fallbackAvatar(),
            ),
          )
        : fallbackAvatar();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        avatar,
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                L10n.get("author"),
                style: TextStyle(
                  fontSize: 11,
                  color: mutedColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                name,
                style: TextStyle(
                  fontSize: 13,
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ConversationAvatarContent extends StatelessWidget {
  const ConversationAvatarContent({
    required this.conversation,
    required this.iconColor,
    super.key,
    this.userNameOverride,
  });

  final ConversationSummary conversation;
  final Color iconColor;

  /// When provided, used in place of [ConversationSummary.otherUserName] to
  /// derive initials. Used to show the current user's initials when the last
  /// message in the conversation was sent by them.
  final String? userNameOverride;

  @override
  Widget build(BuildContext context) {
    final userName = userNameOverride ?? conversation.otherUserName;
    final initials = StringUtils.extractInitials(userName);

    if (initials.isNotEmpty) {
      return Text(
        initials,
        style: TextStyle(
          color: iconColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      );
    }

    return ThemeIcon(Icons.person, color: iconColor);
  }
}

/// Location and metro station info, optionally with price.
class ConversationLocationInfo extends StatelessWidget {
  const ConversationLocationInfo({
    required this.conversation,
    required this.textColor,
    this.showPrice = true,
    super.key,
  });

  final ConversationSummary conversation;
  final Color textColor;
  final bool showPrice;

  static String _getLocalizedName({
    String? nameUz,
    String? nameRu,
    String? nameEn,
  }) {
    final currentLanguage = LanguageState().currentLanguage;
    switch (currentLanguage) {
      case "uz":
        return nameUz ?? nameRu ?? nameEn ?? "Unknown";
      case "ru":
        return nameRu ?? nameUz ?? nameEn ?? "Unknown";
      case "en":
        return nameEn ?? nameRu ?? nameUz ?? "Unknown";
      default:
        return nameRu ?? nameUz ?? nameEn ?? "Unknown";
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: LanguageState(),
      builder: (context, child) {
        final hasLocation = conversation.locationNameUz != null ||
            conversation.locationNameRu != null ||
            conversation.locationNameEn != null;
        final hasSubwayStation = conversation.subwayStationNameUz != null ||
            conversation.subwayStationNameRu != null ||
            conversation.subwayStationNameEn != null;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasLocation && hasSubwayStation)
              // A fixed `maxWidth` cap (rather than a percentage of the
              // parent) keeps the station label from hogging space on long
              // names, while [Expanded] lets the district fill whatever
              // remains. An earlier version wrapped this row in a
              // [LayoutBuilder] to derive the cap from the parent width,
              // but nesting a [LayoutBuilder] inside an [IntrinsicHeight]
              // (as this widget is on the grouped inbox header) produces
              // wrong intrinsic heights and pushes the price row below the
              // card's clip.
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ThemeIcon(
                    Icons.train,
                    color: ConversationSubwayStationDisplay._getLineColor(
                      conversation.subwayStationLine ?? 1,
                    ),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 140),
                      child: Text(
                        _getLocalizedName(
                          nameUz: conversation.subwayStationNameUz,
                          nameRu: conversation.subwayStationNameRu,
                          nameEn: conversation.subwayStationNameEn,
                        ),
                        style: TextStyle(fontSize: 12, color: textColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const ThemeIcon(
                    Icons.location_on,
                    color: AppColors.error,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _getLocalizedName(
                        nameUz: conversation.locationNameUz,
                        nameRu: conversation.locationNameRu,
                        nameEn: conversation.locationNameEn,
                      ),
                      style: TextStyle(fontSize: 12, color: textColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              )
            else ...[
              if (hasLocation)
                Row(
                  children: [
                    const ThemeIcon(
                      Icons.location_on,
                      color: AppColors.error,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _getLocalizedName(
                          nameUz: conversation.locationNameUz,
                          nameRu: conversation.locationNameRu,
                          nameEn: conversation.locationNameEn,
                        ),
                        style: TextStyle(fontSize: 12, color: textColor),
                      ),
                    ),
                  ],
                ),
              if (hasSubwayStation) ...[
                if (hasLocation) const SizedBox(height: 4),
                ConversationSubwayStationDisplay(
                  conversation: conversation,
                  textColor: textColor,
                ),
              ],
            ],
            if (showPrice &&
                conversation.listingPrice != null &&
                conversation.listingPrice! > 0) ...[
              const SizedBox(height: 4),
              ConversationPriceDisplay(
                conversation: conversation,
                textColor: textColor,
              ),
            ] else if (showPrice &&
                conversation.contextType == 'gig_request' &&
                conversation.gigBudgetType == 'open') ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const ThemeIcon(Icons.payments,
                      color: Colors.green, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      L10n.get("gigs_request_budget_open"),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }
}

/// Subway station display with line color.
class ConversationSubwayStationDisplay extends StatelessWidget {
  const ConversationSubwayStationDisplay({
    required this.conversation,
    required this.textColor,
    super.key,
  });

  final ConversationSummary conversation;
  final Color textColor;

  static String _getLocalizedName({
    String? nameUz,
    String? nameRu,
    String? nameEn,
  }) {
    final currentLanguage = LanguageState().currentLanguage;
    switch (currentLanguage) {
      case "uz":
        return nameUz ?? nameRu ?? nameEn ?? "Unknown";
      case "ru":
        return nameRu ?? nameUz ?? nameEn ?? "Unknown";
      case "en":
        return nameEn ?? nameRu ?? nameUz ?? "Unknown";
      default:
        return nameRu ?? nameUz ?? nameEn ?? "Unknown";
    }
  }

  static Color _getLineColor(int line) {
    switch (line) {
      case 1:
        return AppColors.metroLine1;
      case 2:
        return AppColors.metroLine2;
      case 3:
        return AppColors.metroLine3;
      case 4:
        return AppColors.metroLine4;
      default:
        return AppColors.metroLine1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ThemeIcon(
          Icons.train,
          color: _getLineColor(conversation.subwayStationLine ?? 1),
          size: 16,
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            _getLocalizedName(
              nameUz: conversation.subwayStationNameUz,
              nameRu: conversation.subwayStationNameRu,
              nameEn: conversation.subwayStationNameEn,
            ),
            style: TextStyle(fontSize: 12, color: textColor),
          ),
        ),
      ],
    );
  }
}

/// Price range display.
class ConversationPriceDisplay extends StatelessWidget {
  const ConversationPriceDisplay({
    required this.conversation,
    required this.textColor,
    super.key,
  });

  final ConversationSummary conversation;
  final Color textColor;

  static String _formatPriceRange(ConversationSummary conversation) {
    final price = conversation.listingPrice;
    if (price != null && price > 0) {
      final cc = conversation.priceCurrencyCode?.trim();
      if (cc != null && cc.isNotEmpty) {
        final formatted = IntFormatUtils.withDotThousands(price);
        return "$formatted $cc";
      }
      return PriceRangeHelper.formatListingPriceRangeWithCurrency(
        price,
        price,
      );
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PriceDisplaySettingsState(),
      builder: (context, _) {
        return Row(
          children: [
            const ThemeIcon(Icons.payments, color: Colors.green, size: 16),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                _formatPriceRange(conversation),
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
