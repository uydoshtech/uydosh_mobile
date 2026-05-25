import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/common_friend.dart";
import "package:uy_dosh/domain/services/follow_service.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/presentation/blocs/listing_owner_profile_bloc.dart";
import "package:uy_dosh/presentation/screens/listing_owner_profile/listing_owner_profile_screen.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/network_avatar_image.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_error_retry_column.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

enum UserFollowListType { followers, following }

class UserFollowListScreen extends StatefulWidget {
  const UserFollowListScreen({
    required this.userId,
    required this.listType,
    this.initialTotalCount,
    super.key,
  });

  final int userId;
  final UserFollowListType listType;
  final int? initialTotalCount;

  @override
  State<UserFollowListScreen> createState() => _UserFollowListScreenState();
}

class _UserFollowListScreenState extends State<UserFollowListScreen> {
  final List<FollowUserSummary> _users = [];
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _error;
  int _page = 1;
  int _totalPages = 0;
  late int _total;

  @override
  void initState() {
    super.initState();
    _total = widget.initialTotalCount ?? 0;
    getIt<AppAnalyticsService>().logScreenView(
      screenName: widget.listType == UserFollowListType.followers
          ? "followers_list"
          : "following_list",
    );
    _scrollController.addListener(_onScroll);
    _loadUsers(reset: true);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers({required bool reset}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _error = null;
        _page = 1;
        _totalPages = 0;
      });
    } else {
      if (_isLoadingMore || _page >= _totalPages) return;
      setState(() => _isLoadingMore = true);
    }

    try {
      final nextPage = reset ? 1 : _page + 1;
      final result = widget.listType == UserFollowListType.followers
          ? await getIt<IFollowService>().getFollowers(
              widget.userId,
              page: nextPage,
            )
          : await getIt<IFollowService>().getFollowing(
              widget.userId,
              page: nextPage,
            );

      if (!mounted) return;
      setState(() {
        if (reset) {
          _users
            ..clear()
            ..addAll(result.users);
        } else {
          _users.addAll(result.users);
        }
        _page = result.page;
        _totalPages = result.totalPages;
        _total = result.total;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _loadUsers(reset: false);
    }
  }

  String _title() {
    final baseTitle = widget.listType == UserFollowListType.followers
        ? L10n.get("followers_list_title")
        : L10n.get("following_list_title");
    return "$baseTitle ($_total)";
  }

  String _emptyMessage() {
    return widget.listType == UserFollowListType.followers
        ? L10n.get("no_followers_yet")
        : L10n.get("no_following_yet");
  }

  void _openUserProfile(FollowUserSummary user) {
    HapticFeedbackUtils.impact();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => BlocProvider(
          create: (context) => ListingOwnerProfileBloc(
            getIt<IUserProfileService>(),
            getIt<IFollowService>(),
          ),
          child: ListingOwnerProfileScreen(userId: user.userId),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UydoshAppBar(
        leading: ThreeDAppBarIconButton.backLeading(context),
        title: ListenableBuilder(
          listenable: LanguageState(),
          builder: (context, _) => Text(_title()),
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

    if (_error != null) {
      return ListenableBuilder(
        listenable: LanguageState(),
        builder: (context, _) {
          return UydoshErrorRetryColumn(
            message: _error!,
            onRetry: () => _loadUsers(reset: true),
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
                _emptyMessage(),
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

    return ListView.separated(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            itemCount: _users.length + (_isLoadingMore ? 1 : 0),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              if (index >= _users.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }

              final user = _users[index];
              return Material(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _openUserProfile(user),
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
                            user.name ?? "#${user.userId}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ThemeIcon(
                          Icons.chevron_right,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withValues(alpha: 0.7),
                        ),
                      ],
                    ),
                  ),
                ),
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
