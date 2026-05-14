import "package:cached_network_image/cached_network_image.dart";
import "package:firebase_auth/firebase_auth.dart";
import "package:flutter/material.dart";
import "package:image_picker/image_picker.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/price_display_settings_state.dart";
import "package:uy_dosh/base/services/listing_photo_cropper.dart";
import "package:uy_dosh/base/state/profile_completion_state.dart";
import "package:uy_dosh/base/utils/avatar_url_utils.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/presentation/screens/listing_detail/widgets/listing_detail_tile_shell.dart";
import "package:uy_dosh/presentation/widgets/common/pressable_transform.dart";
import "package:uy_dosh/presentation/widgets/common/neumorphic_blinking_dot.dart";
import "package:uy_dosh/presentation/widgets/common/profile_role_badge.dart";
import "package:uy_dosh/presentation/widgets/common/swipe_dismissible_sheet.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";
import "package:uy_dosh/presentation/widgets/uydosh_link_button.dart";

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
    // A custom upload is stored as a relative backend path
    // (e.g. /images/avatars/avatar_42_xxx.jpg). Treat that as the source of
    // truth so the avatar refreshes immediately after the user uploads a new
    // photo — otherwise the Google/Firebase URL below wins and the new image
    // never shows up here, even though the backend has it. Google avatars
    // come back as absolute https URLs and fall through to the Firebase
    // path, which keeps them fresh for users who haven't customized.
    final raw = widget.profile.avatarUrl?.trim();
    final hasCustomUpload = raw != null &&
        raw.isNotEmpty &&
        !raw.startsWith("http://") &&
        !raw.startsWith("https://");
    if (hasCustomUpload) {
      return resolveAvatarUrl(raw);
    }
    return widget.cachedGooglePhotoUrl ??
        FirebaseAuth.instance.currentUser?.photoURL ??
        resolveAvatarUrl(raw);
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

  /// Opens the UyDosh-styled crop screen tuned for avatars (1:1 circular
  /// preview, no listing watermark, 1024px output cap). Returns the path of
  /// the cropped file, or `null` if cancelled.
  Future<String?> _cropToSquare(String sourcePath) async {
    try {
      return await cropProfileAvatar(context, sourcePath);
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
                  ],
                ),
              ),
              if (((widget.profile.name ?? widget.cachedGoogleDisplayName) ??
                      "")
                  .isNotEmpty) ...[
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: "#${widget.profile.userId}",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant
                              .withValues(alpha: 0.72),
                        ),
                      ),
                      WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: SizedBox(
                            width: 4,
                            height: 4,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withValues(alpha: 0.45),
                              ),
                            ),
                          ),
                        ),
                      ),
                      TextSpan(
                        text: widget.profile.name ??
                            widget.cachedGoogleDisplayName ??
                            "",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              if (widget.userRoleLoaded) ...[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.center,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.userRole == "admin")
                          _buildAdminShieldBadge(context)
                        else
                          ProfileRoleNeumorphicBadge(
                            label: widget.getRoleLabel(widget.userRole),
                          ),
                        const SizedBox(width: 8),
                        ListenableBuilder(
                          listenable: Listenable.merge([
                            LanguageState(),
                            PriceDisplaySettingsState(),
                          ]),
                          builder: (context, _) =>
                              _buildPreferencesChip(context),
                        ),
                      ],
                    ),
                  ),
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

  /// Compact staff indicator so the header row stays calm next to preferences.
  Widget _buildAdminShieldBadge(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final label = widget.getRoleLabel(widget.userRole);
    return Tooltip(
      message: label,
      child: Semantics(
        label: label,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: scheme.surfaceContainerHighest.withValues(alpha: 0.42),
            border: Border.all(
              color: scheme.outline.withValues(alpha: 0.28),
            ),
          ),
          alignment: Alignment.center,
          child: ThemeIcon(
            Icons.shield_outlined,
            size: 18,
            color: scheme.onSurfaceVariant.withValues(alpha: 0.88),
          ),
        ),
      ),
    );
  }

  Widget _buildPreferencesChip(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final bg = theme.cardTheme.color ?? scheme.surface;

    return Tooltip(
      message: L10n.get("settings_section_preferences"),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedbackUtils.impact();
          _showProfilePreferencesSheet(context);
        },
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: ThreeDSurfaceStyle.surfaceGradient(context, bg),
            boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ThemeIcon(
                  Icons.tune,
                  size: 18,
                  color: scheme.onSurface.withValues(alpha: 0.85),
                ),
                const SizedBox(width: 6),
                Text(
                  L10n.get("settings_section_preferences"),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    height: 1.25,
                    letterSpacing: 0.15,
                    color: scheme.onSurface,
                  ),
                ),
                const SizedBox(width: 2),
                ThemeIcon(
                  Icons.keyboard_arrow_down,
                  size: 18,
                  color: scheme.onSurface.withValues(alpha: 0.75),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showProfilePreferencesSheet(BuildContext context) async {
    await showAppBottomSheet<void>(
      context: context,
      showDragHandle: true,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (sheetContext) {
        final scheme = Theme.of(sheetContext).colorScheme;
        final surface = scheme.surface;
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            gradient: ThreeDSurfaceStyle.surfaceGradient(sheetContext, surface),
            boxShadow: ThreeDSurfaceStyle.elevatedShadows(sheetContext),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
              child: ListenableBuilder(
                listenable: Listenable.merge([
                  LanguageState(),
                  PriceDisplaySettingsState(),
                ]),
                builder: (context, _) {
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            L10n.get("settings_section_preferences"),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              height: 1.25,
                              leadingDistribution: TextLeadingDistribution.even,
                              color: scheme.onSurface,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          L10n.get("language"),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.15,
                            height: 1.2,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: LanguagePickerOptionTile(
                                code: "uz",
                                popNavigatorOnSelect: false,
                                segmentSlot: true,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LanguagePickerOptionTile(
                                code: "ru",
                                popNavigatorOnSelect: false,
                                segmentSlot: true,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LanguagePickerOptionTile(
                                code: "en",
                                popNavigatorOnSelect: false,
                                segmentSlot: true,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          L10n.get("price_display_currency"),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.15,
                            height: 1.2,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Expanded(
                              child: _PriceDisplayCurrencyPickerOption(
                                currency: PriceDisplayCurrency.national,
                                popNavigatorOnSelect: false,
                                segmentSlot: true,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _PriceDisplayCurrencyPickerOption(
                                currency: PriceDisplayCurrency.usd,
                                popNavigatorOnSelect: false,
                                segmentSlot: true,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
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
    final orderedMissingKeys = _orderMissingProfileFieldKeys(missingKeys);
    final missingLabels = orderedMissingKeys
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
                    const NeumorphicBlinkingDot(size: 10),
                    const SizedBox(width: 6),
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
        return L10n.get("work", fallback: "Work");
      case "cleanliness":
        return L10n.get("cleanliness", fallback: "Cleanliness");
      case "noiseLevel":
        return L10n.get("noise_level", fallback: "Noise level");
      case "sociability":
        return L10n.get("sociability", fallback: "Sociability");
      case "guestsAllowed":
        return L10n.get("guests", fallback: "Guests");
      case "smokingPreference":
        return L10n.get("smoking_preference", fallback: "Smoking");
      case "alcoholPreference":
        return L10n.get("alcohol_preference", fallback: "Alcohol");
      case "cookingHabits":
        return L10n.get("cooking_habits", fallback: "Cooking");
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

  /// Order missing fields in the same sequence as Edit Profile controls.
  static List<String> _orderMissingProfileFieldKeys(List<String> keys) {
    const order = <String>[
      // Basic info (top of edit profile screen)
      "name",
      "gender",
      "region",
      "university",
      "aboutMe",
      "telegram",

      // Lifestyle section (as shown in edit profile screen)
      "employed",
      "wakeupTime",
      "sleepTime",
      "cleanliness",
      "noiseLevel",
      "sociability",
      "guestsAllowed",
      "smokingPreference",
      "alcoholPreference",
      "cookingHabits",
      "petsPreference",
    ];

    final rank = <String, int>{};
    for (var i = 0; i < order.length; i++) {
      rank[order[i]] = i;
    }

    final sorted = [...keys];
    sorted.sort((a, b) {
      final ra = rank[a];
      final rb = rank[b];
      if (ra == null && rb == null) return a.compareTo(b);
      if (ra == null) return 1;
      if (rb == null) return -1;
      return ra.compareTo(rb);
    });
    return sorted;
  }
}

class _PriceDisplayCurrencyPickerOption extends StatelessWidget {
  const _PriceDisplayCurrencyPickerOption({
    required this.currency,
    this.popNavigatorOnSelect = true,
    this.segmentSlot = false,
  });

  final PriceDisplayCurrency currency;

  /// When embedded in a bottom sheet, avoid popping the sheet on each tap.
  final bool popNavigatorOnSelect;

  /// Compact cell for a horizontal segment row (profile preferences sheet).
  final bool segmentSlot;

  @override
  Widget build(BuildContext context) {
    if (segmentSlot) {
      return _buildSegmentSlot(context);
    }
    final isCurrent = PriceDisplaySettingsState().currency == currency;
    final scheme = Theme.of(context).colorScheme;
    final surface = scheme.surface;
    final labelKey = currency == PriceDisplayCurrency.usd
        ? "price_display_currency_usd"
        : "price_display_currency_national";
    final radius = 14.0;
    final borderRadius = BorderRadius.circular(radius);
    const hPad = 16.0;
    const vPad = 14.0;
    const titleSize = 16.0;
    const checkSize = 22.0;

    return PressableTransform(
      feedback: PressableFeedback.selection,
      onTap: () {
        if (popNavigatorOnSelect) Navigator.pop(context);
        PriceDisplaySettingsState().setCurrency(currency);
      },
      borderRadius: borderRadius,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          gradient: ThreeDSurfaceStyle.surfaceGradient(context, surface),
          boxShadow: isCurrent
              ? ThreeDSurfaceStyle.insetRecessedShadows(context)
              : ThreeDSurfaceStyle.neumorphicSoftRaisedShadows(context),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                L10n.get(labelKey),
                style: TextStyle(
                  fontSize: titleSize,
                  height: 1.2,
                  fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  color: scheme.onSurface,
                ),
              ),
            ),
            if (isCurrent)
              ThemeIcon(Icons.check, color: scheme.onSurface, size: checkSize),
          ],
        ),
      ),
    );
  }

  Widget _buildSegmentSlot(BuildContext context) {
    final isCurrent = PriceDisplaySettingsState().currency == currency;
    final scheme = Theme.of(context).colorScheme;
    final surface = scheme.surface;
    final labelKey = currency == PriceDisplayCurrency.usd
        ? "price_display_currency_usd"
        : "price_display_currency_national";
    final shortCode =
        currency == PriceDisplayCurrency.usd ? "USD" : "UZS";
    const borderRadius = BorderRadius.all(Radius.circular(12));

    return Tooltip(
      message: L10n.get(labelKey),
      child: PressableTransform(
        feedback: PressableFeedback.selection,
        onTap: () {
          if (popNavigatorOnSelect) Navigator.pop(context);
          PriceDisplaySettingsState().setCurrency(currency);
        },
        borderRadius: borderRadius,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            gradient: ThreeDSurfaceStyle.surfaceGradient(context, surface),
            boxShadow: isCurrent
                ? ThreeDSurfaceStyle.insetRecessedShadows(context)
                : ThreeDSurfaceStyle.neumorphicSoftRaisedShadows(context),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _segmentLeading(scheme.onSurface),
                  const SizedBox(height: 6),
                  Text(
                    shortCode,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.1,
                      fontWeight:
                          isCurrent ? FontWeight.w700 : FontWeight.w600,
                      letterSpacing: 0.2,
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
              if (isCurrent)
                Positioned(
                  top: -2,
                  right: -2,
                  child: ThemeIcon(
                    Icons.check_circle,
                    color: scheme.primary,
                    size: 18,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _segmentLeading(Color onSurface) {
    return switch (currency) {
      PriceDisplayCurrency.usd => Text(
        r"$",
        style: TextStyle(
          fontSize: 26,
          height: 1.05,
          fontWeight: FontWeight.w700,
          color: onSurface,
        ),
      ),
      PriceDisplayCurrency.national => const Text(
        "🇺🇿",
        style: TextStyle(fontSize: 26, height: 1.05),
        textAlign: TextAlign.center,
      ),
    };
  }
}
