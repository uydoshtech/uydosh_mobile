import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/state/home_refresh_state.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/services/user_block_service.dart";
import "package:uy_dosh/base/utils/toast_reporting.dart";
import "package:uy_dosh/presentation/widgets/common/confirmation_dialog.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/network_avatar_image.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_error_retry_column.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

class BlockedUsersScreen extends StatefulWidget {
  const BlockedUsersScreen({super.key});

  @override
  State<BlockedUsersScreen> createState() => _BlockedUsersScreenState();
}

class _BlockedUsersScreenState extends State<BlockedUsersScreen> {
  final List<BlockedUserSummary> _users = [];
  final Set<int> _unblockingIds = {};

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    getIt<AppAnalyticsService>().logScreenView(screenName: "blocked_users");
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final users = await getIt<IUserBlockService>().getBlockedUsers();
      if (!mounted) return;
      setState(() {
        _users
          ..clear()
          ..addAll(users);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _unblockUser(BlockedUserSummary user) async {
    if (_unblockingIds.contains(user.userId)) return;

    final confirmed = await CommonConfirmationDialogs.showGenericConfirmation(
      context: context,
      titleKey: "unblock_user_confirm_title",
      messageKey: "unblock_user_confirm_body",
      confirmButtonKey: "unblock_user",
    );
    if (confirmed != true || !mounted) return;

    setState(() => _unblockingIds.add(user.userId));
    final result = await getIt<IUserBlockService>().toggleBlock(user.userId);
    if (!mounted) return;

    setState(() => _unblockingIds.remove(user.userId));

    if (result == null || result.isBlocked) {
      ToastReporting.errorKey(context, "unblock_user_error");
      return;
    }

    setState(() {
      _users.removeWhere((u) => u.userId == user.userId);
    });
    HomeRefreshState().forceRefreshNow();
    ToastReporting.successKey(context, "unblock_user_success");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UydoshAppBar(
        leading: ThreeDAppBarIconButton.backLeading(context),
        title: ListenableBuilder(
          listenable: LanguageState(),
          builder: (context, _) => Text(L10n.get("blocked_users_title")),
        ),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return ListenableBuilder(
        listenable: LanguageState(),
        builder: (context, _) =>
            CenteredHouseLoadingIndicator(text: L10n.get("loading")),
      );
    }

    final error = _error;
    if (error != null) {
      return ListenableBuilder(
        listenable: LanguageState(),
        builder: (context, _) {
          return UydoshErrorRetryColumn(
            message: error,
            onRetry: _loadUsers,
          );
        },
      );
    }

    if (_users.isEmpty) {
      return ListenableBuilder(
        listenable: LanguageState(),
        builder: (context, _) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                L10n.get("blocked_users_empty"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      );
    }

    return ListenableBuilder(
      listenable: LanguageState(),
      builder: (context, _) {
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          itemCount: _users.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final user = _users[index];
            final busy = _unblockingIds.contains(user.userId);
            return Material(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    _buildUserAvatar(context, user.avatarUrl),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        user.name?.trim().isNotEmpty == true
                            ? user.name!.trim()
                            : "#${user.userId}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: busy
                          ? null
                          : () {
                              HapticFeedbackUtils.impact();
                              _unblockUser(user);
                            },
                      child: busy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(L10n.get("unblock_user")),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildUserAvatar(BuildContext context, String? avatarUrl) {
    const size = 44.0;
    final scheme = Theme.of(context).colorScheme;
    final fallback = CircleAvatar(
      radius: size / 2,
      backgroundColor: scheme.surfaceContainerHighest,
      child: ThemeIcon(
        Icons.person,
        size: size * 0.5,
        color: scheme.onSurface,
      ),
    );
    final resolvedUrl = resolveAvatarUrl(avatarUrl);
    if (resolvedUrl == null) {
      return fallback;
    }

    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: NetworkAvatarImage(
          imageUrl: resolvedUrl,
          size: size,
          fallback: fallback,
        ),
      ),
    );
  }
}
