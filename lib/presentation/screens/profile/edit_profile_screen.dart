import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/profile_completion_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/send_sound_utils.dart";
import "package:uy_dosh/domain/models/auth/update_profile_request.dart";
import "package:uy_dosh/domain/models/region.dart";
import "package:uy_dosh/domain/models/university.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/domain/services/region_service.dart";
import "package:uy_dosh/domain/services/university_service.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/presentation/widgets/common/gender_picker.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/profile_dropdown_control.dart";
import "package:uy_dosh/presentation/widgets/common/profile_slider_control.dart";
import "package:uy_dosh/presentation/widgets/common/profile_toggle_control.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({required this.profile, super.key});

  final UserProfile profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _aboutMeController;
  late TextEditingController _telegramController;

  // Form state as ValueNotifiers - only the relevant widget rebuilds on change
  late ValueNotifier<int> _selectedGender;
  late ValueNotifier<int?> _selectedRegionId;
  late ValueNotifier<int?> _selectedUniversityId;
  late ValueNotifier<bool> _isStudent;
  late ValueNotifier<String> _selectedLanguage;
  late ValueNotifier<String> _selectedRole;
  late ValueNotifier<bool?> _employed;
  late ValueNotifier<int?> _cleanliness;
  late ValueNotifier<int?> _noiseLevel;
  late ValueNotifier<int?> _sociability;
  late ValueNotifier<bool?> _guestsAllowed;
  late ValueNotifier<String?> _smokingPreference;
  late ValueNotifier<String?> _alcoholPreference;
  late ValueNotifier<bool?> _cookingHabits;
  late ValueNotifier<String?> _petsPreference;
  late ValueNotifier<String?> _wakeupTime;
  late ValueNotifier<String?> _sleepTime;

  List<Region> _regions =
      []; // Initialize to empty list to avoid LateInitializationError
  List<University> _universities =
      []; // Initialize to empty list to avoid LateInitializationError
  late ValueNotifier<bool> _isLoading;
  late ValueNotifier<bool> _isLoadingRegions;
  late ValueNotifier<bool> _isLoadingUniversities;
  bool _isAdmin = false;
  late ValueNotifier<bool> _isRoleLoaded;

  // Scroll controllers for wheel pickers
  FixedExtentScrollController? _regionScrollController;
  FixedExtentScrollController? _universityScrollController;

  /// Role as loaded from session (baseline for dirty check).
  String? _baselineRole;

  late final Listenable _formListenables;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.profile.name ?? "");
    _aboutMeController = TextEditingController(
      text: widget.profile.aboutMe ?? "",
    );
    _telegramController = TextEditingController(
      text: widget.profile.telegram ?? "",
    );

    _selectedGender = ValueNotifier(widget.profile.gender ?? 1);
    _selectedRegionId = ValueNotifier(widget.profile.regionId);
    _selectedUniversityId = ValueNotifier(widget.profile.universityId);
    _isStudent = ValueNotifier(widget.profile.universityId != null);
    _selectedLanguage = ValueNotifier(
      widget.profile.preferredLanguage ?? LanguageState().currentLanguage,
    );
    _selectedRole = ValueNotifier("tenant");
    _employed = ValueNotifier(widget.profile.employed);
    _cleanliness = ValueNotifier(widget.profile.cleanliness);
    _noiseLevel = ValueNotifier(widget.profile.noiseLevel);
    _sociability = ValueNotifier(widget.profile.sociability);
    _guestsAllowed = ValueNotifier(widget.profile.guestsAllowed);
    _smokingPreference = ValueNotifier(widget.profile.smokingPreference);
    _alcoholPreference = ValueNotifier(widget.profile.alcoholPreference);
    _cookingHabits = ValueNotifier(widget.profile.cookingHabits);
    _petsPreference = ValueNotifier(widget.profile.petsPreference);
    _wakeupTime = ValueNotifier(widget.profile.wakeupTime);
    _sleepTime = ValueNotifier(widget.profile.sleepTime);
    _isLoading = ValueNotifier(false);
    _isLoadingRegions = ValueNotifier(true);
    _isLoadingUniversities = ValueNotifier(true);
    _isRoleLoaded = ValueNotifier(false);

    _formListenables = Listenable.merge([
      _nameController,
      _aboutMeController,
      _telegramController,
      _selectedGender,
      _selectedRegionId,
      _selectedUniversityId,
      _isStudent,
      _selectedLanguage,
      _selectedRole,
      _employed,
      _cleanliness,
      _noiseLevel,
      _sociability,
      _guestsAllowed,
      _smokingPreference,
      _alcoholPreference,
      _cookingHabits,
      _petsPreference,
      _wakeupTime,
      _sleepTime,
      _isRoleLoaded,
    ]);

    _loadRegions();
    _loadUniversities();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final role = await SessionManager.getUserRole();
    if (mounted) {
      _isAdmin = role == "admin";
      final resolved =
          (role == "admin" || role == "landlord") ? role! : "tenant";
      _selectedRole.value = resolved;
      _baselineRole = resolved;
      _isRoleLoaded.value = true;
    }
  }

  String _normText(String? s) => (s ?? "").trim();

  List<String> _computeChangedFieldLabels() {
    final p = widget.profile;
    final changed = <String>[];

    void addLabel(String key, {String? fallback}) {
      var label = L10n.get(key, fallback: fallback).trim();
      label = label.replaceAll(RegExp(r":\s*$"), "").trim();
      if (label.isEmpty) return;
      changed.add(label);
    }

    if (_nameController.text.trim() != (p.name ?? "").trim()) {
      addLabel("name", fallback: "Name");
    }
    if (_normText(_aboutMeController.text) != _normText(p.aboutMe)) {
      addLabel("about_me", fallback: "About me");
    }
    if (_normText(_telegramController.text) != _normText(p.telegram)) {
      addLabel("telegram", fallback: "Telegram");
    }
    if (_selectedGender.value != (p.gender ?? 1)) {
      addLabel("gender", fallback: "Gender");
    }
    if (_selectedRegionId.value != _resolvedRegionIdFromProfile()) {
      addLabel("im_from", fallback: "Region");
    }

    final baselineStudent = p.universityId != null;
    if (_isStudent.value != baselineStudent) {
      addLabel("are_you_student", fallback: "Student");
    }

    final effectiveUni = _isStudent.value ? _selectedUniversityId.value : null;
    if (effectiveUni != _resolvedUniversityIdFromProfile()) {
      addLabel("university", fallback: "University");
    }

    final langBaseline = p.preferredLanguage ?? LanguageState().currentLanguage;
    if (_selectedLanguage.value != langBaseline) {
      addLabel("language", fallback: "Language");
    }

    if (_isRoleLoaded.value) {
      final br = _baselineRole;
      if (br != null && _selectedRole.value != br) {
        addLabel("are_you_landlord_or_renter", fallback: "Role");
      }
    }

    if (p.employed != _employed.value) addLabel("employed", fallback: "Employed");
    if (p.wakeupTime != _wakeupTime.value) addLabel("wakeup_time", fallback: "Wake-up time");
    if (p.sleepTime != _sleepTime.value) addLabel("sleep_time", fallback: "Sleep time");
    if (p.cleanliness != _cleanliness.value) addLabel("cleanliness", fallback: "Cleanliness");
    if (p.noiseLevel != _noiseLevel.value) addLabel("noise_level", fallback: "Noise level");
    if (p.sociability != _sociability.value) addLabel("sociability", fallback: "Sociability");
    if (p.guestsAllowed != _guestsAllowed.value) addLabel("guests_allowed", fallback: "Guests");
    if (p.smokingPreference != _smokingPreference.value) {
      addLabel("smoking_preference", fallback: "Smoking");
    }
    if (p.alcoholPreference != _alcoholPreference.value) {
      addLabel("alcohol_preference", fallback: "Alcohol");
    }
    if (p.cookingHabits != _cookingHabits.value) {
      addLabel("cooking_habits", fallback: "Cooking");
    }
    if (p.petsPreference != _petsPreference.value) {
      addLabel("pets_preference", fallback: "Pets");
    }

    return changed;
  }

  int? _resolvedRegionIdFromProfile() {
    final id = widget.profile.regionId;
    if (id == null) return null;
    if (_regions.isEmpty) return id;
    return _regions.any((r) => r.id == id) ? id : null;
  }

  int? _resolvedUniversityIdFromProfile() {
    final id = widget.profile.universityId;
    if (id == null) return null;
    if (_universities.isEmpty) return id;
    return _universities.any((u) => u.id == id) ? id : null;
  }

  bool _isFormDirty() {
    final p = widget.profile;
    if (_nameController.text.trim() != (p.name ?? "").trim()) return true;
    if (_normText(_aboutMeController.text) != _normText(p.aboutMe)) {
      return true;
    }
    if (_normText(_telegramController.text) != _normText(p.telegram)) {
      return true;
    }
    if (_selectedGender.value != (p.gender ?? 1)) return true;
    if (_selectedRegionId.value != _resolvedRegionIdFromProfile()) {
      return true;
    }

    final baselineStudent = p.universityId != null;
    if (_isStudent.value != baselineStudent) return true;

    final effectiveUni = _isStudent.value ? _selectedUniversityId.value : null;
    if (effectiveUni != _resolvedUniversityIdFromProfile()) return true;

    final langBaseline = p.preferredLanguage ?? LanguageState().currentLanguage;
    if (_selectedLanguage.value != langBaseline) return true;

    if (_isRoleLoaded.value) {
      final br = _baselineRole;
      if (br != null && _selectedRole.value != br) return true;
    }

    if (p.employed != _employed.value) return true;
    if (p.cleanliness != _cleanliness.value) return true;
    if (p.noiseLevel != _noiseLevel.value) return true;
    if (p.sociability != _sociability.value) return true;
    if (p.guestsAllowed != _guestsAllowed.value) return true;
    if (p.smokingPreference != _smokingPreference.value) return true;
    if (p.alcoholPreference != _alcoholPreference.value) return true;
    if (p.cookingHabits != _cookingHabits.value) return true;
    if (p.petsPreference != _petsPreference.value) return true;
    if (p.wakeupTime != _wakeupTime.value) return true;
    if (p.sleepTime != _sleepTime.value) return true;

    return false;
  }

  Future<void> _onPopInvoked(bool didPop, dynamic result) async {
    if (didPop) return;
    final changedFields = _computeChangedFieldLabels();
    final leave = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        final changedPrefix = L10n.get("changed_fields");
        final bullet = "•";
        final contentText = changedFields.isEmpty
            ? L10n.get("unsaved_changes_message")
            : "${L10n.get("unsaved_changes_message")}\n\n$changedPrefix:\n$bullet ${changedFields.join("\n$bullet ")}";
        return AlertDialog(
          backgroundColor: theme.dialogTheme.backgroundColor,
          title: Text(
            L10n.get("unsaved_changes_title"),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          content: Text(
            contentText,
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(L10n.get("keep_editing")),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
              child: Text(L10n.get("leave_without_saving")),
            ),
          ],
        );
      },
    );
    if (!mounted || !(leave ?? false)) return;
    Navigator.of(context).pop(result);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutMeController.dispose();
    _telegramController.dispose();
    _selectedGender.dispose();
    _selectedRegionId.dispose();
    _selectedUniversityId.dispose();
    _isStudent.dispose();
    _selectedLanguage.dispose();
    _selectedRole.dispose();
    _employed.dispose();
    _cleanliness.dispose();
    _noiseLevel.dispose();
    _sociability.dispose();
    _guestsAllowed.dispose();
    _smokingPreference.dispose();
    _alcoholPreference.dispose();
    _cookingHabits.dispose();
    _petsPreference.dispose();
    _wakeupTime.dispose();
    _sleepTime.dispose();
    _isLoading.dispose();
    _isLoadingRegions.dispose();
    _isLoadingUniversities.dispose();
    _isRoleLoaded.dispose();
    _regionScrollController?.dispose();
    _universityScrollController?.dispose();
    super.dispose();
  }

  Future<void> _loadRegions() async {
    try {
      final regionService = getIt<IRegionService>();
      final regions = await regionService.getRegions();

      // Sort regions alphabetically by their localized names
      final currentLanguage = LanguageState().currentLanguage;
      regions.sort((a, b) {
        final nameA = a.getLocalizedName(currentLanguage);
        final nameB = b.getLocalizedName(currentLanguage);
        return nameA.compareTo(nameB);
      });

      setState(() => _regions = regions);
      _isLoadingRegions.value = false;

      // Set the selected region based on the profile's regionId
      if (widget.profile.regionId != null) {
        final regionExists = regions.any(
          (region) => region.id == widget.profile.regionId,
        );
        _selectedRegionId.value = regionExists ? widget.profile.regionId : null;
      } else {
        _selectedRegionId.value = null;
      }

      // Initialize scroll controller after regions are loaded
      _initializeRegionScrollController();
    } catch (e) {
      _isLoadingRegions.value = false;
      if (mounted) {
        ToastTheme.showError(
          context,
          message: L10n.get(
            "error_loading_regions",
          ).replaceAll("{error}", e.toString()),
        );
      }
    }
  }

  void _initializeRegionScrollController() {
    if (_regions.isNotEmpty) {
      final initialItem = _getInitialRegionItem();
      _regionScrollController?.dispose();
      _regionScrollController = FixedExtentScrollController(
        initialItem: initialItem,
      );
      setState(() {}); // Trigger rebuild to use new scroll controller
    }
  }

  Future<void> _loadUniversities() async {
    try {
      final universityService = getIt<IUniversityService>();
      final universities = await universityService.getUniversities();
      setState(() => _universities = universities);
      _isLoadingUniversities.value = false;

      // Initialize scroll controller after universities are loaded
      _initializeUniversityScrollController();
    } catch (e) {
      _isLoadingUniversities.value = false;
      if (mounted) {
        ToastTheme.showError(
          context,
          message: L10n.get(
            "error_loading_universities",
          ).replaceAll("{error}", e.toString()),
        );
      }
    }
  }

  void _initializeUniversityScrollController() {
    if (_universities.isNotEmpty) {
      final initialItem = _getInitialUniversityItem();
      _universityScrollController?.dispose();
      _universityScrollController = FixedExtentScrollController(
        initialItem: initialItem,
      );
      setState(() {}); // Trigger rebuild to use new scroll controller
    }
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ToastTheme.showError(
        context,
        message: L10n.get("name_required"),
      );
      return;
    }

    _isLoading.value = true;

    try {
      // Validate and prepare the data
      final name = _nameController.text.trim();
      final gender = _selectedGender.value;
      final regionId = _selectedRegionId.value;

      // If user is a student, require university selection
      if (_isStudent.value && _selectedUniversityId.value == null) {
        ToastTheme.showError(
          context,
          message: L10n.get("please_select_university"),
        );
        _isLoading.value = false;
        return;
      }

      final universityId =
          _isStudent.value ? _selectedUniversityId.value : null;

      // Handle about me text: if it's empty, send null to clear it; if it has content, send the content
      final aboutMe = _aboutMeController.text.trim();
      final aboutMeToSend = aboutMe.isEmpty ? null : aboutMe;

      // Handle telegram text: if it's empty, send null to clear it; if it has content, send the content
      final telegram = _telegramController.text.trim();
      final telegramToSend = telegram.isEmpty ? null : telegram;

      // Preserve admin role: check actual role at save time to avoid overwriting
      // when dropdown wasn't loaded yet (race condition)
      final currentRole = await SessionManager.getUserRole();
      final roleToSave =
          (currentRole == "admin") ? "admin" : _selectedRole.value;

      final updateRequest = UpdateProfileRequest(
        name: name,
        gender: gender,
        regionId: regionId,
        universityId: universityId,
        role: roleToSave,
        aboutMe: aboutMeToSend,
        telegram: telegramToSend,
        employed: _employed.value,
        cleanliness: _cleanliness.value,
        noiseLevel: _noiseLevel.value,
        sociability: _sociability.value,
        guestsAllowed: _guestsAllowed.value,
        smokingPreference: _smokingPreference.value,
        alcoholPreference: _alcoholPreference.value,
        cookingHabits: _cookingHabits.value,
        petsPreference: _petsPreference.value,
        wakeupTime: _wakeupTime.value,
        sleepTime: _sleepTime.value,
        preferredLanguage: _selectedLanguage.value,
      );

      // Debug logging to see what values are being sent
      logger.d("🔍 [EditProfileScreen] Update request values:");
      logger.d("  - telegram: $telegramToSend");
      logger.d("  - smokingPreference: ${_smokingPreference.value}");
      logger.d("  - alcoholPreference: ${_alcoholPreference.value}");
      logger.d("  - wakeupTime: ${_wakeupTime.value}");
      logger.d("  - sleepTime: ${_sleepTime.value}");
      logger.d("  - employed: ${_employed.value}");
      logger.d("  - cleanliness: ${_cleanliness.value}");
      logger.d("  - noiseLevel: ${_noiseLevel.value}");
      logger.d("  - sociability: ${_sociability.value}");
      logger.d("  - guestsAllowed: ${_guestsAllowed.value}");
      logger.d("  - cookingHabits: ${_cookingHabits.value}");
      logger.d("  - petsPreference: ${_petsPreference.value}");

      // Also log the JSON that will be sent
      final requestJson = updateRequest.toJson();
      logger.d("🔍 [EditProfileScreen] JSON being sent:");
      logger.d(requestJson);

      final userProfileService = getIt<IUserProfileService>();
      final updatedProfile = await userProfileService.updateProfile(
        updateRequest,
      );

      if (mounted) {
        ToastTheme.showSuccess(
          context,
          message: L10n.get(
            "profile_updated_success",
          ),
        );

        await SessionManager.storeUserRole(roleToSave);
        await SessionManager.storeUserProfile(updatedProfile);
        ProfileCompletionState().updateFromProfile(updatedProfile);

        Navigator.of(context).pop(true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ToastTheme.showError(
          context,
          message: L10n.get(
            "error_updating_profile",
          ).replaceAll("{error}", e.toString()),
        );
      }
    } finally {
      if (mounted) {
        _isLoading.value = false;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: _formListenables,
      builder: (context, _) {
        return PopScope(
          canPop: !_isFormDirty(),
          onPopInvokedWithResult: _onPopInvoked,
          child: Scaffold(
            appBar: UydoshAppBar(
              leading: ThreeDAppBarIconButton.backLeading(context),
              title: Text(
                L10n.get("edit_profile"),
                style: theme.appBarTheme.titleTextStyle,
              ),
              backgroundColor: theme.appBarTheme.backgroundColor ??
                  theme.colorScheme.primary,
              foregroundColor: theme.appBarTheme.foregroundColor ??
                  theme.colorScheme.onPrimary,
              elevation: 0,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: _isLoading,
                    builder: (context, isLoading, _) => IconButton(
                      onPressed: isLoading ? null : _saveProfile,
                      icon: isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.appBarTheme.foregroundColor ??
                                      theme.colorScheme.onPrimary,
                                ),
                              ),
                            )
                          : const ThemeIcon(Icons.save),
                      tooltip: L10n.get(
                        "save_changes",
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name Field
                  _buildTextField(
                    label: L10n.get("name"),
                    controller: _nameController,
                    icon: Icons.person,
                  ),

                  const SizedBox(height: 24),

                  // Gender Selector
                  _buildGenderSelector(context),

                  const SizedBox(height: 24),

                  // Region Selector
                  _buildRegionSelector(context),

                  const SizedBox(height: 24),

                  // Student status (like onboarding wizard)
                  _buildStudentSelector(context),

                  // University Selector (only show when user selects "I'm a student")
                  ValueListenableBuilder<bool>(
                    valueListenable: _isStudent,
                    builder: (context, isStudent, _) => isStudent
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 24),
                              _buildUniversitySelector(context),
                            ],
                          )
                        : const SizedBox.shrink(),
                  ),

                  const SizedBox(height: 24),

                  // About Me Field
                  _buildTextField(
                    label: L10n.get("about_me"),
                    controller: _aboutMeController,
                    icon: Icons.info,
                    maxLines: 3,
                  ),

                  const SizedBox(height: 24),

                  // Telegram Field
                  _buildTextField(
                    label: L10n.get("telegram"),
                    controller: _telegramController,
                    icon: Icons.telegram,
                  ),

                  const SizedBox(height: 24),

                  // Language (visible to other users - what language you speak)
                  ValueListenableBuilder<String>(
                    valueListenable: _selectedLanguage,
                    builder: (context, selectedLanguage, _) =>
                        ProfileDropdownControl(
                      label: L10n.get("language"),
                      value: selectedLanguage,
                      onChanged: (value) {
                        if (value != null) {
                          _selectedLanguage.value = value;
                          LanguageState().setLanguage(value);
                        }
                      },
                      icon: CupertinoIcons.globe,
                      options: const [
                        DropdownOption(value: "uz", label: "🇺🇿 O'zbekcha"),
                        DropdownOption(value: "ru", label: "🇷🇺 Русский"),
                        DropdownOption(value: "en", label: "🇺🇸 English"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Role Dropdown (landlord / tenant; admin option when user is admin)
                  ValueListenableBuilder<bool>(
                    valueListenable: _isRoleLoaded,
                    builder: (context, isRoleLoaded, _) => isRoleLoaded
                        ? ValueListenableBuilder<String>(
                            valueListenable: _selectedRole,
                            builder: (context, selectedRole, _) =>
                                ProfileDropdownControl(
                              label: L10n.get(
                                "are_you_landlord_or_renter",
                              ),
                              value: selectedRole,
                              onChanged: (value) =>
                                  _selectedRole.value = value ?? "tenant",
                              icon: Icons.badge,
                              options: [
                                if (_isAdmin)
                                  DropdownOption(
                                    value: "admin",
                                    label: L10n.get(
                                      "role_admin",
                                    ),
                                  ),
                                DropdownOption(
                                  value: "landlord",
                                  label: L10n.get(
                                    "role_landlord",
                                  ),
                                ),
                                DropdownOption(
                                  value: "tenant",
                                  label: L10n.get(
                                    "role_tenant",
                                  ),
                                ),
                              ],
                            ),
                          )
                        : _buildRoleLoadingPlaceholder(context),
                  ),

                  const SizedBox(height: 24),

                  // New Profile Fields Section
                  Text(
                    L10n.get(
                      "lifestyle_preferences",
                    ),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: _getLifestyleHeaderColor(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Employed Toggle
                  ValueListenableBuilder<bool?>(
                    valueListenable: _employed,
                    builder: (context, employed, _) => ProfileToggleControl(
                      label: L10n.get("employed"),
                      value: employed,
                      onChanged: (value) => _employed.value = value,
                      icon: Icons.work,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Wake-up Time Dropdown
                  ValueListenableBuilder<String?>(
                    valueListenable: _wakeupTime,
                    builder: (context, wakeupTime, _) => ProfileDropdownControl(
                      label: L10n.get(
                        "wakeup_time",
                      ),
                      value: wakeupTime,
                      onChanged: (value) => _wakeupTime.value = value,
                      icon: Icons.wb_sunny,
                      options: [
                        DropdownOption(
                          value: null,
                          label: L10n.get(
                            "not_specified",
                          ),
                        ),
                        DropdownOption(
                          value: "morning",
                          label: L10n.get(
                            "morning",
                          ),
                        ),
                        DropdownOption(
                          value: "evening",
                          label: L10n.get(
                            "evening",
                          ),
                        ),
                        DropdownOption(
                          value: "night",
                          label: L10n.get("night"),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sleep Time Dropdown
                  ValueListenableBuilder<String?>(
                    valueListenable: _sleepTime,
                    builder: (context, sleepTime, _) => ProfileDropdownControl(
                      label: L10n.get(
                        "sleep_time",
                      ),
                      value: sleepTime,
                      onChanged: (value) => _sleepTime.value = value,
                      icon: Icons.bedtime,
                      options: [
                        DropdownOption(
                          value: null,
                          label: L10n.get(
                            "not_specified",
                          ),
                        ),
                        DropdownOption(
                          value: "morning",
                          label: L10n.get(
                            "morning",
                          ),
                        ),
                        DropdownOption(
                          value: "evening",
                          label: L10n.get(
                            "evening",
                          ),
                        ),
                        DropdownOption(
                          value: "night",
                          label: L10n.get("night"),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Cleanliness Slider
                  ValueListenableBuilder<int?>(
                    valueListenable: _cleanliness,
                    builder: (context, cleanliness, _) => ProfileSliderControl(
                      label: L10n.get(
                        "cleanliness",
                      ),
                      value: cleanliness,
                      onChanged: (value) => _cleanliness.value = value,
                      min: 1,
                      max: 5,
                      icon: Icons.cleaning_services,
                      labels: [
                        L10n.get("very_messy"),
                        L10n.get("messy"),
                        L10n.get("average"),
                        L10n.get("clean"),
                        L10n.get("very_clean"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Noise Level Slider
                  ValueListenableBuilder<int?>(
                    valueListenable: _noiseLevel,
                    builder: (context, noiseLevel, _) => ProfileSliderControl(
                      label: L10n.get(
                        "noise_level",
                      ),
                      value: noiseLevel,
                      onChanged: (value) => _noiseLevel.value = value,
                      min: 1,
                      max: 5,
                      icon: Icons.volume_up,
                      labels: [
                        L10n.get("very_quiet"),
                        L10n.get("quiet"),
                        L10n.get("average"),
                        L10n.get("loud"),
                        L10n.get("very_loud"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sociability Slider
                  ValueListenableBuilder<int?>(
                    valueListenable: _sociability,
                    builder: (context, sociability, _) => ProfileSliderControl(
                      label: L10n.get(
                        "sociability",
                      ),
                      value: sociability,
                      onChanged: (value) => _sociability.value = value,
                      min: 1,
                      max: 5,
                      icon: Icons.people,
                      labels: [
                        L10n.get(
                          "very_introverted",
                        ),
                        L10n.get("introverted"),
                        L10n.get("balanced"),
                        L10n.get("extroverted"),
                        L10n.get(
                          "very_extroverted",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Guests Allowed Toggle
                  ValueListenableBuilder<bool?>(
                    valueListenable: _guestsAllowed,
                    builder: (context, guestsAllowed, _) =>
                        ProfileToggleControl(
                      label: L10n.get(
                        "guests_allowed",
                      ),
                      value: guestsAllowed,
                      onChanged: (value) => _guestsAllowed.value = value,
                      icon: Icons.group_add,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Smoking Preference Dropdown
                  ValueListenableBuilder<String?>(
                    valueListenable: _smokingPreference,
                    builder: (context, smokingPreference, _) =>
                        ProfileDropdownControl(
                      label: L10n.get(
                        "smoking_preference",
                      ),
                      value: smokingPreference,
                      onChanged: (value) => _smokingPreference.value = value,
                      icon: Icons.smoking_rooms,
                      options: [
                        DropdownOption(
                          value: null,
                          label: L10n.get(
                            "not_specified",
                          ),
                        ),
                        DropdownOption(
                          value: "non-smoker",
                          label: L10n.get(
                            "non_smoker",
                          ),
                        ),
                        DropdownOption(
                          value: "occasional",
                          label: L10n.get(
                            "occasional_smoker",
                          ),
                        ),
                        DropdownOption(
                          value: "regular",
                          label: L10n.get(
                            "regular_smoker",
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Alcohol Preference Dropdown
                  ValueListenableBuilder<String?>(
                    valueListenable: _alcoholPreference,
                    builder: (context, alcoholPreference, _) =>
                        ProfileDropdownControl(
                      label: L10n.get(
                        "alcohol_preference",
                      ),
                      value: alcoholPreference,
                      onChanged: (value) => _alcoholPreference.value = value,
                      icon: Icons.local_bar,
                      options: [
                        DropdownOption(
                          value: null,
                          label: L10n.get(
                            "not_specified",
                          ),
                        ),
                        DropdownOption(
                          value: "non-drinker",
                          label: L10n.get(
                            "non_drinker",
                          ),
                        ),
                        DropdownOption(
                          value: "occasional",
                          label: L10n.get(
                            "occasional_drinker",
                          ),
                        ),
                        DropdownOption(
                          value: "regular",
                          label: L10n.get(
                            "regular_drinker",
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Cooking Habits Toggle
                  ValueListenableBuilder<bool?>(
                    valueListenable: _cookingHabits,
                    builder: (context, cookingHabits, _) =>
                        ProfileToggleControl(
                      label: L10n.get(
                        "cooking_habits",
                      ),
                      value: cookingHabits,
                      onChanged: (value) => _cookingHabits.value = value,
                      icon: Icons.restaurant,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Pets preference (like / dislike / have cat / have dog)
                  ValueListenableBuilder<String?>(
                    valueListenable: _petsPreference,
                    builder: (context, petsPreference, _) =>
                        ProfileDropdownControl(
                      label: L10n.get(
                        "pets_preference",
                      ),
                      value: petsPreference,
                      onChanged: (value) => _petsPreference.value = value,
                      icon: Icons.pets,
                      options: [
                        DropdownOption(
                          value: null,
                          label: L10n.get(
                            "not_specified",
                          ),
                        ),
                        DropdownOption(
                          value: "like_pets",
                          label: L10n.get(
                            "pets_like_pets",
                          ),
                        ),
                        DropdownOption(
                          value: "dont_like_pets",
                          label: L10n.get(
                            "pets_dont_like_pets",
                          ),
                        ),
                        DropdownOption(
                          value: "have_cat",
                          label: L10n.get(
                            "pets_have_cat",
                          ),
                        ),
                        DropdownOption(
                          value: "have_dog",
                          label: L10n.get(
                            "pets_have_dog",
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Save Button
                  ValueListenableBuilder<bool>(
                    valueListenable: _isLoading,
                    builder: (context, isLoading, _) => SizedBox(
                      width: double.infinity,
                      child: GhostButtonFactory.iconText(
                        onPressed: isLoading ? null : _saveProfile,
                        icon: Icons.save,
                        text: isLoading
                            ? L10n.get(
                                "saving",
                              )
                            : L10n.get(
                                "save_changes",
                              ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        isLoading: isLoading,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoleLoadingPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    final isBlueTheme = ThemeState().isBlueTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: isBlueTheme
            ? BlueThemeColors.surface
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            ThemeIcon(
              Icons.badge,
              color: isBlueTheme
                  ? Colors.white
                  : theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                L10n.get(
                  "are_you_landlord_or_renter",
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: isBlueTheme
                      ? Colors.white
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);
    final isBlueTheme = ThemeState().isBlueTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _getLifestyleHeaderColor(),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: ThemeIcon(icon, color: theme.colorScheme.onSurfaceVariant),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: theme.colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: isBlueTheme
                ? BlueThemeColors.surface
                : theme.colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: _selectedGender,
      builder: (context, selectedGender, _) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            L10n.get("gender"),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _getLifestyleHeaderColor(),
            ),
          ),
          const SizedBox(height: 8),
          GenderPicker(
            selectedGender: selectedGender,
            onGenderChanged: (gender) => _selectedGender.value = gender,
            showArrows: false,
          ),
        ],
      ),
    );
  }

  Widget _buildStudentSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          L10n.get("are_you_student"),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _getLifestyleHeaderColor(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildStudentOption(
                context,
                isStudent: true,
                label: L10n.get("yes_student"),
                icon: Icons.school,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStudentOption(
                context,
                isStudent: false,
                label: L10n.get("no_student"),
                icon: Icons.work,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStudentOption(
    BuildContext context, {
    required bool isStudent,
    required String label,
    required IconData icon,
  }) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isStudent,
      builder: (context, currentIsStudent, _) {
        final theme = Theme.of(context);
        final isBlueTheme = ThemeState().isBlueTheme;
        final isSelected = currentIsStudent == isStudent;
        final backgroundColor = isSelected
            ? Colors.white
            : (isBlueTheme
                ? BlueThemeColors.surface
                : theme.colorScheme.surfaceContainerHighest);
        final borderColor =
            isSelected ? Colors.black : theme.colorScheme.outline;
        final textColor = isSelected
            ? Colors.black
            : (isBlueTheme ? Colors.white : theme.colorScheme.onSurface);

        return GestureDetector(
          onTap: () {
            HapticFeedbackUtils.impact();
            SendSoundUtils.playSelectionSound();
            _isStudent.value = isStudent;
            if (isStudent) {
              // Auto-select first university if none selected
              if (_universities.isNotEmpty &&
                  _selectedUniversityId.value == null) {
                _selectedUniversityId.value = _universities.first.id;
                _initializeUniversityScrollController();
              }
            } else {
              _selectedUniversityId.value = null;
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ThemeIcon(icon, color: textColor, size: 20),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRegionSelector(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: LanguageState(),
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              L10n.get("im_from"),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _getLifestyleHeaderColor(),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: ThreeDSurfaceStyle.wheelPickerPlateDecoration(
                context,
                theme: theme,
              ),
              height: 80,
              child: Row(
                children: [
                  Expanded(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _isLoadingRegions,
                      builder: (context, isLoadingRegions, _) =>
                          isLoadingRegions
                              ? Center(
                                  child: Text(
                                    L10n.get(
                                      "loading_regions",
                                    ),
                                    style: TextStyle(
                                      color: ThemeState().isBlueTheme
                                          ? Colors.white
                                          : Colors.black,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                )
                              : _regionScrollController != null
                                  ? CupertinoPicker(
                                      backgroundColor: Colors.transparent,
                                      itemExtent: 40,
                                      scrollController: _regionScrollController,
                                      onSelectedItemChanged: (index) {
                                        HapticFeedbackUtils.impact();
                                        SendSoundUtils.playSelectionSound();
                                        if (index == 0) {
                                          _selectedRegionId.value = null;
                                        } else {
                                          final regionIndex = index - 1;
                                          if (regionIndex < _regions.length) {
                                            _selectedRegionId.value =
                                                _regions[regionIndex].id;
                                          }
                                        }
                                      },
                                      children: [
                                        // Unselected option
                                        Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ThemeIcon(
                                                Icons.location_on,
                                                color: theme.colorScheme
                                                    .onSurfaceVariant,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                L10n.get(
                                                  "select_region",
                                                ),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      ThemeState().isBlueTheme
                                                          ? Colors.white
                                                          : Colors.black,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Region options
                                        ..._regions.asMap().entries.map(
                                              (entry) => Center(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    ThemeIcon(
                                                      Icons.location_on,
                                                      color:
                                                          _getRegionIconColorForIndex(
                                                        entry.key + 1,
                                                      ),
                                                      size: 18,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Flexible(
                                                      child: Text(
                                                        _getLocalizedRegionName(
                                                          entry.value,
                                                        ),
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: ThemeState()
                                                                  .isBlueTheme
                                                              ? Colors.white
                                                              : Colors.black,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                      ],
                                    )
                                  : Center(
                                      child: Text(
                                        L10n.get(
                                          "loading_regions",
                                        ),
                                        style: TextStyle(
                                          color: ThemeState().isBlueTheme
                                              ? Colors.white
                                              : Colors.black,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  int _getInitialRegionItem() {
    // If no region is selected, return 0 (first item: "Select region")
    if (_selectedRegionId.value == null) {
      return 0;
    }

    // Find the index of the selected region ID in the wheel picker
    final regionIndex = _regions.indexWhere(
      (region) => region.id == _selectedRegionId.value,
    );

    // Return the wheel picker index (0 = "Select region", 1 = first region, etc.)
    return regionIndex >= 0 ? regionIndex + 1 : 0;
  }

  Color _getRegionIconColorForIndex(int index) {
    // Alternate between different colors based on region index
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.brown,
    ];
    return colors[(index - 1) % colors.length];
  }

  Widget _buildUniversitySelector(BuildContext context) {
    final theme = Theme.of(context);
    return ListenableBuilder(
      listenable: LanguageState(),
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              L10n.get("university"),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _getLifestyleHeaderColor(),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: ThreeDSurfaceStyle.wheelPickerPlateDecoration(
                context,
                theme: theme,
              ),
              height: 120,
              child: Row(
                children: [
                  Expanded(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _isLoadingUniversities,
                      builder: (context, isLoadingUniversities, _) =>
                          isLoadingUniversities
                              ? Center(
                                  child: Text(
                                    L10n.get(
                                      "loading_universities",
                                    ),
                                    style: TextStyle(
                                      color: ThemeState().isBlueTheme
                                          ? Colors.white
                                          : Colors.black,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                )
                              : _universityScrollController != null
                                  ? CupertinoPicker(
                                      backgroundColor: Colors.transparent,
                                      itemExtent: 50,
                                      scrollController:
                                          _universityScrollController,
                                      onSelectedItemChanged: (index) {
                                        HapticFeedbackUtils.impact();
                                        SendSoundUtils.playSelectionSound();
                                        if (index == 0) {
                                          _selectedUniversityId.value = null;
                                        } else {
                                          final universityIndex = index - 1;
                                          if (universityIndex <
                                              _universities.length) {
                                            _selectedUniversityId.value =
                                                _universities[universityIndex]
                                                    .id;
                                          }
                                        }
                                      },
                                      children: [
                                        // Unselected option
                                        Center(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ThemeIcon(
                                                Icons.school,
                                                color: theme.colorScheme
                                                    .onSurfaceVariant,
                                                size: 18,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                L10n.get(
                                                  "select_university",
                                                ),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      ThemeState().isBlueTheme
                                                          ? Colors.white
                                                          : Colors.black,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                        // University options
                                        ..._universities.asMap().entries.map(
                                              (entry) => Center(
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    ThemeIcon(
                                                      Icons.school,
                                                      color:
                                                          _getUniversityIconColorForIndex(
                                                        entry.key + 1,
                                                      ),
                                                      size: 18,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Flexible(
                                                      child: Text(
                                                        entry.value
                                                            .getLocalizedNameCapitalized(
                                                          LanguageState()
                                                              .currentLanguage,
                                                        ),
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          color: ThemeState()
                                                                  .isBlueTheme
                                                              ? Colors.white
                                                              : Colors.black,
                                                        ),
                                                        textAlign:
                                                            TextAlign.center,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                      ],
                                    )
                                  : Center(
                                      child: Text(
                                        L10n.get(
                                          "loading_universities",
                                        ),
                                        style: TextStyle(
                                          color: ThemeState().isBlueTheme
                                              ? Colors.white
                                              : Colors.black,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  int _getInitialUniversityItem() {
    // If no university is selected, return 0 (first item: "Select university")
    if (_selectedUniversityId.value == null) {
      return 0;
    }

    // Find the index of the selected university ID in the wheel picker
    final universityIndex = _universities.indexWhere(
      (university) => university.id == _selectedUniversityId.value,
    );

    // Return the wheel picker index (0 = "Select university", 1 = first university, etc.)
    return universityIndex >= 0 ? universityIndex + 1 : 0;
  }

  Color _getUniversityIconColorForIndex(int index) {
    // Alternate between different colors based on university index
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.indigo,
      Colors.brown,
      Colors.red,
    ];
    return colors[(index - 1) % colors.length];
  }

  String _getSelectedRegionName() {
    if (_isLoadingRegions.value) {
      return L10n.get("loading_regions");
    }

    if (_selectedRegionId.value == null) {
      return L10n.get("select_region");
    }

    final selectedRegion = _regions.firstWhere(
      (region) => region.id == _selectedRegionId.value,
      orElse: () => Region(
        id: 0,
        name: L10n.get("unknown"),
        shortName: L10n.get("unknown"),
      ),
    );

    return _getLocalizedRegionName(selectedRegion);
  }

  String _getLocalizedRegionName(Region region) {
    return region.getLocalizedName(LanguageState().currentLanguage);
  }

  /// Get theme-aware color for lifestyle preferences header
  Color _getLifestyleHeaderColor() {
    if (ThemeState().isBlueTheme) {
      return Colors.white; // White text for blue theme
    } else {
      return Colors.black; // Black text for other themes
    }
  }
}
