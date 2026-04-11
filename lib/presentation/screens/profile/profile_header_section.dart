import "package:cached_network_image/cached_network_image.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/constants/app_theme.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/profile_completion_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_tile_shell.dart";
import "package:uy_dosh/presentation/widgets/common/blinking_dot_widget.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/uydosh_link_button.dart";

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isBlueTheme = ThemeState().currentTheme == AppTheme.blueTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isBlueTheme ? BlueThemeColors.buttonPrimary : Colors.black,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}

class ProfileHeaderSection extends StatelessWidget {
  const ProfileHeaderSection({
    required this.profile,
    required this.cachedGoogleDisplayName,
    required this.cachedGooglePhotoUrl,
    required this.userRole,
    required this.userRoleLoaded,
    required this.userBlocked,
    required this.getRoleLabel,
    required this.onEditProfile,
    super.key,
  });

  final UserProfile profile;
  final String? cachedGoogleDisplayName;
  final String? cachedGooglePhotoUrl;
  final String? userRole;
  final bool userRoleLoaded;
  final bool userBlocked;
  final String Function(String? role) getRoleLabel;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    final isComplete = ProfileCompletionState.completionPercent(profile) >= 100;

    return Column(
      children: [
        Center(
          child: Column(
            children: [
              Stack(
                alignment: Alignment.bottomRight,
                children: [
                  _buildProfileAvatar(context),
                  if (userBlocked)
                    Tooltip(
                      message: L10n.get("admin_user_detail_blocked"),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Theme.of(context).colorScheme.surface,
                            width: 2,
                          ),
                        ),
                        child: const ThemeIcon(
                          Icons.block,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else if (isComplete)
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Theme.of(context).colorScheme.surface,
                          width: 2,
                        ),
                      ),
                      child: const ThemeIcon(
                        Icons.check,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                ],
              ),
              if (((profile.name ?? cachedGoogleDisplayName) ?? "")
                  .isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  profile.name ?? cachedGoogleDisplayName ?? "",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (userRoleLoaded) ...[
                const SizedBox(height: 4),
                _RoleBadge(
                  label: getRoleLabel(userRole),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (!isComplete) ...[
          _buildProfileCompletionCard(context, profile, isComplete),
          const SizedBox(height: 4),
        ] else ...[
          const SizedBox(height: 4),
        ],
      ],
    );
  }

  Widget _buildProfileAvatar(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(999)),
        gradient: ThreeDSurfaceStyle.surfaceGradient(context, surface),
        boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
      ),
      child: ClipOval(
        child: _buildProfilePicture(context),
      ),
    );
  }

  Widget _buildProfilePicture(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final photoUrl = cachedGooglePhotoUrl ?? currentUser?.photoURL;

    if (photoUrl != null) {
      return CachedNetworkImage(
        imageUrl: photoUrl,
        width: 100,
        height: 100,
        fit: BoxFit.cover,
        memCacheWidth: 200,
        memCacheHeight: 200,
        fadeInDuration: const Duration(milliseconds: 300),
        fadeInCurve: Curves.easeOut,
        placeholder:
            (context, url) => Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
        errorWidget:
            (context, url, error) => ThemeIcon(
              Icons.person,
              size: 50,
              color: Theme.of(context).colorScheme.onSurface,
            ),
      );
    }

    return Center(
      child: ThemeIcon(
        Icons.person,
        size: 50,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildProfileCompletionCard(
    BuildContext context,
    UserProfile profile,
    bool isComplete,
  ) {
    final completionPercent = ProfileCompletionState.completionPercent(profile);
    final completionFraction = completionPercent / 100;

    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        cardTheme: theme.cardTheme.copyWith(
          margin: EdgeInsets.zero,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          color: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      child: ListingDetailTileShell(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (!isComplete) ...[
                    const SizedBox(
                      width: 10,
                      height: 10,
                      child: BlinkingDotWidget(
                        color: Colors.green,
                        size: 10,
                        duration: Duration(milliseconds: 1000),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      L10n.get("profile_completion"),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (isComplete)
                    ThemeIcon(
                      Icons.check_circle,
                      size: 18,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                L10n.get("profile_completion_hint"),
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: completionFraction,
                  minHeight: 8,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).progressIndicatorTheme.color ??
                        Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "$completionPercent%",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              if (!userBlocked) ...[
                const SizedBox(height: 8),
                UydoshLinkButton(
                  text: L10n.get("complete_profile"),
                  onPressed: onEditProfile,
                  outlined: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
