import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/domain/models/gig/gig_category.dart";
import "package:uy_dosh/domain/models/gig/gig_request.dart";
import "package:uy_dosh/presentation/blocs/gig/gig_post_request_bloc.dart";
import "package:uy_dosh/presentation/screens/gig/gig_category_icons.dart";
import "package:uy_dosh/presentation/widgets/common/glass_bottom_sheet_surface.dart";
import "package:uy_dosh/presentation/widgets/common/keyboard_dismiss_scope.dart";
import "package:uy_dosh/presentation/widgets/common/swipe_dismissible_sheet.dart";
import "package:uy_dosh/presentation/widgets/common/neumorphic_toggle.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_app_bar_icon_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/common/toast_theme.dart";
import "package:uy_dosh/presentation/widgets/common/uydosh_plate_text_form_field.dart";
import "package:uy_dosh/presentation/widgets/common/yandex_address_suggest_field.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

class PostGigRequestScreen extends StatefulWidget {
  const PostGigRequestScreen({super.key});

  @override
  State<PostGigRequestScreen> createState() => _PostGigRequestScreenState();
}

class _PostGigRequestScreenState extends State<PostGigRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();
  final _addressController = TextEditingController();
  GigCategory? _selectedCategory;
  GigRequestBudgetType _budgetType = GigRequestBudgetType.fixed;
  bool _isRemote = false;
  bool _showCategoryError = false;
  bool _showTitleError = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _submit() {
    final titleMissing = _titleController.text.trim().isEmpty;
    final categoryMissing = _selectedCategory == null;
    if (titleMissing != _showTitleError ||
        categoryMissing != _showCategoryError) {
      setState(() {
        _showTitleError = titleMissing;
        _showCategoryError = categoryMissing;
      });
    }
    if (titleMissing || categoryMissing) {
      return;
    }
    final budget = _budgetController.text.isEmpty
        ? null
        : int.tryParse(_budgetController.text);
    context.read<GigPostRequestBloc>().add(
          SubmitGigRequest(
            categoryId: _selectedCategory!.id,
            title: _titleController.text.trim(),
            budgetType: _budgetType,
            budgetAmount: budget,
            descriptionRu: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
            addressText: _addressController.text.trim().isEmpty
                ? null
                : _addressController.text.trim(),
            isRemote: _isRemote,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final language = LanguageState().currentLanguage;
    return BlocConsumer<GigPostRequestBloc, GigPostRequestState>(
      listener: (context, state) {
        if (state is GigPostRequestSuccess) {
          ToastTheme.showSuccessSimple(
            context,
            message: L10n.get("gigs_post_request_success_toast"),
          );
          Navigator.of(context).pop();
        } else if (state is GigPostRequestError) {
          ToastTheme.showErrorSimple(context, message: state.message);
        }
      },
      builder: (context, state) {
        final idle = state is GigPostRequestIdle ? state : null;
        final categories = idle?.categories ?? const <GigCategory>[];
        final submitting = state is GigPostRequestSubmitting;

        return Scaffold(
          appBar: AppBar(
            leading: ThreeDAppBarIconButton.backLeading(context),
            title: Text(L10n.get("gigs_post_request_title")),
          ),
          body: KeyboardDismissScope(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                keyboardDismissBehavior: KeyboardDismissScope.scrollBehavior,
                children: [
                  _FieldLabel(L10n.get("gigs_post_request_field_category")),
                  _CategoryPlate(
                    categories: categories,
                    selected: _selectedCategory,
                    language: language,
                    showError: _showCategoryError,
                    onChanged: (c) {
                      setState(() {
                        _selectedCategory = c;
                        if (c != null) _showCategoryError = false;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  _FieldLabel(L10n.get("gigs_post_request_field_title")),
                  UydoshPlateTextFormField(
                    hintText: "",
                    showErrorBorder: _showTitleError,
                    controller: _titleController,
                    textInputAction: TextInputAction.next,
                    style: _fieldTextStyle(context),
                    decoration: UydoshPlateFieldDecoration.gigPostField(
                      context,
                      hintText: L10n.get("gigs_post_request_field_title"),
                    ),
                    onChanged: (_) {
                      if (_showTitleError) {
                        setState(() => _showTitleError = false);
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  _FieldLabel(L10n.get("gigs_post_request_field_description")),
                  UydoshPlateTextFormField(
                    hintText: "",
                    controller: _descriptionController,
                    maxLines: 5,
                    minLines: 4,
                    style: _fieldTextStyle(context),
                    decoration: UydoshPlateFieldDecoration.gigPostField(
                      context,
                      hintText: L10n.get(
                        "gigs_post_request_field_description",
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  _FieldLabel(L10n.get("gigs_post_request_field_budget_type")),
                  _BudgetTypePlate(
                    value: _budgetType,
                    onChanged: (v) => setState(() => _budgetType = v),
                  ),
                  if (_budgetType != GigRequestBudgetType.open) ...[
                    const SizedBox(height: 14),
                    _FieldLabel(L10n.get("gigs_post_request_field_amount")),
                    UydoshPlateTextFormField(
                      hintText: "",
                      controller: _budgetController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      style: _fieldTextStyle(context),
                      decoration: UydoshPlateFieldDecoration.gigPostField(
                        context,
                        hintText: "UZS",
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                  _FieldLabel(L10n.get("gigs_post_request_field_address")),
                  YandexAddressSuggestField(
                    hintText: L10n.get("gigs_post_request_field_address"),
                    controller: _addressController,
                    style: _fieldTextStyle(context),
                    decoration: UydoshPlateFieldDecoration.gigPostField(
                      context,
                      hintText: L10n.get("gigs_post_request_field_address"),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _RemoteTogglePlate(
                    value: _isRemote,
                    label: L10n.get("gigs_post_request_field_remote"),
                    onChanged: (v) => setState(() => _isRemote = v),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    onPressed: submitting ? null : _submit,
                    isLoading: submitting,
                    height: 54,
                    width: double.infinity,
                    borderRadius: BorderRadius.circular(16),
                    child: Text(
                      L10n.get("gigs_post_request_submit"),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
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
}

// ---------------------------------------------------------------------------
// Shared styling helpers
// ---------------------------------------------------------------------------

TextStyle _fieldTextStyle(BuildContext context) {
  return TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: ThemeState().isLightTheme
        ? Colors.black
        : Theme.of(context).colorScheme.onSurface,
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6, bottom: 6, top: 2),
      child: Text(
        text.replaceAll(RegExp(r'\s*\([^)]*\)'), '').trim(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          color:
              Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.65),
        ),
      ),
    );
  }
}

class _PlateField extends StatelessWidget {
  const _PlateField({required this.child, this.showErrorBorder = false});
  final Widget child;
  final bool showErrorBorder;

  @override
  Widget build(BuildContext context) {
    return WheelPickerPlateContainer(
      theme: Theme.of(context),
      showErrorBorder: showErrorBorder,
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Category picker — opens a bottom sheet, paints the sunken plate.
// ---------------------------------------------------------------------------

class _CategoryPlate extends StatelessWidget {
  const _CategoryPlate({
    required this.categories,
    required this.selected,
    required this.language,
    required this.onChanged,
    required this.showError,
  });

  final List<GigCategory> categories;
  final GigCategory? selected;
  final String language;
  final ValueChanged<GigCategory?> onChanged;
  final bool showError;

  Future<void> _pick(BuildContext context) async {
    if (categories.isEmpty) return;
    final picked = await showAppBottomSheet<GigCategory>(
      context: context,
      builder: (sheetCtx) {
        final scheme = Theme.of(sheetCtx).colorScheme;
        const radius = BorderRadius.vertical(top: Radius.circular(20));
        return GlassBottomSheetSurface(
          borderRadius: radius,
          child: Material(
            type: MaterialType.transparency,
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: scheme.onSurface.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 6),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(sheetCtx).height * 0.55,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => Divider(
                        height: 1,
                        color: scheme.onSurface.withValues(alpha: 0.08),
                      ),
                      itemBuilder: (_, i) {
                        final c = categories[i];
                        final isSelected = c.id == selected?.id;
                        return ListTile(
                          leading: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: scheme.secondary.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              c.icon,
                              color: scheme.secondary,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            c.localizedName(language),
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_rounded,
                                  color: scheme.secondary,
                                )
                              : null,
                          onTap: () => Navigator.of(sheetCtx).pop(c),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final hintColor = Theme.of(context).brightness == Brightness.dark
        ? scheme.onSurface.withValues(alpha: 0.45)
        : Colors.grey[500];
    final hasValue = selected != null;
    final canTap = categories.isNotEmpty;
    final placeholder = L10n.get("gigs_post_request_field_category");

    return _PlateField(
      showErrorBorder: showError,
      child: InkWell(
        borderRadius: ThreeDSurfaceStyle.wheelPickerPlateRadius,
        onTap: canTap ? () => _pick(context) : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              if (hasValue) ...[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: scheme.secondary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(
                    selected!.icon,
                    color: scheme.secondary,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  hasValue ? selected!.localizedName(language) : placeholder,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: hasValue
                        ? (ThemeState().isLightTheme
                            ? Colors.black
                            : scheme.onSurface)
                        : hintColor,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: scheme.onSurface.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Budget type — segmented neumorphic chip group.
// ---------------------------------------------------------------------------

class _BudgetTypePlate extends StatelessWidget {
  const _BudgetTypePlate({required this.value, required this.onChanged});
  final GigRequestBudgetType value;
  final ValueChanged<GigRequestBudgetType> onChanged;

  @override
  Widget build(BuildContext context) {
    final entries = <(GigRequestBudgetType, String)>[
      (GigRequestBudgetType.fixed, L10n.get("gigs_budget_type_fixed")),
      (GigRequestBudgetType.hourly, L10n.get("gigs_budget_type_hourly")),
      (GigRequestBudgetType.open, L10n.get("gigs_budget_type_open")),
    ];
    return _PlateField(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            for (final entry in entries)
              Expanded(
                child: _BudgetSegmentButton(
                  label: entry.$2,
                  selected: entry.$1 == value,
                  onTap: () => onChanged(entry.$1),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Selected segment uses the app's standard "raised chip" treatment
/// (gradient + dual shadows + brand button color), matching `AmenityToggle`
/// and the rest of the app's highlighted-selection styling.
class _BudgetSegmentButton extends StatelessWidget {
  const _BudgetSegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isBlueTheme = ThemeState().isBlueTheme;
    final chipBase = selected
        ? (isBlueTheme
            ? BlueThemeColors.buttonPrimary
            : theme.colorScheme.primary)
        : (isBlueTheme
            ? BlueThemeColors.card
            : theme.colorScheme.surfaceContainerHighest);
    final textColor = isBlueTheme
        ? (selected
            ? BlueThemeColors.textPrimary
            : theme.colorScheme.onSurfaceVariant)
        : (selected
            ? theme.colorScheme.onPrimary
            : theme.colorScheme.onSurface.withValues(alpha: 0.75));

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: selected
              ? ThreeDSurfaceStyle.surfaceGradient(context, chipBase)
              : null,
          boxShadow:
              selected ? ThreeDSurfaceStyle.elevatedShadows(context) : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Remote toggle — sunken plate with switch.
// ---------------------------------------------------------------------------

class _RemoteTogglePlate extends StatelessWidget {
  const _RemoteTogglePlate({
    required this.value,
    required this.label,
    required this.onChanged,
  });
  final bool value;
  final String label;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return _PlateField(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: scheme.onSurface,
                ),
              ),
            ),
            NeumorphicThemeAwareToggle(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
