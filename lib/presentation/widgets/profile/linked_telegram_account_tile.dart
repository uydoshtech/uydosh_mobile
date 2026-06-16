import "dart:async";

import "package:flutter/material.dart";
import "package:url_launcher/url_launcher.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/presentation/widgets/common/confirmation_dialog.dart";
import "package:uy_dosh/presentation/widgets/common/network_avatar_image.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";

/// Avatar diameter for the linked Telegram row — slightly larger than field
/// icons (20) but compact like chat list avatars (32).
const double kLinkedTelegramAccountAvatarSize = 32;

/// Resolves the Telegram profile photo URL from cache and profile fields.
String? resolveTelegramAccountAvatarUrl({
  required UserProfile profile,
  String? cachedTelegramPhotoUrl,
}) {
  final cached = cachedTelegramPhotoUrl?.trim();
  if (cached != null && cached.isNotEmpty) {
    return cached;
  }

  final fromProfile = profile.telegramAvatarUrl?.trim();
  if (fromProfile != null && fromProfile.isNotEmpty) {
    return resolveAvatarUrl(fromProfile);
  }

  final rawAvatar = profile.avatarUrl?.trim();
  if (rawAvatar != null &&
      rawAvatar.isNotEmpty &&
      isTelegramHostedAvatarUrl(rawAvatar)) {
    return resolveAvatarUrl(rawAvatar);
  }

  return null;
}

/// Standard linked Telegram account row used on profile and edit profile.
class LinkedTelegramAccountTile extends StatelessWidget {
  const LinkedTelegramAccountTile({
    required this.profile,
    this.cachedTelegramPhotoUrl,
    this.telegramUsername,
    this.onTap,
    super.key,
  });

  final UserProfile profile;
  final String? cachedTelegramPhotoUrl;

  /// When set, overrides [UserProfile.telegram] (e.g. after a fresh link).
  final String? telegramUsername;

  /// When null and a username is shown, tapping opens Telegram after confirmation.
  final VoidCallback? onTap;

  Color _linkedLabelColor(BuildContext context) {
    if (ThemeState().isBlueTheme) {
      // colorScheme.primary is dark blue on this theme — unread-style emerald reads clearly.
      return const Color(0xFF34D399);
    }
    return Theme.of(context).colorScheme.primary;
  }

  String? _resolvedUsername() {
    final username = telegramUsername ?? profile.telegram;
    final trimmed = username?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    final normalized =
        trimmed.startsWith("@") ? trimmed.substring(1).trim() : trimmed;
    return normalized.isEmpty ? null : normalized;
  }

  Widget? _buildAvatar(BuildContext context) {
    final photoUrl = resolveTelegramAccountAvatarUrl(
      profile: profile,
      cachedTelegramPhotoUrl: cachedTelegramPhotoUrl,
    );
    if (photoUrl == null) return null;

    final fallback = Center(
      child: ThemeIcon(
        Icons.person,
        size: 18,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
    return SizedBox(
      width: kLinkedTelegramAccountAvatarSize,
      height: kLinkedTelegramAccountAvatarSize,
      child: ClipOval(
        child: NetworkAvatarImage(
          imageUrl: photoUrl,
          size: kLinkedTelegramAccountAvatarSize,
          fallback: fallback,
        ),
      ),
    );
  }

  Future<void> _confirmOpenTelegram(
    String username,
    BuildContext context,
  ) async {
    final shouldOpen = await CommonConfirmationDialogs.showGenericConfirmation(
      context: context,
      titleKey: "open_in_telegram",
      messageKey: "open_in_telegram_confirmation",
      confirmButtonKey: "confirm",
    );

    if (shouldOpen ?? false) {
      await _openTelegram(username, context);
    }
  }

  Future<void> _openTelegram(String username, BuildContext context) async {
    final cleanUsername =
        username.startsWith("@") ? username.substring(1) : username;

    final url = "https://t.me/$cleanUsername";

    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
      } else {
        ToastTheme.showError(context, message: "Could not open Telegram");
      }
    } catch (e) {
      ToastTheme.showError(context, message: "Could not open Telegram");
    }
  }

  @override
  Widget build(BuildContext context) {
    final username = _resolvedUsername();
    final showUsername = username != null;

    return InkWell(
      onTap: showUsername
          ? () {
              HapticFeedbackUtils.impact();
              if (onTap != null) {
                onTap!();
              } else {
                unawaited(_confirmOpenTelegram(username, context));
              }
            }
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ThemeIcon(
                  Icons.telegram,
                  size: 20,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        L10n.get("telegram"),
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        showUsername ? "@$username" : L10n.get("not_specified"),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showUsername) ...[
                  if (_buildAvatar(context) case final avatar?) ...[
                    avatar,
                    const SizedBox(width: 8),
                  ],
                  ThemeIcon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                ],
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 32, top: 4),
              child: Text(
                L10n.get("telegram_account_linked"),
                style: TextStyle(
                  fontSize: 12,
                  color: _linkedLabelColor(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
