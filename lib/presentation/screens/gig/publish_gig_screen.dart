import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:uy_dosh/base/constants/app_colors.dart";
import "package:uy_dosh/base/localization/l10n.dart";
import "package:uy_dosh/base/state/theme_state.dart";
import "package:uy_dosh/base/util/theme_helper.dart";
import "package:uy_dosh/base/utils/haptic_feedback_utils.dart";
import "package:uy_dosh/domain/models/gig/gig_category.dart";
import "package:uy_dosh/domain/models/gig/gig_offer.dart";
import "package:uy_dosh/domain/models/gig/gig_request.dart";
import "package:uy_dosh/presentation/blocs/gig/gig_post_offer_bloc.dart";
import "package:uy_dosh/presentation/blocs/gig/gig_post_request_bloc.dart";
import "package:uy_dosh/presentation/screens/gig/gig_category_icons.dart";
import "package:uy_dosh/presentation/widgets/common/primary_button.dart";
import "package:uy_dosh/presentation/widgets/common/three_d_surface_style.dart";
import "package:uy_dosh/presentation/widgets/language_switcher.dart";

/// Two flavors of "publish something to the gig hub":
///
/// * [task] — the user *needs* a service; they describe a job and a budget,
///   and providers bid on it. Backed by [GigPostRequestBloc] →
///   `POST /gigs/requests`.
/// * [service] — the user *provides* a service; they list price + category,
///   and clients book them. Backed by [GigPostOfferBloc] →
///   `POST /gigs/offers`.
enum GigPublishMode { task, service }

/// Single screen that subsumes the legacy `PostGigRequestScreen` /
/// `PostGigOfferScreen` pair. A segmented toggle at the top swaps the
/// flavor; common fields (category / title / description / remote) stay
/// stable across modes so the user doesn't have to re-enter shared inputs
/// when they realize they meant "task" instead of "service" (or vice
/// versa). Submit dispatches to whichever bloc matches the current mode.
class PublishGigScreen extends StatefulWidget {
  const PublishGigScreen({
    super.key,
    this.initialMode = GigPublishMode.task,
  });

  final GigPublishMode initialMode;

  @override
  State<PublishGigScreen> createState() => _PublishGigScreenState();
}

class _PublishGigScreenState extends State<PublishGigScreen> {
  // Shared form scaffolding. Re-validating with the same key across modes
  // is fine because the conditionally-mounted fields drop out of the form
  // tree when their mode is inactive.
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Task-only.
  final _budgetController = TextEditingController();
  final _addressController = TextEditingController();
  GigRequestBudgetType _budgetType = GigRequestBudgetType.fixed;

  // Service-only.
  final _priceController = TextEditingController();
  final _minDurationController = TextEditingController();
  GigPricingType _pricingType = GigPricingType.fixed;

