import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/utils/string_utils.dart";
import "package:uy_dosh/domain/models/conversation.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

/// Shared widgets for displaying conversation/listing info in the messages inbox.
/// Used by ConversationTile, OutgoingConversationTile, and GroupedConversationsList.

/// Avatar content - initials or person icon fallback.
class ConversationAvatarContent extends StatelessWidget {
  const ConversationAvatarContent({
    required this.conversation,
    required this.iconColor,
    super.key,
  });

  final ConversationSummary conversation;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final userName = conversation.otherUserName;
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

    return Icon(Icons.person, color: iconColor);
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
            if (hasLocation) ...[
              Row(
                children: [
                  const Icon(
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
            ],
            if (hasSubwayStation) ...[
              const SizedBox(height: 4),
              ConversationSubwayStationDisplay(
                conversation: conversation,
                textColor: textColor,
              ),
            ],
            if (showPrice &&
                (conversation.listingMinPrice != null ||
                    conversation.listingMaxPrice != null)) ...[
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
        Icon(
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
    final minPrice = conversation.listingMinPrice;
    final maxPrice = conversation.listingMaxPrice;

    if (minPrice != null && maxPrice != null) {
      if (minPrice == maxPrice) {
        return minPrice.toString();
      } else {
        return "$minPrice - $maxPrice";
      }
    } else if (minPrice != null) {
      return "от $minPrice";
    } else if (maxPrice != null) {
      return "до $maxPrice";
    } else {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.attach_money, color: Colors.green, size: 16),
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
