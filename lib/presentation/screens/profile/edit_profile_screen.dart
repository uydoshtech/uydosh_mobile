import "dart:async";

import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/api/client/json_encodable.dart";
import "package:uy_dosh/base/api/client/oauth_api_client.dart";
import "package:uy_dosh/base/cache/country_cache.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
import "package:uy_dosh/base/services/app_analytics_service.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/logger/logger.dart";
import "package:uy_dosh/base/services/session_manager.dart";
import "package:uy_dosh/base/state/profile_completion_state.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/state/price_display_settings_state.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/base/utils/safe_state.dart";
import "package:uy_dosh/base/utils/send_sound_utils.dart";
import "package:uy_dosh/domain/models/auth/update_profile_request.dart";
import "package:uy_dosh/domain/models/country.dart";
import "package:uy_dosh/domain/models/region.dart";
import "package:uy_dosh/domain/models/university.dart";
import "package:uy_dosh/domain/models/user_profile.dart";
import "package:uy_dosh/domain/services/country_service.dart";
import "package:uy_dosh/domain/services/region_service.dart";
import "package:uy_dosh/domain/services/university_service.dart";
import "package:uy_dosh/domain/services/user_profile_service.dart";
import "package:uy_dosh/presentation/widgets/common/app_bar_profile_icon.dart";
import "package:uy_dosh/presentation/widgets/common/gender_picker.dart";
import "package:uy_dosh/presentation/widgets/common/glass_bottom_sheet_surface.dart";
import "package:uy_dosh/presentation/widgets/common/swipe_dismissible_sheet.dart";
import "package:uy_dosh/presentation/widgets/common/ghost_button.dart";
import "package:uy_dosh/presentation/widgets/common/keyboard_dismiss_scope.dart";
import "package:uy_dosh/presentation/widgets/common/profile_dropdown_control.dart";
import "package:uy_dosh/presentation/widgets/common/profile_slider_control.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/unsaved_changes_dialog.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_app_bar.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({required this.profile, super.key});

  final UserProfile profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
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
  late ValueNotifier<String?> _employed;
  late ValueNotifier<int?> _cleanliness;
  late ValueNotifier<int?> _noiseLevel;
  late ValueNotifier<int?> _sociability;
  late ValueNotifier<String?> _guestsAllowed;
  late ValueNotifier<String?> _smokingPreference;
  late ValueNotifier<String?> _alcoholPreference;
  late ValueNotifier<String?> _cookingHabits;
  late ValueNotifier<String?> _petsPreference;
  late ValueNotifier<String?> _wakeupTime;
  late ValueNotifier<String?> _sleepTime;

  List<Region> _regions =
      []; // Initialize to empty list to avoid LateInitializationError
  List<University> _universities =
      []; // Initialize to empty list to avoid LateInitializationError
  List<Country> _countries = <Country>[];
  late final ICountryService _countryService;
  late ValueNotifier<String> _selectedCountryIso2;
  late ValueNotifier<bool> _isLoading;
  late ValueNotifier<bool> _isLoadingRegions;
  late ValueNotifier<bool> _isLoadingUniversities;
  bool _isAdmin = false;
  /// Staff role fixed in DB (shown in picker but not self-assignable).
  String? _pinnedStaffRole;
  late ValueNotifier<bool> _isRoleLoaded;

  /// Role as loaded from session (baseline for dirty check).
  String? _baselineRole;

  /// Price display preference baseline for dirty check (local prefs, not profile API).
  PriceDisplayCurrency? _baselinePriceDisplay;

  /// Dropdown slugs for [cookingHabits] (API remains bool?).
  static const String _cookingSlugAtHome = "cooks_at_home";
  static const String _cookingSlugDoesNot = "does_not_cook";

  bool? _cookingHabitsBoolFromSlug(String? slug) {
    if (slug == null) return null;
    if (slug == _cookingSlugAtHome) return true;
    if (slug == _cookingSlugDoesNot) return false;
    return null;
  }

  String? _cookingHabitsSlugFromBool(bool? b) {
    if (b == null) return null;
    return b ? _cookingSlugAtHome : _cookingSlugDoesNot;
  }

  /// API [noise_level]: 1 = quiet … 5 = loud; slider uses the same mapping
  /// (left → right, see labels).
  int _committedNoiseApiValue() =>
      _noiseLevel.value ?? widget.profile.noiseLevel ?? 1;

  static const String _employedSlugYes = "employed_yes";
  static const String _employedSlugNo = "employed_no";

  bool? _employedBoolFromSlug(String? slug) {
    if (slug == null) return null;
    if (slug == _employedSlugYes) return true;
    if (slug == _employedSlugNo) return false;
    return null;
  }

  String? _employedSlugFromBool(bool? b) {
    if (b == null) return null;
    return b ? _employedSlugYes : _employedSlugNo;
  }

  static const String _guestsSlugYes = "guests_yes";
  static const String _guestsSlugNo = "guests_no";

  bool? _guestsBoolFromSlug(String? slug) {
    if (slug == null) return null;
    if (slug == _guestsSlugYes) return true;
    if (slug == _guestsSlugNo) return false;
    return null;
  }

  String? _guestsSlugFromBool(bool? b) {
    if (b == null) return null;
    return b ? _guestsSlugYes : _guestsSlugNo;
  }

  late final Listenable _formListenables;

  /// Pulse animation for the save button to gently blink when there are
  /// unsaved changes, drawing the user's attention to it.
  late final AnimationController _savePulseController;
  late final Animation<double> _savePulseOpacity;

  @override
  void initState() {
    super.initState();
    getIt<AppAnalyticsService>().logScreenView(screenName: "edit_profile");

    _nameController = TextEditingController(text: widget.profile.name ?? "");
    _aboutMeController = TextEditingController(
      text: widget.profile.aboutMe ?? "",
    );
    _telegramController = TextEditingController(
      text: widget.profile.telegram ?? "",
    );

    _selectedGender = ValueNotifier(widget.profile.gender ?? 1);
    _selectedRegionId = ValueNotifier(widget.profile.regionId);
    final persistedIso = widget.profile.originCountryIso2?.trim().toUpperCase();
    final hasPersistedIso = persistedIso != null && persistedIso.isNotEmpty;
    final initialCountryIso = widget.profile.regionId != null
        ? CountryCache.defaultIso2
        : (hasPersistedIso ? persistedIso : CountryCache.defaultIso2);
    _selectedCountryIso2 = ValueNotifier(initialCountryIso);
    _countryService = getIt<ICountryService>();
    _selectedUniversityId = ValueNotifier(widget.profile.universityId);
    _isStudent = ValueNotifier(widget.profile.universityId != null);
    _selectedLanguage = ValueNotifier(
      widget.profile.preferredLanguage ?? LanguageState().currentLanguage,
    );
    _selectedRole = ValueNotifier("tenant");
    _employed = ValueNotifier(_employedSlugFromBool(widget.profile.employed));
    _cleanliness = ValueNotifier(widget.profile.cleanliness);
    _noiseLevel = ValueNotifier(widget.profile.noiseLevel);
    _sociability = ValueNotifier(widget.profile.sociability);
    _guestsAllowed = ValueNotifier(
      _guestsSlugFromBool(widget.profile.guestsAllowed),
    );
    _smokingPreference = ValueNotifier(widget.profile.smokingPreference);
    _alcoholPreference = ValueNotifier(widget.profile.alcoholPreference);
    _cookingHabits = ValueNotifier(
      _cookingHabitsSlugFromBool(widget.profile.cookingHabits),
    );
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
      _selectedCountryIso2,
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
      PriceDisplaySettingsState(),
    ]);

    if (PriceDisplaySettingsState().isInitialized) {
      _baselinePriceDisplay = PriceDisplaySettingsState().currency;
    }
    unawaited(_ensurePriceDisplayBaseline());

    _savePulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _savePulseOpacity = Tween<double>(begin: 0.45, end: 1.0).animate(
      CurvedAnimation(
        parent: _savePulseController,
        curve: Curves.easeInOut,
      ),
    );

    _loadCountries();
    _loadRegions();
    _loadUniversities();
    _loadUserRole();
  }

  Future<void> _loadCountries() async {
    try {
      final countries = await _countryService.getCountries(
        LanguageState().currentLanguage,
      );
      setStateIfMounted(() => _countries = countries);
    } catch (error, stack) {
      logger.e(
        "Failed to load countries on edit profile screen",
        error: error,
        stackTrace: stack,
      );
    }
  }

  Future<void> _loadUserRole() async {
    // Start with the locally cached role so we render quickly, then refresh
    // from the server so stale caches (e.g. after a role promotion in the DB)
    // can't hide the admin option or cause us to send a downgraded role on save.
    var role = await SessionManager.getUserRole();
    final serverRole = await _fetchRoleFromServer();
    if (serverRole != null && serverRole != role) {
      await SessionManager.storeUserRole(serverRole);
      role = serverRole;
    }
    if (mounted) {
      _isAdmin = role == "admin";
      _pinnedStaffRole =
          (role == "manager" || role == "moderator") ? role : null;
      final resolved = (role != null &&
              (role == "admin" ||
                  role == "landlord" ||
                  role == "tenant" ||
                  role == "manager" ||
                  role == "moderator" ||
                  role == "service_provider" ||
                  role == "service_requester"))
          ? role
          : "tenant";
      _selectedRole.value = resolved;
      _baselineRole = resolved;
      _isRoleLoaded.value = true;
    }
  }

  Future<String?> _fetchRoleFromServer() async {
    try {
      final response = await getIt<IOAuthApiClient>()
          .post<Map<String, dynamic>, _EditProfileEmptyRequest>(
        "/users/verify-session",
        (json) => json as Map<String, dynamic>,
        data: _EditProfileEmptyRequest(),
      );
      final user = response["user"];
      if (user is Map<String, dynamic>) {
        return user["role"] as String?;
      }
    } catch (e) {
      logger.d("⚠️ [EditProfileScreen] Failed to refresh role from server: $e");
    }
    return null;
  }

  String _normText(String? s) => (s ?? "").trim();

  Future<void> _ensurePriceDisplayBaseline() async {
    await PriceDisplaySettingsState().initialize();
    if (!mounted) return;
    _baselinePriceDisplay ??= PriceDisplaySettingsState().currency;
    setStateIfMounted(() {});
  }

  bool _isPriceDisplayDirty() {
    final b = _baselinePriceDisplay;
    if (b == null) return false;
    return PriceDisplaySettingsState().currency != b;
  }

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
    if (_isOriginDirty(p)) {
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
        addLabel("select_your_primary_role", fallback: "Role");
      }
    }

    if (p.employed != _employedBoolFromSlug(_employed.value)) {
      addLabel("work", fallback: "Work");
    }
    if (p.wakeupTime != _wakeupTime.value)
      addLabel("wakeup_time", fallback: "Wake-up time");
    if (p.sleepTime != _sleepTime.value)
      addLabel("sleep_time", fallback: "Sleep time");
    if (p.cleanliness != _cleanliness.value)
      addLabel("cleanliness", fallback: "Cleanliness");
    if (p.noiseLevel != _committedNoiseApiValue())
      addLabel("noise_level", fallback: "Noise level");
    if (p.sociability != _sociability.value)
      addLabel("sociability", fallback: "Sociability");
    if (p.guestsAllowed != _guestsBoolFromSlug(_guestsAllowed.value)) {
      addLabel("guests", fallback: "Guests");
    }
    if (p.smokingPreference != _smokingPreference.value) {
      addLabel("smoking_preference", fallback: "Smoking");
    }
    if (p.alcoholPreference != _alcoholPreference.value) {
      addLabel("alcohol_preference", fallback: "Alcohol");
    }
    if (p.cookingHabits != _cookingHabitsBoolFromSlug(_cookingHabits.value)) {
      addLabel("cooking_habits", fallback: "Cooking");
    }
    if (p.petsPreference != _petsPreference.value) {
      addLabel("pets_preference", fallback: "Pets");
    }

    if (_isPriceDisplayDirty()) {
      addLabel("price_display_currency", fallback: "Price currency");
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

  String _savedOriginCountryIso2(UserProfile p) {
    if (p.regionId != null || p.region != null) {
      return CountryCache.defaultIso2;
    }
    final raw = p.originCountryIso2;
    if (raw != null && raw.trim().isNotEmpty) {
      return raw.trim().toUpperCase();
    }
    return CountryCache.defaultIso2;
  }

  String _resolvedOriginIso2ForForm() {
    if (_selectedRegionId.value != null) return CountryCache.defaultIso2;
    return _selectedCountryIso2.value.trim().toUpperCase();
  }

  bool _isOriginDirty(UserProfile p) {
    return _selectedRegionId.value != _resolvedRegionIdFromProfile() ||
        _resolvedOriginIso2ForForm() != _savedOriginCountryIso2(p);
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
    if (_isOriginDirty(p)) return true;

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

    if (p.employed != _employedBoolFromSlug(_employed.value)) return true;
    if (p.cleanliness != _cleanliness.value) return true;
    if (p.noiseLevel != _committedNoiseApiValue()) return true;
    if (p.sociability != _sociability.value) return true;
    if (p.guestsAllowed != _guestsBoolFromSlug(_guestsAllowed.value)) {
      return true;
    }
    if (p.smokingPreference != _smokingPreference.value) return true;
    if (p.alcoholPreference != _alcoholPreference.value) return true;
    if (p.cookingHabits != _cookingHabitsBoolFromSlug(_cookingHabits.value)) {
      return true;
    }
    if (p.petsPreference != _petsPreference.value) return true;
    if (p.wakeupTime != _wakeupTime.value) return true;
    if (p.sleepTime != _sleepTime.value) return true;

    if (_isPriceDisplayDirty()) return true;

    return false;
  }

  Future<void> _onPopInvoked(bool didPop, dynamic result) async {
    if (didPop) return;
    final changedFields = _computeChangedFieldLabels();
    final leave = await UnsavedChangesDialog.show(
      context,
      changedFieldLabels: changedFields,
    );
    if (!mounted || !leave) return;
    Navigator.of(context).pop(result);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutMeController.dispose();
    _telegramController.dispose();
    _selectedGender.dispose();
    _selectedRegionId.dispose();
    _selectedCountryIso2.dispose();
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
    _savePulseController.dispose();
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

      setStateIfMounted(() => _regions = regions);
      _isLoadingRegions.value = false;

      // Set the selected region based on the profile's regionId
      if (widget.profile.regionId != null) {
        final regionExists = regions.any(
          (region) => region.id == widget.profile.regionId,
        );
        _selectedRegionId.value = regionExists ? widget.profile.regionId : null;
        if (_selectedRegionId.value != null) {
          _selectedCountryIso2.value = CountryCache.defaultIso2;
        }
      } else {
        _selectedRegionId.value = null;
      }
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

  Future<void> _loadUniversities() async {
    try {
      final universityService = getIt<IUniversityService>();
      final universities = await universityService.getUniversities();
      setStateIfMounted(() => _universities = universities);
      _isLoadingUniversities.value = false;
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

  Future<void> _saveProfile() async {
    HapticFeedbackUtils.impact();
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
        employed: _employedBoolFromSlug(_employed.value),
        cleanliness: _cleanliness.value,
        noiseLevel: _committedNoiseApiValue(),
        sociability: _sociability.value,
        guestsAllowed: _guestsBoolFromSlug(_guestsAllowed.value),
        smokingPreference: _smokingPreference.value,
        alcoholPreference: _alcoholPreference.value,
        cookingHabits: _cookingHabitsBoolFromSlug(_cookingHabits.value),
        petsPreference: _petsPreference.value,
        wakeupTime: _wakeupTime.value,
        sleepTime: _sleepTime.value,
        preferredLanguage: _selectedLanguage.value,
        originCountryIso2: _resolvedOriginIso2ForForm(),
      );

      // Debug logging to see what values are being sent
      logger.d("🔍 [EditProfileScreen] Update request values:");
      logger.d("  - telegram: $telegramToSend");
      logger.d("  - smokingPreference: ${_smokingPreference.value}");
      logger.d("  - alcoholPreference: ${_alcoholPreference.value}");
      logger.d("  - wakeupTime: ${_wakeupTime.value}");
      logger.d("  - sleepTime: ${_sleepTime.value}");
      logger.d(
        "  - employed: ${_employedBoolFromSlug(_employed.value)}",
      );
      logger.d("  - cleanliness: ${_cleanliness.value}");
      logger.d("  - noiseLevel: ${_committedNoiseApiValue()}");
      logger.d("  - sociability: ${_sociability.value}");
      logger.d(
        "  - guestsAllowed: ${_guestsBoolFromSlug(_guestsAllowed.value)}",
      );
      logger.d(
        "  - cookingHabits: ${_cookingHabitsBoolFromSlug(_cookingHabits.value)}",
      );
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
        if (mounted) {
          precacheCurrentUserAvatar(context, updatedProfile.avatarUrl);
        }

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
            // Unified soft-UI background so neumorphic shadows on the cards
            // blend seamlessly with the page instead of clashing with a
            // contrasting scaffold tone.
            backgroundColor: theme.colorScheme.surface,
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
                ValueListenableBuilder<bool>(
                  valueListenable: _isLoading,
                  builder: (context, isLoading, _) {
                    if (isLoading) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: IconButton(
                          onPressed: null,
                          icon: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.appBarTheme.foregroundColor ??
                                    theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                          tooltip: L10n.get("save_changes"),
                        ),
                      );
                    }
                    if (!_isFormDirty()) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: FadeTransition(
                        opacity: _savePulseOpacity,
                        child: IconButton(
                          onPressed: () {
                            HapticFeedbackUtils.impact();
                            _saveProfile();
                          },
                          icon: const ThemeIcon(Icons.save),
                          tooltip: L10n.get("save_changes"),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: KeyboardDismissScope(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                keyboardDismissBehavior: KeyboardDismissScope.scrollBehavior,
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

                    // Price display currency (UZS or USD)
                    ListenableBuilder(
                      listenable: PriceDisplaySettingsState(),
                      builder: (context, _) {
                        final currency =
                            PriceDisplaySettingsState().currencySlug;
                        return ProfileDropdownControl(
                          label: L10n.get("price_display_currency"),
                          value: currency,
                          onChanged: (value) async {
                            if (value == null) return;
                            _baselinePriceDisplay ??=
                                PriceDisplaySettingsState().currency;
                            await PriceDisplaySettingsState().setCurrency(
                              value == "usd"
                                  ? PriceDisplayCurrency.usd
                                  : PriceDisplayCurrency.national,
                            );
                          },
                          icon: Icons.payments,
                          options: [
                            DropdownOption(
                              value: "national",
                              label:
                                  L10n.get("price_display_currency_national"),
                              icon: Icons.flag,
                            ),
                            DropdownOption(
                              value: "usd",
                              label: L10n.get("price_display_currency_usd"),
                              icon: Icons.attach_money,
                            ),
                          ],
                        );
                      },
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
                                  "select_your_primary_role",
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
                                      icon: Icons.admin_panel_settings,
                                    ),
                                  if (_pinnedStaffRole == "manager")
                                    DropdownOption(
                                      value: "manager",
                                      label: L10n.get(
                                        "role_manager",
                                      ),
                                      icon: Icons.supervisor_account_outlined,
                                    ),
                                  if (_pinnedStaffRole == "moderator")
                                    DropdownOption(
                                      value: "moderator",
                                      label: L10n.get(
                                        "role_moderator",
                                      ),
                                      icon: Icons.shield_outlined,
                                    ),
                                  DropdownOption(
                                    value: "landlord",
                                    label: L10n.get(
                                      "role_landlord",
                                    ),
                                    icon: Icons.home_work,
                                  ),
                                  DropdownOption(
                                    value: "tenant",
                                    label: L10n.get(
                                      "role_tenant",
                                    ),
                                    icon: Icons.key,
                                  ),
                                  DropdownOption(
                                    value: "service_requester",
                                    label: L10n.get(
                                      "role_service_requester",
                                    ),
                                    icon: Icons.assignment_ind,
                                  ),
                                  DropdownOption(
                                    value: "service_provider",
                                    label: L10n.get(
                                      "role_service_provider",
                                    ),
                                    icon: Icons.home_repair_service,
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

                    // Employed (dropdown; stored as bool? on API)
                    ValueListenableBuilder<String?>(
                      valueListenable: _employed,
                      builder: (context, employed, _) => ProfileDropdownControl(
                        label: L10n.get("work"),
                        value: employed,
                        onChanged: (value) => _employed.value = value,
                        icon: Icons.work,
                        options: [
                          DropdownOption(
                            value: null,
                            label: L10n.get("not_specified"),
                            icon: Icons.not_interested,
                          ),
                          DropdownOption(
                            value: _employedSlugYes,
                            label: L10n.get("employed"),
                            icon: Icons.work,
                          ),
                          DropdownOption(
                            value: _employedSlugNo,
                            label: L10n.get("not_employed"),
                            icon: Icons.work_off_outlined,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Wake-up Time Dropdown
                    ValueListenableBuilder<String?>(
                      valueListenable: _wakeupTime,
                      builder: (context, wakeupTime, _) =>
                          ProfileDropdownControl(
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
                            icon: Icons.not_interested,
                          ),
                          DropdownOption(
                            value: "morning",
                            label: L10n.get(
                              "morning",
                            ),
                            icon: Icons.wb_sunny_outlined,
                          ),
                          DropdownOption(
                            value: "evening",
                            label: L10n.get(
                              "evening",
                            ),
                            icon: Icons.wb_twilight,
                          ),
                          DropdownOption(
                            value: "night",
                            label: L10n.get("night"),
                            icon: Icons.nights_stay_outlined,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Sleep Time Dropdown
                    ValueListenableBuilder<String?>(
                      valueListenable: _sleepTime,
                      builder: (context, sleepTime, _) =>
                          ProfileDropdownControl(
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
                            icon: Icons.not_interested,
                          ),
                          DropdownOption(
                            value: "morning",
                            label: L10n.get(
                              "morning",
                            ),
                            icon: Icons.wb_sunny_outlined,
                          ),
                          DropdownOption(
                            value: "evening",
                            label: L10n.get(
                              "evening",
                            ),
                            icon: Icons.wb_twilight,
                          ),
                          DropdownOption(
                            value: "night",
                            label: L10n.get("night"),
                            icon: Icons.nights_stay_outlined,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Cleanliness Slider
                    ValueListenableBuilder<int?>(
                      valueListenable: _cleanliness,
                      builder: (context, cleanliness, _) =>
                          ProfileSliderControl(
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
                        scaleStartLabel: L10n.get("very_messy"),
                        scaleEndLabel: L10n.get("very_clean"),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Noise: inverted track (loud/noisy on the left); API still
                    // 1 = quiet … 5 = loud.
                    ValueListenableBuilder<int?>(
                      valueListenable: _noiseLevel,
                      builder: (context, noiseLevel, _) =>
                          ProfileSliderControl(
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
                        scaleStartLabel: L10n.get("very_loud"),
                        scaleEndLabel: L10n.get("very_quiet"),
                        invertTrack: true,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Sociability Slider
                    ValueListenableBuilder<int?>(
                      valueListenable: _sociability,
                      builder: (context, sociability, _) =>
                          ProfileSliderControl(
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
                        scaleStartLabel: L10n.get("very_introverted"),
                        scaleEndLabel: L10n.get("very_extroverted"),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Guests allowed (dropdown; stored as bool? on API)
                    ValueListenableBuilder<String?>(
                      valueListenable: _guestsAllowed,
                      builder: (context, guestsAllowed, _) =>
                          ProfileDropdownControl(
                        label: L10n.get(
                          "guests",
                        ),
                        value: guestsAllowed,
                        onChanged: (value) => _guestsAllowed.value = value,
                        icon: Icons.group_add,
                        options: [
                          DropdownOption(
                            value: null,
                            label: L10n.get(
                              "not_specified",
                            ),
                            icon: Icons.not_interested,
                          ),
                          DropdownOption(
                            value: _guestsSlugYes,
                            label: L10n.get(
                              "guests_permitted",
                            ),
                            icon: Icons.group_add,
                          ),
                          DropdownOption(
                            value: _guestsSlugNo,
                            label: L10n.get(
                              "guests_not_permitted",
                            ),
                            icon: Icons.block,
                          ),
                        ],
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
                            icon: Icons.not_interested,
                          ),
                          DropdownOption(
                            value: "non-smoker",
                            label: L10n.get(
                              "non_smoker",
                            ),
                            icon: Icons.smoke_free,
                          ),
                          DropdownOption(
                            value: "occasional",
                            label: L10n.get(
                              "occasional_smoker",
                            ),
                            icon: Icons.smoking_rooms_outlined,
                          ),
                          DropdownOption(
                            value: "regular",
                            label: L10n.get(
                              "regular_smoker",
                            ),
                            icon: Icons.smoking_rooms,
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
                            icon: Icons.not_interested,
                          ),
                          DropdownOption(
                            value: "non-drinker",
                            label: L10n.get(
                              "non_drinker",
                            ),
                            icon: Icons.no_drinks,
                          ),
                          DropdownOption(
                            value: "occasional",
                            label: L10n.get(
                              "occasional_drinker",
                            ),
                            icon: Icons.wine_bar_outlined,
                          ),
                          DropdownOption(
                            value: "regular",
                            label: L10n.get(
                              "regular_drinker",
                            ),
                            icon: Icons.local_bar,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Cooking habits (dropdown; stored as bool on API)
                    ValueListenableBuilder<String?>(
                      valueListenable: _cookingHabits,
                      builder: (context, cookingHabits, _) =>
                          ProfileDropdownControl(
                        label: L10n.get(
                          "cooking_habits",
                        ),
                        value: cookingHabits,
                        onChanged: (value) => _cookingHabits.value = value,
                        icon: Icons.restaurant,
                        options: [
                          DropdownOption(
                            value: null,
                            label: L10n.get(
                              "not_specified",
                            ),
                            icon: Icons.not_interested,
                          ),
                          DropdownOption(
                            value: _cookingSlugAtHome,
                            label: L10n.get(
                              "cook",
                            ),
                            icon: Icons.restaurant,
                          ),
                          DropdownOption(
                            value: _cookingSlugDoesNot,
                            label: L10n.get(
                              "dont_cook",
                            ),
                            icon: Icons.takeout_dining,
                          ),
                        ],
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
                            icon: Icons.not_interested,
                          ),
                          DropdownOption(
                            value: "like_pets",
                            label: L10n.get(
                              "pets_like_pets",
                            ),
                            icon: Icons.pets,
                          ),
                          DropdownOption(
                            value: "dont_like_pets",
                            label: L10n.get(
                              "pets_dont_like_pets",
                            ),
                            icon: Icons.block,
                          ),
                          DropdownOption(
                            value: "have_cat",
                            label: L10n.get(
                              "pets_have_cat",
                            ),
                            icon: Icons.cruelty_free,
                          ),
                          DropdownOption(
                            value: "have_dog",
                            label: L10n.get(
                              "pets_have_dog",
                            ),
                            icon: Icons.pets_outlined,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Save Button - only visible when there are unsaved changes
                    // (or while a save is in progress), with a gentle pulse to
                    // draw the user's attention.
                    ValueListenableBuilder<bool>(
                      valueListenable: _isLoading,
                      builder: (context, isLoading, _) {
                        if (!isLoading && !_isFormDirty()) {
                          return const SizedBox.shrink();
                        }
                        final button = SizedBox(
                          width: double.infinity,
                          child: GhostButtonFactory.iconText(
                            onPressed: isLoading ? null : _saveProfile,
                            icon: Icons.save,
                            text: isLoading
                                ? L10n.get("saving")
                                : L10n.get("save_changes"),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            isLoading: isLoading,
                            neumorphicSoftUi: true,
                          ),
                        );
                        if (isLoading) return button;
                        return FadeTransition(
                          opacity: _savePulseOpacity,
                          child: button,
                        );
                      },
                    ),
                  ],
                ),
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
    final baseColor =
        isBlueTheme ? BlueThemeColors.surface : theme.colorScheme.surface;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: ThreeDSurfaceStyle.surfaceGradient(context, baseColor),
        boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  "select_your_primary_role",
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
    // Neumorphic recessed (inset) input: flat fill that matches the surface
    // with inner shadows, no hard border — feels "soft-UI" / new-morphic.
    final baseColor =
        isBlueTheme ? BlueThemeColors.surface : theme.colorScheme.surface;
    final iconColor =
        isBlueTheme ? Colors.white : theme.colorScheme.onSurfaceVariant;
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
        const SizedBox(height: 10),
        DecoratedBox(
          decoration: BoxDecoration(
            color: baseColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: ThreeDSurfaceStyle.insetRecessedShadows(context),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isBlueTheme ? Colors.white : theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              prefixIcon: ThemeIcon(icon, color: iconColor),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              filled: false,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
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
        final baseColor =
            isBlueTheme ? BlueThemeColors.surface : theme.colorScheme.surface;
        // Selected = raised plate; unselected = inset / pressed-in.
        // Keep the label at full contrast in both states.
        final textColor =
            isBlueTheme ? Colors.white : theme.colorScheme.onSurface;
        final iconColor = isBlueTheme
            ? Colors.white
            : (isSelected
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurfaceVariant);

        return GestureDetector(
          onTap: () {
            HapticFeedbackUtils.impact();
            SendSoundUtils.playSelectionSound();
            _isStudent.value = isStudent;
            // Intentionally keep `_selectedUniversityId` when toggling off —
            // the save payload and dirty-check already ignore it while
            // `_isStudent` is false, so preserving it lets the user toggle
            // back without losing their previous university pick.
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isSelected ? null : baseColor,
              gradient: isSelected
                  ? ThreeDSurfaceStyle.surfaceGradient(context, baseColor)
                  : null,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isSelected
                  ? ThreeDSurfaceStyle.elevatedShadows(context)
                  : ThreeDSurfaceStyle.insetRecessedShadows(context),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ThemeIcon(icon, color: iconColor, size: 20),
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildCountrySelectorTile(context)),
                const SizedBox(width: 12),
                Expanded(child: _buildRegionSelectorTile(context)),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Compact country tile that sits side-by-side with the region tile. Country
  /// is UI-only state on this screen: the server derives country from the
  /// selected region's `country_id`. Switching country clears an invalid
  /// region selection.
  Widget _buildCountrySelectorTile(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: _selectedCountryIso2,
      builder: (context, iso2, _) {
        final country = CountryCache.getCountryByIso2(iso2);
        final hasCountries = _countries.isNotEmpty;
        return _buildCompactLocationTile(
          context,
          label: L10n.get("country"),
          leading: country != null
              ? Text(
                  country.flag,
                  style: const TextStyle(fontSize: 20, height: 1.1),
                )
              : const Icon(Icons.public, size: 20),
          valueText: country != null
              ? country.getLocalizedName(LanguageState().currentLanguage)
              : L10n.get("tap_to_select_country"),
          isPlaceholder: country == null,
          onTap: hasCountries ? () => _showCountryPickerSheet(context) : null,
        );
      },
    );
  }

  Widget _buildRegionSelectorTile(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoadingRegions,
      builder: (context, isLoadingRegions, _) => ValueListenableBuilder<int?>(
        valueListenable: _selectedRegionId,
        builder: (context, regionId, __) => ValueListenableBuilder<String>(
          valueListenable: _selectedCountryIso2,
          builder: (context, iso2, ___) {
            // Regions are seeded only for Uzbekistan right now. For any
            // other country we show a gentle "not available" placeholder
            // rather than an empty disabled picker.
            final hasRegionsForCountry = iso2 == CountryCache.defaultIso2;
            const tileIcon = Icons.location_city;
            if (!hasRegionsForCountry) {
              return _buildCompactLocationTile(
                context,
                label: L10n.get("city"),
                leading: const Icon(tileIcon, size: 20),
                valueText: L10n.get("no_regions_for_country"),
                isPlaceholder: true,
                onTap: null,
              );
            }

            final iconColor =
                regionId == null ? null : _getRegionIconColorForId(regionId);
            return _buildCompactLocationTile(
              context,
              label: L10n.get("city"),
              leading: Icon(
                tileIcon,
                size: 20,
                color: iconColor,
              ),
              valueText: isLoadingRegions
                  ? L10n.get("loading_regions")
                  : _getSelectedRegionName(),
              isPlaceholder: regionId == null,
              isLoading: isLoadingRegions,
              onTap: isLoadingRegions || _regions.isEmpty
                  ? null
                  : () => _showRegionPickerSheet(context),
            );
          },
        ),
      ),
    );
  }

  /// Compact card used for the side-by-side country/region tiles. Mirrors the
  /// raised-neumorphic look of [_buildPickerTile] but in a denser layout with
  /// a small label on top to disambiguate the two columns.
  Widget _buildCompactLocationTile(
    BuildContext context, {
    required String label,
    required Widget leading,
    required String valueText,
    required bool isPlaceholder,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    final theme = Theme.of(context);
    final isBlueTheme = ThemeState().isBlueTheme;
    final baseColor =
        isBlueTheme ? BlueThemeColors.surface : theme.colorScheme.surface;
    final labelColor =
        isBlueTheme ? Colors.white70 : theme.colorScheme.onSurfaceVariant;
    final valueColor = isPlaceholder
        ? (isBlueTheme ? Colors.white70 : theme.colorScheme.onSurfaceVariant)
        : (isBlueTheme ? Colors.white : theme.colorScheme.onSurface);
    final chevronColor =
        isBlueTheme ? Colors.white : theme.colorScheme.onSurfaceVariant;
    final defaultLeadingColor =
        isBlueTheme ? Colors.white : theme.colorScheme.onSurfaceVariant;

    final tileRadius = BorderRadius.circular(14);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap == null
            ? null
            : () {
                HapticFeedbackUtils.impact();
                SendSoundUtils.playSelectionSound();
                onTap();
              },
        borderRadius: tileRadius,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: tileRadius,
            gradient: ThreeDSurfaceStyle.surfaceGradient(context, baseColor),
            boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                  color: labelColor,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  SizedBox(
                    width: 24,
                    child: Center(
                      child: IconTheme.merge(
                        data: IconThemeData(color: defaultLeadingColor),
                        child: leading,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      valueText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            isPlaceholder ? FontWeight.w500 : FontWeight.w600,
                        fontStyle:
                            isLoading ? FontStyle.italic : FontStyle.normal,
                        color: valueColor,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  ThemeIcon(
                    Icons.arrow_drop_down,
                    color: chevronColor,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
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
            ValueListenableBuilder<bool>(
              valueListenable: _isLoadingUniversities,
              builder: (context, isLoadingUniversities, _) =>
                  ValueListenableBuilder<int?>(
                valueListenable: _selectedUniversityId,
                builder: (context, _, __) => _buildPickerTile(
                  context,
                  icon: Icons.school,
                  iconColor: _selectedUniversityId.value == null
                      ? null
                      : _getUniversityIconColorForId(
                          _selectedUniversityId.value!,
                        ),
                  valueText: isLoadingUniversities
                      ? L10n.get("loading_universities")
                      : _getSelectedUniversityName(),
                  isPlaceholder: _selectedUniversityId.value == null,
                  isLoading: isLoadingUniversities,
                  onTap: isLoadingUniversities || _universities.isEmpty
                      ? null
                      : () => _showUniversityPickerSheet(context),
                ),
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

  String _getSelectedUniversityName() {
    if (_isLoadingUniversities.value) {
      return L10n.get("loading_universities");
    }

    if (_selectedUniversityId.value == null) {
      return L10n.get("select_university");
    }

    final idx = _universities.indexWhere(
      (u) => u.id == _selectedUniversityId.value,
    );
    if (idx < 0) return L10n.get("select_university");
    return _universities[idx]
        .getLocalizedNameCapitalized(LanguageState().currentLanguage);
  }

  Color? _getRegionIconColorForId(int regionId) {
    final idx = _regions.indexWhere((r) => r.id == regionId);
    if (idx < 0) return null;
    return _getRegionIconColorForIndex(idx + 1);
  }

  Color? _getUniversityIconColorForId(int universityId) {
    final idx = _universities.indexWhere((u) => u.id == universityId);
    if (idx < 0) return null;
    return _getUniversityIconColorForIndex(idx + 1);
  }

  /// A tappable neumorphic "plate" that displays an icon, the currently
  /// selected value, and a chevron. Opens a bottom-sheet picker on tap so
  /// the form doesn't scroll the selection by accident.
  Widget _buildPickerTile(
    BuildContext context, {
    required IconData icon,
    required String valueText,
    required bool isPlaceholder,
    required bool isLoading,
    required VoidCallback? onTap,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    final isBlueTheme = ThemeState().isBlueTheme;
    final baseColor =
        isBlueTheme ? BlueThemeColors.surface : theme.colorScheme.surface;
    final defaultIconColor =
        isBlueTheme ? Colors.white : theme.colorScheme.onSurfaceVariant;
    final valueColor = isPlaceholder
        ? (isBlueTheme ? Colors.white70 : theme.colorScheme.onSurfaceVariant)
        : (isBlueTheme ? Colors.white : theme.colorScheme.onSurface);
    final chevronColor =
        isBlueTheme ? Colors.white : theme.colorScheme.onSurfaceVariant;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap == null
            ? null
            : () {
                HapticFeedbackUtils.impact();
                SendSoundUtils.playSelectionSound();
                onTap();
              },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: ThreeDSurfaceStyle.surfaceGradient(context, baseColor),
            boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                ThemeIcon(
                  icon,
                  color: iconColor ?? defaultIconColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    valueText,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          isPlaceholder ? FontWeight.w500 : FontWeight.w600,
                      fontStyle:
                          isLoading ? FontStyle.italic : FontStyle.normal,
                      color: valueColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                ThemeIcon(
                  Icons.arrow_drop_down,
                  color: chevronColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCountryPickerSheet(BuildContext context) {
    // Guard against the picker opening before the async load finishes — the
    // cache resolves synchronously, but being defensive avoids an empty wheel.
    var countries = _countries;
    if (countries.isEmpty) {
      countries = CountryCache.getCountriesSortedByLanguage(
        LanguageState().currentLanguage,
      );
    }
    if (countries.isEmpty) {
      logger.d("Country picker requested but country list is empty");
      return;
    }
    var initialIndex = countries.indexWhere(
      (c) => c.iso2 == _selectedCountryIso2.value,
    );
    if (initialIndex < 0) initialIndex = 0;

    final controller = FixedExtentScrollController(initialItem: initialIndex);
    var pendingIso2 = countries[initialIndex].iso2;
    showAppBottomSheet<void>(
      context: context,
      useSafeArea: false,
      barrierColor: Colors.black.withValues(alpha: 0.06),
      builder: (sheetContext) {
        return _buildPickerBottomSheet(
          sheetContext: sheetContext,
          title: L10n.get("select_country"),
          controller: controller,
          itemExtent: 48,
          itemCount: countries.length,
          itemBuilder: (index) =>
              _buildCountryPickerSheetRow(sheetContext, countries[index]),
          onSelectedItemChanged: (index) {
            SendSoundUtils.playCupertinoWheelSound();
            pendingIso2 = countries[index].iso2;
          },
          onConfirm: () {
            final previousIso2 = _selectedCountryIso2.value;
            _selectedCountryIso2.value = pendingIso2;
            // Clear the region when moving away from a country whose regions
            // we render (currently only UZ). Keep the existing region when
            // staying within the same country.
            if (previousIso2 != pendingIso2 &&
                pendingIso2 != CountryCache.defaultIso2) {
              _selectedRegionId.value = null;
            }
            Navigator.of(sheetContext).pop();
          },
        );
      },
    ).whenComplete(controller.dispose);
  }

  Widget _buildCountryPickerSheetRow(BuildContext context, Country country) {
    final theme = Theme.of(context);
    final isBlueTheme = ThemeState().isBlueTheme;
    final textColor = isBlueTheme ? Colors.white : theme.colorScheme.onSurface;
    final isoColor = textColor.withValues(alpha: 0.55);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(country.flag, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                country.getLocalizedName(LanguageState().currentLanguage),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              country.iso2,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isoColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRegionPickerSheet(BuildContext context) {
    final initialItem = _getInitialRegionItem();
    final controller = FixedExtentScrollController(initialItem: initialItem);
    // Track a pending selection so dismissing the sheet without confirming
    // keeps the previous value (prevents accidental overwrites).
    var pendingRegionId = _selectedRegionId.value;
    showAppBottomSheet<void>(
      context: context,
      useSafeArea: false,
      barrierColor: Colors.black.withValues(alpha: 0.06),
      builder: (sheetContext) {
        return _buildPickerBottomSheet(
          sheetContext: sheetContext,
          title: L10n.get("select_region"),
          controller: controller,
          itemExtent: 48,
          itemCount: _regions.length + 1,
          itemBuilder: (index) {
            if (index == 0) {
              return _buildPickerSheetRow(
                sheetContext,
                icon: Icons.location_on,
                label: L10n.get("select_region"),
                iconColor: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                isPlaceholder: true,
              );
            }
            final region = _regions[index - 1];
            return _buildPickerSheetRow(
              sheetContext,
              icon: Icons.location_on,
              label: _getLocalizedRegionName(region),
              iconColor: _getRegionIconColorForIndex(index),
            );
          },
          onSelectedItemChanged: (index) {
            SendSoundUtils.playCupertinoWheelSound();
            pendingRegionId = index == 0 ? null : _regions[index - 1].id;
          },
          onConfirm: () {
            _selectedRegionId.value = pendingRegionId;
            if (pendingRegionId != null) {
              _selectedCountryIso2.value = CountryCache.defaultIso2;
            }
            Navigator.of(sheetContext).pop();
          },
        );
      },
    ).whenComplete(controller.dispose);
  }

  void _showUniversityPickerSheet(BuildContext context) {
    final initialItem = _getInitialUniversityItem();
    final controller = FixedExtentScrollController(initialItem: initialItem);
    var pendingUniversityId = _selectedUniversityId.value;
    showAppBottomSheet<void>(
      context: context,
      useSafeArea: false,
      barrierColor: Colors.black.withValues(alpha: 0.06),
      builder: (sheetContext) {
        return _buildPickerBottomSheet(
          sheetContext: sheetContext,
          title: L10n.get("select_university"),
          controller: controller,
          itemExtent: 56,
          itemCount: _universities.length + 1,
          itemBuilder: (index) {
            if (index == 0) {
              return _buildPickerSheetRow(
                sheetContext,
                icon: Icons.school,
                label: L10n.get("select_university"),
                iconColor: Theme.of(sheetContext).colorScheme.onSurfaceVariant,
                isPlaceholder: true,
              );
            }
            final university = _universities[index - 1];
            return _buildPickerSheetRow(
              sheetContext,
              icon: Icons.school,
              label: university.getLocalizedNameCapitalized(
                LanguageState().currentLanguage,
              ),
              iconColor: _getUniversityIconColorForIndex(index),
            );
          },
          onSelectedItemChanged: (index) {
            SendSoundUtils.playCupertinoWheelSound();
            pendingUniversityId =
                index == 0 ? null : _universities[index - 1].id;
          },
          onConfirm: () {
            _selectedUniversityId.value = pendingUniversityId;
            Navigator.of(sheetContext).pop();
          },
        );
      },
    ).whenComplete(controller.dispose);
  }

  Widget _buildPickerBottomSheet({
    required BuildContext sheetContext,
    required String title,
    required FixedExtentScrollController controller,
    required double itemExtent,
    required int itemCount,
    required Widget Function(int index) itemBuilder,
    required ValueChanged<int> onSelectedItemChanged,
    required VoidCallback onConfirm,
  }) {
    final theme = Theme.of(sheetContext);
    final isBlueTheme = ThemeState().isBlueTheme;
    final textColor = isBlueTheme ? Colors.white : theme.colorScheme.onSurface;
    final handleColor =
        (isBlueTheme ? Colors.white : Colors.black).withValues(alpha: 0.25);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: GlassBottomSheetSurface(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: handleColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
                SizedBox(
                  height: 220,
                  child: CupertinoPicker(
                    backgroundColor: Colors.transparent,
                    changeReportingBehavior:
                        ChangeReportingBehavior.onScrollEnd,
                    scrollController: controller,
                    itemExtent: itemExtent,
                    onSelectedItemChanged: onSelectedItemChanged,
                    children: [
                      for (var i = 0; i < itemCount; i++) itemBuilder(i),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: GhostButtonFactory.iconText(
                      onPressed: onConfirm,
                      icon: Icons.check,
                      text: L10n.get("confirm"),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      neumorphicSoftUi: true,
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

  Widget _buildPickerSheetRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color iconColor,
    bool isPlaceholder = false,
  }) {
    final theme = Theme.of(context);
    final isBlueTheme = ThemeState().isBlueTheme;
    final textColor = isPlaceholder
        ? (isBlueTheme ? Colors.white70 : theme.colorScheme.onSurfaceVariant)
        : (isBlueTheme ? Colors.white : theme.colorScheme.onSurface);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ThemeIcon(icon, color: iconColor, size: 18),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
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

class _EditProfileEmptyRequest implements IJsonEncodable {
  @override
  Map<String, dynamic> toJson() => const <String, dynamic>{};
}
