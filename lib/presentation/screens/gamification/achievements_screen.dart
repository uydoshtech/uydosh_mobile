import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/achievement_unlock_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/state/authentication_state.dart";
import "package:uy_dosh/base/state/profile_completion_state.dart";
import "package:uy_dosh/domain/models/achievement.dart";
import "package:uy_dosh/domain/services/favorite_service.dart";
import "package:uy_dosh/domain/services/gamification_service.dart";
import "package:uy_dosh/domain/services/listing_service.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/presentation/blocs/gamification_bloc.dart";
import "package:uy_dosh/presentation/screens/auth/auth_wizard_screen.dart";
import "package:uy_dosh/base/constants/app_config.dart";
import "package:uy_dosh/presentation/widgets/common/common_app_bar.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  Future<void> _loadAndCheck(BuildContext ctx) async {
    if (!AuthenticationState().isAuthenticated) return;
    if (!mounted) return;

    final stats = await _gatherStats();
    if (!mounted) return;

    final bloc = ctx.read<GamificationBloc>();
    bloc.add(const GamificationEvent.loadAchievements());
    bloc.add(GamificationEvent.checkAndUnlock(
      hasAccount: stats.hasAccount,
      profileCompletionPercent: stats.profileCompletionPercent,
      viewedListingsCount: stats.viewedListingsCount,
      favoritesCount: stats.favoritesCount,
      messagesSentCount: stats.messagesSentCount,
      listingsCreatedCount: stats.listingsCreatedCount,
      conversationsStartedCount: stats.conversationsStartedCount,
    ));

    final service = getIt<IGamificationService>();
    await service.recordAppOpen();
    final newlyUnlocked = await service.checkAndUnlockAchievements(
      hasAccount: stats.hasAccount,
      profileCompletionPercent: stats.profileCompletionPercent,
      viewedListingsCount: stats.viewedListingsCount,
      favoritesCount: stats.favoritesCount,
      messagesSentCount: stats.messagesSentCount,
      listingsCreatedCount: stats.listingsCreatedCount,
      conversationsStartedCount: stats.conversationsStartedCount,
    );

    if (mounted && newlyUnlocked.isNotEmpty) {
      bloc.add(const GamificationEvent.loadAchievements());
      AchievementUnlockState().setPendingAchievement(newlyUnlocked.first);
    }

    await service.markAchievementsAsSeen();
  }

  Future<_GamificationStats> _gatherStats() async {
    final hasAccount = AuthenticationState().isAuthenticated;
    var profileCompletionPercent = 0;
    var viewedListingsCount = 0;
    var favoritesCount = 0;
    var listingsCreatedCount = 0;

    try {
      final profile = await getIt<IUserProfileService>().getCurrentUserProfile();
      profileCompletionPercent =
          ProfileCompletionState.completionPercent(profile);
    } catch (_) {}

    try {
      final viewed =
          await getIt<IListingService>().getViewedListings(page: 1, limit: 1);
      viewedListingsCount = viewed.total;
    } catch (_) {}

    try {
      final favorites =
          await getIt<IFavoriteService>().getUserFavorites(page: 1, limit: 100);
      favoritesCount = favorites.length;
    } catch (_) {}

    final userId = await SessionManager.getUserId();
    if (userId != null) {
      try {
        final myListings = await getIt<IListingService>()
            .getListingsByUserId(userId: userId, page: 1, limit: 1);
        listingsCreatedCount = myListings.total;
      } catch (_) {}
    }

    var messagesSentCount = 0;
    try {
      final hasSentFirst =
          await getIt<IGamificationService>().hasSentFirstMessage();
      if (hasSentFirst) messagesSentCount = 1;
    } catch (_) {}

    return _GamificationStats(
      hasAccount: hasAccount,
      profileCompletionPercent: profileCompletionPercent,
      viewedListingsCount: viewedListingsCount,
      favoritesCount: favoritesCount,
      messagesSentCount: messagesSentCount,
      listingsCreatedCount: listingsCreatedCount,
      conversationsStartedCount: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildContent(context);
  }

  Widget _buildContent(BuildContext context) {
    if (!AuthenticationState().isAuthenticated) {
      return Scaffold(
        appBar: CommonAppBar(
          title: L10n.get("achievements_title"),
          showBackButton: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(L10n.get("achievements_auth_prompt")),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const AuthWizardScreen(),
                    ),
                  );
                },
                child: Text(L10n.get("sign_in")),
              ),
            ],
          ),
        ),
      );
    }

    return BlocProvider(
      create: (context) => GamificationBloc(getIt<IGamificationService>()),
      child: _AchievementsBody(buildAchievementsList: _buildAchievementsList),
    );
  }

  Widget _buildAchievementsList(
    BuildContext context,
    List<Achievement> achievements,
    Set<String> unlockedIds,
  ) {
    if (achievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              L10n.get("achievements_empty"),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              L10n.get("achievements_empty_desc"),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final a = achievements[index];
        final isUnlocked = unlockedIds.contains(a.id);
        return _AchievementTile(
          achievement: a,
          isUnlocked: isUnlocked,
          descriptionKey: "${a.key}_desc",
        );
      },
    );
  }
}

