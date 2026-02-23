import "package:flutter/material.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/domain/models/region.dart";
import "package:uy_dosh/domain/models/university.dart";
import "package:uy_dosh/presentation/screens/auth/auth_wizard_theme.dart";
import "package:uy_dosh/presentation/widgets/common/house_loading_indicator.dart";

class AuthWizardProfilePage extends StatelessWidget {
  const AuthWizardProfilePage({
    super.key,
    required this.profileScrollController,
    required this.nameController,
    required this.selectedGender,
    required this.onGenderSelected,
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
  });

  final ScrollController profileScrollController;
  final TextEditingController nameController;
  final int? selectedGender;
  final ValueChanged<int?> onGenderSelected;
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

  Color _getOnboardingTextColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;

  Color _getOnboardingTextSecondaryColor(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;

  Color _getOnboardingCardColor(BuildContext context) =>
      Theme.of(context).colorScheme.surfaceContainerHighest;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: profileScrollController,
      child: Container(
        padding: const EdgeInsets.only(left: 32, right: 32, top: 0, bottom: 0),
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
            DecoratedBox(
              decoration: BoxDecoration(
                color: _getOnboardingCardColor(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: nameController,
                keyboardType: TextInputType.text,
                style: TextStyle(color: AuthWizardTheme.getInputTextColor()),
                decoration: InputDecoration(
                  hintText: L10n.get("full_name_hint"),
                  hintStyle: TextStyle(
                    color: _getOnboardingTextSecondaryColor(context)
                        .withOpacity(0.6),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.cardBorder,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.cardBorder,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.cardBorder.withOpacity(0.8),
                      width: 2,
                    ),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  prefixIcon: Icon(
                    Icons.person,
                    color: _getOnboardingTextSecondaryColor(context),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Flexible(
                  child: _buildGenderOption(
                    context,
                    1,
                    L10n.get("male"),
                    Icons.male,
                  ),
                ),
                const SizedBox(width: 20),
                Flexible(
                  child: _buildGenderOption(
                    context,
                    2,
                    L10n.get("female"),
                    Icons.female,
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
            if (isLoadingRegions)
              _buildLoadingCard(
                context,
                L10n.get("loading_regions"),
              )
            else if (regions.isNotEmpty)
              _buildRegionSelector(context)
            else if (!isLoadingRegions)
              _buildEmptyCard(
                context,
                L10n.get("no_regions_available"),
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
                  child: _buildRoleOption(
                    context,
                    "landlord",
                    L10n.get("role_landlord"),
                    Icons.home_work,
                  ),
                ),
                const SizedBox(width: 20),
                Flexible(
                  child: _buildRoleOption(
                    context,
                    "tenant",
                    L10n.get("role_tenant"),
                    Icons.key,
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
                  child: _buildStudentOption(
                    context,
                    true,
                    L10n.get("yes_student"),
                    Icons.school,
                  ),
                ),
                const SizedBox(width: 20),
                Flexible(
                  child: _buildStudentOption(
                    context,
                    false,
                    L10n.get("no_student"),
                    Icons.work,
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
                _buildUniversitySelector(context)
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getOnboardingTextColor(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: CenteredHouseLoadingIndicator(
        text: text,
        textStyle: TextStyle(
          color: _getOnboardingTextColor(context),
          fontSize: 16,
        ),
        size: 20,
      ),
    );
  }

  Widget _buildEmptyCard(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _getOnboardingTextColor(context).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: _getOnboardingTextSecondaryColor(context),
          fontSize: 16,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildGenderOption(
    BuildContext context,
    int gender,
    String label,
    IconData icon,
  ) {
    final isSelected = selectedGender == gender;
    return GestureDetector(
      onTap: () => onGenderSelected(gender),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AuthWizardTheme.getSelectedButtonBackgroundColor()
              : _getOnboardingTextColor(context).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AuthWizardTheme.getSelectedButtonTextColor()
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AuthWizardTheme.getSelectedButtonTextColor()
                    : _getOnboardingTextColor(context),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(width: 12),
            Icon(
              icon,
              color: isSelected
                  ? AuthWizardTheme.getSelectedButtonTextColor()
                  : _getOnboardingTextColor(context),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleOption(
    BuildContext context,
    String role,
    String label,
    IconData icon,
  ) {
    final isSelected = selectedRole == role;
    return GestureDetector(
      onTap: () => onRoleSelected(role),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AuthWizardTheme.getSelectedButtonBackgroundColor()
              : _getOnboardingTextColor(context).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AuthWizardTheme.getSelectedButtonTextColor()
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AuthWizardTheme.getSelectedButtonTextColor()
                    : _getOnboardingTextColor(context),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(width: 12),
            Icon(
              icon,
              color: isSelected
                  ? AuthWizardTheme.getSelectedButtonTextColor()
                  : _getOnboardingTextColor(context),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentOption(
    BuildContext context,
    bool studentValue,
    String label,
    IconData icon,
  ) {
    final isSelected = isStudent == studentValue;
    return GestureDetector(
      onTap: () => onStudentSelected(studentValue),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : _getOnboardingTextColor(context).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.black
                    : _getOnboardingTextColor(context),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              textAlign: TextAlign.left,
            ),
            const SizedBox(width: 12),
            Icon(
              icon,
              color: isSelected
                  ? Colors.black
                  : _getOnboardingTextColor(context),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegionSelector(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selectedRegionId != null
            ? AuthWizardTheme.getSelectedButtonBackgroundColor()
            : _getOnboardingCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selectedRegionId != null
              ? AuthWizardTheme.getSelectedButtonBorderColor()
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onShowRegionPicker,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Icon(
                Icons.public,
                color: selectedRegionId != null
                    ? AuthWizardTheme.getSelectedButtonTextColor()
                    : _getOnboardingTextSecondaryColor(context),
                size: 24,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (selectedRegionId != null) ...[
                      Text(
                        getRegionName(
                          regions.firstWhere(
                            (r) => r.id == selectedRegionId,
                          ),
                        ),
                        style: TextStyle(
                          color: AuthWizardTheme.getSelectedButtonTextColor(),
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
                          color: AuthWizardTheme.getSelectedButtonTextColor(),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ] else ...[
                      Text(
                        L10n.get("tap_to_select_region"),
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
              Icon(
                selectedRegionId != null
                    ? Icons.check_circle
                    : Icons.arrow_drop_down,
                color: selectedRegionId != null
                    ? AuthWizardTheme.getSelectedButtonTextColor()
                    : _getOnboardingTextSecondaryColor(context),
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUniversitySelector(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: selectedUniversity != null
            ? AuthWizardTheme.getSelectedButtonBackgroundColor()
            : _getOnboardingCardColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selectedUniversity != null
              ? AuthWizardTheme.getSelectedButtonBorderColor()
              : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onShowUniversityPicker,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Icon(
                Icons.school,
                color: selectedUniversity != null
                    ? AuthWizardTheme.getSelectedButtonTextColor()
                    : _getOnboardingTextSecondaryColor(context),
                size: 24,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (selectedUniversity != null) ...[
                      Text(
                        getUniversityName(selectedUniversity!),
                        style: TextStyle(
                          color: AuthWizardTheme.getSelectedButtonTextColor(),
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
                          color: AuthWizardTheme.getSelectedButtonTextColor(),
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
              Icon(
                selectedUniversity != null
                    ? Icons.check_circle
                    : Icons.arrow_drop_down,
                color: selectedUniversity != null
                    ? AuthWizardTheme.getSelectedButtonTextColor()
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
