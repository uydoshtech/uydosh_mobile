import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/utils/int_format_utils.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";

/// Shared widgets for displaying conversation/listing info in the messages inbox.
/// Used by ConversationTile, OutgoingConversationTile, and GroupedConversationsList.

/// Avatar content - initials or person icon fallback.
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
        final hasLocation =
            conversation.locationNameUz != null ||
            conversation.locationNameRu != null ||
            conversation.locationNameEn != null;
        final hasSubwayStation =
            conversation.subwayStationNameUz != null ||
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
      final formatted = IntFormatUtils.withDotThousands(price);
      final cc = conversation.priceCurrencyCode?.trim();
      if (cc != null && cc.isNotEmpty) {
        return "$formatted $cc";
      }
      return "$formatted y.e.";
    }
    return "";
  }

  @override
  Widget build(BuildContext context) {
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
  }
}