class _AchievementsBody extends StatefulWidget {
  const _AchievementsBody({
    required this.buildAchievementsList,
  });

  final Widget Function(
    BuildContext context,
    List<Achievement> achievements,
    Set<String> unlockedIds,
  ) buildAchievementsList;

  @override
  State<_AchievementsBody> createState() => _AchievementsBodyState();
}

class _AchievementsBodyState extends State<_AchievementsBody> {
  bool _hasLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoaded) {
      _hasLoaded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final parent = context.findAncestorStateOfType<_AchievementsScreenState>();
          parent?._loadAndCheck(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CommonAppBar(
        title: L10n.get("achievements_title"),
        showBackButton: true,
      ),
      body: BlocBuilder<GamificationBloc, GamificationState>(
        builder: (context, state) {
          return state.map(
            initial: (_) => CenteredHouseLoadingIndicator(
              text: L10n.get("loading"),
              rotationDuration: AppConfig.defaultHouseRotationDuration,
            ),
            loading: (_) => CenteredHouseLoadingIndicator(
              text: L10n.get("loading"),
              rotationDuration: AppConfig.defaultHouseRotationDuration,
            ),
            loaded: (s) => widget.buildAchievementsList(
              context,
              s.achievements,
              s.unlockedIds,
            ),
            error: (e) => Center(child: Text(e.message)),
          );
        },
      ),
    );
  }
}

class _GamificationStats {
  _GamificationStats({
    required this.hasAccount,
    required this.profileCompletionPercent,
    required this.viewedListingsCount,
    required this.favoritesCount,
    required this.messagesSentCount,
    required this.listingsCreatedCount,
    required this.conversationsStartedCount,
  });

  final bool hasAccount;
  final int profileCompletionPercent;
  final int viewedListingsCount;
  final int favoritesCount;
  final int messagesSentCount;
  final int listingsCreatedCount;
  final int conversationsStartedCount;
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile({
    required this.achievement,
    required this.isUnlocked,
    required this.descriptionKey,
  });

  final Achievement achievement;
  final bool isUnlocked;
  final String descriptionKey;

  @override
  Widget build(BuildContext context) {
    final isLight = ThemeState().isLightTheme;
    final isBlueTheme = ThemeState().isBlueTheme;
    final badgeColor = isLight && isUnlocked
        ? Colors.transparent
        : (isUnlocked
            ? Theme.of(context).colorScheme.primaryContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest);
    final badgeBorder = isLight && isUnlocked
        ? Border.all(color: Colors.black, width: 2)
        : null;
    final iconColor = isLight && isUnlocked
        ? Colors.black
        : (isUnlocked
            ? (isBlueTheme ? Colors.white : Theme.of(context).colorScheme.primary)
            : (isBlueTheme ? Colors.white.withValues(alpha: 0.7) : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5)));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: badgeColor,
            shape: BoxShape.circle,
            border: badgeBorder,
          ),
          child: Icon(
            achievement.icon,
            color: iconColor,
          ),
        ),
        title: Text(
          L10n.get(achievement.key),
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isUnlocked
                ? Theme.of(context).colorScheme.onSurface
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        subtitle: Text(
          L10n.get(descriptionKey),
          style: TextStyle(
            color: isUnlocked
                ? Theme.of(context).colorScheme.onSurfaceVariant
                : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
          ),
        ),
        trailing: isUnlocked
            ? Icon(
                Icons.check_circle,
                color: isLight
                    ? Colors.black
                    : (isBlueTheme ? Colors.white : Theme.of(context).colorScheme.primary),
              )
            : Icon(
                Icons.lock_outline,
                color: isBlueTheme
                    ? Colors.white.withValues(alpha: 0.7)
                    : Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
      ),
    );
  }
}
