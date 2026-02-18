import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/injection/injection.dart";
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
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
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
  late int _selectedGender;
  late int? _selectedRegionId;
  late int? _selectedUniversityId;
  List<Region> _regions =
      []; // Initialize to empty list to avoid LateInitializationError
  List<University> _universities =
      []; // Initialize to empty list to avoid LateInitializationError
  bool _isLoading = false;
  bool _isLoadingRegions = true;
  bool _isLoadingUniversities = true;

  String _selectedRole = "tenant";
  bool _isAdmin = false;
  bool _isRoleLoaded = false;

  // Scroll controllers for wheel pickers
  FixedExtentScrollController? _regionScrollController;
  FixedExtentScrollController? _universityScrollController;

  // New profile fields
  bool? _employed;
  int? _cleanliness;
  int? _noiseLevel;
  int? _sociability;
  bool? _guestsAllowed;
  String? _smokingPreference;
  String? _alcoholPreference;
  bool? _cookingHabits;
  bool? _petsPreference;
  String? _wakeupTime;
  String? _sleepTime;

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
    _selectedGender = widget.profile.gender ?? 1;
    _selectedRegionId =
        widget.profile.regionId; // Initialize with profile value
    _selectedUniversityId = widget.profile.universityId;

    // Initialize new profile fields
    _employed = widget.profile.employed;
    _cleanliness = widget.profile.cleanliness;
    _noiseLevel = widget.profile.noiseLevel;
    _sociability = widget.profile.sociability;
    _guestsAllowed = widget.profile.guestsAllowed;
    _smokingPreference = widget.profile.smokingPreference;
    _alcoholPreference = widget.profile.alcoholPreference;
    _cookingHabits = widget.profile.cookingHabits;
    _petsPreference = widget.profile.petsPreference;
    _wakeupTime = widget.profile.wakeupTime;
    _sleepTime = widget.profile.sleepTime;

    _loadRegions();
    _loadUniversities();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final role = await SessionManager.getUserRole();
    if (mounted) {
      setState(() {
        _isAdmin = role == "admin";
        _selectedRole = (role == "admin" || role == "landlord") ? role! : "tenant";
        _isRoleLoaded = true;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutMeController.dispose();
    _telegramController.dispose();
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

      setState(() {
        _regions = regions;
        _isLoadingRegions = false;

        // Set the selected region based on the profile's regionId
        if (widget.profile.regionId != null) {
          final regionExists = regions.any(
            (region) => region.id == widget.profile.regionId,
          );

          if (regionExists) {
            _selectedRegionId = widget.profile.regionId;
          } else {
            _selectedRegionId = null;
          }
        } else {
          _selectedRegionId = null;
        }
      });

      // Initialize scroll controller after regions are loaded
      _initializeRegionScrollController();
    } catch (e) {
      setState(() {
        _isLoadingRegions = false;
      });
      if (mounted) {
        ToastTheme.showError(
          context,
          message: LanguageAwareStringHelper.getCurrent(
            context,
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
      setState(() {
        _universities = universities;
        _isLoadingUniversities = false;
      });

      // Initialize scroll controller after universities are loaded
      _initializeUniversityScrollController();
    } catch (e) {
      setState(() {
        _isLoadingUniversities = false;
      });
      if (mounted) {
        ToastTheme.showError(
          context,
          message: LanguageAwareStringHelper.getCurrent(
            context,
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
        message: LanguageAwareStringHelper.getCurrent(context, "name_required"),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Validate and prepare the data
      final name = _nameController.text.trim();
      final gender = _selectedGender;
      final regionId = _selectedRegionId;
      final universityId = _selectedUniversityId;

      // Handle about me text: if it's empty, send null to clear it; if it has content, send the content
      final aboutMe = _aboutMeController.text.trim();
      final aboutMeToSend = aboutMe.isEmpty ? null : aboutMe;

      // Handle telegram text: if it's empty, send null to clear it; if it has content, send the content
      final telegram = _telegramController.text.trim();
      final telegramToSend = telegram.isEmpty ? null : telegram;

      // Preserve admin role: check actual role at save time to avoid overwriting
      // when dropdown wasn't loaded yet (race condition)
      final currentRole = await SessionManager.getUserRole();
      final roleToSave = (currentRole == "admin") ? "admin" : _selectedRole;

      final updateRequest = UpdateProfileRequest(
        name: name,
        gender: gender,
        regionId: regionId,
        universityId: universityId,
        role: roleToSave,
        aboutMe: aboutMeToSend,
        telegram: telegramToSend,
        employed: _employed,
        cleanliness: _cleanliness,
        noiseLevel: _noiseLevel,
        sociability: _sociability,
        guestsAllowed: _guestsAllowed,
        smokingPreference: _smokingPreference,
        alcoholPreference: _alcoholPreference,
        cookingHabits: _cookingHabits,
        petsPreference: _petsPreference,
        wakeupTime: _wakeupTime,
        sleepTime: _sleepTime,
      );

      // Debug logging to see what values are being sent
      logger.d("🔍 [EditProfileScreen] Update request values:");
      logger.d("  - telegram: $telegramToSend");
      logger.d("  - smokingPreference: $_smokingPreference");
      logger.d("  - alcoholPreference: $_alcoholPreference");
      logger.d("  - wakeupTime: $_wakeupTime");
      logger.d("  - sleepTime: $_sleepTime");
      logger.d("  - employed: $_employed");
      logger.d("  - cleanliness: $_cleanliness");
      logger.d("  - noiseLevel: $_noiseLevel");
      logger.d("  - sociability: $_sociability");
      logger.d("  - guestsAllowed: $_guestsAllowed");
      logger.d("  - cookingHabits: $_cookingHabits");
      logger.d("  - petsPreference: $_petsPreference");

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
          message: LanguageAwareStringHelper.getCurrent(
            context,
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
          message: LanguageAwareStringHelper.getCurrent(
            context,
            "error_updating_profile",
          ).replaceAll("{error}", e.toString()),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LanguageAwareStringHelper.getCurrent(context, "edit_profile"),
          style: theme.appBarTheme.titleTextStyle,
        ),
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary,
        foregroundColor:
            theme.appBarTheme.foregroundColor ?? theme.colorScheme.onPrimary,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              onPressed: _isLoading ? null : _saveProfile,
              icon:
                  _isLoading
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
                      : const Icon(Icons.save),
              tooltip: LanguageAwareStringHelper.getCurrent(
                context,
                "save_changes",
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
              label: LanguageAwareStringHelper.getCurrent(context, "name"),
              controller: _nameController,
              icon: Icons.person,
            ),

            const SizedBox(height: 24),

            // Gender Selector
            _buildGenderSelector(context),

            const SizedBox(height: 24),

            // Region Selector
            _buildRegionSelector(context),

            // University Selector (only show when user is a student, i.e. universityId is set)
            if (widget.profile.universityId != null) ...[
              const SizedBox(height: 24),
              _buildUniversitySelector(context),
            ],

            const SizedBox(height: 24),

            // About Me Field
            _buildTextField(
              label: LanguageAwareStringHelper.getCurrent(context, "about_me"),
              controller: _aboutMeController,
              icon: Icons.info,
              maxLines: 3,
            ),

            const SizedBox(height: 24),

            // Telegram Field
            _buildTextField(
              label: LanguageAwareStringHelper.getCurrent(context, "telegram"),
              controller: _telegramController,
              icon: Icons.telegram,
            ),

            const SizedBox(height: 24),

            // Role Dropdown (landlord / tenant; admin option when user is admin)
            if (!_isRoleLoaded)
              _buildRoleLoadingPlaceholder(context)
            else
              ProfileDropdownControl(
                label: LanguageAwareStringHelper.getCurrent(
                  context,
                  "are_you_landlord_or_renter",
                ),
                value: _selectedRole,
                onChanged: (value) => setState(() => _selectedRole = value ?? "tenant"),
                icon: Icons.badge,
                options: [
                  if (_isAdmin)
                    DropdownOption(
                      value: "admin",
                      label: LanguageAwareStringHelper.getCurrent(
                        context,
                        "role_admin",
                      ),
                    ),
                  DropdownOption(
                    value: "landlord",
                    label: LanguageAwareStringHelper.getCurrent(
                      context,
                      "role_landlord",
                    ),
                  ),
                  DropdownOption(
                    value: "tenant",
                    label: LanguageAwareStringHelper.getCurrent(
                      context,
                      "role_tenant",
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // New Profile Fields Section
            Text(
              LanguageAwareStringHelper.getCurrent(
                context,
                "lifestyle_preferences",
              ),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: _getLifestyleHeaderColor(),
              ),
            ),

            const SizedBox(height: 16),

            // Employed Toggle
            ProfileToggleControl(
              label: LanguageAwareStringHelper.getCurrent(context, "employed"),
              value: _employed,
              onChanged: (value) => setState(() => _employed = value),
              icon: Icons.work,
            ),

            const SizedBox(height: 16),

            // Cleanliness Slider
            ProfileSliderControl(
              label: LanguageAwareStringHelper.getCurrent(
                context,
                "cleanliness",
              ),
              value: _cleanliness,
              onChanged: (value) => setState(() => _cleanliness = value),
              min: 1,
              max: 5,
              icon: Icons.cleaning_services,
              labels: [
                LanguageAwareStringHelper.getCurrent(context, "very_messy"),
                LanguageAwareStringHelper.getCurrent(context, "messy"),
                LanguageAwareStringHelper.getCurrent(context, "average"),
                LanguageAwareStringHelper.getCurrent(context, "clean"),
                LanguageAwareStringHelper.getCurrent(context, "very_clean"),
              ],
            ),

            const SizedBox(height: 16),

            // Noise Level Slider
            ProfileSliderControl(
              label: LanguageAwareStringHelper.getCurrent(
                context,
                "noise_level",
              ),
              value: _noiseLevel,
              onChanged: (value) => setState(() => _noiseLevel = value),
              min: 1,
              max: 5,
              icon: Icons.volume_up,
              labels: [
                LanguageAwareStringHelper.getCurrent(context, "very_quiet"),
                LanguageAwareStringHelper.getCurrent(context, "quiet"),
                LanguageAwareStringHelper.getCurrent(context, "average"),
                LanguageAwareStringHelper.getCurrent(context, "loud"),
                LanguageAwareStringHelper.getCurrent(context, "very_loud"),
              ],
            ),

            const SizedBox(height: 16),

            // Sociability Slider
            ProfileSliderControl(
              label: LanguageAwareStringHelper.getCurrent(
                context,
                "sociability",
              ),
              value: _sociability,
              onChanged: (value) => setState(() => _sociability = value),
              min: 1,
              max: 5,
              icon: Icons.people,
              labels: [
                LanguageAwareStringHelper.getCurrent(
                  context,
                  "very_introverted",
                ),
                LanguageAwareStringHelper.getCurrent(context, "introverted"),
                LanguageAwareStringHelper.getCurrent(context, "balanced"),
                LanguageAwareStringHelper.getCurrent(context, "extroverted"),
                LanguageAwareStringHelper.getCurrent(
                  context,
                  "very_extroverted",
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Guests Allowed Toggle
            ProfileToggleControl(
              label: LanguageAwareStringHelper.getCurrent(
                context,
                "guests_allowed",
              ),
              value: _guestsAllowed,
              onChanged: (value) => setState(() => _guestsAllowed = value),
              icon: Icons.group_add,
            ),

            const SizedBox(height: 16),

            // Smoking Preference Dropdown
            ProfileDropdownControl(
              label: LanguageAwareStringHelper.getCurrent(
                context,
                "smoking_preference",
              ),
              value: _smokingPreference,
              onChanged: (value) => setState(() => _smokingPreference = value),
              icon: Icons.smoking_rooms,
              options: [
                DropdownOption(
                  value: null,
                  label: LanguageAwareStringHelper.getCurrent(
                    context,
                    "not_specified",
                  ),
                ),
                DropdownOption(
                  value: "non-smoker",
                  label: LanguageAwareStringHelper.getCurrent(
                    context,
                    "non_smoker",
                  ),
                ),
                DropdownOption(
                  value: "occasional",
                  label: LanguageAwareStringHelper.getCurrent(
                    context,
                    "occasional_smoker",
                  ),
                ),
                DropdownOption(
                  value: "regular",
                  label: LanguageAwareStringHelper.getCurrent(
                    context,
                    "regular_smoker",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Alcohol Preference Dropdown
            ProfileDropdownControl(
              label: LanguageAwareStringHelper.getCurrent(
                context,
                "alcohol_preference",
              ),
              value: _alcoholPreference,
              onChanged: (value) => setState(() => _alcoholPreference = value),
              icon: Icons.local_bar,
              options: [
                DropdownOption(
                  value: null,
                  label: LanguageAwareStringHelper.getCurrent(
                    context,
                    "not_specified",
                  ),
                ),
                DropdownOption(
                  value: "non-drinker",
                  label: LanguageAwareStringHelper.getCurrent(
                    context,
                    "non_drinker",
                  ),
                ),
                DropdownOption(
                  value: "occasional",
                  label: LanguageAwareStringHelper.getCurrent(
                    context,
                    "occasional_drinker",
                  ),
                ),
                DropdownOption(
                  value: "regular",
                  label: LanguageAwareStringHelper.getCurrent(
                    context,
                    "regular_drinker",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Cooking Habits Toggle
            ProfileToggleControl(
              label: LanguageAwareStringHelper.getCurrent(
                context,
                "cooking_habits",
              ),
              value: _cookingHabits,
              onChanged: (value) => setState(() => _cookingHabits = value),
              icon: Icons.restaurant,
            ),

            const SizedBox(height: 16),

            // Pets Preference Toggle
            ProfileToggleControl(
              label: LanguageAwareStringHelper.getCurrent(
                context,
                "pets_preference",
              ),
              value: _petsPreference,
              onChanged: (value) => setState(() => _petsPreference = value),
              icon: Icons.pets,
            ),

            const SizedBox(height: 16),

            // Wake-up Time Dropdown
            ProfileDropdownControl(
              label: LanguageAwareStringHelper.getCurrent(
                context,
                "wakeup_time",
              ),
              value: _wakeupTime,
              onChanged: (value) => setState(() => _wakeupTime = value),
              icon: Icons.wb_sunny,
              options: [
                DropdownOption(
                  value: null,
                  label: LanguageAwareStringHelper.getCurrent(
                    context,
                    "not_specified",
                  ),
                ),
                DropdownOption(
                  value: "morning",
                  label: LanguageAwareStringHelper.getCurrent(
                    context,
                    "morning",
                  ),
                ),
                DropdownOption(
                  value: "evening",
                  label: LanguageAwareStringHelper.getCurrent(
                    context,
                    "evening",
                  ),
                ),
                DropdownOption(
                  value: "night",
                  label: LanguageAwareStringHelper.getCurrent(context, "night"),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Sleep Time Dropdown
            ProfileDropdownControl(
              label: LanguageAwareStringHelper.getCurrent(
                context,
                "sleep_time",
              ),
              value: _sleepTime,
              onChanged: (value) => setState(() => _sleepTime = value),
              icon: Icons.bedtime,
              options: [
                DropdownOption(
                  value: null,
                  label: LanguageAwareStringHelper.getCurrent(
                    context,
                    "not_specified",
                  ),
                ),
                DropdownOption(
                  value: "morning",
                  label: LanguageAwareStringHelper.getCurrent(
                    context,
                    "morning",
                  ),
                ),
                DropdownOption(
                  value: "evening",
                  label: LanguageAwareStringHelper.getCurrent(
                    context,
                    "evening",
                  ),
                ),
                DropdownOption(
                  value: "night",
                  label: LanguageAwareStringHelper.getCurrent(context, "night"),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: GhostButtonFactory.iconText(
                onPressed: _isLoading ? null : _saveProfile,
                icon: Icons.save,
                text:
                    _isLoading
                        ? LanguageAwareStringHelper.getCurrent(
                          context,
                          "saving",
                        )
                        : LanguageAwareStringHelper.getCurrent(
                          context,
                          "save_changes",
                        ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                isLoading: _isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleLoadingPlaceholder(BuildContext context) {
    final theme = Theme.of(context);
    final isBlueTheme = ThemeState().isBlueTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color:
            isBlueTheme
                ? BlueThemeColors.surface
                : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(
              Icons.badge,
              color:
                  isBlueTheme
                      ? Colors.white
                      : theme.colorScheme.onSurfaceVariant,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                LanguageAwareStringHelper.getCurrent(
                  context,
                  "are_you_landlord_or_renter",
                ),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color:
                      isBlueTheme
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
            prefixIcon: Icon(icon, color: theme.colorScheme.onSurfaceVariant),
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
            fillColor:
                isBlueTheme
                    ? BlueThemeColors.surface
                    : theme.colorScheme.surfaceContainerHighest,
          ),
        ),
      ],
    );
  }

  Widget _buildGenderSelector(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LanguageAwareStringHelper.getCurrent(context, "gender"),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _getLifestyleHeaderColor(),
          ),
        ),
        const SizedBox(height: 8),
        GenderPicker(
          selectedGender: _selectedGender,
          onGenderChanged: (gender) {
            setState(() {
              _selectedGender = gender;
            });
          },
          showArrows: false,
        ),
      ],
    );
  }

  Widget _buildRegionSelector(BuildContext context) {
    final theme = Theme.of(context);
    final isBlueTheme = ThemeState().isBlueTheme;
    return ListenableBuilder(
      listenable: LanguageState(),
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LanguageAwareStringHelper.getCurrent(context, "im_from"),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _getLifestyleHeaderColor(),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color:
                    isBlueTheme
                        ? BlueThemeColors.surface
                        : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              height: 80,
              child: Row(
                children: [
                  Expanded(
                    child:
                        _isLoadingRegions
                            ? Center(
                              child: Text(
                                LanguageAwareStringHelper.getCurrent(
                                  context,
                                  "loading_regions",
                                ),
                                style: TextStyle(
                                  color:
                                      ThemeState().isBlueTheme
                                          ? Colors.white
                                          : Colors.black,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            )
                            : _regionScrollController != null
                            ? CupertinoPicker(
                              itemExtent: 40,
                              scrollController: _regionScrollController,
                              onSelectedItemChanged: (index) {
                                HapticFeedbackUtils.impact();
                                SendSoundUtils.playSelectionSound();
                                setState(() {
                                  if (index == 0) {
                                    // "Select region" option
                                    _selectedRegionId = null;
                                  } else {
                                    // Get the actual region ID from the selected index
                                    final regionIndex = index - 1;
                                    if (regionIndex < _regions.length) {
                                      _selectedRegionId =
                                          _regions[regionIndex].id;
                                    }
                                  }
                                });
                              },
                              children: [
                                // Unselected option
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        LanguageAwareStringHelper.getCurrent(
                                          context,
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
                                ..._regions
                                    .asMap()
                                    .entries
                                    .map(
                                      (entry) => Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
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
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      ThemeState().isBlueTheme
                                                          ? Colors.white
                                                          : Colors.black,
                                                ),
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    ,
                              ],
                            )
                            : Center(
                              child: Text(
                                LanguageAwareStringHelper.getCurrent(
                                  context,
                                  "loading_regions",
                                ),
                                style: TextStyle(
                                  color:
                                      ThemeState().isBlueTheme
                                          ? Colors.white
                                          : Colors.black,
                                  fontStyle: FontStyle.italic,
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
    if (_selectedRegionId == null) {
      return 0;
    }

    // Find the index of the selected region ID in the wheel picker
    final regionIndex = _regions.indexWhere(
      (region) => region.id == _selectedRegionId,
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
      Colors.pink,
    ];
    return colors[(index - 1) % colors.length];
  }

  Widget _buildUniversitySelector(BuildContext context) {
    final theme = Theme.of(context);
    final isBlueTheme = ThemeState().isBlueTheme;
    return ListenableBuilder(
      listenable: LanguageState(),
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LanguageAwareStringHelper.getCurrent(context, "university"),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: _getLifestyleHeaderColor(),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color:
                    isBlueTheme
                        ? BlueThemeColors.surface
                        : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: theme.colorScheme.outline),
              ),
              height: 120,
              child: Row(
                children: [
                  Expanded(
                    child:
                        _isLoadingUniversities
                            ? Center(
                              child: Text(
                                LanguageAwareStringHelper.getCurrent(
                                  context,
                                  "loading_universities",
                                ),
                                style: TextStyle(
                                  color:
                                      ThemeState().isBlueTheme
                                          ? Colors.white
                                          : Colors.black,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            )
                            : _universityScrollController != null
                            ? CupertinoPicker(
                              itemExtent: 50,
                              scrollController: _universityScrollController,
                              onSelectedItemChanged: (index) {
                                HapticFeedbackUtils.impact();
                                SendSoundUtils.playSelectionSound();
                                setState(() {
                                  if (index == 0) {
                                    // "Select university" option
                                    _selectedUniversityId = null;
                                  } else {
                                    // Get the actual university ID from the selected index
                                    final universityIndex = index - 1;
                                    if (universityIndex <
                                        _universities.length) {
                                      _selectedUniversityId =
                                          _universities[universityIndex].id;
                                    }
                                  }
                                });
                              },
                              children: [
                                // Unselected option
                                Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.school,
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        LanguageAwareStringHelper.getCurrent(
                                          context,
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
                                ..._universities
                                    .asMap()
                                    .entries
                                    .map(
                                      (entry) => Center(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
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
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      ThemeState().isBlueTheme
                                                          ? Colors.white
                                                          : Colors.black,
                                                ),
                                                textAlign: TextAlign.center,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                    ,
                              ],
                            )
                            : Center(
                              child: Text(
                                LanguageAwareStringHelper.getCurrent(
                                  context,
                                  "loading_universities",
                                ),
                                style: TextStyle(
                                  color:
                                      ThemeState().isBlueTheme
                                          ? Colors.white
                                          : Colors.black,
                                  fontStyle: FontStyle.italic,
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
    if (_selectedUniversityId == null) {
      return 0;
    }

    // Find the index of the selected university ID in the wheel picker
    final universityIndex = _universities.indexWhere(
      (university) => university.id == _selectedUniversityId,
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
      Colors.pink,
      Colors.red,
    ];
    return colors[(index - 1) % colors.length];
  }

  String _getSelectedRegionName() {
    if (_isLoadingRegions) {
      return LanguageAwareStringHelper.getCurrent(context, "loading_regions");
    }

    if (_selectedRegionId == null) {
      return LanguageAwareStringHelper.getCurrent(context, "select_region");
    }

    final selectedRegion = _regions.firstWhere(
      (region) => region.id == _selectedRegionId,
      orElse:
          () => Region(
            id: 0,
            name: LanguageAwareStringHelper.getCurrent(context, "unknown"),
            shortName: LanguageAwareStringHelper.getCurrent(context, "unknown"),
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
