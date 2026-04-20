import "package:cached_network_image/cached_network_image.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:image_cropper/image_cropper.dart";
import "package:image_picker/image_picker.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/constants/app_theme.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/profile_completion_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_tile_shell.dart";
import "package:uy_dosh/presentation/widgets/common/blinking_dot_widget.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
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

class ProfileHeaderSection extends StatefulWidget {
  const ProfileHeaderSection({
    required this.profile,
    required this.cachedGoogleDisplayName,
    required this.cachedGooglePhotoUrl,
    required this.userRole,
    required this.userRoleLoaded,
    required this.userBlocked,
    required this.getRoleLabel,
    required this.onEditProfile,
    required this.onAvatarUpdated,
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

  /// Invoked after a successful avatar upload so the parent can refresh
  /// cached profile data.
  final VoidCallback onAvatarUpdated;

  @override
  State<ProfileHeaderSection> createState() => _ProfileHeaderSectionState();
}

class _ProfileHeaderSectionState extends State<ProfileHeaderSection> {
  final ImagePicker _picker = ImagePicker();
  bool _uploadingAvatar = false;

  String? _effectiveAvatarUrl() {
    // Prefer the Google/Firebase photo while the user is signed in with
    // Google — it is always fresh. Fall back to whatever is stored on the
    // profile (custom upload, or a previously-backfilled Google URL) for
    // users who don't have an active Firebase photoURL (e.g. phone auth).
    return widget.cachedGooglePhotoUrl ??
        FirebaseAuth.instance.currentUser?.photoURL ??
        resolveAvatarUrl(widget.profile.avatarUrl);
  }

  Future<void> _pickAndUploadAvatar() async {
    if (_uploadingAvatar || widget.userBlocked) return;
    HapticFeedbackUtils.impact();

    XFile? picked;
    try {
      picked = await _picker.pickImage(
        source: ImageSource.gallery,
        // Pick near-original; the cropper will clamp final output.
        imageQuality: 95,
      );
    } catch (_) {
      if (!mounted) return;
      ToastTheme.showError(
        context,
        message: L10n.get("error_picking_photo"),
      );
      return;
    }

    if (picked == null) return;

    final cropped = await _cropToSquare(picked.path);
    if (cropped == null) return;

    setState(() => _uploadingAvatar = true);
    try {
      await getIt<IUserProfileService>().uploadAvatar(cropped);
      if (!mounted) return;
      ToastTheme.showSuccess(
        context,
        message: L10n.get("profile_photo_updated"),
      );
      widget.onAvatarUpdated();
    } catch (_) {
      if (!mounted) return;
      ToastTheme.showError(
        context,
        message: L10n.get("error_uploading_profile_photo"),
      );
    } finally {
      if (mounted) setState(() => _uploadingAvatar = false);
    }
  }

  /// Presents the native cropper (uCrop on Android, TOCropViewController on
  /// iOS) with a 1:1 lock so the cropped output always fills the circle
  /// avatar. Returns the path of the cropped file, or `null` if cancelled.
  Future<String?> _cropToSquare(String sourcePath) async {
    try {
      final theme = Theme.of(context);
      final toolbarTitle = L10n.get("crop_profile_photo");
      final result = await ImageCropper().cropImage(
        sourcePath: sourcePath,
        maxWidth: 1024,
        maxHeight: 1024,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 85,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: toolbarTitle,
            toolbarColor: theme.colorScheme.surface,
            toolbarWidgetColor: theme.colorScheme.onSurface,
            statusBarLight: theme.brightness == Brightness.light,
            backgroundColor: Colors.black,
            activeControlsWidgetColor: theme.colorScheme.primary,
            lockAspectRatio: true,
            hideBottomControls: true,
            cropStyle: CropStyle.circle,
            initAspectRatio: CropAspectRatioPreset.square,
            aspectRatioPresets: const [CropAspectRatioPreset.square],
          ),
          IOSUiSettings(
            title: toolbarTitle,
            doneButtonTitle: L10n.get("crop_done"),
            cancelButtonTitle: L10n.get("crop_cancel"),
            aspectRatioLockEnabled: true,
            resetAspectRatioEnabled: false,
            rotateButtonsHidden: true,
            aspectRatioPickerButtonHidden: true,
            cropStyle: CropStyle.circle,
            aspectRatioPresets: const [CropAspectRatioPreset.square],
          ),
        ],
      );
      return result?.path;
    } catch (_) {
      if (mounted) {
        ToastTheme.showError(
          context,
          message: L10n.get("error_picking_photo"),
        );
      }
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isComplete =
        ProfileCompletionState.completionPercent(widget.profile) >= 100;

    return Column(
      children: [
        Center(
          child: Column(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(child: _buildProfileAvatar(context)),
                    // Bottom-right: edit-avatar affordance (camera) for anyone
                    // who can upload; replaced by a block badge for blocked
                    // users. Hidden only while an upload is in flight.
                    if (widget.userBlocked)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Tooltip(
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
                        ),
                      )
                    else if (!_uploadingAvatar)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: _buildCameraBadge(context),
                      ),
                    // Top-right: profile-completion tick (only when 100%),
                    // so it doesn't collide with the edit affordance below.
                    if (!widget.userBlocked && isComplete)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Tooltip(
                          message: L10n.get("profile_completion"),
                          child: Container(
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
                        ),
                      ),
                  ],
                ),
              ),
              if (((widget.profile.name ?? widget.cachedGoogleDisplayName) ??
                      "")
                  .isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  widget.profile.name ?? widget.cachedGoogleDisplayName ?? "",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (widget.userRoleLoaded) ...[
                const SizedBox(height: 4),
                _RoleBadge(
                  label: widget.getRoleLabel(widget.userRole),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        if (!isComplete) ...[
          _buildProfileCompletionCard(context, widget.profile, isComplete),
          const SizedBox(height: 4),
        ] else ...[
          const SizedBox(height: 4),
        ],
      ],
    );
  }

  Widget _buildProfileAvatar(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final canUpload = !widget.userBlocked;

    return Semantics(
      button: canUpload,
      label: L10n.get("upload_profile_photo"),
      child: GestureDetector(
        onTap: canUpload ? _pickAndUploadAvatar : null,
        child: Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(999)),
            gradient: ThreeDSurfaceStyle.surfaceGradient(context, surface),
            boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
          ),
          child: ClipOval(
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildProfilePicture(context),
                if (_uploadingAvatar)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                    ),
                    child: const Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCameraBadge(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: L10n.get("upload_profile_photo"),
      child: GestureDetector(
        onTap: _pickAndUploadAvatar,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.colorScheme.surface,
              width: 2,
            ),
          ),
          child: const ThemeIcon(
            Icons.photo_camera,
            size: 18,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture(BuildContext context) {
    final photoUrl = _effectiveAvatarUrl();

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
    final missingKeys = ProfileCompletionState.getMissingFields(profile);
    final missingLabels = missingKeys
        .map(_labelForMissingProfileFieldKey)
        .toList()
      ..removeWhere((e) => e.trim().isEmpty);

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
              if (missingLabels.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  L10n.get("missing_fields_title"),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  missingLabels.join(", "),
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (!widget.userBlocked) ...[
                const SizedBox(height: 8),
                UydoshLinkButton(
                  text: L10n.get("complete_profile"),
                  onPressed: widget.onEditProfile,
                  outlined: true,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static String _labelForMissingProfileFieldKey(String key) {
    switch (key) {
      case "name":
        return L10n.get("name", fallback: "Name");
      case "gender":
        return L10n.get("gender", fallback: "Gender");
      case "region":
        return L10n.get("im_from", fallback: "Region");
      case "university":
        return L10n.get("university", fallback: "University");
      case "aboutMe":
        return L10n.get("about_me", fallback: "About me");
      case "telegram":
        return L10n.get("telegram", fallback: "Telegram");
      case "employed":
        return L10n.get("employed", fallback: "Employed");
      case "cleanliness":
        return L10n.get("cleanliness", fallback: "Cleanliness");
      case "noiseLevel":
        return L10n.get("noise_level", fallback: "Noise level");
      case "sociability":
        return L10n.get("sociability", fallback: "Sociability");
      case "guestsAllowed":
        return L10n.get("guests_allowed", fallback: "Guests allowed");
      case "smokingPreference":
        return L10n.get("smoking_preference", fallback: "Smoking");
      case "alcoholPreference":
        return L10n.get("alcohol_preference", fallback: "Alcohol");
      case "cookingHabits":
        return L10n.get("cooking_habits", fallback: "Cooking habits");
      case "petsPreference":
        return L10n.get("pets_preference", fallback: "Pets preference");
      case "wakeupTime":
        return L10n.get("wakeup_time", fallback: "Wake-up time");
      case "sleepTime":
        return L10n.get("sleep_time", fallback: "Sleep time");
      default:
        return key;
    }
  }
}
