import "dart:async";

import "package:flutter/material.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/util/date_utils.dart";
import "package:uy_dosh/base/util/dio_api_error_message.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/domain/services/admin_telegram_mini_app_location_service.dart";
import "package:uy_dosh/presentation/screens/admin/admin_telegram_user_location_history_screen.dart";
import "package:uy_dosh/presentation/widgets/common/common_list_view.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_text_field.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_error_retry_column.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/base/state/theme_state.dart";

/// Admin screen: pick a Telegram Mini App visitor (by username or numeric id)
/// to inspect their reported device location history.
class AdminTelegramUserLocationsScreen extends StatefulWidget {
  const AdminTelegramUserLocationsScreen({super.key});

  @override
  State<AdminTelegramUserLocationsScreen> createState() =>
      _AdminTelegramUserLocationsScreenState();
}

class _AdminTelegramUserLocationsScreenState
    extends State<AdminTelegramUserLocationsScreen> {
  static const int _pageSize = 30;

  final IAdminTelegramMiniAppLocationService _service =
      getIt<IAdminTelegramMiniAppLocationService>();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<TelegramMiniAppLocationUserSummary> _users = [];
  Timer? _debounce;
  String _search = "";
  int _page = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetch();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoadingMore || !_hasMore) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 200) {
      _fetch(loadMore: true);
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _search = value.trim();
      _fetch();
    });
  }

  Future<void> _fetch({bool loadMore = false}) async {
    if (_isLoading || _isLoadingMore) return;
    setState(() {
      _hasError = false;
      _errorMessage = null;
      if (loadMore) {
        _isLoadingMore = true;
      } else {
        _isLoading = true;
        _page = 1;
      }
    });

    try {
      final page = loadMore ? _page + 1 : 1;
      final result = await _service.listUsers(
        search: _search,
        page: page,
        limit: _pageSize,
      );
      setStateIfMounted(() {
        if (loadMore) {
          _users.addAll(result.users);
        } else {
          _users
            ..clear()
            ..addAll(result.users);
        }
        _page = page;
        _hasMore = result.hasMore;
      });
    } catch (e) {
      setStateIfMounted(() {
        _hasError = !loadMore;
        _errorMessage = throwableUserMessage(e);
      });
    } finally {
      setStateIfMounted(() {
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _openHistory(TelegramMiniAppLocationUserSummary user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AdminTelegramUserLocationHistoryScreen(
          telegramUserId: user.telegramUserId,
          telegramUsername: user.telegramUsername,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UydoshAppBar(
        leading: ThreeDAppBarIconButton.backLeading(context),
        title: Text(
          L10n.get("admin_telegram_locations_title"),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListenableBuilder(
        listenable: LanguageState(),
        builder: (context, _) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: ThreeDTextField(
                controller: _searchController,
                hintText: L10n.get("admin_telegram_locations_search_hint"),
                borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
                textInputAction: TextInputAction.search,
                prefixIconConstraints: const BoxConstraints(
                  minWidth: 42,
                  minHeight: 40,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 22,
                  color: ThemeState().isBlueTheme
                      ? Colors.white
                      : Theme.of(context).colorScheme.primary,
                ),
                onChanged: _onSearchChanged,
              ),
            ),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(child: HouseLoadingIndicator());
    }
    if (_hasError) {
      return UydoshErrorRetryColumn(
        title: L10n.get("admin_telegram_locations_error"),
        message: _errorMessage,
        onRetry: _fetch,
        retryLabel: L10n.get("admin_district_heatmap_retry"),
      );
    }
    if (_users.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            L10n.get("admin_telegram_locations_empty"),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }
    return CommonListView(
      controller: _scrollController,
      itemCount: _users.length,
      showLoadMoreIndicator: true,
      hasMore: _hasMore,
      itemSpacing: 10,
      itemBuilder: (context, index) => _UserTile(
        user: _users[index],
        onTap: () => _openHistory(_users[index]),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user, required this.onTap});

  final TelegramMiniAppLocationUserSummary user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = user.telegramUsername != null
        ? "@${user.telegramUsername}"
        : "#${user.telegramUserId}";

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: ThreeDSurfaceStyle.surfaceGradient(
          context,
          theme.colorScheme.surface,
        ),
        boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                ThemeIcon(
                  Icons.person_pin_circle_outlined,
                  size: 28,
                  color: theme.colorScheme.onSurface,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              label,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (user.phoneNumber != null) ...[
                            const SizedBox(width: 6),
                            ThemeIcon(
                              Icons.phone,
                              size: 16,
                              color: theme.colorScheme.tertiary,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        L10n.getWithParams(
                          "admin_telegram_locations_ping_count",
                          params: {"count": "${user.pingCount}"},
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppDateUtils.formatRelativePastDate(user.lastSeenAt),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ThemeIcon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
