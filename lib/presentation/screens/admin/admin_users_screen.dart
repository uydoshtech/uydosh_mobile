import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_strings.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/domain/models/admin_user.dart";
import "package:uy_dosh/domain/services/admin_user_service.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/screens/admin/admin_user_listings_screen.dart";

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final List<AdminUser> _users = [];
  final Map<int, int> _listingCounts = {};
  final Set<int> _listingCountsLoading = {};
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

      if (!mounted) return;
      setState(() {
        _users.addAll(response);
        _hasMore = response.length >= _pageSize;
        if (_hasMore) {
          _pageNumber += 1;
        }
      });
      _loadCountsForUsers(response);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _loadCountsForUsers(List<AdminUser> users) {
    for (final user in users) {
      _loadListingCount(user);
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
      if (!mounted) return;
      setState(() {
        _listingCounts[user.id] = response.data.length;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _listingCounts[user.id] = -1;
      });
    } finally {
      _listingCountsLoading.remove(user.id);
    }
  }

  Future<void> _refresh() async {
    _pageNumber = 1;
    _hasMore = true;
    _users.clear();
    _listingCounts.clear();
    _listingCountsLoading.clear();
    await _fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LanguageAwareStringHelper.getCurrent(context, "admin_users_title"),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body:
          _isLoading
              ? CenteredHouseLoadingIndicator(
                text: LanguageAwareStringHelper.getCurrent(
                  context,
                  "admin_users_loading",
                ),
              )
              : _hasError
              ? _buildErrorState(context)
              : _buildUsersList(context),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 12),
          Text(
            LanguageAwareStringHelper.getCurrent(context, "admin_users_error"),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          if (_errorMessage != null) ...[
            const SizedBox(height: 6),
            Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refresh,
            child: Text(
              LanguageAwareStringHelper.getCurrent(context, "retry"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList(BuildContext context) {
    if (_users.isEmpty) {
      return Center(
        child: Text(
          LanguageAwareStringHelper.getCurrent(context, "admin_users_empty"),
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _users.length + (_isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _users.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final user = _users[index];
          final listingCount = _listingCounts[user.id];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder:
                        (context) => AdminUserListingsScreen(
                          userId: user.id,
                          userEmail: user.email,
                        ),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.email ??
                                LanguageAwareStringHelper.getCurrent(
                                  context,
                                  "not_specified",
                                ),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color:
                              Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildMetaRow(
                      context,
                      labelKey: "admin_users_id",
                      value: user.id.toString(),
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
                      value:
                          listingCount == null
                              ? LanguageAwareStringHelper.getCurrent(
                                context,
                                "admin_users_listings_count_loading",
                              )
                              : listingCount >= 0
                              ? listingCount.toString()
                              : LanguageAwareStringHelper.getCurrent(
                                context,
                                "admin_users_listings_count_error",
                              ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetaRow(
    BuildContext context, {
    required String labelKey,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Text(
            "${LanguageAwareStringHelper.getCurrent(context, labelKey)}: ",
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
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
        return LanguageAwareStringHelper.getCurrent(context, "role_tenant");
      case "landlord":
        return LanguageAwareStringHelper.getCurrent(context, "role_landlord");
      case "manager":
        return LanguageAwareStringHelper.getCurrent(context, "role_manager");
      case "admin":
        return LanguageAwareStringHelper.getCurrent(context, "role_admin");
      default:
        return LanguageAwareStringHelper.getCurrent(context, "not_specified");
    }
  }

  String _formatDate(DateTime? value, BuildContext context) {
    if (value == null) {
      return LanguageAwareStringHelper.getCurrent(context, "not_specified");
    }
    final local = value.toLocal();
    final year = local.year.toString();
    final month = local.month.toString().padLeft(2, "0");
    final day = local.day.toString().padLeft(2, "0");
    return "$year-$month-$day";
  }
}
