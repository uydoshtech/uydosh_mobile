import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/domain/models/admin_user.dart";
import "package:uy_dosh/domain/services/admin_user_service.dart";
import "package:uy_dosh/domain/services/complaint_service.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/screens/admin/admin_user_detail_screen.dart";
import "package:intl/intl.dart";

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final List<AdminUser> _users = [];
  final Map<int, String?> _userNames = {};
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

  Future<void> _loadUserName(AdminUser user) async {
    if (user.id <= 0) return;
    if (_userNames.containsKey(user.id)) return;
    if (_userNamesLoading.contains(user.id)) return;

    _userNamesLoading.add(user.id);
    try {
      final profile =
          await getIt<IUserProfileService>().getUserProfile(user.id);
      if (!mounted) return;
      setState(() {
        _userNames[user.id] = profile.name;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _userNames[user.id] = null;
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
      final response = await getIt<IComplaintService>().getUserListingComplaints(
        user.id,
      );
      if (!mounted) return;
      setState(() {
        _complaintCounts[user.id] = response.length;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
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
          final userName = _userNames[user.id];
          final listingCount = _listingCounts[user.id];
          final complaintCount = _complaintCounts[user.id];
          return Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                Navigator.of(context)
                    .push(
                      MaterialPageRoute(
                        builder: (context) => AdminUserDetailScreen(user: user),
                      ),
                    )
                    .then((result) {
                      if (result is Map) {
                        final resultUserId = result["userId"];
                        final resultRole = result["role"];
                        if (resultUserId == user.id && resultRole is String) {
                          setState(() {
                            _users[index] =
                                AdminUser(
                                  id: user.id,
                                  email: user.email,
                                  role: resultRole,
                                  firebaseUid: user.firebaseUid,
                                  telegramId: user.telegramId,
                                  createdAt: user.createdAt,
                                );
                          });
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
                      children: [
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
                                  color:
                                      Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Flexible(
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
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
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
                    if (userName != null && userName.trim().isNotEmpty)
                      _buildMetaRow(
                        context,
                        labelKey: "name",
                        value: userName,
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
                    _buildMetaRow(
                      context,
                      labelKey: "admin_user_complaints_group_count",
                      value:
                          complaintCount == null
                              ? LanguageAwareStringHelper.getCurrent(
                                context,
                                "admin_users_listings_count_loading",
                              )
                              : complaintCount >= 0
                              ? complaintCount.toString()
                              : LanguageAwareStringHelper.getCurrent(
                                context,
                                "admin_users_listings_count_error",
                              ),
                      labelColor:
                          complaintCount != null && complaintCount > 0
                              ? Theme.of(context).colorScheme.error
                              : null,
                      valueColor:
                          complaintCount != null && complaintCount > 0
                              ? Theme.of(context).colorScheme.error
                              : null,
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
    Color? labelColor,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Text(
            "${LanguageAwareStringHelper.getCurrent(context, labelKey)}: ",
            style: TextStyle(
              fontSize: 12,
              color:
                  labelColor ??
                  Theme.of(context).colorScheme.onSurfaceVariant,
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
}
