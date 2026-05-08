import "package:flutter/material.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/country.dart";
import "package:uy_dosh/domain/models/region.dart";
import "package:uy_dosh/domain/models/university.dart";
import "package:uy_dosh/presentation/screens/auth/auth_wizard_theme.dart";
import "package:uy_dosh/presentation/widgets/common/error_border_pulse.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";
import "package:uy_dosh/presentation/widgets/common/pressable_transform.dart";
import "package:uy_dosh/presentation/widgets/common/theme_icon.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_text_field.dart";

class AuthWizardProfilePage extends StatelessWidget {
  const AuthWizardProfilePage({
    required this.profileScrollController,
    required this.nameController,
    required this.selectedGender,
    required this.onGenderSelected,
    required this.selectedCountry,
    required this.onShowCountryPicker,
    required this.getCountryName,
    required this.selectedRegionId,
    required this.regions,
    required this.onShowRegionPicker,
    required this.selectedRole,
    required this.onRoleSelected,
    required this.isStudent,
    required this.onStudentSelected,
    required this.selectedUniversity,
    required this.universities,
    required this.onShowUniversityPicker,
    required this.isLoadingRegions,
    required this.isLoadingUniversities,
    required this.getRegionName,
    required this.getUniversityName,
    super.key,
    this.nameMissing = false,
    this.genderMissing = false,
    this.regionMissing = false,
    this.roleMissing = false,
    this.studentMissing = false,
    this.universityMissing = false,
  });

  final ScrollController profileScrollController;
  final TextEditingController nameController;
  final int? selectedGender;
  final ValueChanged<int?> onGenderSelected;
  final Country? selectedCountry;
  final VoidCallback onShowCountryPicker;
  final String Function(Country) getCountryName;
  final int? selectedRegionId;
  final List<Region> regions;
  final VoidCallback onShowRegionPicker;
  final String? selectedRole;
  final ValueChanged<String?> onRoleSelected;
  final bool? isStudent;
  final ValueChanged<bool?> onStudentSelected;
  final University? selectedUniversity;
  final List<University> universities;
  final VoidCallback onShowUniversityPicker;
  final bool isLoadingRegions;
  final bool isLoadingUniversities;
  final String Function(Region) getRegionName;
  final String Function(University) getUniversityName;

  /// When true, the corresponding control(s) render a pulsing red border to
  /// indicate that the user attempted to submit the form without filling
  /// the field. The parent screen sets these flags after a failed
  /// validation pass and resets them as the user touches each field.
  ///
  /// For groups (gender / role / student) the flag covers both pills in the
  /// row so it's visually clear that *one of them* must be picked.
  final bool nameMissing;
  final bool genderMissing;
  final bool regionMissing;
  final bool roleMissing;
  final bool studentMissing;
  final bool universityMissing;

  Color _getOnboardingTextColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  Color _getOnboardingTextSecondaryColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  /// Neutral card surface used as the raised neumorphic base. Kept close to the
  /// onboarding background so the dual shadows do the talking.
  Color _getRaisedSurfaceColor(BuildContext context) =>
      Theme.of(context).colorScheme.surface;

  /// Tinted surface used when a card is in its "selected" (recessed) state. We
  /// fall back to the color scheme's primary for themes where
  /// [AuthWizardTheme.getSelectedButtonBackgroundColor] is transparent.
  Color _getSelectedSurfaceColor(BuildContext context) {
    final selected = AuthWizardTheme.getSelectedButtonBackgroundColor();
    if (selected == Colors.transparent) {
      return Theme.of(context).colorScheme.primary;
    }
    return selected;
  }