  GigCategory? _selectedCategory;
  bool _isRemote = false;
  bool _showCategoryError = false;
  late GigPublishMode _mode;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    // Both blocs are provided by the navigation push; warm both category
    // lists eagerly so toggling the mode is instant.
    context
        .read<GigPostRequestBloc>()
        .add(const LoadCategoriesForRequest());
    context.read<GigPostOfferBloc>().add(const LoadCategoriesForOffer());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _minDurationController.dispose();
    super.dispose();
  }

  void _setMode(GigPublishMode next) {
    if (next == _mode) return;
    setState(() {
      _mode = next;
      // A category selected for one flavor is meaningful for the other
      // (same `IGigService.listCategories()` source), so we keep it. We
      // do clear the category-missing error indicator though; it'll be
      // re-set on next submit if still missing.
      _showCategoryError = false;
    });
  }

  void _submit() {
    final formValid = _formKey.currentState!.validate();
    final categoryMissing = _selectedCategory == null;
    if (categoryMissing != _showCategoryError) {
      setState(() => _showCategoryError = categoryMissing);
    }
    if (!formValid || categoryMissing) return;

    final desc = _descriptionController.text.trim().isEmpty
        ? null
        : _descriptionController.text.trim();

    if (_mode == GigPublishMode.task) {
      final budget = _budgetController.text.trim().isEmpty
          ? null
          : int.tryParse(_budgetController.text.trim());
      context.read<GigPostRequestBloc>().add(
            SubmitGigRequest(
              categoryId: _selectedCategory!.id,
              title: _titleController.text.trim(),
              budgetType: _budgetType,
              budgetAmount: budget,
              descriptionRu: desc,
              addressText: _addressController.text.trim().isEmpty
                  ? null
                  : _addressController.text.trim(),
              isRemote: _isRemote,
            ),
          );
    } else {
      final price = int.tryParse(_priceController.text.trim());
      if (price == null) return;
      final minDuration = _minDurationController.text.trim().isEmpty
          ? null
          : int.tryParse(_minDurationController.text.trim());
      context.read<GigPostOfferBloc>().add(
            SubmitGigOffer(
              categoryId: _selectedCategory!.id,
              title: _titleController.text.trim(),
              pricingType: _pricingType,
              price: price,
              descriptionRu: desc,
              // Min-duration only meaningful for hourly pricing — drop it
              // otherwise so we don't ship a misleading value to the API.
              minDurationMinutes:
                  _pricingType == GigPricingType.hourly ? minDuration : null,
              isRemote: _isRemote,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final language = LanguageState().currentLanguage;
    return Scaffold(
      appBar: AppBar(title: Text(L10n.get("gigs_publish_screen_title"))),
      // Two listeners — one per bloc — handle the success/error toasts.
      // `MultiBlocListener` keeps the body free of nested builders.
      body: MultiBlocListener(
        listeners: [
          BlocListener<GigPostRequestBloc, GigPostRequestState>(
            listener: (context, state) {
              if (state is GigPostRequestSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text(L10n.get("gigs_post_request_success_toast")),
                  ),
                );
                Navigator.of(context).pop();
              } else if (state is GigPostRequestError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
          ),
          BlocListener<GigPostOfferBloc, GigPostOfferState>(
            listener: (context, state) {
              if (state is GigPostOfferSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text(L10n.get("gigs_post_offer_success_toast")),
                  ),
                );
                Navigator.of(context).pop();
              } else if (state is GigPostOfferError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message)),
                );
              }
            },
          ),
        ],
        child: BlocBuilder<GigPostRequestBloc, GigPostRequestState>(
          builder: (context, requestState) {
            return BlocBuilder<GigPostOfferBloc, GigPostOfferState>(
              builder: (context, offerState) {
                // Pull category list / loading state from whichever bloc
                // owns the current mode. Both call the same backend so
                // the lists are typically identical in practice.
                final List<GigCategory> categories;
                final bool loadingCategories;
                final String? categoriesError;
                final VoidCallback retryLoadCategories;
                if (_mode == GigPublishMode.task) {
                  final idle = requestState is GigPostRequestIdle
                      ? requestState
                      : null;
                  categories = idle?.categories ?? const <GigCategory>[];
                  loadingCategories = idle?.loadingCategories ?? false;
                  categoriesError = idle?.categoriesError;
                  retryLoadCategories = () => context
                      .read<GigPostRequestBloc>()
                      .add(const LoadCategoriesForRequest());
                } else {
                  final idle =
                      offerState is GigPostOfferIdle ? offerState : null;
                  categories = idle?.categories ?? const <GigCategory>[];
                  loadingCategories = idle?.loadingCategories ?? false;
                  categoriesError = idle?.categoriesError;
                  retryLoadCategories = () => context
                      .read<GigPostOfferBloc>()
                      .add(const LoadCategoriesForOffer());
                }

                final submitting = (_mode == GigPublishMode.task &&
                        requestState is GigPostRequestSubmitting) ||
                    (_mode == GigPublishMode.service &&
                        offerState is GigPostOfferSubmitting);

                return Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      _PublishModeToggle(
                        value: _mode,
                        onChanged: _setMode,
                      ),
                      const SizedBox(height: 22),
                      _FieldLabel(
                        L10n.get("gigs_post_request_field_category"),
                      ),
                      _CategoryPlate(
                        categories: categories,
                        selected: _selectedCategory,
                        language: language,
                        showError: _showCategoryError,
                        loading: loadingCategories,
                        errorMessage: categoriesError,
                        onRetry: retryLoadCategories,
                        onChanged: (c) {
                          setState(() {
                            _selectedCategory = c;
                            if (c != null) _showCategoryError = false;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      _FieldLabel(
                        L10n.get("gigs_post_request_field_title"),
                      ),
                      _PlateField(
                        child: TextFormField(
                          controller: _titleController,
                          textInputAction: TextInputAction.next,
                          style: _fieldTextStyle(context),
                          decoration: _plateInputDecoration(
                            context,
                            hint: L10n.get("gigs_post_request_field_title"),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                  ? L10n.get("gigs_post_request_required")
                                  : null,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _FieldLabel(
                        L10n.get("gigs_post_request_field_description"),
                      ),
                      _PlateField(
                        child: TextFormField(
                          controller: _descriptionController,
                          maxLines: 5,
                          minLines: 4,
                          style: _fieldTextStyle(context),
                          decoration: _plateInputDecoration(
                            context,
                            hint: L10n.get(
                              "gigs_post_request_field_description",
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      if (_mode == GigPublishMode.task)
                        ..._buildTaskFields()
                      else
                        ..._buildServiceFields(),
                      const SizedBox(height: 14),
                      _RemoteTogglePlate(
                        value: _isRemote,
                        label:
                            L10n.get("gigs_post_request_field_remote"),
                        onChanged: (v) =>
                            setState(() => _isRemote = v),
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        onPressed: submitting ? null : _submit,
                        isLoading: submitting,
                        height: 54,
                        width: double.infinity,
                        borderRadius: BorderRadius.circular(16),
                        child: Text(
                          _mode == GigPublishMode.task
                              ? L10n.get("gigs_post_request_submit")
                              : L10n.get("gigs_post_offer_submit"),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildTaskFields() {
    return [
      _FieldLabel(L10n.get("gigs_post_request_field_budget_type")),
      _BudgetTypePlate(
        value: _budgetType,
        onChanged: (v) => setState(() => _budgetType = v),
      ),
      if (_budgetType != GigRequestBudgetType.open) ...[
        const SizedBox(height: 14),
        _FieldLabel(L10n.get("gigs_post_request_field_amount")),
        _PlateField(
          child: TextFormField(
            controller: _budgetController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: _fieldTextStyle(context),
            decoration: _plateInputDecoration(context, hint: "UZS"),
          ),
        ),
      ],
      const SizedBox(height: 14),
      _FieldLabel(L10n.get("gigs_post_request_field_address")),
      _PlateField(
        child: TextFormField(
          controller: _addressController,
          style: _fieldTextStyle(context),
          decoration: _plateInputDecoration(
            context,
            hint: L10n.get("gigs_post_request_field_address"),
          ),
        ),
      ),
    ];
  }

  List<Widget> _buildServiceFields() {
    return [
      _FieldLabel(L10n.get("gigs_post_offer_field_pricing_type")),
      _PricingTypePlate(
        value: _pricingType,
        onChanged: (v) => setState(() => _pricingType = v),
      ),
      const SizedBox(height: 14),
      _FieldLabel(L10n.get("gigs_post_offer_field_price")),
      _PlateField(
        child: TextFormField(
          controller: _priceController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: _fieldTextStyle(context),
          decoration: _plateInputDecoration(context, hint: "UZS"),
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return L10n.get("gigs_post_request_required");
            }
            final n = int.tryParse(v.trim());
            if (n == null || n <= 0) {
              return L10n.get("gigs_post_request_required");
            }
            return null;
          },
        ),
      ),
      if (_pricingType == GigPricingType.hourly) ...[
        const SizedBox(height: 14),
        _FieldLabel(L10n.get("gigs_post_offer_field_min_duration")),
        _PlateField(
          child: TextFormField(
            controller: _minDurationController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: _fieldTextStyle(context),
            decoration: _plateInputDecoration(
              context,
              hint: L10n.get("gigs_post_offer_field_min_duration_hint"),
            ),
          ),
        ),
      ],
    ];
  }
}

// ---------------------------------------------------------------------------
// Mode toggle — Task / Service.
//
// Visually mirrors the inbox screen's incoming/outgoing switcher: a 3D pill
// container with an animated sliding thumb that rides under the active
// segment. We keep haptics on tap so it feels identical to the inbox tab.
// ---------------------------------------------------------------------------

class _PublishModeToggle extends StatelessWidget {
  const _PublishModeToggle({required this.value, required this.onChanged});

  final GigPublishMode value;
  final ValueChanged<GigPublishMode> onChanged;

  static const double _height = 48;
  static const double _outerRadius = 24;
  static const double _innerRadius = 22;
  static const double _thumbInset = 2;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeState(),
      builder: (context, _) {
        final themeState = ThemeState();
        final primaryColor = themeState.primaryColor;
        final cardColor = themeState.cardColor;
        final selectedTextColor =
            ThemeData.estimateBrightnessForColor(primaryColor) ==
                    Brightness.dark
                ? Colors.white
                : Colors.black;
        final unselectedTextColor = themeState.unselectedTabTextColor;

        final isTask = value == GigPublishMode.task;

        return LayoutBuilder(
          builder: (context, constraints) {
              final thumbWidth =
                  (constraints.maxWidth - _thumbInset * 2) / 2;
              return Container(
                height: _height,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(_outerRadius),
                  gradient: ThreeDSurfaceStyle.surfaceGradient(
                    context,
                    cardColor,
                  ),
                  boxShadow: ThreeDSurfaceStyle.elevatedShadows(context),
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      left: isTask ? _thumbInset : null,
                      right: isTask ? null : _thumbInset,
                      top: _thumbInset,
                      bottom: _thumbInset,
                      child: Container(
                        width: thumbWidth,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(_innerRadius),
                          gradient: ThreeDSurfaceStyle.surfaceGradient(
                            context,
                            primaryColor,
                          ),
                          boxShadow:
                              ThreeDSurfaceStyle.elevatedShadows(context),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _PublishModeTab(
                            icon: Icons.assignment_outlined,
                            label: L10n.get("gigs_publish_mode_task"),
                            isSelected: isTask,
                            selectedTextColor: selectedTextColor,
                            unselectedTextColor: unselectedTextColor,
                            onTap: () {
                              HapticFeedbackUtils.selection();
                              onChanged(GigPublishMode.task);
                            },
                          ),
                        ),
                        Expanded(
                          child: _PublishModeTab(
                            icon: Icons.handyman_outlined,
                            label: L10n.get("gigs_publish_mode_service"),
                            isSelected: !isTask,
                            selectedTextColor: selectedTextColor,
                            unselectedTextColor: unselectedTextColor,
                            onTap: () {
                              HapticFeedbackUtils.selection();
                              onChanged(GigPublishMode.service);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
        );
      },
    );
  }
}

class _PublishModeTab extends StatelessWidget {
  const _PublishModeTab({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.selectedTextColor,
    required this.unselectedTextColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final Color selectedTextColor;
  final Color unselectedTextColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? selectedTextColor : unselectedTextColor;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: _PublishModeToggle._height,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeInOut,
          opacity: isSelected ? 1.0 : 0.82,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            scale: isSelected ? 1.0 : 0.96,
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 18, color: color),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared styling helpers — these mirror the file-private helpers in the
// legacy `post_gig_request_screen.dart` / `post_gig_offer_screen.dart`.
// Kept duplicated for now to keep this change contained; promote to a
// shared `gig_form_widgets.dart` once the legacy screens are retired.
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

InputDecoration _plateInputDecoration(BuildContext context, {String? hint}) {
  final hintColor = Theme.of(context).brightness == Brightness.dark
      ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45)
      : Colors.grey[500];
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: hintColor,
    ),
    filled: true,
    fillColor: Colors.transparent,
    border: const OutlineInputBorder(borderSide: BorderSide.none),
    enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none),
    focusedBorder: const OutlineInputBorder(borderSide: BorderSide.none),
    errorBorder: const OutlineInputBorder(borderSide: BorderSide.none),
    focusedErrorBorder: const OutlineInputBorder(borderSide: BorderSide.none),
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    isDense: true,
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
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
          color: Theme.of(context)
              .colorScheme
              .onSurface
              .withValues(alpha: 0.65),
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

class _CategoryPlate extends StatelessWidget {
  const _CategoryPlate({
    required this.categories,
    required this.selected,
    required this.language,
    required this.onChanged,
    required this.showError,
    required this.loading,
    required this.errorMessage,
    required this.onRetry,
  });

  final List<GigCategory> categories;
  final GigCategory? selected;
  final String language;
  final ValueChanged<GigCategory?> onChanged;
  final bool showError;
  final bool loading;
  final String? errorMessage;
  final VoidCallback onRetry;

  Future<void> _pick(BuildContext context) async {
    if (categories.isEmpty) return;
    final picked = await showModalBottomSheet<GigCategory>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return SafeArea(
          child: ListView.separated(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: categories.length,
            separatorBuilder: (_, __) => Divider(
              height: 1,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.08),
            ),
            itemBuilder: (_, i) {
              final c = categories[i];
              final isSelected = c.id == selected?.id;
              final scheme = Theme.of(context).colorScheme;
              return ListTile(
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: scheme.secondary.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(c.icon, color: scheme.secondary, size: 20),
                ),
                title: Text(
                  c.localizedName(language),
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                trailing: isSelected
                    ? Icon(Icons.check_rounded, color: scheme.secondary)
                    : null,
                onTap: () => Navigator.of(context).pop(c),
              );
            },
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
    final hasCategories = categories.isNotEmpty;
    final hasError = errorMessage != null && !loading && !hasCategories;
    final canTap = hasCategories;

    final placeholder = loading
        ? L10n.get("gigs_loading")
        : (hasError
            ? L10n.get("gigs_categories_unavailable")
            : L10n.get("gigs_post_request_field_category"));

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
              if (loading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: scheme.onSurface.withValues(alpha: 0.6),
                  ),
                )
              else if (hasError)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints.tightFor(
                    width: 32,
                    height: 32,
                  ),
                  onPressed: onRetry,
                  tooltip: L10n.get("gigs_retry"),
                  icon: Icon(
                    Icons.refresh_rounded,
                    color: scheme.secondary,
                  ),
                )
              else
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
                child: _SegmentButton(
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

class _PricingTypePlate extends StatelessWidget {
  const _PricingTypePlate({required this.value, required this.onChanged});
  final GigPricingType value;
  final ValueChanged<GigPricingType> onChanged;

  @override
  Widget build(BuildContext context) {
    final entries = <(GigPricingType, String)>[
      (GigPricingType.fixed, L10n.get("gigs_pricing_type_fixed")),
      (GigPricingType.hourly, L10n.get("gigs_pricing_type_hourly")),
      (GigPricingType.perUnit, L10n.get("gigs_pricing_type_per_unit")),
    ];
    return _PlateField(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            for (final entry in entries)
              Expanded(
                child: _SegmentButton(
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
class _SegmentButton extends StatelessWidget {
  const _SegmentButton({
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
          boxShadow: selected
              ? ThreeDSurfaceStyle.elevatedShadows(context)
              : null,
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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
            Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: scheme.secondary,
            ),
          ],
        ),
      ),
    );
  }
}
