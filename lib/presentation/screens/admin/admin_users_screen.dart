import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/domain/models/admin_user.dart";
import "package:uy_dosh/domain/services/admin_user_service.dart";
import "package:uy_dosh/domain/services/complaint_service.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/presentation/screens/admin/admin_user_detail_screen.dart";
import "package:uy_dosh/presentation/widgets/common/common_list_view.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/network_avatar_image.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_error_retry_column.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_logo_spinner.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final List<AdminUser> _users = [];
  final Map<int, String?> _userNames = {};
  final Map<int, String?> _userAvatarUrls = {};
  final Map<int, int> _listingCounts = {};
  final Map<int, int> _complaintCounts = {};
  final Set<int> _listingCountsLoading = {};
  final Set<int> _complaintCountsLoading = {};
  final Set<int> _userNamesLoading = {};
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasError = false;
  String? _errorMessage;
  int _pageNumber = 1;
  final int _pageSize = 20;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoadingMore || !_hasMore) {
      return;
    }
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _fetchUsers(loadMore: true);
    }
  }

  Future<void> _fetchUsers({bool loadMore = false}) async {
    if (_isLoading || _isLoadingMore) return;

    setState(() {
      _hasError = false;
      _errorMessage = null;
      if (loadMore) {
        _isLoadingMore = true;
      } else {
        _isLoading = true;
      }
    });

    try {
      final response = await getIt<IAdminUserService>().getUsers(
        pageNumber: _pageNumber,
        pageSize: _pageSize,
      );

      setStateIfMounted(() {
        _users.addAll(response);
        _hasMore = response.length >= _pageSize;
        if (_hasMore) {
          _pageNumber += 1;
        }
      });
      _loadCountsForUsers(response);
    } catch (e) {
      setStateIfMounted(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    } finally {
      setStateIfMounted(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _loadCountsForUsers(List<AdminUser> users) {
    for (final user in users) {
      _loadUserName(user);
      _loadListingCount(user);
      _loadComplaintCount(user);
    }
  }

  Future<void> _loadListingCount(AdminUser user) async {
    if (user.id <= 0) return;
    if (_listingCounts.containsKey(user.id)) return;
    if (_listingCountsLoading.contains(user.id)) return;

    _listingCountsLoading.add(user.id);
    try {
      final response = await getIt<IListingService>().getListingsByUserId(
        userId: user.id,
        page: 1,
        limit: 1000,
      );
      setStateIfMounted(() {
        _listingCounts[user.id] = response.data.length;
      });
    } catch (_) {
      setStateIfMounted(() {
        _listingCounts[user.id] = -1;
      });
    } finally {
      _listingCountsLoading.remove(user.id);
    }
  }

  Future<void> _loadUserName(AdminUser user) async {
    if (user.id <= 0) return;
    if (_userNames.containsKey(user.id)) return;
    if (_userNamesLoading.contains(user.id)) return;

    _userNamesLoading.add(user.id);
    try {
      final profile =
          await getIt<IUserProfileService>().getUserProfile(user.id);
      setStateIfMounted(() {
        _userNames[user.id] = profile.name;
        _userAvatarUrls[user.id] = profile.avatarUrl;
      });
    } catch (_) {
      setStateIfMounted(() {
        _userNames[user.id] = null;
        _userAvatarUrls[user.id] = null;
      });
    } finally {
      _userNamesLoading.remove(user.id);
    }
  }

  Future<void> _loadComplaintCount(AdminUser user) async {
    if (user.id <= 0) return;
    if (_complaintCounts.containsKey(user.id)) return;
    if (_complaintCountsLoading.contains(user.id)) return;

    _complaintCountsLoading.add(user.id);
    try {
      final response =
          await getIt<IComplaintService>().getUserListingComplaints(
        user.id,
      );
      setStateIfMounted(() {
        _complaintCounts[user.id] = response.length;
      });
    } catch (_) {
      setStateIfMounted(() {
        _complaintCounts[user.id] = -1;
      });
    } finally {
      _complaintCountsLoading.remove(user.id);
    }
  }

  Future<void> _refresh() async {
    _pageNumber = 1;
    _hasMore = true;
    _users.clear();
    _userNames.clear();
    _userAvatarUrls.clear();
    _listingCounts.clear();
    _listingCountsLoading.clear();
    _complaintCounts.clear();
    _complaintCountsLoading.clear();
    _userNamesLoading.clear();
    await _fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UydoshAppBar(
        leading: ThreeDAppBarIconButton.backLeading(context),
        title: Text(
          L10n.get("admin_users_title"),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: _isLoading
          ? CenteredHouseLoadingIndicator(
              text: L10n.get("admin_users_loading"),
            )
          : _hasError
              ? _buildErrorState(context)
              : _buildUsersList(context),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return UydoshErrorRetryColumn(
      title: L10n.get("admin_users_error"),
      message: _errorMessage,
      onRetry: _refresh,
    );
  }

  Widget _buildUsersList(BuildContext context) {
    if (_users.isEmpty) {
      return Center(
        child: Text(
          L10n.get("admin_users_empty"),
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return CommonListView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemSpacing: 8,
      itemCount: _users.length,
      itemBuilder: (context, index) {
        final user = _users[index];
        final userName = _userNames[user.id];
        final avatarUrl = _userAvatarUrls[user.id];
        final listingCount = _listingCounts[user.id];
        final complaintCount = _complaintCounts[user.id];
        final theme = Theme.of(context);
        const tileRadius = BorderRadius.all(Radius.circular(16));

        return Stack(
          clipBehavior: Clip.none,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: tileRadius,
                gradient: ThreeDSurfaceStyle.surfaceGradient(
                  context,
                  theme.colorScheme.surface,
                ),
                boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
              ),
              child: Material(
                color: Colors.transparent,
                elevation: 0,
                shadowColor: Colors.transparent,
                surfaceTintColor: Colors.transparent,
                shape: const RoundedRectangleBorder(borderRadius: tileRadius),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  borderRadius: tileRadius,
                  onTap: () {
                    Navigator.of(context)
                        .push(
                      MaterialPageRoute(
                        builder: (context) => AdminUserDetailScreen(user: user),
                      ),
                    )
                        .then((result) {
                      if (!mounted) return;
                      if (result is Map) {
                        final resultUser = result["user"] as AdminUser?;
                        if (resultUser != null && resultUser.id == user.id) {
                          setState(() {
                            _users[index] = resultUser;
                          });
                        } else {
                          final resultUserId = result["userId"];
                          final resultRole = result["role"];
                          if (resultUserId == user.id && resultRole is String) {
                            setState(() {
                              _users[index] = AdminUser(
                                id: user.id,
                                email: user.email,
                                role: resultRole,
                                firebaseUid: user.firebaseUid,
                                telegramId: user.telegramId,
                                createdAt: user.createdAt,
                                isBlocked: user.isBlocked,
                                blockedAt: user.blockedAt,
                                blockedUntil: user.blockedUntil,
                                blockedReason: user.blockedReason,
                                isOnline: user.isOnline,
                                telegramUsername: user.telegramUsername,
                                isTelegramMiniAppOnly:
                                    user.isTelegramMiniAppOnly,
                                signupSource: user.signupSource,
                              );
                            });
                          }
                        }
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                _AdminUserAvatar(
                                  avatarUrl: avatarUrl,
                                  initials: _buildUserInitials(
                                    name: userName,
                                    email: user.email,
                                  ),
                                ),
                                if (user.isTelegramMiniAppOnly)
                                  Positioned(
                                    bottom: -4,
                                    right: -4,
                                    child: Tooltip(
                                      message: L10n.get(
                                        "admin_users_mini_app_only_tooltip",
                                      ),
                                      child: const _TelegramMiniAppBadge(),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    "ID: ${user.id}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "•",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      user.email ?? L10n.get("not_specified"),
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ThemeIcon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (userName != null && userName.trim().isNotEmpty)
                          _buildMetaRow(
                            context,
                            labelKey: "name",
                            value: userName,
                          ),
                        if (user.isTelegramMiniAppOnly &&
                            (user.telegramUsername?.trim().isNotEmpty ?? false))
                          _buildMetaRow(
                            context,
                            labelKey: "admin_users_telegram_username",
                            value: "@${user.telegramUsername!.trim()}",
                          ),
                        _buildMetaRow(
                          context,
                          labelKey: "admin_users_role",
                          value: _getRoleLabel(user.role, context),
                        ),
                        _buildMetaRow(
                          context,
                          labelKey: "admin_users_created_at",
                          value: _formatDate(user.createdAt, context),
                        ),
                        _buildMetaRow(
                          context,
                          labelKey: "admin_users_listings_count",
                          value: listingCount == null
                              ? L10n.get("admin_users_listings_count_loading")
                              : listingCount >= 0
                                  ? listingCount.toString()
                                  : L10n.get(
                                      "admin_users_listings_count_error"),
                        ),
                        _buildMetaRow(
                          context,
                          labelKey: "admin_user_complaints_group_count",
                          value: complaintCount == null
                              ? L10n.get("admin_users_listings_count_loading")
                              : complaintCount >= 0
                                  ? complaintCount.toString()
                                  : L10n.get(
                                      "admin_users_listings_count_error"),
                          labelColor:
                              complaintCount != null && complaintCount > 0
                                  ? theme.colorScheme.error
                                  : null,
                          valueColor:
                              complaintCount != null && complaintCount > 0
                                  ? theme.colorScheme.error
                                  : null,
                        ),
                        if (user.isCurrentlyBlocked)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Row(
                              children: [
                                ThemeIcon(
                                  Icons.block,
                                  color: theme.colorScheme.error,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  L10n.get("admin_user_detail_blocked"),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: theme.colorScheme.error,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (user.isOnline)
              Positioned(
                top: -8,
                right: -8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                    border: Border.all(
                      color: theme.colorScheme.surface,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        );
      },
      showRefreshIndicator: true,
      onRefresh: _refresh,
      showLoadMoreIndicator: _isLoadingMore,
      hasMore: _isLoadingMore,
      loadMoreIndicator: const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(child: UydoshLogoSpinner()),
      ),
    );
  }

  Widget _buildMetaRow(
    BuildContext context, {
    required String labelKey,
    required String value,
    Color? labelColor,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Text(
            "${L10n.get(labelKey)}: ",
            style: TextStyle(
              fontSize: 12,
              color:
                  labelColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 12, color: valueColor),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleLabel(String? role, BuildContext context) {
    switch (role) {
      case "tenant":
        return L10n.get("role_tenant");
      case "landlord":
        return L10n.get("role_landlord");
      case "service_requester":
        return L10n.get("role_service_requester");
      case "service_provider":
        return L10n.get("role_service_provider");
      case "manager":
        return L10n.get("role_manager");
      case "admin":
        return L10n.get("role_admin");
      default:
        return L10n.get("not_specified");
    }
  }

  String _formatDate(DateTime? value, BuildContext context) {
    if (value == null) {
      return L10n.get("not_specified");
    }
    final local = value.toLocal();
    final locale = LanguageState().currentLanguage;
    try {
      return _capitalizeMonth(DateFormat("dd MMMM yyyy", locale).format(local));
    } catch (_) {
      return _capitalizeMonth(DateFormat("dd MMMM yyyy").format(local));
    }
  }

  String _capitalizeMonth(String dateText) {
    final parts = dateText.split(" ");
    if (parts.length < 2) {
      return dateText;
    }
    final month = parts[1];
    if (month.isEmpty) {
      return dateText;
    }
    parts[1] = "${month.substring(0, 1).toUpperCase()}${month.substring(1)}";
    return parts.join(" ");
  }

  String? _buildUserInitials({String? name, String? email}) {
    final source = (name != null && name.trim().isNotEmpty)
        ? name.trim()
        : (email != null && email.trim().isNotEmpty ? email.trim() : null);
    if (source == null) return null;

    final parts = source
        .replaceAll(RegExp(r"[^A-Za-zА-Яа-яЁё0-9\s]"), " ")
        .split(RegExp(r"\s+"))
        .where((p) => p.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) return null;

    if (parts.length == 1) {
      final p = parts.first;
      final first = p.isNotEmpty ? p[0] : "";
      final second = p.length >= 2 ? p[1] : "";
      final res = (first + second).toUpperCase();
      return res.trim().isEmpty ? null : res;
    }

    final res = (parts[0][0] + parts[1][0]).toUpperCase();
    return res.trim().isEmpty ? null : res;
  }
}

/// Small brand-colored Telegram badge overlapping the bottom-right of the
/// avatar for users who only ever used the Telegram Mini App (see
/// `AdminUser.isTelegramMiniAppOnly`).
class _TelegramMiniAppBadge extends StatelessWidget {
  const _TelegramMiniAppBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.telegramBrandBlue,
        border: Border.all(
          color: Theme.of(context).colorScheme.surface,
          width: 2,
        ),
      ),
      child: const Icon(
        Icons.telegram,
        size: 11,
        color: Colors.white,
      ),
    );
  }
}

class _AdminUserAvatar extends StatelessWidget {
  const _AdminUserAvatar({
    required this.avatarUrl,
    required this.initials,
  });

  final String? avatarUrl;
  final String? initials;

  @override
  Widget build(BuildContext context) {
    final size = 36.0;
    final theme = Theme.of(context);
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface;
    final border = onSurface.withValues(alpha: 0.08);

    final url = resolveAvatarUrl(avatarUrl);

    Widget content;
    if (url != null && url.isNotEmpty) {
      content = ClipOval(
        child: SizedBox(
          width: size,
          height: size,
          child: NetworkAvatarImage(
            imageUrl: url,
            size: size,
            fallback:
                Center(child: _InitialsAvatarFallback(initials: initials)),
          ),
        ),
      );
    } else {
      content = _InitialsAvatarFallback(initials: initials);
    }

    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Color.lerp(surface, onSurface, 0.02),
          border: Border.all(color: border, width: 1),
        ),
        child: Center(child: content),
      ),
    );
  }
}

class _InitialsAvatarFallback extends StatelessWidget {
  const _InitialsAvatarFallback({required this.initials});

  final String? initials;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = initials?.trim();
    final hasText = text != null && text.isNotEmpty;

    if (!hasText) {
      return ThemeIcon(
        Icons.person,
        size: 18,
        color: theme.colorScheme.onSurfaceVariant,
      );
    }

    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: theme.colorScheme.onSurface,
      ),
    );
  }
}