  /// Raised vs. recessed decoration shared by every card-like tap target on
  /// this page (gender, role, student, country, city, university). Selection
  /// is conveyed through depth + a subtle colour tint rather than hard borders.
  BoxDecoration _neumorphicCardDecoration(
    BuildContext context, {
    required bool isSelected,
    BorderRadius borderRadius = const BorderRadius.all(Radius.circular(12)),
  }) {
    final base = isSelected
        ? _getSelectedSurfaceColor(context)
        : _getRaisedSurfaceColor(context);
    return BoxDecoration(
      borderRadius: borderRadius,
      gradient: ThreeDSurfaceStyle.surfaceGradient(context, base),
      boxShadow: isSelected
          ? ThreeDSurfaceStyle.insetRecessedShadows(context)
          : ThreeDSurfaceStyle.elevatedShadows(context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: profileScrollController,
      child: Container(
        padding: const EdgeInsets.only(left: 36, right: 36, top: 16, bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            L10n.text(
              "complete_profile_subheader",
              style: TextStyle(
                fontSize: 16,
                color: _getOnboardingTextSecondaryColor(context),
              ),
            ),
            const SizedBox(height: 16),
            L10n.text(
              "full_name",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _getOnboardingTextColor(context),
              ),
            ),
            const SizedBox(height: 16),
            ThreeDTextField(
              controller: nameController,
              hintText: L10n.get("full_name_hint"),
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              onTap: HapticFeedbackUtils.impact,
              showErrorBorder: nameMissing,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Flexible(
                  child: ErrorBorderPulse(
                    showError: genderMissing,
                    child: _buildGenderOption(
                      context,
                      1,
                      L10n.get("male"),
                      Icons.male,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Flexible(
                  child: ErrorBorderPulse(
                    showError: genderMissing,
                    child: _buildGenderOption(
                      context,
                      2,
                      L10n.get("female"),
                      Icons.female,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                L10n.text(
                  "select_region_profile_creation_title",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: _getOnboardingTextColor(context),
                  ),
                ),
                const SizedBox(height: 4),
                L10n.text(
                  "select_region_profile_creation_description",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: _getOnboardingTextColor(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildCountrySelector(context)),
                const SizedBox(width: 12),
                Expanded(
                  child: ErrorBorderPulse(
                    showError: regionMissing,
                    child: _buildCitySelectorColumn(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            L10n.text(
              "are_you_landlord_or_renter",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _getOnboardingTextColor(context),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Flexible(
                  child: ErrorBorderPulse(
                    showError: roleMissing,
                    child: _buildRoleOption(
                      context,
                      "landlord",
                      L10n.get("role_landlord"),
                      Icons.home_work,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Flexible(
                  child: ErrorBorderPulse(
                    showError: roleMissing,
                    child: _buildRoleOption(
                      context,
                      "tenant",
                      L10n.get("role_tenant"),
                      Icons.key,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            L10n.text(
              "are_you_student",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _getOnboardingTextColor(context),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Flexible(
                  child: ErrorBorderPulse(
                    showError: studentMissing,
                    child: _buildStudentOption(
                      context,
                      true,
                      L10n.get("yes_student"),
                      Icons.school,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Flexible(
                  child: ErrorBorderPulse(
                    showError: studentMissing,
                    child: _buildStudentOption(
                      context,
                      false,
                      L10n.get("no_student"),
                      Icons.work,
                    ),
                  ),
                ),
              ],
            ),
            if (isStudent ?? false) ...[
              const SizedBox(height: 32),
              if (isLoadingUniversities)
                _buildLoadingCard(
                  context,
                  L10n.get("loading_universities"),
                )
              else if (universities.isNotEmpty)
                ErrorBorderPulse(
                  showError: universityMissing,
                  child: _buildUniversitySelector(context),
                )
              else if (!isLoadingUniversities)
                _buildEmptyCard(
                  context,
                  L10n.get("no_universities_available"),
                ),
              const SizedBox(height: 100),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingCard(BuildContext context, String text) {
    return DecoratedBox(
      decoration: _neumorphicCardDecoration(context, isSelected: false),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: CenteredHouseLoadingIndicator(
          text: text,
          textStyle: TextStyle(
            color: _getOnboardingTextColor(context),
            fontSize: 16,
          ),
          size: 20,
        ),
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context, String text) {
    return DecoratedBox(
      decoration: _neumorphicCardDecoration(context, isSelected: false),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Text(
          text,
          style: TextStyle(
            color: _getOnboardingTextSecondaryColor(context),
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildGenderOption(
    BuildContext context,
    int gender,
    String label,
    IconData icon,
  ) {
    return _buildToggleOption(
      context,
      isSelected: selectedGender == gender,
      label: label,
      icon: icon,
      onTap: () => onGenderSelected(gender),
    );
  }

  Widget _buildRoleOption(
    BuildContext context,
    String role,
    String label,
    IconData icon,
  ) {
    return _buildToggleOption(
      context,
      isSelected: selectedRole == role,
      label: label,
      icon: icon,
      onTap: () => onRoleSelected(role),
    );
  }

  Widget _buildStudentOption(
    BuildContext context,
    bool studentValue,
    String label,
    IconData icon,
  ) {
    return _buildToggleOption(
      context,
      isSelected: isStudent == studentValue,
      label: label,
      icon: icon,
      onTap: () => onStudentSelected(studentValue),
    );
  }

  /// Shared soft-UI pill used by the gender, role, and student toggles. Raised
  /// neumorphic shell when unselected; recessed + tinted when selected.
  Widget _buildToggleOption(
    BuildContext context, {
    required bool isSelected,
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final contentColor = isSelected
        ? AuthWizardTheme.getSelectedButtonTextColor()
        : _getOnboardingTextColor(context);
    return PressableTransform(
      onTap: () {
        HapticFeedbackUtils.impact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: DecoratedBox(
        decoration: _neumorphicCardDecoration(
          context,
          isSelected: isSelected,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: contentColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                textAlign: TextAlign.left,
              ),
              const SizedBox(width: 12),
              ThemeIcon(icon, color: contentColor, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Country selector (compact, half-width). Always has a selection since
  /// Uzbekistan is preselected on mount.
  Widget _buildCountrySelector(BuildContext context) {
    return _buildCompactSelectorShell(
      context,
      label: L10n.get("country"),
      isSelected: selectedCountry != null,
      onTap: onShowCountryPicker,
      leading: selectedCountry != null
          ? Text(
              selectedCountry!.flag,
              style: const TextStyle(fontSize: 22, height: 1.1),
            )
          : ThemeIcon(
              Icons.public,
              color: _getOnboardingTextSecondaryColor(context),
              size: 22,
            ),
      value: selectedCountry != null
          ? getCountryName(selectedCountry!)
          : L10n.get("tap_to_select_country"),
    );
  }

  /// Column that mirrors the country selector's height by using the same
  /// compact shell, but additionally handles loading / empty states for
  /// regions.
  Widget _buildCitySelectorColumn(BuildContext context) {
    if (isLoadingRegions) {
      return _buildLoadingCard(context, L10n.get("loading_regions"));
    }
    if (regions.isEmpty) {
      return _buildEmptyCard(
        context,
        L10n.get("no_regions_for_country"),
      );
    }
    return _buildCitySelector(context);
  }

  Widget _buildCitySelector(BuildContext context) {
    final hasSelection = selectedRegionId != null;
    String? value;
    if (hasSelection) {
      try {
        value = getRegionName(
          regions.firstWhere((r) => r.id == selectedRegionId),
        );
      } catch (_) {
        // Selected region id no longer in the filtered list (e.g. after
        // changing country). Fall through to the placeholder.
        value = null;
      }
    }

    return _buildCompactSelectorShell(
      context,
      label: L10n.get("city"),
      isSelected: value != null,
      onTap: onShowRegionPicker,
      leading: ThemeIcon(
        Icons.location_city,
        color: value != null
            ? AuthWizardTheme.getSelectedButtonTextColor()
            : _getOnboardingTextSecondaryColor(context),
        size: 22,
      ),
      value: value ?? L10n.get("tap_to_select_region"),
    );
  }

  /// Shared compact selector card used for both country and city. Shows a
  /// small label on top and a `leading + value + chevron` row underneath.
  /// Designed to fit comfortably in half of the onboarding content width.
  Widget _buildCompactSelectorShell(
    BuildContext context, {
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required Widget leading,
    required String value,
  }) {
    return PressableTransform(
      onTap: () {
        HapticFeedbackUtils.impact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: DecoratedBox(
        decoration: _neumorphicCardDecoration(
          context,
          isSelected: isSelected,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isSelected
                      ? AuthWizardTheme.getSelectedButtonTextColor()
                            .withOpacity(0.8)
                      : _getOnboardingTextSecondaryColor(context),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  SizedBox(width: 24, child: Center(child: leading)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      value,
                      style: TextStyle(
                        color: isSelected
                            ? AuthWizardTheme.getSelectedButtonTextColor()
                            : _getOnboardingTextColor(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  ThemeIcon(
                    isSelected ? Icons.check_circle : Icons.arrow_drop_down,
                    color: isSelected
                        ? AuthWizardTheme.getSelectedButtonTextColor()
                        : _getOnboardingTextSecondaryColor(context),
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

  Widget _buildUniversitySelector(BuildContext context) {
    final isSelected = selectedUniversity != null;
    final selectedTextColor = AuthWizardTheme.getSelectedButtonTextColor();
    return PressableTransform(
      onTap: () {
        HapticFeedbackUtils.impact();
        onShowUniversityPicker();
      },
      borderRadius: BorderRadius.circular(12),
      child: DecoratedBox(
        decoration: _neumorphicCardDecoration(
          context,
          isSelected: isSelected,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              ThemeIcon(
                Icons.school,
                color: isSelected
                    ? selectedTextColor
                    : _getOnboardingTextSecondaryColor(context),
                size: 24,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isSelected) ...[
                      Text(
                        getUniversityName(selectedUniversity!),
                        style: TextStyle(
                          color: selectedTextColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      L10n.text(
                        "selected",
                        style: TextStyle(
                          color: selectedTextColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ] else ...[
                      Text(
                        L10n.get("tap_to_select_university"),
                        style: TextStyle(
                          color: _getOnboardingTextSecondaryColor(context),
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              ThemeIcon(
                isSelected ? Icons.check_circle : Icons.arrow_drop_down,
                color: isSelected
                    ? selectedTextColor
                    : _getOnboardingTextSecondaryColor(context),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
